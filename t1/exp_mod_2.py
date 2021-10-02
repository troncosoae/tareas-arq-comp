import sys


def exp_mod(x, y, z):
    return x**y % z


def exp_mod_ext(x, y, z):
    return x**y % z


if __name__ == '__main__':
    x = int(sys.argv[1])
    y = int(sys.argv[2])
    z = int(sys.argv[3])

    print('x**y % z')

    print('x**y:', x**y)

    print(exp_mod(x, y, z))
