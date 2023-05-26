from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

filename = 'baboon.jpg'

ori_img = Image.open(filename, 'r')
ori_data = np.array(ori_img, dtype=np.uint8)
img_h, img_w, _ = ori_data.shape

comp_data = np.zeros((img_h, img_w, 3), dtype=np.uint8)

for i in img_h:
    for j in img_w:
        up_pixel = comp_data[i-1][j] if i > 0 else np.full((3), 127)
        left_pixel = comp_data[i][j-1] if j > 0 else np.full((3), 127)
        diff = ori_data[i][j] - ((up_pixel + left_pixel) >> 1)
        comp_data[i][j][0] = (diff[0] % 128) >> 2
        comp_data[i][j][1] = (diff[0] % 128) >> 1
        comp_data[i][j][2] = (diff[0] % 128) >> 2

recon_data = np.zeros((img_h, img_w, 3), dtype=np.uint8)

for i in img_h:
    for j in img_w:
        up_pixel = recon_data[i-1][j] if i > 0 else np.full((3), 127)
        left_pixel = recon_data[i][j-1] if j > 0 else np.full((3), 127)
        diff = comp_data[i][j]
        diff[0] = diff[0] << 2
        diff[1] = diff[1] << 1
        diff[2] = diff[2] << 2
        recon_data[i][j] = diff + ((up_pixel + left_pixel) >> 1)

plt.imshow(np.concatenate((ori_data, recon_data), axis=1))
plt.show()
