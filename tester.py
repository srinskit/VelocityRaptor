from WBTree import WBT


def main():
    tree = WBT()
    data = open('data')
    for val in data:
        tree.insert(int(val))
    data.close()
    tree.print_tree()
    data = open('data')
    for val in data:
        if tree.search(int(val)) is None:
            # print(val)
            print(':(')
    print('Done')


if __name__ == '__main__':
    main()
