import re

dpa_path = 'scripts/individual_small.do'
out_path = 'scripts/indiv_dicts.txt'

varnames = (
    'cutoff',
    'match',
    'educ',
    'hrwork',
    'employ',
    'relhead',
    'age',
)


with open(dpa_path, 'r') as f, open(out_path, 'w') as out:
    for varname in varnames:
        out.write("#{}\nvarcode = {{\n".format(varname))
        for line in f:
            # Match, get subgroups
            m = re.match(
                'rename ([ERV]{{1,2}}\d+) {}(\d{{4}})'.format(varname),
                line)
            if m:
                varcode, year = m.group(1), m.group(2)
                out.write("    {}: '{}',\n".format(year, varcode))
        f.seek(0)
        out.write("}\n\n")
