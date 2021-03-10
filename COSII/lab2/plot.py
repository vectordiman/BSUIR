import matplotlib.pyplot


def create_plot(x_list, y_list, title):
    fig, (ax) = matplotlib.pyplot.subplots(1, 1)

    ax.plot(x_list, y_list)
    ax.set(title=title)
    ax.grid()

    matplotlib.pyplot.show()

