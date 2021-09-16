import matplotlib.pyplot


class Histogram:
    points: any

    def __init__(self, points):
        self.points = points

    def show(self, bins, title, info, color):
        matplotlib.pyplot.figure(figsize=(8, 8))
        matplotlib.pyplot.hist(self.points, bins, color=color)
        matplotlib.pyplot.title(title)
        matplotlib.pyplot.xlabel(info, labelpad=5)
        matplotlib.pyplot.grid()

        matplotlib.pyplot.show()
