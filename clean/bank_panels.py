from __future__ import division, print_function

import numpy as np

from econtools import load_or_build

from util import data_path
from clean.psid import load_full_panel


def load_nonbankrupt_panel(_load=True, _rebuild=False, _rebuild_down=False):
    if _load:
        file_path = data_path('nonbankruptpeople2.dta')
        df = load_or_build(file_path,
                           build=load_nonbankrupt_panel,
                           force=_rebuild,
                           bkwargs=dict(_load=False,
                                        _rebuild_down=_rebuild_down)
                           )
        return df

    df = uniform_cleaning(_rebuild_down=_rebuild_down)
    df = df.query('bank_filed == 0').copy()

    return df


def load_bankrupt_panel(_load=True, _rebuild=False, _rebuild_down=False):
    if _load:
        file_path = data_path('bankruptpeople2.dta')
        df = load_or_build(file_path,
                           build=load_bankrupt_panel,
                           force=_rebuild,
                           bkwargs=dict(_load=False,
                                        _rebuild_down=_rebuild_down)
                           )
        return df

    df = uniform_cleaning(_rebuild_down=_rebuild_down)
    df = df.query('bank_filed == 1').copy()

    df['event_year'] = df['year'] - df['bank_year']

    # Restrict to "head or wife in year of bankruptcy"
    df = _flag_bankyear_couple(df)    # Creates vars `bank_is_head[wife]`
    df = df[df[['bank_is_head', 'bank_is_wife']].max(axis=1)].copy()

    # Restrict to "age>28 at bankruptcy"
    age28 = df.loc[df['event_year'] == 0, 'age'] >= 28
    df = df.join(age28.to_frame('age28'))
    df = df[df['age28']].copy()
    df.drop('age28', axis=1, inplace=True)

    # Restrict to filling years after 1985
    df = df.query('1985 <= bank_year').copy()

    return df

def _flag_bankyear_couple(df):      #noqa
    """ Create flags for 'is head/wife in filing year """
    df['temp'] = (
        (df['event_year'] == 0) &
        (df['relhead'] == 'head') &
        (df['sequence_number'] == 1)
    )
    df['bank_is_head'] = df.groupby(level='person_id',
                                    axis=0)['temp'].transform('max')
    # Get 'wife' (not always `sequence_number = 2`, but wife is unique w/in
    # `interview_number` up to a couple coding errors that should be outside
    # the sample)
    df['temp'] = (
        (df['event_year'] == 0) &
        (df['relhead'] == 'wife') &
        ((df['sequence_number'] <= 10)      # In the family
         | (df['sequence_number'] == 51))   # or 'institutionalized'
    )
    df['bank_is_wife'] = df.groupby(level='person_id',
                                    axis=0)['temp'].transform('max')
    df.drop('temp', axis=1, inplace=True)

    return df


def uniform_cleaning(_rebuild_down=False):
    """ Basic cleaning for both bankrupt and non-bankrupt panels """
    df = load_full_panel(_rebuild=_rebuild_down).reset_index()

    # # Restrict sample
    # Drop if person not interviewed in this year
    df = df.query('sequence_number != 0').copy()
    # Drop if Don't Know whether filed (all other bank vars are missing)
    df = df[df['bank_filed'].notnull()].copy()
    # Drop if not actually in the sample (by seq_num)
    df = df[df['sequence_number'] < 70].copy()

    # # Create variables
    #   Current-year `head` and `spouse`
    df['head'] = (df['relhead'] == 'head') & (df['sequence_number'] == 1)
    df['spouse'] = (df['relhead'] == 'wife')
    #   Unemployed
    df['unemployed'] = (df['employ'] == 'unemployed').astype(int)
    emp_miss = df['employ'] == ''
    df.loc[emp_miss.values, 'unemployed'] = np.nan
    #   Hhold-level unemployment variables
    heads_unemp = df.set_index(['interview_number', 'year'])
    heads_unemp = heads_unemp.loc[heads_unemp['head'].values,
                                  'unemployed'].squeeze().copy()
    df.reset_index(inplace=True)
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

    return df.set_index('person_id')


if __name__ == '__main__':
    # Keep this here to easily create the DTA files
    bank = load_bankrupt_panel(_rebuild=True)
    nonbank = load_nonbankrupt_panel(_rebuild=True)
