def f1(x):
    y = (3**x % x) % 3
    return y


def f2(x):
    y = (((3 % x)**x) % x) % 3
    return y


for x in range(1, 700):
    print(f'f({x}) = {f1(x)}')
    if f1(x) != f2(x):
        raise Exception('err')
