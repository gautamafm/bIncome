from os.path import abspath, join

DATA_PATH = abspath('d:/data/bIncome')
OUT_PATH = abspath('../out')


def data_path(*args):
    return join(DATA_PATH, *args)


def out_path(*args):
    return join(OUT_PATH, *args)


def src_path(*args):
    return join(DATA_PATH, 'src', *args)
