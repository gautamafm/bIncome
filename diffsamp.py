"""
New and old `bankruptpeople` files are different. How are they different?

3/3/2016: Looks like it's mostly just the age cutoff (was 23, now 28)
"""
from __future__ import division, print_function

import numpy as np
import pandas as pd

from clean import load_bankrupt_panel


def fix_old():
    old = pd.read_stata('../data/bankruptpeople1.dta')
    new_codebook = {
        'match': 'interview_number',
        'yrfil1': 'bank_year',
        'wrBank': 'bank_filed',
        'cutoff': 'sequence_number',
    }
    old.rename(columns=new_codebook, inplace=True)
    old = old[old['sequence_number'] < 70].copy()

    return old


def old_only():
    new = load_bankrupt_panel(_load=False)
    new_fams = new.loc[new['year'] == 1996, 'interview_number'].unique()
    old = fix_old()
    old_fams = old.loc[old['year'] == 1996, 'interview_number'].unique()
    only_old_fams = [x for x in old_fams if x not in new_fams]
    old_pn = old.set_index(['id', 'year']).to_panel()
    temp = np.tile(old_pn.loc['interview_number', :, 1996].isin(only_old_fams).values.reshape(-1, 1),
                   (1, old_pn.shape[2]))

    old_pn['only_old'] = temp
    df = old_pn.to_frame(filter_observations=False)

    return df


if __name__ == '__main__':
    df = old_only()
