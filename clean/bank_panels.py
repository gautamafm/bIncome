from __future__ import division, print_function

import numpy as np
import pandas as pd

from econtools import load_or_build

from util import data_path
from clean.psid import load_full_panel


@load_or_build(data_path('nonbankruptpeople2.dta'))
def load_nonbankrupt_panel(_rebuild_down=False):

    df = uniform_cleaning(_rebuild_down=_rebuild_down)
    df = df.query('bank_filed == 0').copy()

    return df

@load_or_build(data_path('bankruptpeople2.dta'))
def load_bankrupt_panel(_rebuild_down=False):

    df = uniform_cleaning(_rebuild_down=_rebuild_down)
    df = df.query('bank_filed == 1').copy()

    df['event_year'] = df['year'] - df['bank_year']

    # Restrict to filling years after 1985
    df = df[df['event_year'].notnull()].copy()
    df = df[df['bank_year'] >= 1985].copy()

    # Drop if we don't observe you before you file
    income_obs = df[df['tot_fam_income'].notnull()].copy()
    min_es_year = income_obs.groupby(level='person_id')['event_year'].min()
    df = df.join(min_es_year.to_frame('min_es_year'))
    df['min_es_year'] = df['min_es_year'].fillna(99)
    df = df[df['min_es_year'] <= - 1].copy()
    df = df.drop('min_es_year', axis=1)

    # Restrict to "age>28 at bankruptcy"
    df['tmp'] = False
    criteria = (df['event_year'] == 0) & (df['age'] >= 24)
    df.loc[criteria, 'tmp'] = True
    cutoff = df.groupby(level='person_id')['tmp'].max()
    df = df.join(cutoff.to_frame('age_cutoff'))
    df = df[df['age_cutoff']].copy()
    df = df.drop(['tmp', 'age_cutoff'], axis=1)

    return df


def uniform_cleaning(_rebuild_down=False):
    """ Basic cleaning for both bankrupt and non-bankrupt panels """
    df = load_full_panel(_rebuild=_rebuild_down)

    # Drop if filed but don't know year
    drop_me = (df['bank_filed'] == 1) & (df['bank_year'].isnull())
    df = df[~drop_me].copy()

    # # Fill in missing data
    # Fill in birth year and age
    yob = _get_yob(df)
    df = df.drop('yearbirth', axis=1)
    df = df.join(yob.to_frame('yearbirth'))
    df = df.reset_index('year')
    df['age'] = np.where(df['age'].notnull(),
                         df['age'],
                         df['year'] - df['yearbirth'])
    df = df.set_index('year', append=True).sort_index()

    # Backfill stuff
    for col in ('educ', 'mrstat'):
        df[col] = df.groupby(level='person_id')[col].bfill()

    # Backfill columns in off years
    df = df.sort_index()
    off_years = [1998, 2000, 2002, 2004, 2006]
    off_year_slicer = pd.IndexSlice[:, off_years]
    for col in ('relhead', 'sequence_number',):
        shift_col = df.groupby(level='person_id')[col].shift(-1)
        df.loc[off_year_slicer, col] = shift_col.loc[off_year_slicer]

    # Average off-year income
    on_years = [1997, 1999, 2001, 2003, 2005]
    on_year_slicer = pd.IndexSlice[:, on_years]
    grouper = df.groupby(level='person_id')['tot_fam_income']
    moving_avg = grouper.rolling(window=3, min_periods=2, center=True).mean()
    df.loc[on_year_slicer, 'tot_fam_income'] = moving_avg.loc[on_year_slicer]

    df = df.reset_index()

    # # Restrict sample
    # Drop if age is missing
    df = df[df['age'].notnull()].copy()
    # Drop if person not interviewed in this year
    df = df.query('sequence_number != 0').copy()
    # Drop if Don't Know whether filed (all other bank vars are missing)
    df = df[df['bank_filed'].notnull()].copy()

    # # Create variables
    #   Current-year `head` and `spouse`
    df['head'] = (df['relhead'] == 'head') & (df['sequence_number'] == 1)
    df['spouse'] = (df['relhead'] == 'wife')
    df['is_adult_now'] = df['head'] | df['spouse']
    #   Unemployed
    df['unemployed'] = (df['employ'] == 'unemployed').astype(int)
    emp_miss = df['employ'] == ''
    df.loc[emp_miss.values, 'unemployed'] = np.nan
    #   Hhold-level unemployment variables
    is_head = (df['head']) & (df['interview_number'].notnull())
    heads_unemp = df[is_head].set_index(['interview_number', 'year'])
    heads_unemp = heads_unemp['unemployed'].copy()
    df = df.join(heads_unemp.to_frame('head_unemploy'),
                 on=['interview_number', 'year'], how='left')
    del heads_unemp
    #   Total food exp.
    food_vars = ['food_stamps', 'food_home', 'food_out']
    df['food_tot'] = df[food_vars].sum(axis=1, skipna=False)
    #   Married, etc.
    df['married'] = (df['mrstat'] == 'm').astype(int)
    df['divorced'] = (df['mrstat'] == 'd').astype(int)
    df.loc[df['mrstat'].isnull(), ['married', 'divorced']] = np.nan

    df = df.reset_index()

    if 'index' in df.columns:
        df = df.drop('index', axis=1)

    # Restrict to "head or wife in 1996 (year of reporting)"
    df = _flag_1996_couple(df)    # Creates vars `bank_is_head[wife]`
    df = df[df[['head_in_1996', 'wife_in_1996']].max(axis=1)].copy()

    return df.set_index('person_id')

def _get_yob(df):
    yob_1996 = df.loc[pd.IndexSlice[:, 1996], 'yearbirth']
    yob_1996.index = yob_1996.index.droplevel('year')
    yob_mode = df.groupby(
        level='person_id')['yearbirth'].apply(lambda x: x.mode().squeeze())
    yob_mode[yob_mode.apply(lambda x: type(x) is not np.float64)] = np.nan
    yob = yob_1996.to_frame('yob').join(yob_mode.to_frame('mode'))
    yob['yearbirth'] = np.where(yob['yob'].notnull(), yob['yob'], yob['mode'])

    yob['yearbirth'] = yob['yearbirth'].astype(np.float64)
    return yob['yearbirth'].copy()

def _flag_1996_couple(df):
    """ Create flags for 'is head/wife in filing year """
    df['temp'] = (
        (df['year'] == 1996) &
        (df['relhead'] == 'head') &
        (df['sequence_number'] == 1)
    )
    df['head_in_1996'] = df.groupby('person_id',
                                    axis=0)['temp'].transform('max')
    # Get 'wife' (not always `sequence_number = 2`, but wife is unique w/in
    # `interview_number` up to a couple coding errors that should be outside
    # the sample)
    df['temp'] = (
        (df['year'] == 1996) &
        (df['relhead'] == 'wife') &
        ((df['sequence_number'] <= 10) |    # In the family
         (df['sequence_number'] == 51))     # or 'institutionalized'
    )
    df['wife_in_1996'] = df.groupby('person_id',
                                    axis=0)['temp'].transform('max')
    df.drop('temp', axis=1, inplace=True)

    return df


if __name__ == '__main__':
    # Keep this here to easily create the DTA files
    bank = load_bankrupt_panel(_rebuild=True)
    nonbank = load_nonbankrupt_panel(_rebuild=True)
