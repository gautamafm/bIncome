from __future__ import division, print_function

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

    df = load_full_panel(_rebuild=_rebuild_down).reset_index('year')
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

    df = load_full_panel(_rebuild=_rebuild_down).reset_index('year')
    df = df.query('bank_filed == 1').copy()

    df['event_year'] = df['year'] - df['bank_year']
    # Restrict to "head in year of bankruptcy"
    df['temp'] = (
        (df['event_year'] == 0) &
        (df['relhead'] == 'head') &
        (df['sequence_number'] == 1)
    )
    df['is_head'] = df.groupby(level='person_id',
                               axis=0)['temp'].transform('max')
    df = df[df['is_head'] == 1]
    df.drop(['is_head', 'temp'], axis=1, inplace=True)

    # Restrict to "age>28 at bankruptcy"
    age28 = df.loc[df['event_year'] == 0, 'age'] >= 28
    df = df.join(age28.to_frame('age28'))
    df = df[df['age28']].copy()
    df.drop('age28', axis=1, inplace=True)

    # Restrict to filling years after 1985
    df = df.query('bank_year >= 1985').copy()

    return df


if __name__ == '__main__':
    df = load_bankrupt_panel(_load=False)
