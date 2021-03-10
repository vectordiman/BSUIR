import fourier
import numpy


def create_x(length):
    points = []
    for i in range(length):
        # 2 * pi / length - разбиваем на интервалы
        points.append(2 * i * numpy.pi / length)
    return points


def create_y(points):
    function = []
    for x in points:
        function.append(numpy.sin(2 * x))
    return function


def create_z(points):
    function = []
    for x in points:
        function.append(numpy.cos(7 * x))
    return function


def get_real(points):
    result = []
    for item in points:
        result.append(item.real)
    return result


def correlation(x_list, y_list, length):
    result = []

    for m in range(length):
        amount = 0
        for h in range(length):
            amount += x_list[h] * y_list[m + h - length]
        amount /= length
        result.append(amount / length)

    return result


def correlation_fft(x_list, y_list, length):
    cx = fourier.create_fft(x_list, 1, 1)
    cy = fourier.create_fft(y_list, 1, 1)
    result = []

    for i in range(length):
        cx[i] = numpy.conjugate(cx[i])
    for i in range(length):
        result.append(cx[i] * cy[i] / length)

    result = fourier.create_fft(result, -1, 4)
    return result


def convolution(x_list, y_list, length):
    result = []

    for m in range(length):
        amount = 0
        for h in range(length):
            amount += x_list[h] * y_list[m - h]
        result.append(amount / length)

    return result


def convolution_fft(x_list, y_list, length):
    cx = fourier.create_fft(x_list, 1, 1)
    cy = fourier.create_fft(y_list, 1, 1)
    result = []

    for i in range(length):
        result.append((cx[i] * cy[i]) / length)

    result = fourier.create_fft(result, -1, 2)
    return result
