import sys


def activacion(x):
    if x > 150:
        y = (3**x % x) % 3
        return 1 if y > 0 else 0
    else:
        y = (x - 1) % x
        return 1 if y > 0 else 0


if __name__ == '__main__':
    x = int(sys.argv[1])
    print(activacion(x))
