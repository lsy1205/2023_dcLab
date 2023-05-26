from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

filename = 'baboon.jpg'

ori_img = Image.open(filename, 'r')
ori_data = np.array(ori_img, dtype=int)
img_h, img_w, _ = ori_data.shape

comp_data = np.zeros((img_h, img_w, 3), dtype=int)
tmp_data = np.zeros((img_h, img_w, 3), dtype=int)

for i in range(img_h):
    for j in range(img_w):
        up_pixel = tmp_data[i-1][j] if i > 0 else np.full((3), 127)
        left_pixel = tmp_data[i][j-1] if j > 0 else np.full((3), 127)
        diff = ori_data[i][j] - ((up_pixel + left_pixel) // 2)
        diff = np.clip(diff, -128, 127)
        comp_data[i][j][0] = diff[0] // 4
        comp_data[i][j][1] = diff[1] // 2
        comp_data[i][j][2] = diff[2] // 4

        diff2 = comp_data[i][j] * 1
        diff2[0] = diff2[0] * 4
        diff2[1] = diff2[1] * 2
        diff2[2] = diff2[2] * 4
        tmp_data[i][j] = diff2 + ((up_pixel + left_pixel) // 2)

recon_data = np.zeros((img_h, img_w, 3), dtype=int)

for i in range(img_h):
    for j in range(img_w):
        up_pixel = recon_data[i-1][j] if i > 0 else np.full((3), 127)
        left_pixel = recon_data[i][j-1] if j > 0 else np.full((3), 127)
        diff = comp_data[i][j]
        diff[0] = diff[0] * 4
        diff[1] = diff[1] * 2
        diff[2] = diff[2] * 4
        recon_data[i][j] = diff + ((up_pixel + left_pixel) // 2)

plt.imshow(np.concatenate((ori_data, recon_data), axis=1))
plt.show()
