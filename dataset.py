from random import randint


def make(file, n, start, stop, unique=False):
    done = {}
    while n > 0:
        x = randint(start, stop)
        if not unique or x not in done:
            file.write(str(x) + '\n')
            if unique:
                done[x] = True
            n -= 1


if __name__ == '__main__':
    make(open('data', 'w'), 1000, 0, 5000)
