import fourier
import plot


def main():
    number = 64
    x_list = fourier.create_x(number)
    y_list = fourier.create_y(x_list)
    frequency_list = fourier.create_frequency(number)

    y_list_fft = fourier.create_fft(y_list, 1)
    y_list_fft_reverse = fourier.create_fft(y_list_fft, -1)

    y_list_dft = fourier.create_dft(y_list, number, 1)
    y_list_dft_reverse = fourier.create_dft(y_list_dft, number, -1)

    amplitude_list_fft = fourier.create_amplitude(y_list_fft, number)
    amplitude_list_dft = fourier.create_amplitude(y_list_dft, number)
    phase_list_fft = fourier.create_phase(y_list_fft, number)
    phase_list_dft = fourier.create_phase(y_list_dft, number)

    plot.create_plot(x_list, y_list, 'График функции')

    plot.create_plot(frequency_list, phase_list_dft, 'График фазового спектра (ДПФ)')
    plot.create_plot(frequency_list, amplitude_list_dft, 'График амплитудного спектра (ДПФ)')
    plot.create_plot(x_list, y_list_dft_reverse, 'Обратный график (ДПФ)')

    plot.create_plot(frequency_list, phase_list_fft, 'График фазового спектра (БПФ)')
    plot.create_plot(frequency_list, amplitude_list_fft, 'График амплитудного спектра (БПФ)')
    plot.create_plot(x_list, y_list_fft_reverse, 'Обратный график (БПФ)')

    # Деление на 2, так как функции вызывались дважды
    print('Количество умножений (ДПФ): ' + str(int(fourier.counter_dft / 2)))
    print('Количество умножений (БПФ): ' + str(int(fourier.counter_fft / 2)))

    print('Время формирования (ДПФ): ' + str(fourier.time_dft))
    print('Время формирования (БПФ): ' + str(fourier.time_fft))


if __name__ == '__main__':
    main()
