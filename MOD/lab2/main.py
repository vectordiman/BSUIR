import sequence
import histogram

if __name__ == '__main__':

    a = int(input('Введите a\n'))
    r = int(input('Введите r\n'))
    m = int(input('Введите m\n'))
    precision = int(input('Введите precision\n'))
    begin = int(input('Введите begin\n'))
    end = int(input('Введите end\n'))

    sequence = sequence.Sequence(a, r, m, precision, begin, end)
    _range = sequence.range()

    range_even = sequence.even(begin, end, _range)
    histogram_even = histogram.Histogram(range_even)
    histogram_even.show(20, "Равномерное распределение", sequence.label(range_even), 'k')

    range_gaussian = sequence.gaussian(_range)
    histogram_gaussian = histogram.Histogram(range_gaussian)
    histogram_gaussian.show(20, "Гауссово распределение", sequence.label(range_gaussian), 'k')

    range_exp = sequence.exp(_range)
    histogram_exp = histogram.Histogram(range_exp)
    histogram_exp.show(20, "Экспоненциальное распределение", sequence.label(range_exp), 'k')

    range_gamma = sequence.gamma(_range)
    histogram_gamma = histogram.Histogram(range_gamma)
    histogram_gamma.show(20, "Гамма-распределение", sequence.label(range_gamma), 'k')

    range_triangle = sequence.triangle(_range)
    histogram_triangle = histogram.Histogram(range_triangle)
    histogram_triangle.show(20, "Треугольное распределение", sequence.label(range_triangle), 'k')

    range_simpson = sequence.simpson(_range)
    histogram_simpson = histogram.Histogram(range_simpson)
    histogram_simpson.show(20, "Распределение Симпсона", sequence.label(range_simpson), 'k')
