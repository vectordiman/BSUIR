from PIL import Image
import plot
from handler import Handler
from handler import brightness
from filter import Filter


def main():
    image = Image.open('assets/in/blur.jpg')
    _brightness = brightness(image)

    # negative_image = Handler(image).negative()
    # negative_brightness = brightness(negative_image)
    # negative_image.save('assets/out/colors-negative.jpg')
    #
    # sobel_image = Filter(image).sobel()
    # sobel_brightness = brightness(sobel_image)
    # sobel_image.save('assets/out/colors-sobel.jpg')

    high_image = Filter(image).high()
    high_brightness = brightness(high_image)
    high_image.save('assets/out/blur-high.jpg')

    image_plot = plot.Plot(image, _brightness)
    image_plot.show('Исходное изображение', 'Яркость исходного изображения', 256)

    high_plot = plot.Plot(high_image, high_brightness)
    high_plot.show('Отфильтрованное изображение', 'Яркость отфильтрованного изображения', 256)

    # negative_plot = plot.Plot(negative_image, negative_brightness)
    # negative_plot.show('Негативное изображение', 'Яркость негативного изображения', 256)
    #
    # sobel_plot = plot.Plot(sobel_image, sobel_brightness)
    # sobel_plot.show('Отфильтрованное изображение', 'Яркость отфильтрованного изображения', 256)


if __name__ == '__main__':
    main()
