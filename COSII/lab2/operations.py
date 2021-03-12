import time
import fourier
import numpy

counter_correlation = 0
counter_correlation_fft = 0
counter_convolution = 0
counter_convolution_fft = 0

time_correlation = 0.0
time_correlation_fft = 0.0
time_convolution = 0.0
time_convolution_fft = 0.0


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
    global time_correlation
    global counter_correlation

    time_correlation = time.time()
    result = []

    for m in range(length):
        amount = 0
        for h in range(length):
            amount += x_list[h] * y_list[m + h - length]
            counter_correlation += 2
        amount /= length
        result.append(amount / length)
        counter_correlation += 2

    time_correlation = time.time() - time_correlation
    return result


def correlation_fft(x_list, y_list, length):
    global time_correlation_fft
    global counter_correlation_fft

    time_correlation_fft = time.time()
    fourier.counter_fft = 0

    cx = fourier.create_fft(x_list, 1, 1)
    cy = fourier.create_fft(y_list, 1, 1)
    result = []

    for i in range(length):
        cx[i] = numpy.conjugate(cx[i])
        counter_correlation_fft += 1
    for i in range(length):
        result.append(cx[i] * cy[i] / length)
        counter_correlation_fft += 2

    result = fourier.create_fft(result, -1, 4)
    counter_correlation_fft += fourier.counter_fft
    time_correlation_fft = time.time() - time_correlation_fft
    return result


def convolution(x_list, y_list, length):
    global time_convolution
    global counter_convolution

    time_convolution = time.time()
    result = []

    for m in range(length):
        amount = 0
        for h in range(length):
            amount += x_list[h] * y_list[m - h]
            counter_convolution += 2
        result.append(amount / length)
        counter_convolution += 1

    time_convolution = time.time() - time_convolution
    return result


def convolution_fft(x_list, y_list, length):
    global time_convolution_fft
    global counter_convolution_fft

    time_convolution_fft = time.time()
    fourier.counter_fft = 0

    cx = fourier.create_fft(x_list, 1, 1)
    cy = fourier.create_fft(y_list, 1, 1)
    result = []

    for i in range(length):
        result.append((cx[i] * cy[i]) / length)
        counter_convolution_fft += 2

    result = fourier.create_fft(result, -1, 2)
    counter_convolution_fft += fourier.counter_fft
    time_convolution_fft = time.time() - time_convolution_fft
    return result
