import cmath
import time
import numpy

counter_dft = 0
counter_fft = 0

time_dft = 0
time_fft = 0


def create_x(length):
    points = []
    for i in range(length):
        # 2 * pi / n - разбиваем на интервалы
        points.append(i * numpy.pi / 32)
    return points


def create_y(points):
    function = []
    for x in points:
        function.append(complex(numpy.sin(2 * x) + numpy.cos(7 * x), x))
    return function


def create_frequency(length):
    frequency = []
    for i in range(-int(length / 2), int(length / 2), 1):
        frequency.append(i)
    return frequency


def create_amplitude(points, length):
    amplitude = []
    for i in range(length):
        amplitude.append(abs(points[i]))
    return amplitude


def create_phase(points, length):
    phase = []
    for i in range(length):
        phase.append(cmath.phase(points[i]))
    return phase


def create_dft(points, length, direction):
    global counter_dft
    global time_dft

    time_dft = time.time()
    n = length
    dft = []

    for m in range(n):
        c = complex(0)

        for k in range(n):
            w = complex(numpy.cos(m * k * 2 * numpy.pi / n), direction * numpy.sin(m * k * 2 * numpy.pi / n))
            c += w * points[k]
            counter_dft += 1

        if direction == -1:
            c /= n

        dft.append(c)

    time_dft = time.time() - time_dft
    return dft


def create_fft(points, direction, correction):
    global time_fft

    time_fft = time.time()
    fft = []
    for i in range(int(len(points))):
        fft.append(complex(points[i]))

    fft = create_recursive_fft(fft, direction, correction)

    time_fft = time.time() - time_fft
    return fft


def create_recursive_fft(points, direction, correction):
    global counter_fft
    n = int(len(points))
    fft_first = []
    fft_second = []
    fft = []

    if n == 1:
        return points

    wn = complex(numpy.cos(2 * numpy.pi / n), direction * numpy.sin(2 * numpy.pi / n))
    w = complex(1, 0)

    for i in range(int(n / 2)):
        fft_first.append(points[i] + points[i + int(n / 2)])
        fft_second.append((points[i] - points[i + int(n / 2)]) * w)
        w = w * wn
        counter_fft += 1

    even = create_recursive_fft(fft_first, direction, correction)
    uneven = create_recursive_fft(fft_second, direction, correction)

    for i in range(int(n / 2)):
        fft.append(even[i])
        fft.append(uneven[i])

    if direction == -1:
        for i in range(n):
            fft[i] /= correction

    return fft
