import matplotlib.pyplot


class Histogram:
    points: any

    def __init__(self, points):
        self.points = points

    def show(self, bins, title, color):
        matplotlib.pyplot.hist(self.points, bins, color=color)
        matplotlib.pyplot.title(title)
        matplotlib.pyplot.grid()

        matplotlib.pyplot.show()
