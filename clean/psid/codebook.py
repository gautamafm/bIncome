"""
Renames and standardizes requested variable.

Standardization may include:
    - Re-labeling bad codes and topcodes
    - Combining several variables
        (e.g., 1990 has x = a + b, 1991 has a and b separately; set x = a + b)
"""
from __future__ import division, print_function
import numpy as np


# Individual Panel
class indiv_std(object):

    def standardize(self, df, varname):
        varcode, codebook, year_diff, multi_codebook = getattr(self, varname)()
        # Replace using codebook
        if codebook:
            for survey_year, code in varcode.iteritems():
                if multi_codebook:
                    this_book = codebook[survey_year]
                else:
                    this_book = codebook
                df[code].replace(this_book, inplace=True)
        # Rename variables
        rename_varcode = {varcode[x]: (varname, x) for x in varcode.keys()}
        df.rename(columns=rename_varcode, inplace=True)

    def interview_number(self):
        varcode = {
            2007: 'ER33901',
            2005: 'ER33801',
            2003: 'ER33701',
            2001: 'ER33601',
            1999: 'ER33501',
            1997: 'ER33401',
            1996: 'ER33301',
            1995: 'ER33201',
            1994: 'ER33101',
            1993: 'ER30806',
            1992: 'ER30733',
            1991: 'ER30689',
            1990: 'ER30642',
            1989: 'ER30606',
            1988: 'ER30570',
            1987: 'ER30535',
            1986: 'ER30498',
            1985: 'ER30463',
            1984: 'ER30429',
            1983: 'ER30399',
            1982: 'ER30373',
            1981: 'ER30343',
            1980: 'ER30313',
            1979: 'ER30283',
            1978: 'ER30246',
            1977: 'ER30217',
            1976: 'ER30188',
            1975: 'ER30160',
            1974: 'ER30138',
            1973: 'ER30117',
            1972: 'ER30091',
            1971: 'ER30067',
            1970: 'ER30043',
            1969: 'ER30020',
            1968: 'ER30001',
        }
        year_diff = 0
        codebook = None
        multi_codebook = False

        return varcode, codebook, year_diff, multi_codebook

    def sequence_number(self):
        varcode = {
            2007: 'ER33902',
            2005: 'ER33802',
            2003: 'ER33702',
            2001: 'ER33602',
            1999: 'ER33502',
            1997: 'ER33402',
            1996: 'ER33302',
            1995: 'ER33202',
            1994: 'ER33102',
            1993: 'ER30807',
            1992: 'ER30734',
            1991: 'ER30690',
            1990: 'ER30643',
            1989: 'ER30607',
            1988: 'ER30571',
            1987: 'ER30536',
            1986: 'ER30499',
            1985: 'ER30464',
            1984: 'ER30430',
            1983: 'ER30400',
            1982: 'ER30374',
            1981: 'ER30344',
            1980: 'ER30314',
            1979: 'ER30284',
            1978: 'ER30247',
            1977: 'ER30218',
            1976: 'ER30189',
            1975: 'ER30161',
            1974: 'ER30139',
            1973: 'ER30118',
            1972: 'ER30092',
            1971: 'ER30068',
            1970: 'ER30044',
            1969: 'ER30021',
        }
        year_diff = 0
        # Use this codebook to create `sequence_number_label` or something
        codebook = {
            0: '',      # Latino sample, family nonresponse by `survey_year`,
                        # or moved out before last `survey_year
        }
        codebook.update({x: 'family' for x in range(1, 20 + 1)})
        codebook.update({x: 'instit' for x in range(51, 59 + 1)})
        codebook.update({x: 'moveout' for x in range(71, 80 + 1)})
        codebook.update({x: 'died' for x in range(81, 89 + 1)})

        # Need to be able to see `seq = 1` to ID true head
        codebook = None

        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook

    def educ(self):
        varcode = {
            1968: 'ER30010',
            1970: 'ER30052',
            1971: 'ER30076',
            1972: 'ER30100',
            1973: 'ER30126',
            1974: 'ER30147',
            1975: 'ER30169',
            1976: 'ER30197',
            1977: 'ER30226',
            1978: 'ER30255',
            1979: 'ER30296',
            1980: 'ER30326',
            1981: 'ER30356',
            1982: 'ER30384',
            1983: 'ER30413',
            1984: 'ER30443',
            1985: 'ER30478',
            1986: 'ER30513',
            1987: 'ER30549',
            1988: 'ER30584',
            1989: 'ER30620',
            1990: 'ER30657',
            1991: 'ER30703',
            1992: 'ER30748',
            1993: 'ER30820',
            1994: 'ER33115',
            1995: 'ER33215',
            1996: 'ER33315',
            1997: 'ER33415',
            1999: 'ER33516',
            2001: 'ER33616',
            2003: 'ER33716',
            2005: 'ER33817',
            2007: 'ER33917',
        }
        year_diff = 0
        codebook = {
            0: np.nan,  # Inap.; latino sample, not born yet, mover out,
                        #   head/wife, did not stop school
            17: 16,     # Some variables allows `17: some postgrad` while
                        #   others recode 17 to 16. See doc for ER30197.
            18: np.nan,  # Wild (1997)
            98: np.nan,  # DK
            99: np.nan,  # DK/NA
        }

        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook

    def hrwork(self):
        raise NotImplementedError

    def employ(self):
        varcode = {
            1979: 'ER30293',
            1980: 'ER30323',
            1981: 'ER30353',
            1982: 'ER30382',
            1983: 'ER30411',
            1984: 'ER30441',
            1985: 'ER30474',
            1986: 'ER30509',
            1987: 'ER30545',
            1988: 'ER30580',
            1989: 'ER30616',
            1990: 'ER30653',
            1991: 'ER30699',
            1992: 'ER30744',
            1993: 'ER30816',
            1994: 'ER33111',
            1995: 'ER33211',
            1996: 'ER33311',
            1997: 'ER33411',
            1999: 'ER33512',
            2001: 'ER33612',
            2003: 'ER33712',
            2005: 'ER33813',
            2007: 'ER33913',
        }
        year_diff = 0
        codebook = {
            0: '',
            1: 'employed',
            2: 'templayoff',
            3: 'unemployed',
            4: 'retired',
            5: 'disabled',
            6: 'housewife',
            7: 'student',
            8: '',          # Other; (1979) DK, died, etc.
            9: '',          # NA/DK
        }

        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook

    def relhead(self):
        """
        Data note: 'head' here is not always mean 'head'. If last year's head
            left before this year's survey, then everyone (I think) in the
            household gets coded as 'head'. The true head is found by taking
            'head' here and `sequence_number = 1`.
            See, e.g., doc to ER30431
        Cleaning note: I did not check ~1984--2003
        """
        varcode = {
            2007: 'ER33903',
            2005: 'ER33803',
            2003: 'ER33703',
            2001: 'ER33603',
            1999: 'ER33503',
            1997: 'ER33403',
            1996: 'ER33303',
            1995: 'ER33203',
            1994: 'ER33103',
            1993: 'ER30808',
            1992: 'ER30735',
            1991: 'ER30691',
            1990: 'ER30644',
            1989: 'ER30608',
            1988: 'ER30572',
            1987: 'ER30537',
            1986: 'ER30500',
            1985: 'ER30465',
            1984: 'ER30431',
            1983: 'ER30401',
            1982: 'ER30375',
            1981: 'ER30345',
            1980: 'ER30315',
            1979: 'ER30285',
            1978: 'ER30248',
            1977: 'ER30219',
            1976: 'ER30190',
            1975: 'ER30162',
            1974: 'ER30140',
            1973: 'ER30119',
            1972: 'ER30093',
            1971: 'ER30069',
            1970: 'ER30045',
            1969: 'ER30022',
            1968: 'ER30003',
        }
        year_diff = 0
        # if 1968 <= self.survey_year <= 1982:
        codebook1 = {
            0: '',
            1: 'head',
            2: 'wife',
            3: 'child',
            4: 'sibling',
            5: 'parent',
            6: 'grandchild',
            7: 'other',                 # Relative
            8: 'other',                 # non-relative
            9: 'wife',                  # Husband ("wife" is Head)
        }
        # elif 1983 <= self.survey_year <= 2007:
        codebook2 = {
            0: '',                      # Inap.
            10: 'head',
            20: 'wife',
            22: 'wife',                 # Cohabitor
            30: 'child',
            33: 'stepchild',
            35: 'stepchild',            # Wife's, but not head's
            37: 'child-in-law',
            38: 'fosterchild',
            40: 'sibling',
            47: 'bro-in-law',
            48: 'bro-in-law',           # If cohabitating
            50: 'parent',
            57: 'parent-in-law',
            58: 'parent-in-law',        # If cohabitating
            60: 'grandchild',
            65: 'great-grandchild',
            66: 'grandparent',
            67: 'grandparent-in-law',   # Wife's
            68: 'great-grandparent',
            69: 'great-grandparent',    # Wife's
            70: 'nephew',               # and neices ("niblings")
            71: 'nephew',               # Wife's
            72: 'uncle',
            73: 'uncle',                # Wife's
            74: 'cousin',
            75: 'cousin',               # Wife's
            83: 'stepchild',            # Cohabitor's kids, if first year
            88: 'wife',                 # First-year cohabitor
            90: 'wife',                 # Husband
            95: 'other',                # relative of head's
            96: 'other',                # relative of wife's
            97: 'other',                # relative of cohabitor's
            98: 'other',                # nonrelatives (2007: "includes
                                        #       homosexual partners")
        }

        codebook = {x: codebook1 for x in range(1968, 1982 + 1)}
        codebook.update({x: codebook2 for x in range(1983, 2007 + 1)})
        multi_codebook = True

        return varcode, codebook, year_diff, multi_codebook

    def age(self):
        varcode = {
            2007: 'ER33904',
            2005: 'ER33804',
            2003: 'ER33704',
            2001: 'ER33604',
            1999: 'ER33504',
            1997: 'ER33404',
            1996: 'ER33304',
            1995: 'ER33204',
            1994: 'ER33104',
            1993: 'ER30809',
            1992: 'ER30736',
            1991: 'ER30692',
            1990: 'ER30645',
            1989: 'ER30609',
            1988: 'ER30573',
            1987: 'ER30538',
            1986: 'ER30501',
            1985: 'ER30466',
            1984: 'ER30432',
            1983: 'ER30402',
            1982: 'ER30376',
            1981: 'ER30346',
            1980: 'ER30316',
            1979: 'ER30286',
            1978: 'ER30249',
            1977: 'ER30220',
            1976: 'ER30191',
            1975: 'ER30163',
            1974: 'ER30141',
            1973: 'ER30120',
            1972: 'ER30094',
            1971: 'ER30070',
            1970: 'ER30046',
            1969: 'ER30023',
            1968: 'ER30004',
        }
        year_diff = 0
        codebook = {
            0: np.nan,      # Latino sample, mover-out
            999: np.nan,    # NA; DK
        }

        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook

    def yearbirth(self):
        varcode = {
            1983: 'ER30404',
            1984: 'ER30434',
            1985: 'ER30468',
            1986: 'ER30503',
            1987: 'ER30540',
            1988: 'ER30575',
            1989: 'ER30611',
            1990: 'ER30647',
            1991: 'ER30694',
            1992: 'ER30738',
            1993: 'ER30811',
            1994: 'ER33106',
            1995: 'ER33206',
            1996: 'ER33306',
            1997: 'ER33406',
            1999: 'ER33506',
            2001: 'ER33606',
            2003: 'ER33706',
            2005: 'ER33806',
            2007: 'ER33906',
            # 2009: 'ER34006',    # Codebook not checked for these three
            # 2011: 'ER34106',
            # 2013: 'ER34206',
        }
        year_diff = 0
        codebook = {
            0: np.nan,
            9999: np.nan,
        }
        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook

    def longweight(self):
        varcode = {
            1996: 'ER33318',
        }
        year_diff = 0
        codebook = None
        multi_codebook = False
        return varcode, codebook, year_diff, multi_codebook


def family_std(df, varname, survey_year, **kwargs):
    """
    Inputs
    ------
    `df` - DataFrame of family-year data. Columns should have already been
        altered to be two-level by varcode/varname and year.
    `varname` - the English name of the variable to be standardized
        (e.g., 'tot_fam_income' as opposed to a variable code like 'ER41027')
    `survey_year` - The survey year from which `df` is taken.

    Return
    ------
    None. The function modifies `df` in place.
    """

    varname_to_object = {
        'food_stamps': food_stamps,
        'mortgage_pay': mortgage_pay,
        'mortgage_balance': mortgage_balance,
        'rent_pay': rent_pay,
        'food_home': food_home,
        'food_out': food_out,
    }

    if varname in varname_to_object:
        func = varname_to_object[varname]().std
    else:
        func = other_vars(survey_year).get_std_func(varname)

    func(df, survey_year)


# Family-year files
class food_stamps(object):

    def std(self, df, survey_year):
        """
        Survey years 1974 to 1979 had two questions:
            "How much did you pay for food stamps" `paid_stamps`
            "What was the value of food you got from food stamps, minus
                `paid_stamps" `bonus_stamps`

        To make consistent (total exp on food via stamps),set
            `food_stamps = paid_stamps + bonus_stamps`
        """

        var_code, paid_code, bonus_code = self.varcodes()

        codebook = self.codebooks(survey_year)

        # Period-specific cleaning
        if 1975 <= survey_year <= 1979:
            # Unclear if this should be `bonus` + `paid` or just the 'bonus'
            paid = paid_code[survey_year]
            bonus = bonus_code[survey_year]
            if False:
                stamps = df[[paid, bonus]].replace(codebook).sum(axis=1)
            else:
                stamps = df[bonus].replace(codebook)
        elif 1980 <= survey_year <= 1993:
            # Easy, just replace `nan` where needed
            code = var_code[survey_year]
            stamps = df[code].replace(codebook)
        elif 1994 <= survey_year <= 2007:
            # Get raw stamps data, the period scale, and number of months
            # received
            raw_stamp = df[var_code[survey_year]].squeeze()
            raw_stamp.replace(codebook, inplace=True)
            period_scale = self.period(df, survey_year).squeeze()
            month_count = self.number_months(df, survey_year).squeeze()
            # If `period_scale` is 1, then number reported was total for year,
            # don't need month_count. Otherwise, scale by fraction of year with
            # stamps
            scale = period_scale.where(
                period_scale == 1,
                period_scale.values * month_count.values / 12)
            stamps = raw_stamp * scale
        else:
            return

        # Put `stamps` value into `df`
        varname = 'food_stamps'
        real_year = survey_year - 1
        col_index = (varname, real_year)
        df[col_index] = stamps

    def varcodes(self):
        std_code = {
            2007: 'ER36673',
            2005: 'ER25655',
            2003: 'ER21653',
            2001: 'ER18387',
            1999: 'ER14256',
            1997: 'ER11050',
            1996: 'ER8156',
            1995: 'ER6059',
            1994: 'ER3060',
            # During 1980--1993, the below is the accurate "stamps in YR"
            # That I recreate in other years
            1993: 'V21727',
            1992: 'V20411',
            1991: 'V19111',
            1990: 'V17811',
            1989: 'V16395',
            1988: 'V14895',
            1987: 'V13880',
            1986: 'V12778',
            1985: 'V11379',
            1984: 'V10239',
            1983: 'V8868',
            1982: 'V8260',
            1981: 'V7568',
            1980: 'V6976',
        }

        paid_code = {
            1979: 'V6380',
            1978: 'V5774',
            1977: 'V5275',
            1976: 'V4362',
            1975: 'V3849',
        }

        bonus_code = {
            1979: 'V6382',
            1978: 'V5776',
            1977: 'V5277',
            1976: 'V4364',
            1975: 'V3851',
        }

        return std_code, paid_code, bonus_code

    def codebooks(self, survey_year):
        # No 'bad' codes until 1994
        if 1975 <= survey_year <= 1993:
            codebook = {
                9999: np.nan,       # top code
            }
        elif 1994 <= survey_year <= 1997:
            codebook = {
                99997: np.nan,      # top code
                99998: np.nan,      # DK
                99999: np.nan,      # refuse
            }
        elif 1999 <= survey_year <= 2007:
            codebook = {
                999997: np.nan,
                999998: np.nan,
                999999: np.nan,
            }

        return codebook

    def period(self, df, survey_year):
        def year_to_code(survey_year):
            xwalk = {
                2007: 'ER36674',
                2005: 'ER25656',
                2003: 'ER21654',
                2001: 'ER18388',
                1999: 'ER14257',
                1997: 'ER11051',
                1996: 'ER8157',
                1995: 'ER6060',
                1994: 'ER3061',
                1993: 'V21714',     # Unneeded, but leave
            }
            return xwalk[survey_year]

        def year_to_scale(survey_year):
            if (1996 <= survey_year <= 2007) or (survey_year == 1993):
                scale_dict = {
                    0: 0,                   # no stamps
                    1: np.nan,              # wild code
                    3: 52,                  # Week
                    4: 52 / 2,              # Two weeks
                    5: 12,                  # Month
                    6: 1,                   # Year
                    7: np.nan,              # Other
                    8: np.nan, 9: np.nan    # Don't know/refused
                }
            elif survey_year == 1995:
                # This one is squirrely; see codebook
                scale_dict = {
                    0: 0,                   # no stamps
                    1: 12,                  # Month duplicate, should be 0 obs
                    2: 52 / 2,              # Two weeks dup, should be 0 obs
                    3: 52,                  # Week
                    4: 52 / 2,              # Two weeks
                    5: 12,                  # Month
                    6: 1,                   # Year
                    7: np.nan,              # Other
                    8: np.nan, 9: np.nan    # Don't know/refused
                }
            elif survey_year == 1994:
                # Also squirrely;
                scale_dict = {
                    0: 0,                   # no stamps
                    1: 12,                  # Month
                    2: 52 / 2,              # Two weeks
                    3: 52,                  # Week
                    4: np.nan,              # Other
                    8: np.nan, 9: np.nan    # DK/NA/refuse
                }
            else:
                raise ValueError("Bad year, {}".format(survey_year))

            return scale_dict

        raw_period = df[year_to_code(survey_year)]
        scale = raw_period.replace(year_to_scale(survey_year))
        return scale

    def number_months(self, df, survey_year):
        """
        Return number of months person received food stamps.

        Note: In most years, each column is a binary for 'got stamps in this
        month'.  However, in 1994, the coding is 'what is the first month you
        got food stamps', so column 1 is 1 for Jan, 2 for Feb, etc. Also, col 1
        is 13 for 'all year'.
        """
        xwalk = {
            # Year: List of variable codes (12), bad code
            2007: (['ER366{}'.format(x) for x in range(76, 87 + 1)], 9),
            2005: (['ER256{}'.format(x) for x in range(58, 69 + 1)], 9),
            2003: (['ER216{}'.format(x) for x in range(56, 67 + 1)], 9),
            2001: (['ER18{}'.format(x) for x in range(390, 401 + 1)], 9),
            1999: (['ER142{}'.format(x) for x in range(58, 69 + 1)], 9),
            1997: (['ER110{}'.format(x) for x in range(52, 63 + 1)], 9),
            1996: (['ER81{}'.format(x) for x in range(58, 69 + 1)], 8),
            1995: (['ER60{}'.format(x) for x in range(61, 72 + 1)], 8),
            # 1994 extra weird (first mention...)
            1994: (['ER30{}'.format(x) for x in range(62, 73 + 1)], (98, 99)),
            # 1980--1993 has accurate "total value of stamps in year"
            # Before 1979, the question is "value for year"
        }
        variables, badcode = xwalk[survey_year]
        month_flags = df[variables].replace(badcode, 0)
        num_months = (month_flags > 0).sum(axis=1)
        if survey_year == 1994:
            # In 1994
            num_months[month_flags.iloc[:, 0] == 13] = 12

        return num_months


class super_food_home_out(object):
    """
    `food_home` and `food_out` have the same `std` method.
    """

    def std(self, df, survey_year):
        col_index = (self.varname, survey_year - 1)
        # Get `varcode` for `survey_year` if possible, else quit
        try:
            varcode = self.varcodes(survey_year)
        except KeyError:
            return
        codebook = self.codebooks(survey_year)
        if survey_year < 1994:
            df[col_index] = df[varcode].replace(codebook)
        elif survey_year >= 1994:
            period_varcodes = self._period_varcodes(survey_year)
            period_codebook = self._period_codebooks(survey_year)
            # Replace nan codes
            all_cols = df[list(varcode)].replace(codebook)
            # Scale to year, sum
            scale_to_year = df[list(period_varcodes)].replace(period_codebook)
            df[col_index] = (all_cols.values *
                             scale_to_year.values).sum(axis=1)


class food_home(super_food_home_out):
    """
    Before survey year 1994, 'food at home' was the sum of four survey answers:
        1) food bought at home (person not on food stamps)
        2) food delivered (person not on food stamps)
        3) food bought at home (person on food stamps)
        4) food delivered (person on food stamps)
    From 1994 on, these are 4 separate variables

    NOTE: Method `std` inherited from `super_food_home_out` and `varname` set
        by `__init__`.
    """
    def __init__(self):
        self.varname = 'food_home'

    def varcodes(self, survey_year):
        varcode = {
            2007: ('ER36716',       # Food at home (no stamps)
                   'ER36720',       # Food delivered (no stamps)
                   'ER36706',       # Food at home (stamps)
                   'ER36710'),      # Food delivered (stamps)
            2005: ('ER25698',
                   'ER25702',
                   'ER25688',
                   'ER25692'),
            2003: ('ER21696',
                   'ER21700',
                   'ER21686',
                   'ER21690'),
            2001: ('ER18431',
                   'ER18435',
                   'ER18421',
                   'ER18425'),
            1999: ('ER14295',
                   'ER14298',
                   'ER14288',
                   'ER14291'),
            1997: ('ER11076',
                   'ER11079',
                   'ER11068',
                   'ER11071'),
            1996: ('ER8181',
                   'ER8184',
                   'ER8174',
                   'ER8177'),
            1995: ('ER6084',
                   'ER6087',
                   'ER6077',
                   'ER6080'),
            1994: ('ER3085',
                   'ER3088',
                   'ER3078',
                   'ER3081'),
            1993: 'V21707',         # Food at home and delivered
            1992: 'V20407',
            1991: 'V19107',
            1990: 'V17807',
            1987: 'V13876',
            1986: 'V12774',
            1985: 'V11375',
            1984: 'V10235',
            1983: 'V8864',
            1982: 'V8256',
            1981: 'V7564',
            1980: 'V6972',
            1979: 'V6376',
            1978: 'V5770',
            1977: 'V5271',
            1976: 'V4354',
            1975: 'V3841',
            1974: 'V3441',
        }
        return varcode[survey_year]

    def codebooks(self, survey_year):
        if 1994 <= survey_year <= 2007:
            codebook = {
                99997: np.nan,      # topcode
                99998: np.nan,
                99999: np.nan,
            }
        elif 1983 <= survey_year <= 1993:
            codebook = {
                99999: np.nan,      # topcode
            }
        elif 1974 <= survey_year <= 1982:
            codebook = {
                9999: np.nan,       # topcode
            }

        return codebook

    def _period_varcodes(self, survey_year):
        home = {
            2007: 'ER36717',
            2005: 'ER25699',
            2003: 'ER21697',
            2001: 'ER18432',
            1999: 'ER14296',
            1997: 'ER11077',
            1996: 'ER8182',
            1995: 'ER6085',
            1994: 'ER3086',
        }
        deliver = {
            2007: 'ER36721',
            2005: 'ER25703',
            2003: 'ER21701',
            2001: 'ER18436',
            1999: 'ER14299',
            1997: 'ER11080',
            1996: 'ER8185',
            1995: 'ER6088',
            1994: 'ER3089',
        }
        home_st = {
            2007: 'ER36707',
            2005: 'ER25689',
            2003: 'ER21687',
            2001: 'ER18422',
            1999: 'ER14289',
            1997: 'ER11069',
            1996: 'ER8175',
            1995: 'ER6078',
            1994: 'ER3079',
        }
        del_st = {
            2007: 'ER36711',
            2005: 'ER25693',
            2003: 'ER21691',
            2001: 'ER18426',
            1999: 'ER14292',
            1997: 'ER11072',
            1996: 'ER8178',
            1995: 'ER6081',
            1994: 'ER3082',
        }
        varcode = {x: (home[x], deliver[x], home_st[x], del_st[x])
                   for x in home.keys()}
        return varcode[survey_year]

    def _period_codebooks(self, survey_year):
        if survey_year == 1994:
            codebook = {
                0: 0,       # Inap.
                1: 52,      # Week
                2: 52 / 2,  # Two weeks
                3: 12,      # Month
                4: np.nan,  # Other
                8: np.nan,  # DK
                9: np.nan,  # Refused
            }
        if 1995 <= survey_year <= 1997:
            codebook = {
                0: 0,       # Inap.
                1: np.nan,  # wild code
                2: 365,     # Day
                3: 52,      # Week
                4: 52 / 2,  # Two weeks
                5: 12,      # Month
                6: 1,       # Year
                7: np.nan,  # Other
                8: np.nan,  # DK
                9: np.nan,  # Refused
            }
        if 1999 <= survey_year <= 2007:
            codebook = {
                0: 0,       # Inap.
                1: np.nan,  # wild code
                2: np.nan,  # wild code
                3: 52,      # Week
                4: 52 / 2,  # Two weeks
                5: 12,      # Month
                6: 1,       # Year
                7: np.nan,  # Other
                8: np.nan,  # DK
                9: np.nan,  # Refused
            }

        return codebook


class food_out(super_food_home_out):
    """
    Before 1994, variable is straightforward.
    From 1994 on, there are two mutually exclusive variables, one for people
        who used food stamps and one for those you didn't.

    NOTE: Method `std` inherited from `super_food_home_out` and `varname` set
        by `__init__`.
    """

    def __init__(self):
        self.varname = 'food_out'

    def varcodes(self, survey_year):
        out = {
            2007: 'ER36723',
            2005: 'ER25705',
            2003: 'ER21703',
            2001: 'ER18438',
            1999: 'ER14300',
            1997: 'ER11081',
            1996: 'ER8186',
            1995: 'ER6089',
            1994: 'ER3090',
            1993: 'V21711',
            1992: 'V20409',
            1991: 'V19109',
            1990: 'V17809',
            1987: 'V13878',
            1986: 'V12776',
            1985: 'V11377',
            1984: 'V10237',
            1983: 'V8866',
            1982: 'V8258',
            1981: 'V7566',
            1980: 'V6974',
            1979: 'V6378',
            1978: 'V5772',
            1977: 'V5273',
            1976: 'V4368',
            1975: 'V3853',
            1974: 'V3445',
        }
        out_st = {
            2007: 'ER36713',
            2005: 'ER25695',
            2003: 'ER21693',
            2001: 'ER18428',
            1999: 'ER14293',
            1997: 'ER11073',
            1996: 'ER8179',
            1995: 'ER6082',
            1994: 'ER3083',
        }
        varcode = {x: (out[x], out_st[x]) for x in out_st.keys()}
        varcode.update({x: out[x] for x in out.keys() if x not in out_st})
        return varcode[survey_year]

    def codebooks(self, survey_year):
        if 1994 <= survey_year <= 2007:
            codebook = {
                99997: np.nan,      # topcode
                99998: np.nan,
                99999: np.nan,
                99999.90: np.nan,   # wild (1995, stamps)
                99999.99: np.nan,   # wild (2005)
                99999.97: np.nan,   # wild (1997)
            }
        elif survey_year == 1993:
            codebook = {
                99999: np.nan,      # topcode
            }
        elif 1974 <= survey_year <= 1992:
            codebook = {
                9999: np.nan,       # topcode
            }

        return codebook

    def _period_varcodes(self, survey_year):
        out = {
            2007: 'ER36724',
            2005: 'ER25706',
            2003: 'ER21704',
            2001: 'ER18439',
            1999: 'ER14301',
            1997: 'ER11082',
            1996: 'ER8187',
            1995: 'ER6090',
            1994: 'ER3091',
        }
        out_st = {
            2007: 'ER36714',
            2005: 'ER25696',
            2003: 'ER21694',
            2001: 'ER18429',
            1999: 'ER14294',
            1997: 'ER11074',
            1996: 'ER8180',
            1995: 'ER6083',
            1994: 'ER3084',
        }
        varcode = {x: (out[x], out_st[x]) for x in out_st.keys()}
        return varcode[survey_year]

    def _period_codebooks(self, survey_year):
        if 1995 <= survey_year <= 2007:
            codebook = {
                0: 0,       # Inap.
                2: 365,     # Day
                3: 52,      # Week
                4: 52 / 2,  # Two weeks
                5: 12,      # Month
                6: 1,       # Year
                7: np.nan,  # Other
                8: np.nan,  # DK
                9: np.nan,  # Refused
            }
        if survey_year == 1994:
            codebook = {
                0: 0,       # Inap.
                1: 52,      # Week
                2: 52 / 2,  # Two weeks
                3: 12,      # Month
                4: np.nan,  # Other
                8: np.nan,  # DK
                9: np.nan,  # Refused
            }
        return codebook


class mortgage_pay(object):
    """
    Monthly mortgage payments

    Variable types over time:
    1994--2007+: Monthly mortgage payments for each mortage
    1993: Total montly mortgage payments and total paid last year
    --1992: Total paid last year
    """
    def std(self, df, survey_year):
        varname = 'mortgage_pay'
        try:
            varcode = self.varcodes(survey_year)
        except KeyError:
            return
        codebook = self.codebook(survey_year)

        if 1993 < survey_year:
            # Pull the variables, drop/miss, sum
            mort1, mort2 = varcode
            mort = df[mort1].replace(codebook) + df[mort2].replace(codebook)
            df[(varname, survey_year)] = mort
        elif survey_year == 1993:
            mort_now, mort_last = varcode
            # From "Current monthly mortgage payments"
            df[(varname, survey_year)] = df[mort_now].replace(codebook)
            # From "Total mortgage payments last year"
            df[(varname, survey_year - 1)] = (
                df[mort_last].replace(codebook) / 12
            )
        else:
            # Pull the variable, make monthly
            df[(varname, survey_year - 1)] = df[varcode].replace(codebook) / 12

    def varcodes(self, survey_year):
        varcode = {
            2007: ('ER36044', 'ER36056'),
            2005: ('ER25044', 'ER25055'),
            2003: ('ER21053', 'ER21064'),
            2001: ('ER17054', 'ER17065'),
            1999: ('ER13048', 'ER13057'),
            1997: ('ER10046', 'ER10047'),
            1996: ('ER7044', 'ER7045'),
            1995: ('ER5038', 'ER5039'),
            1994: ('ER2039',        # monthly, first mortgage only
                   'ER2040'),       # monthly, second mortgage only
            1993: ('V21614',        # monthly, all mortgages
                   'V21615'),       # last year, all mortgages
            1992: 'V20328',
            1991: 'V19028',
            1990: 'V17728',
            1987: 'V13728',
            1986: 'V12528',
            1985: 'V11129',
            1984: 'V10022',
            1983: 'V8821',
            1981: 'V7521',
            1980: 'V6921',
            1979: 'V6323',
            1978: 'V5721',
            1977: 'V5221',
            1976: 'V4322',
        }
        return varcode[survey_year]

    def codebook(self, survey_year):
        if 1994 <= survey_year <= 2007:
            codebook = {
                99997: np.nan,  # topcode
                99998: np.nan,
                99999: np.nan
            }
        elif survey_year == 1993:
            codebook = {
                99998: np.nan,  # topcode for monthly 1993
                99999: np.nan,  # topcode for annual 1993, missing for monthly
            }
        elif 1983 <= survey_year <= 1992:
            codebook = {
                99999: np.nan,  # topcode
            }
        elif 1976 <= survey_year <= 1981:
            codebook = {
                9999: np.nan,   # topcode
            }

        return codebook


class rent_pay(object):
    """
    Question is
    1994--2007: "monthly rent payment"
    1993: both "monthly rent" and "annual rent last year"
    --1992: "annual rent last year"
    """

    def std(self, df, survey_year):
        varname = 'rent_pay'
        try:
            varcode = self.varcodes(survey_year)
        except KeyError:
            return
        codebook = self.codebooks(survey_year)

        if survey_year > 1993:
            df[(varname, survey_year)] = df[varcode].replace(codebook)
        elif survey_year == 1993:
            # This year
            df[(varname, survey_year)] = df[varcode[0]].replace(codebook[0])
            # Last year
            df[(varname, survey_year - 1)] = (
                df[varcode[1]].replace(codebook[1]) / 12
            )
        elif survey_year < 1993:
            df[(varname, survey_year - 1)] = df[varcode].replace(codebook) / 12

    def varcodes(self, survey_year):
        varcodes = {
            2007: 'ER36065',
            2005: 'ER25063',
            2003: 'ER21072',
            2001: 'ER17074',
            1999: 'ER13065',
            1997: 'ER10060',
            1996: 'ER7121',
            1995: 'ER5048',
            1994: 'ER2049',
            1993: ('V21620',    # Current monthly rent
                   'V21622'),   # Total ann rent last year
            1992: 'V20333',
            1991: 'V19033',
            1990: 'V17733',
            1987: 'V13732',
            1986: 'V12532',
            1985: 'V11133',
            1984: 'V10026',
            1983: 'V8825',
            1982: 'V8221',
            1981: 'V7525',
            1980: 'V6925',
            1979: 'V6326',
            1978: 'V5723',
            1977: 'V5225',
            1976: 'V4326',
            1975: 'V3819',
            1974: 'V3419',
        }
        return varcodes[survey_year]

    def codebooks(self, survey_year):
        # Always 0 for those that don't rent
        if 1994 <= survey_year <= 2007:
            codebook = {
                99997: np.nan,      # top code
                99998: np.nan,
                99999: np.nan,
            }
        elif survey_year == 1993:
            # Monthly
            codebook1 = {
                9998: np.nan,      # top code
                9999: np.nan,
            }
            # Annual
            codebook2 = {
                99999: np.nan,      # top code
            }
            codebook = (codebook1, codebook2)
        elif 1983 <= survey_year <= 1992:
            codebook = {
                99999: np.nan,      # top code
            }
        elif 1974 <= survey_year <= 1982:
            codebook = {
                9999: np.nan,      # top code
            }

        return codebook


class mortgage_balance(object):

    def std(self, df, survey_year):
        varname = 'mortgage_balance'
        col_index = (varname, survey_year)
        try:
            varcode = self.varcodes(survey_year)
        except KeyError:
            return
        codebook = self.codebooks(survey_year)

        if 1993 < survey_year:
            df[col_index] = (df[varcode[0]].replace(codebook) +
                             df[varcode[1]].replace(codebook))
        elif survey_year <= 1993:
            df[col_index] = df[varcode].replace(codebook)

    def varcodes(self, survey_year):
        varcode = {
            2007: ('ER36042',       # Mortgage 1
                   'ER36054'),      # Mortgage 2
            2005: ('ER25042',
                   'ER25053'),
            2003: ('ER21051',
                   'ER21062'),
            2001: ('ER17052',
                   'ER17063'),
            1999: ('ER13047',
                   'ER13056'),
            1997: ('ER10044',
                   'ER10045'),
            1996: ('ER7042',
                   'ER7043'),
            1995: ('ER5036',
                   'ER5037'),
            1994: ('ER2037',
                   'ER2038'),
            1993: 'V21612',         # All mortgages
            1992: 'V20326',
            1991: 'V19026',
            1990: 'V17726',
            1989: 'V16326',
            1988: 'V14826',
            1987: 'V13726',
            1986: 'V12526',
            1985: 'V11127',
            1984: 'V10020',
            1983: 'V8819',
            1981: 'V7519',
            1980: 'V6919',
            1979: 'V6321',
            1978: 'V5719',
            1977: 'V5219',
            1976: 'V4320',
        }
        return varcode[survey_year]

    def codebooks(self, survey_year):
        if 1994 <= survey_year <= 2007:
            codebook = {
                9999997: np.nan,        # top code
                9999998: np.nan,        # DK
                9999999: np.nan,        # N/A, refused
            }
        elif 1982 <= survey_year <= 1993:
            codebook = {
                999999: np.nan,         # top code
            }
        elif 1976 <= survey_year <= 1981:
            codebook = {
                99999: np.nan,          # top code
            }

        return codebook


class other_vars(object):
    """
    Variable-specific methods return `varcode`, `codebook`, and `year_diff`.

    If a variable only has changes in its codebook over time (not its actual
    definition), then it goes here. Anything more complex needs its own object.
    """

    def __init__(self, survey_year):
        """ Take `survey_year` so `codebook` can depend on it. """
        self.survey_year = survey_year

    def get_std_func(self, varname):
        """
        Sets up function `this_std` that mimics standalone function that takes
        `df` and `survey_year`.
        """
        varcode, codebook, year_diff = getattr(self, varname)()

        def this_std(df, survey_year):
            col_index = (varname, survey_year + year_diff)

            # Get `varcode` for `survey_year` if possible, else quit
            try:
                this_varcode = varcode[survey_year]
            except KeyError:
                return
            df[col_index] = df[this_varcode]

            if codebook:
                df[col_index].replace(codebook, inplace=True)

        return this_std

    def interview_number(self):
        varcode = {
            2007: 'ER36002',
            2005: 'ER25002',
            2003: 'ER21002',
            2001: 'ER17002',
            1999: 'ER13002',
            1997: 'ER10002',
            1996: 'ER7002',
            1995: 'ER5002',
            1994: 'ER2002',
            1993: 'V21602',
            1992: 'V20302',
            1991: 'V19002',
            1990: 'V17702',
            1989: 'V16302',
            1988: 'V14802',
            1987: 'V13702',
            1986: 'V12502',
            1985: 'V11102',
            1984: 'V10002',
            1983: 'V8802',
            1982: 'V8202',
            1981: 'V7502',
            1980: 'V6902',
            1979: 'V6302',
            1978: 'V5702',
            1977: 'V5202',
            1976: 'V4302',
            1975: 'V3802',
            1974: 'V3402',
        }
        codebook = None
        year_diff = 0

        return varcode, codebook, year_diff

    def hhold_weight(self):
        varcode = {
            2007: 'ER41069',
            2005: 'ER28078',
            2003: 'ER24180',
            2001: 'ER20459',
            1999: 'ER16519',
            1997: 'ER12224',
            1996: 'ER9251',
            1995: 'ER7000',
            1994: 'ER4160',
            1993: 'V23361',
            1992: 'V21547',
            1991: 'V20243',
            1990: 'V18943',
            1989: 'V17612',
            1988: 'V16208',
            1987: 'V14737',
            1986: 'V13687',
            1985: 'V12446',
            1984: 'V11079',
            1983: 'V9433',
            1982: 'V8727',
            1981: 'V8103',
            1980: 'V7451',
            1979: 'V6805',
            1978: 'V6212',
            1977: 'V5665',
            1976: 'V5099',
            1975: 'V4224',
            1974: 'V3721',
        }
        codebook = None
        year_diff = 0

        return varcode, codebook, year_diff

    def state(self):
        """
        This is PSID's own state code. They don't include FIPS until 1985.
        """
        varcode = {
            2013: 'ER53003',
            2011: 'ER47303',
            2009: 'ER42003',
            2007: 'ER25004',
            2005: 'ER25003',
            2003: 'ER21003',
            2001: 'ER17004',
            1999: 'ER13004',
            1997: 'ER12221',
            1996: 'ER9247',
            1995: 'ER6996',
            1994: 'ER4156',
            1993: 'V21603',
            1992: 'V20303',
            1991: 'V19003',
            1990: 'V17703',
            1989: 'V16303',
            1988: 'V14803',
            1987: 'V13703',
            1986: 'V12503',
            1985: 'V11103',
            1984: 'V10003',
            1983: 'V8803',
            1982: 'V8203',
            1981: 'V7503',
            1980: 'V6903',
            1979: 'V6303',
            1978: 'V5703',
            1977: 'V5203',
            1976: 'V4303',
            1975: 'V3803',
            1974: 'V3403',
        }
        codebook = _PSID_state_to_FIPS_dict()
        codebook.update({
            0: np.nan,      # Maps to many FIPS (PR, GUAM, etc.)
            99: np.nan,     # DK; N/A
        })
        year_diff = 0

        return varcode, codebook, year_diff

    def male_head(self):
        varcode = {
            2007: 'ER36018',
            2005: 'ER25018',
            2003: 'ER21018',
            2001: 'ER17014',
            1999: 'ER13011',
            1997: 'ER10010',
            1996: 'ER7007',
            1995: 'ER5007',
            1994: 'ER2008',
            1993: 'V22407',
            1992: 'V20652',
            1991: 'V19350',
            1990: 'V18050',
            1989: 'V16632',
            1988: 'V15131',
            1987: 'V14115',
            1986: 'V13012',
            1985: 'V11607',
            1984: 'V10420',
            1983: 'V8962',
            1982: 'V8353',
            1981: 'V7659',
            1980: 'V7068',
            1979: 'V6463',
            1978: 'V5851',
            1977: 'V5351',
            1976: 'V4437',
            1975: 'V3922',
            1974: 'V3509',
        }

        codebook = {
            0: np.nan,      # Wild code, [1994,1996]
            1: 1,           # Male head
            2: 0,           # Female head
        }
        year_diff = 0

        return varcode, codebook, year_diff

    def headrace(self):

        varcode = {
            2007: 'ER40565',
            2005: 'ER27393',
            2003: 'ER23426',
            2001: 'ER19989',
            1999: 'ER15928',
            1997: 'ER11848',
            1996: 'ER9060',
            1995: 'ER6814',
            1994: 'ER3944',
            1993: 'V23276',
            1992: 'V21420',
            1991: 'V20114',
            1990: 'V18814',
            1989: 'V17483',
            1988: 'V16086',
            1987: 'V14612',
            1986: 'V13565',
            1985: 'V11938',
            1984: 'V11055',
            1983: 'V9408',
            1982: 'V8723',
            1981: 'V8099',
            1980: 'V7447',
            1979: 'V6802',
            1978: 'V6209',
            1977: 'V5662',
            1976: 'V5096',
            1975: 'V4204',
            1974: 'V3720',
        }
        if 2005 <= self.survey_year <= 2007:
            codebook = {
                1: 'w',     # White
                2: 'b',     # Black
                3: 'n',     # American Indian or Alaska Native
                4: 'a',     # Asian
                5: 'i',     # Native Hawaiian or Pacific Islander
                7: 'o',     # Other
                9: '',      # NA;DK
                0: '',      # Wild code
            }
        elif 1985 <= self.survey_year <= 2003:
            codebook = {
                0: '',      # Inap.: no new head
                1: 'w',     # White
                2: 'b',     # Black
                3: 'n',     # Native American
                4: 'a',     # Asian/Pacific Islander
                5: 'l',     # Latino origin or descent
                6: 'o',     # Color besids black or white
                7: 'o',     # other
                8: '',      # NA (1999)
                9: '',      # NA;DK
            }
        # 1974--1984 is just copied straight from 1972 data. Splitoffs are
        # assumed to have the same race
        elif 1974 <= self.survey_year <= 1984:
            codebook = {
                1: 'w',     # White
                2: 'b',     # Black
                3: 'l',     # Latino origin or descent
                7: 'o',     # other
            }
        year_diff = 0

        return varcode, codebook, year_diff

    def famsize(self):
        """ NOTE: This is not 'household' size. """
        varcode = {
            2007: 'ER36016',
            2005: 'ER25016',
            2003: 'ER21016',
            2001: 'ER17012',
            1999: 'ER13009',
            1997: 'ER10008',
            1996: 'ER7005',
            1995: 'ER5005',
            1994: 'ER2006',
            1993: 'V22405',
            1992: 'V20650',
            1991: 'V19348',
            1990: 'V18048',
            1989: 'V16630',
            1988: 'V15129',
            1987: 'V14113',
            1986: 'V13010',
            1985: 'V11605',
            1984: 'V10418',
            1983: 'V8960',
            1982: 'V8351',
            1981: 'V7657',
            1980: 'V7066',
            1979: 'V6461',
            1978: 'V5849',
            1977: 'V5349',
            1976: 'V4435',
            1975: 'V3920',
            1974: 'V3507',
        }
        codebook = None
        year_diff = 0

        return varcode, codebook, year_diff

    def numchild(self):
        varcode = {
            2007: 'ER36020',
            2005: 'ER25020',
            2003: 'ER21020',
            2001: 'ER17016',
            1999: 'ER13013',
            1997: 'ER10012',
            1996: 'ER7009',
            1995: 'ER5009',
            1994: 'ER2010',
            1993: 'V22409',
            1992: 'V20654',
            1991: 'V19352',
            1990: 'V18052',
            1989: 'V16634',
            1988: 'V15133',
            1987: 'V14117',
            1986: 'V13014',
            1985: 'V11609',
            1984: 'V10422',
            1983: 'V8964',
            1982: 'V8355',
            1981: 'V7661',
            1980: 'V7070',
            1979: 'V6465',
            1978: 'V5853',
            1977: 'V5353',
            1976: 'V4439',
            1975: 'V3924',
            1974: 'V3511',
        }
        year_diff = -1
        codebook = None

        return varcode, codebook, year_diff

    def mrstat(self):
        varcode = {
            2007: 'ER36023',
            2005: 'ER25023',
            2003: 'ER21023',
            2001: 'ER17024',
            1999: 'ER13021',
            1997: 'ER10016',
            1996: 'ER7013',
            1995: 'ER5013',
            1994: 'ER2014',
            1993: 'V22412',
            1992: 'V20657',
            1991: 'V19355',
            1990: 'V18055',
            1989: 'V16637',
            1988: 'V15136',
            1987: 'V14120',
            1986: 'V13017',
            1985: 'V11612',
            1984: 'V10426',
            1983: 'V9276',
            1982: 'V8603',
            1981: 'V7952',
            1980: 'V7261',
            1979: 'V6659',
            1978: 'V6034',
            1977: 'V5502',
            1976: 'V4603',
            1975: 'V4053',
            1974: 'V3598',
        }
        year_diff = 0
        codebook = {
            1: 'm',     # Married
            2: 'n',     # Never married
            3: 'w',     # Widowed
            4: 'd',     # Divorced, annulled
            5: 's',     # Separated
            8: '', 9: '', 0: ''
        }

        return varcode, codebook, year_diff

    def tot_fam_income(self):
        """
        `topcode` is really at top or bottom.

        No binding bottom code in 1998
        No binding bottom/top codes in 1997
        No binding top code in 1995
        Top code is actually 'latino sample' in 1993--1994

        The following survey years have two 'total family income' variables.
        The first is for 'last year', the second is 'year before last'.
        However, 'year before last' is significantly lower quality.
            2003: ('ER24099', 'ER23764'),
            2001: ('ER20456', 'ER20165'),
            1999: ('ER16462', 'ER16219'),

        elif real_year in (2001, 1999, 1997):
            topcode = (999999997,)
            badcode = (999999998, 999999999)
        """
        varcode = {
            2007: 'ER41027',
            2005: 'ER28037',
            2003: 'ER24099',
            2001: 'ER20456',
            1999: 'ER16462',
            1997: 'ER12079',
            1996: 'ER9244',
            1995: 'ER6993',
            1994: 'ER4153',
            1993: 'V23322',
            1992: 'V21481',
            1991: 'V20175',
            1990: 'V18875',
            1989: 'V17533',
            1988: 'V16144',
            1987: 'V14670',
            1986: 'V13623',
            1985: 'V12371',
            1984: 'V11022',
            1983: 'V9375',
            1982: 'V8689',
            1981: 'V8065',
            1980: 'V7412',
            1979: 'V6766',
            1978: 'V6173',
            1977: 'V5626',
            1976: 'V5029',
            1975: 'V4154',
            1974: 'V3676',
        }

        if 1994 <= self.survey_year:
            codebook = {
                -999999: np.nan,    # bottom code
                9999999: np.nan,    # top code or Latino sample (1994, 1995)
            }
        elif 1981 <= self.survey_year <= 1993:
            codebook = {
                1:          np.nan,
                9999999:    np.nan,
            }
        elif self.survey_year == 1980:
            codebook = {
                1:          np.nan,
                999999:     np.nan,
            }
        elif 1974 <= self.survey_year <= 1979:
            codebook = {
                1:          np.nan,
                99999:      np.nan,
            }

        year_diff = -1

        return varcode, codebook, year_diff

    def headlabor(self):
        """
        Not used in final regs, so I haven't gone through the codebook
        -Dan Sullivan (2/29/16)
        """
        varcode = {
            2007: 'ER40921',
            2005: 'ER27931',
            2003: 'ER24116',
            1999: 'ER16463',
            1997: 'ER12080',
            1996: 'ER9231',
            1995: 'ER6980',
            1994: 'ER4140',
            1993: 'V23323',
            1992: 'V21484',
            1991: 'V20178',
            1990: 'V18878',
            1989: 'V17534',
            1988: 'V16145',
            1987: 'V14671',
            1986: 'V13624',
            1985: 'V12372',
            1984: 'V11023',
            1983: 'V9376',
            1982: 'V8690',
            1981: 'V8066',
            1980: 'V7413',
            1979: 'V6767',
            1978: 'V6174',
            1977: 'V5627',
            1976: 'V5031',
            1975: 'V3863',
            1974: 'V3463',
        }
        year_diff = -1
        if 1999 <= self.survey_year <= 2007:
            codebook = {
                9999999: np.nan,        # top code
            }
        if self.survey_year == 1997:
            codebook = {
                999999: np.nan,         # top code
            }
        elif 1993 <= self.survey_year <= 1996:
            codebook = {
                9999999: np.nan,        # latino sample/top code
            }
        elif 1983 <= self.survey_year <= 1992:
            codebook = {
                999999: np.nan,         # top code
            }
        elif 1974 <= self.survey_year <= 1982:
            codebook = {
                99999: np.nan,          # top code
            }

        return varcode, codebook, year_diff

    def wifelabor(self):
        varcode = {
            2007: 'ER40933',
            2005: 'ER27943',
            2003: 'ER24135',
            2001: 'ER20447',
            1999: 'ER16465',
            1997: 'ER12082',
            1996: 'ER9235',
            1995: 'ER6984',
            1994: 'ER4144',
            1993: 'V23324',
            1992: 'V20436',
            1991: 'V19136',
            1990: 'V17836',
            1989: 'V16420',
            1988: 'V14920',
            1987: 'V13905',
            1986: 'V12803',
            1985: 'V11404',
            1984: 'V10263',
            1983: 'V8881',
            1982: 'V8273',
            1981: 'V7580',
            1980: 'V6988',
            1979: 'V6398',
            1978: 'V5788',
            1977: 'V5289',
            1976: 'V4379',
            1975: 'V3865',
            1974: 'V3465',
        }
        year_diff = -1
        if 2001 <= self.survey_year <= 2007:
            codebook = {
                9999999: np.nan,        # top code
            }
        if self.survey_year == 1999:
            codebook = {
                9999997: np.nan,         # top code
            }
        if self.survey_year == 1997:
            codebook = {
                999999: np.nan,         # top code
            }
        elif 1993 <= self.survey_year <= 1996:
            codebook = {
                9999999: np.nan,        # latino sample/top code
            }
        elif 1984 <= self.survey_year <= 1992:
            codebook = {
                999999: np.nan,         # top code
            }
        elif 1974 <= self.survey_year <= 1983:
            codebook = {
                99999: np.nan,          # top code
            }

        return varcode, codebook, year_diff

    def head_unemp(self):
        varcode = {
            2001: 'ER17353',
            1999: 'ER13330',
            1997: 'ER10199',
            1996: 'ER7283',
            1995: 'ER5187',
            1994: 'ER2188',
            1993: 'V22569',
            1992: 'V20792',
            1991: 'V19492',
            1990: 'V18192',
            1989: 'V16754',
            1988: 'V15253',
            1987: 'V14199',
            1986: 'V13101',
            1985: 'V11701',
            1984: 'V10557',
            1983: 'V9032',
            1982: 'V8401',
            1981: 'V7739',
            1980: 'V7116',
            1979: 'V6513',
            1978: 'V5902',
            1977: 'V5413',
            1976: 'V4502',
        }
        year_diff = -1
        codebook = {
            0: 0,       # Not in labor force
            5: 0,       # No
            8: np.nan,
            9: np.nan,
        }

        return varcode, codebook, year_diff

    def homeowner(self):
        """ Formerly `hometype`, then coded to `homeowner` """
        varcode = {
            2007: 'ER36028',
            2005: 'ER25028',
            2003: 'ER21042',
            2001: 'ER17043',
            1999: 'ER13040',
            1997: 'ER10035',
            1996: 'ER7031',
            1995: 'ER5031',
            1994: 'ER2032',
            1993: 'V22427',
            1992: 'V20672',
            1991: 'V19372',
            1990: 'V18072',
            1989: 'V16641',
            1988: 'V15140',
            1987: 'V14126',
            1986: 'V13023',
            1985: 'V11618',
            1984: 'V10437',
            1983: 'V8974',
            1982: 'V8364',
            1981: 'V7675',
            1980: 'V7084',
            1979: 'V6479',
            1978: 'V5864',
            1977: 'V5364',
            1976: 'V4450',
            1975: 'V3939',
            1974: 'V3522',
        }
        codebook = {
            0: np.nan,   # "Inappropriate" (1994)
            1: 1,       # Owns/is buying, either fully or jointly
            5: 0,       # Pays rent
            8: 0,       # Neither owns nor rents
            9: np.nan,  # Wild code/NA/DK/refused
        }
        year_diff = 0

        return varcode, codebook, year_diff

    def home_value(self):
        varcode = {
            2007: 'ER36029',
            2005: 'ER25029',
            2003: 'ER21043',
            2001: 'ER17044',
            1999: 'ER13041',
            1997: 'ER10036',
            1996: 'ER7032',
            1995: 'ER5032',
            1994: 'ER2033',
            1993: 'V21610',
            1992: 'V20324',
            1991: 'V19024',
            1990: 'V17724',
            1989: 'V16324',
            1988: 'V14824',
            1987: 'V13724',
            1986: 'V12524',
            1985: 'V11125',
            1984: 'V10018',
            1983: 'V8817',
            1982: 'V8217',
            1981: 'V7517',
            1980: 'V6917',
            1979: 'V6319',
            1978: 'V5717',
            1977: 'V5217',
            1976: 'V4318',
            1975: 'V3817',
            1974: 'V3417',
        }

        if 2005 <= self.survey_year <= 2007:
            codebook = {
                9999998: np.nan,        # DK
                9999999: np.nan,        # refused
            }
        if 1994 <= self.survey_year <= 2003:
            codebook = {
                9999997: np.nan,        # topcode
                9999998: np.nan,        # DK
                9999999: np.nan,        # refused
            }
        if 1975 <= self.survey_year <= 1993:
            codebook = {
                999999: np.nan,         # top code
            }
        if self.survey_year == 1974:
            codebook = {
                99999: np.nan,          # top code
            }

        year_diff = 0

        return varcode, codebook, year_diff

    def bank_filed(self):
        varcode = {1996: 'ER8915'}
        year_diff = 0
        codebook = {
            0: np.nan,      # Interviewer is not head or wife
            # 1: 1,         # Yes (don't replace, faster)
            5: 0,           # No
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_year(self):
        varcode = {1996: 'ER8917'}
        year_diff = 0
        codebook = {
            0: np.nan,
            1919: 1991,     # "Wild code", but I'm guessing it's 1991
            9998: np.nan,   # DK
            9999: np.nan,   # refused
        }

        return varcode, codebook, year_diff

    def bank_2year(self):
        varcode = {1996: 'ER8943'}
        year_diff = 0
        codebook = {
            0: np.nan,
            9998: np.nan,   # DK
            9999: np.nan,   # refused
        }

        return varcode, codebook, year_diff

    def bank_chapter(self):
        varcode = {1996: 'ER8926'}
        year_diff = 0
        codebook = {
            0: np.nan,
            1: 7,
            2: 13,
            3: 20,      # Ch 13 converted to 7
            7: np.nan,  # Other
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_count(self):
        varcode = {1996: 'ER8916'}
        year_diff = 0
        codebook = {
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_state(self):
        varcode = {1996: 'ER8918'}
        year_diff = 0
        codebook = _PSID_state_to_FIPS_dict()
        codebook.update({
            52: 66,         # Guam
            53: 72,         # PR
            54: 78,         # Virgin Islands (US)
            55: np.nan,     # Foreign country
            98: np.nan,     # DK
            99: np.nan,     # refused
        })

        return varcode, codebook, year_diff

    def bank_assets_seized(self):
        varcode = {1996: 'ER8927'}
        year_diff = 0
        codebook = {
            0: np.nan,
            5: 0,           # No
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_assets_seized_value(self):
        varcode = {1996: 'ER8928'}
        year_diff = 0
        codebook = {
            999998: np.nan,      # DK
            999999: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_plan13_amt(self):
        """
        This obviously needs special handling, but we're not doing anything
        with it right now, so just leave it for later in case we want it

        Other Ch 13 variables I'm not doing right now:
            ER8930 plan13_payperiod
            ER8931 plan13_yrs
            ER8932 plan13_mos
            ER8933 plan13_wks
        """
        raise NotImplementedError
        varcode = {1996: 'ER8929'}
        year_diff = 0
        codebook = {
            # 9997: np.nan,       # top code
            9998: np.nan,       # DK
            9999: np.nan,       # refused
        }

        return varcode, codebook, year_diff

    def bank_plan13_amt_period(self):
        """ See `bank_plan13_amt` """
        raise NotImplementedError
        varcode = {1996: 'ER8930'}
        year_diff = 0
        codebook = {
            3: 52,          # Week
            4: 52 / 2,      # Two weeks
            5: 12,          # Month
            6: 1,           # Year
            7: np.nan,      # Other
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_plan13_completed(self):
        """ Did you complete your replayment plan? """
        varcode = {1996: 'ER8934'}
        year_diff = 0
        codebook = {
            0: np.nan,      # n/a
            5: 0,           # No
            8: np.nan,      # DK
            9: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_debt_filed(self):
        varcode = {1996: 'ER8935'}
        year_diff = 0
        codebook = {
            9999998: np.nan,      # DK
            9999999: np.nan,      # refused
        }

        return varcode, codebook, year_diff

    def bank_debt_remained(self):
        varcode = {1996: 'ER8936'}
        year_diff = 0
        codebook = {
            9999998: np.nan,      # DK
            9999999: np.nan,      # refused
        }

        return varcode, codebook, year_diff


def _PSID_state_to_FIPS_dict():
    codebook = {
        # PSID code, FIPS code
        1: 1,
        50: 2,
        2: 4,
        3: 5,
        4: 6,
        5: 8,
        6: 9,
        7: 10,
        8: 11,
        9: 12,
        10: 13,
        51: 15,
        11: 16,
        12: 17,
        13: 18,
        14: 19,
        15: 20,
        16: 21,
        17: 22,
        18: 23,
        19: 24,
        20: 25,
        21: 26,
        22: 27,
        23: 28,
        24: 29,
        25: 30,
        26: 31,
        27: 32,
        28: 33,
        29: 34,
        30: 35,
        31: 36,
        32: 37,
        33: 38,
        34: 39,
        35: 40,
        36: 41,
        37: 42,
        38: 44,
        39: 45,
        40: 46,
        41: 47,
        42: 48,
        43: 49,
        44: 50,
        45: 51,
        46: 53,
        47: 54,
        48: 55,
        49: 56,
    }
    return codebook


if __name__ == '__main__':
    pass
