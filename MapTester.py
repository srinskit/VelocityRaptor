from HashMap import *


def main():
    H = HashMap(20)
    my_list = [Pair('16IT141', 'Srinag'), Pair('16IT135', 'Shreyas'), Pair('16IT149', 'Yash'),
               Pair('16IT211', 'Bharath')]
    keys = ['16IT141', '16IT142', '16IT135', '16IT149', '16IT211']
    for pair in my_list:
        H.insert(pair)
    for key in keys:
        try:
            print(H.search(key).val)
        except:
            print(key + ' not found')


if __name__ == '__main__':
    main()
