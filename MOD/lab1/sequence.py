import numpy


class Sequence:
    a: any
    r: any
    m: any
    precision: any

    def __init__(self, a, r, m, precision):
        self.a = a
        self.r = r
        self.m = m
        self.precision = precision

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

    def period(self, points):
        result = []
        for i in range(0, len(points)):
            if points[i] == points[-1]:
                result.append(i)
        return result[1] - result[0]

    def aperiodicity(self, points, period):
        i3 = 0
        while points[i3] != points[i3 + period]:
            i3 += 1
        return period + i3

    def indirect(self, points):
        index = 0
        for i in range(0, self.precision, 2):
            if i < (len(points) - 1) and points[i]**2 + points[i + 1]**2 < 1:
                index += 1
        return 2 * index / self.precision
