""" NOTE: NO Sample restriction or variable creation in this file!!! """
from __future__ import division, print_function
from os.path import join

import pandas as pd

from econtools import load_or_build, force_iterable

from util import src_path, data_path
from clean.psid.codebook import family_std, indiv_std

PSID_PATH = src_path('psid')

BANKVARS = ('bank_filed', 'bank_year', 'bank_state',
            'bank_count', 'bank_debt_filed', 'bank_debt_remained',)


def load_full_panel(_load=True, _rebuild=False, _rebuild_down=False):
    """
    Create full PSID panel, conditional on being interviewed in 1996.

    This does not create any variables or restrict the sample in any way, other
    than starting with 1996 households.
    """
    if _load:
        file_path = data_path('panel_full.p')
        df = load_or_build(file_path,
                           build=load_full_panel,
                           force=_rebuild,
                           bkwargs=dict(_load=False,
                                        _rebuild_down=_rebuild_down)
                           )
        return df

    df = load_individual_panel(_rebuild=_rebuild_down)
    df.index.name = 'person_id'
    # Merge family_1996 and indiv, inner
    match_cols = ('interview_number', 1996)
    this_family = load_family_year(1996, _rebuild=_rebuild_down)
    this_family.index = this_family.pop(match_cols).squeeze().values
    df = df.join(this_family, on=[match_cols], how='inner')
    # Merge all other family years, left
    for year in range(1975, 1996):
        match_cols = ('interview_number', year)
        this_family = load_family_year(year, _rebuild=_rebuild_down)
        this_family.index = this_family.pop(match_cols).squeeze().values
        df = df.join(this_family, on=[match_cols], how='left')

    # Reshape long
    df = df.stack('year')

    # Deflate to real dollars
    # NOTE: bankruptcy variables no included
    dollar_cols = ('tot_fam_income', 'headlabor', 'wifelabor', 'home_value',
                   'food_stamps', 'food_home', 'food_out', 'mortgage_pay',
                   'rent_pay', 'mortgage_balance')
    df = _deflate_CPI(df, dollar_cols)

    pan = df.to_panel()
    # Pull forward systematically missing variables
    for col in ('headrace', ):
        pan[col] = pan[col].apply(
            lambda x: x.replace('', method='ffill'),
            axis=0)
    # Fill all bankruptcy variables
    for col in BANKVARS + ('longweight',):
        pan[col].fillna(method='bfill', axis=1, inplace=True)
        pan[col].fillna(method='ffill', axis=1, inplace=True)

    df = pan.to_frame(filter_observations=False)

    return df


def load_individual_panel(_load=True, _rebuild=False):

    if _load:
        file_path = data_path('individual_panel_wide.p')
        df = load_or_build(file_path,
                           build=load_individual_panel,
                           force=_rebuild,
                           bkwargs=dict(_load=False))
        return df

    VARNAMES = ('interview_number', 'sequence_number', 'educ', 'employ',
                'relhead', 'age', 'yearbirth', 'longweight')

    df = load_individual_raw()
    helper = indiv_std()
    for varname in VARNAMES:
        helper.standardize(df, varname)

    # Columns to 2-level
    cols_as_tups = [force_iterable(x) for x in df.columns]
    with_filler_year = [x + (-1,) if len(x) == 1 else x for x in cols_as_tups]
    df.columns = pd.MultiIndex.from_tuples(with_filler_year,
                                           names=['varname', 'year'])
    # Drop unclean
    df.drop(-1, level='year', axis=1, inplace=True)

    return df


def load_individual_raw():
    FAMILY_YEAR_PATH = join(PSID_PATH, 'indiv_6807', 'psid6807.dta')
    df = pd.read_stata(FAMILY_YEAR_PATH)
    return df


def load_family_year(year, _load=True, _rebuild=False):

    if _load:
        file_path = data_path('newsmall', 'family_{}.p').format(year)
        df = load_or_build(file_path,
                           build=load_family_year,
                           force=_rebuild,
                           bargs=(year,),
                           bkwargs=dict(_load=False))
        return df

    df = load_family_year_raw(year)
    # Add 2nd level to column-index for variable's year
    # Everything with `year = -1` will be dropped later
    df.columns = pd.MultiIndex.from_tuples([(x, -1) for x in df.columns],
                                           names=['varname', 'year'])
    # Loop over variables to clean
    VARNAMES = ('interview_number', 'samp_weight', 'state', 'male_head',
                'headrace', 'famsize', 'numchild', 'mrstat', 'tot_fam_income',
                'headlabor', 'wifelabor', 'homeowner', 'home_value',
                'food_stamps', 'food_home', 'food_out', 'mortgage_pay',
                'rent_pay', 'mortgage_balance')
    BANKVARS = ('bank_filed', 'bank_year', 'bank_state', 'bank_2year',
                'bank_chapter', 'bank_count', 'bank_assets_seized',
                'bank_assets_seized_value', 'bank_plan13_completed',
                'bank_debt_filed', 'bank_debt_remained',)
    if year == 1996:
        VARNAMES += BANKVARS

    for varname in VARNAMES:
        family_std(df, varname, year)
    # Drop all un-cleaned variables
    df.drop(-1, level='year', axis=1, inplace=True)

    return df


def load_family_year_raw(year):
    FAMILY_YEAR_PATH = join(PSID_PATH, 'fam_{0}', 'fam_{0}.dta').format(year)
    df = pd.read_stata(FAMILY_YEAR_PATH)
    return df


def _deflate_CPI(df, dollar_cols):
    """
    Deflate `dollar_cols` in `df` to real 2010 dollars.

    `dollar_cols` should be tuple or list-like.
    """
    cpi_path = src_path('cpi_annual.dta')
    cpi = pd.read_stata(cpi_path).set_index('year')

    start_shape = df.shape
    df = df.join(cpi['cpi_to2010'], how='left')

    for col in force_iterable(dollar_cols):
        df[col] *= df['cpi_to2010']

    df.drop('cpi_to2010', axis=1, inplace=True)
    end_shape = df.shape
    assert start_shape == end_shape

    return df


if __name__ == '__main__':
    df = load_full_panel(_rebuild=True)
