from WBTree import WBT


class Pair:
    def __init__(self, key, val=None):
        self.key = key
        self.val = val

    def __le__(self, other):
        return self.key <= other.key

    def __lt__(self, other):
        return self.key < other.key

    def __ne__(self, other):
        return self.key != other.key


class HashMap:
    def __init__(self, size):
        self.size = size
        self.arr = [None for _ in range(size)]

    def hash(self, key):
        h = 0
        x = 33
        for ch in key:
            h *= x
            h += ord(ch)
        return h % self.size

    def insert(self, pair):
        index = self.hash(pair.key)
        if self.arr[index] is None:
            self.arr[index] = WBT()
        self.arr[index].insert(pair)

    def search(self, key):
        index = self.hash(key)
        if self.arr[index] is None:
            return
        node = self.arr[index].search(Pair(key))
        if node is None:
            return
        return node.val
