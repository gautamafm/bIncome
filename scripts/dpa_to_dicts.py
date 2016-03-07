import re

dpa_path = 'scripts/dataprep_a.do'
out_path = 'scripts/varcode_dicts.txt'

varnames = (
    'match',
    'wt',
    'tfinc',
    'famsize',
    'hometype',
    'state',
    'sexofhead',
    'headrace',
    'headlabor',
    'mrstat',
    'wifelabor',
    'heademp',
    'wifeemploy',
    'numchild',
    'mortmo',
    'mort',
    'rentmo',
    'rent',
    'mortpri',
    'hvalue',
    'stamps',
    'stampsper',
    'foodhome_st',
    'foodhomeper_st',
    'fooddel_st',
    'fooddelper_st',
    'foodout_st',
    'foodoutper_st',
    'foodhome',
    'foodhomeper',
    'fooddel',
    'fooddelper',
    'foodout',
    'foodoutper',
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
