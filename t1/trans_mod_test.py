import sys


def mod1(a, b, c):
    return (a % b) % c


def mod2(a, b, c):
    return (a % c) % b


def f1(a, b, c):
    return (a*c) % b


def f2(a, b, c):
    r1 = (a*(c % b)) % b
    r2 = (c*(a % b)) % b
    if r1 != r2:
        raise Exception('err')
    return r1


if __name__ == '__main__':
    for i in range(1, 10):
        for j in range(1, 10):
            for k in range(1, 10):
                # print(f'mod1: {mod1(i, j, k)} - mod2: {mod2(i, j, k)}')
                print(f'f1: {f1(i, j, k)} - f2: {f2(i, j, k)}')
