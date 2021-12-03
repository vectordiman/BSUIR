import numpy
from PIL import Image


def brightness(image):
    points = numpy.asarray(image)
    result = []
    for line in points:
        for pixel in line:
            result.append(int(0.2989 * pixel[0] + 0.5870 * pixel[1] + 0.1140 * pixel[2]))
    return result


class Handler:
    points: any

    def __init__(self, image):
        self.points = numpy.asarray(image)

    def negative(self):
        result = numpy.copy(self.points)
        size = result.shape
        for i in range(0, size[0]):
            for j in range(0, size[1]):
                for k in range(0, size[2]):
                    result[i][j][k] = 255 - result[i][j][k]
        return Image.fromarray(result)
