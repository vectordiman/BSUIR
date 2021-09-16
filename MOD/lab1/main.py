import sequence
import histogram

if __name__ == '__main__':

    a = int(input('Введите a\n'))
    r = int(input('Введите r\n'))
    m = int(input('Введите m\n'))
    precision = int(input('Введите precision\n'))

    sequence = sequence.Sequence(a, r, m, precision)
    _range = sequence.range()

    histogram = histogram.Histogram(_range)
    histogram.show(20, "Выборка", 'k')

    print(f'Математическое ожидание = {sequence.mean(_range)}')
    print(f'Дисперсия = {sequence.var(_range)}')
    print(f'Среднее квадратичное отклонение = {sequence.std(_range)}')
    print(f'Косвенные признаки = {sequence.indirect(_range)}')
    print(f'Период = {sequence.period(_range)}')
    print(f'Апериодичность = {sequence.aperiodicity(_range, sequence.period(_range))}')

