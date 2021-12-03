import numpy
from PIL import Image


class Filter:
    points: any

    def __init__(self, image):
        self.points = numpy.asarray(image)

    def sobel(self):
        result = numpy.copy(self.points)
        size = result.shape
        for i in range(1, size[0] - 1):
            for j in range(1, size[1] - 1):
                for k in range(0, size[2]):
                    p = (self.points[i - 1][j - 1][k] + 2 * self.points[i][j - 1][k] + self.points[i + 1][j - 1][k]) - (
                            self.points[i - 1][j + 1][k] + 2 * self.points[i][j + 1][k] + self.points[i + 1][j + 1][k])
                    q = (self.points[i - 1][j - 1][k] + 2 * self.points[i - 1][j][k] + self.points[i - 1][j + 1][k]) - (
                            self.points[i + 1][j - 1][k] + 2 * self.points[i + 1][j][k] + self.points[i + 1][j + 1][k])
                    result[i][j][k] = min(255, numpy.sqrt(p ** 2 + q ** 2))
        return Image.fromarray(result)

    def high(self):
        result = numpy.copy(self.points)
        size = result.shape
        for i in range(1, size[0] - 1):
            for j in range(1, size[1] - 1):
                for k in range(0, size[2]):
                    H = (self.points[i][j][k] * 9) - (
                                self.points[i - 1][j - 1][k] + self.points[i - 1][j][k] + self.points[i - 1][j + 1][k] + self.points[i][j - 1][k] + self.points[i][j + 1][k] +
                                self.points[i + 1][j - 1][k] + self.points[i + 1][j][k] + self.points[i + 1][j + 1][k])
                    result[i][j][k] = min(255, max(0, 0.1 * H))
        return Image.fromarray(result)
