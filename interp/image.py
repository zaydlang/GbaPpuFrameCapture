from PIL import Image
import numpy as np

def draw_gridlines(numpy_image):
    for x in range(0, IMAGE_WIDTH, 4):
        for y in range(0, IMAGE_HEIGHT):
            set_color(numpy_image, x, y, 0)

    for y in range(0, IMAGE_HEIGHT, 4):
        for x in range(0, IMAGE_WIDTH):
            set_color(numpy_image, x, y, 0)

def get_image(numpy_image):
    return Image.fromarray(numpy_image.astype('uint8'), 'RGB')

def set_color(numpy_image, x, y, color):
    numpy_image[y][x][0] = 255

GRID_WIDTH   = 1
ROW_SIZE     = 308
COL_SIZE     = 228
IMAGE_WIDTH  = GRID_WIDTH * (ROW_SIZE + 1) + ROW_SIZE * 4
IMAGE_HEIGHT = GRID_WIDTH * (COL_SIZE + 1) + COL_SIZE * 4

numpy_image = np.zeros((IMAGE_HEIGHT, IMAGE_WIDTH, 3))

draw_gridlines(numpy_image)
set_color(numpy_image, 0, 0, 0)
get_image(numpy_image).show()