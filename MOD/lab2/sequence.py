import numpy


class Sequence:
    a: any
    r: any
    m: any
    precision: any
    begin: any
    end: any

    def __init__(self, a, r, m, precision, begin, end):
        self.a = a
        self.r = r
        self.m = m
        self.precision = precision
        self.begin = begin
        self.end = end

    def lehmer(self):
        self.r = ((self.a * self.r) % self.m)
        return self.r

    def range(self):
        result = []
        for i in range(self.precision):
            result.append(self.lehmer() / self.m)
        return result

    def mean(self, points):
        return numpy.mean(points)

    def var(self, points):
        return numpy.var(points)

    def std(self, points):
        return numpy.std(points)

    def label(self, points):
        return f'Математическое ожидание = {self.mean(points)}\n Дисперсия = {self.var(points)}\n Среднее ' \
               f'квадратичное отклонение = {self.std(points)}'

    def even(self, begin, end, points):
        result = []
        for i in range(len(points) - 1):
            result.append(begin + (end - begin) * points[i])
        return result

    def gaussian(self, points):
        result = []
        for i in range(0, len(points) - 1, 6):
            amount = 0
            for j in range(6):
                if j + i < len(points) - 1:
                    amount += points[j + i]
            amount -= 3
            result.append(self.begin + self.end * numpy.sqrt(2) * amount)
        return result

    def exp(self, points):
        result = []
        for i in range(len(points) - 1):
            result.append((-1 / self.begin) * numpy.log(points[i]))
        return result

    def gamma(self, points):
        result = []
        for i in range(0, len(points) - 1, self.end):
            amount = points[i]
            for j in range(1, self.end):
                if j + i < len(points) - 1:
                    amount *= points[j + i]
            result.append((-1 / self.begin) * numpy.log(amount))
        return result

    def triangle(self, points):
        result = []
        for i in range(0, len(points) - 2, 2):
            result.append(self.begin + (self.end - self.begin) * max(points[i], points[i + 1]))
        return result

    def simpson(self, points):
        result = []
        for i in range(0, len(points) - 2, 2):
            result.append(self.begin / 2 + (self.end / 2 - self.begin / 2) * points[i] + self.begin / 2 + (self.end / 2 - self.begin / 2) * points[i + 1])
        return result
