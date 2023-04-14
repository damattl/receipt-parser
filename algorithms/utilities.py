from matplotlib import pyplot as plt
import cv2


def compareImages(original: object, edited: object):
    plt.figure(figsize=(10, 30))
    plt.subplot(121), plt.imshow(original, cmap='gray')
    plt.title('Original Image'), plt.xticks([]), plt.yticks([])
    plt.subplot(122), plt.imshow(edited, cmap='gray')
    plt.title('Edited Image'), plt.xticks([]), plt.yticks([])
    plt.show()


def resize(image, ratio):
    width = int(image.shape[1] * ratio)
    height = int(image.shape[0] * ratio)
    dim = (width, height)
    return cv2.resize(image, dim, interpolation=cv2.INTER_AREA)
