from os.path import abspath, join
import platform

OUT_PATH = abspath('../out')

if platform.system() == 'Darwin':       # running on mac so frank machine
    DATA_PATH = abspath('../data')
else:
    DATA_PATH = abspath('d:/data/bIncome')

def data_path(*args):
    return join(DATA_PATH, *args)


def out_path(*args):
    return join(OUT_PATH, *args)


def src_path(*args):
    return join(DATA_PATH, 'src', *args)
