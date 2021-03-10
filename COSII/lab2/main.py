import operations
import plot


def main():
    number = 16
    x_list = operations.create_x(number)
    y_list = operations.create_y(x_list)
    z_list = operations.create_z(x_list)

    correlation_list = operations.correlation(y_list, z_list, number)
    correlation_fft_list = operations.correlation_fft(y_list, z_list, number)

    convolution_list = operations.convolution(y_list, z_list, number)
    convolution_fft_list = operations.convolution_fft(y_list, z_list, number)

    plot.create_plot(x_list, y_list, 'Функция y = sin(2x)')
    plot.create_plot(x_list, z_list, 'Функция z = cos(7x)')

    plot.create_plot(x_list, correlation_list, 'Корреляции')
    plot.create_plot(x_list, correlation_fft_list, 'Корреляции БПФ')

    plot.create_plot(x_list, convolution_list, 'Свертка')
    plot.create_plot(x_list, convolution_fft_list, 'Свертка БПФ')


if __name__ == '__main__':
    main()
