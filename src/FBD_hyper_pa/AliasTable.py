import numpy as np
import random

class AliasTable:
    def __init__(self, values, weigts):
        self.values = values
        self.accept = np.array(weigts, dtype=float) / sum(weigts) * len(values)
        self.alias = np.zeros(len(values), dtype=int)

        small = []
        large = []
        for i, prob in enumerate(self.accept):
            if prob < 1:
                small.append(i)
            else:
                large.append(i)

        while small and large:
            s, l = small.pop(), large.pop()
            self.alias[s] = l
            self.accept[l] -= 1 - self.accept[s]
            if self.accept[l] < 1:
                small.append(l)
            else:
                large.append(l)

        while large:
            self.alias[large.pop()] = large[0]

        while small:
            self.alias[small.pop()] = small[0]

    def sample(self):
        idx = random.randint(0, len(self.values) - 1)
        if random.random() < self.accept[idx]:
            return self.values[idx]
        else:
            return self.values[self.alias[idx]]

if __name__ == '__main__':
    values = [1, 7, 2, 9]
    weights = [1, 2, 3, 10]
    table = AliasTable(values, weights)
    print(table.sample())
