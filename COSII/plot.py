import matplotlib.pyplot


class Plot:
    image: any
    brightness: any

    def __init__(self, image, brightness):
        self.image = image
        self.brightness = brightness

    def show(self, title1, title2, bins):
        fig, (ax1, ax2) = matplotlib.pyplot.subplots(1, 2)
        fig.set_figwidth(15)
        fig.set_figheight(6)

        ax1.imshow(self.image)
        ax1.set(title=title1)
        ax1.grid(False)

        ax2.hist(self.brightness, bins, color='k')
        ax2.set(title=title2)
        ax2.grid(False)

        matplotlib.pyplot.show()
