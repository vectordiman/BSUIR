import cmath
import time
import numpy

counter_dft = 0
counter_fft = 0

time_dft = 0
time_fft = 0


def swap(first, second):
    temp = first
    first = second
    second = temp
    return first, second


def create_x(length):
    points = []
    for i in range(length):
        points.append(i * numpy.pi / 6)
    return points


def create_y(points):
    function = []
    for x in points:
        function.append(numpy.sin(2 * x) + numpy.cos(7 * x))
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


def create_phase_fft(points, length):
    phase = []
    for i in range(length):
        phase.append(cmath.phase(reflection(points)[i]))
    return phase


def reflection(points):
    length = len(points)
    first_part = []
    second_part = []

    i = int(length / 2)
    while i < length:
        first_part.append(points[i])
        i += 1

    for i in range(int(length / 2)):
        second_part.append(points[i])

    first_part.reverse()
    second_part.reverse()
    result = first_part + second_part
    return result


def create_dft(points, length, direction):
    global counter_dft
    global time_dft

    time_dft = time.time()
    n = length
    dft = []

    for m in range(n):
        c = complex(0)
        w = (m / n) * -2j * cmath.pi

        for k in range(n):
            c += cmath.exp(direction * w * k) * points[k]
            counter_dft += 3

        if direction == -1:
            c /= n

        dft.append(c)

    time_dft = time.time() - time_dft
    return dft


def create_fft(points, direction):
    global time_fft

    time_fft = time.time()
    fft = []
    for i in range(int(len(points))):
        fft.append(complex(points[i]))

    fft = create_recursive_fft(fft, direction)

    time_fft = time.time() - time_fft
    return fft


def create_recursive_fft(points, direction):
    global counter_fft
    n = int(len(points))
    even = []
    uneven = []
    fft_first = []
    fft_second = []

    if n == 1:
        return points

    for i in range(n):
        if i % 2 == 0:
            even.append(points[i])
        else:
            uneven.append(points[i])

    even_new = create_recursive_fft(even, direction)
    uneven_new = create_recursive_fft(uneven, direction)

    wn = complex(numpy.cos(2 * numpy.pi / n), direction * numpy.sin(2 * numpy.pi / n))
    w = complex(1, 0)

    for i in range(int(n / 2)):
        fft_first.append(even_new[i] + uneven_new[i] * w)
        fft_second.append(even_new[i] - uneven_new[i] * w)
        w = w * wn
        counter_fft += 3

    fft = fft_first + fft_second

    if direction == -1:
        for i in range(n):
            fft[i] /= 2

    return fft
