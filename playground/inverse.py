import numpy as np

factor = 8192

mask = np.array([[1,1,1,0,0,0,1,1,1],
                 [1,1,0,0,0,0,1,1,1],
                 [1,1,0,0,0,0,1,1,1],
                 [1,1,0,0,0,0,1,1,1],
                 [0,0,0,1,1,1,1,1,1],
                 [0,0,0,1,1,0,1,1,1],
                 [0,0,0,1,1,0,1,1,1],
                 [0,0,0,1,1,0,1,1,1],])

# p = np.array([(200,3), (23, 45), (40, 250), (250, 180)])
p = np.array([(23, 63), (40, 499), (788, 520), (698, 11)])
# p_temp = np.array([(200, 3, 1), (23, 45, 1), (40, 250, 1), (250, 180, 1)])
p_temp = np.array([(23, 63, 1), (40, 499, 1), (788, 520, 1), (698, 11, 1)])
q = np.array([(0, 0), (0, 99), (99, 99), (99, 0)])

M = np.array([[        p[0][0],         p[0][1], 1, 0, 0, 0,           0,           0,         q[0][0]],
              [p[1][0]-p[0][0], p[1][1]-p[0][1], 0, 0, 0, 0,           0,           0, q[1][0]-q[0][0]],
              [p[2][0]-p[0][0], p[2][1]-p[0][1], 0, 0, 0, 0, -p[2][0]*99, -p[2][1]*99, q[2][0]-q[0][0]],
              [p[3][0]-p[0][0], p[3][1]-p[0][1], 0, 0, 0, 0, -p[3][0]*99, -p[3][1]*99, q[3][0]-q[0][0]],
              [0, 0, 0,         p[0][0],         p[0][1], 1,           0,           0,         q[0][1]],
              [0, 0, 0, p[1][0]-p[0][0], p[1][1]-p[0][1], 0, -p[1][0]*99, -p[1][1]*99, q[1][1]-q[0][1]],
              [0, 0, 0, p[2][0]-p[0][0], p[2][1]-p[0][1], 0, -p[2][0]*99, -p[2][1]*99, q[2][1]-q[0][1]],
              [0, 0, 0, p[3][0]-p[0][0], p[3][1]-p[0][1], 0,           0,           0, q[3][1]-q[0][1]]],
              dtype=np.longlong)

M *= mask
M *= factor

print((M//factor).astype(int))

# 1st
M[1] = M[1] * factor // M[1][1]
M[0] = M[0] - M[1] * M[0][1] // factor
M[2] = M[2] - M[1] * M[2][1] // factor
M[3] = M[3] - M[1] * M[3][1] // factor
mask[0][1] = mask[2][1] = mask[3][1] = 0

M[7] = M[7] * factor // M[7][4]
M[4] = M[4] - M[7] * M[4][4] // factor
M[5] = M[5] - M[7] * M[5][4] // factor
M[6] = M[6] - M[7] * M[6][4] // factor
mask[4][4] = mask[5][4] = mask[6][4] = 0
M *= mask
# print((M//factor).astype(int))

# 2nd
M[2] = (M[2] * factor) // M[2][0]
M[3] = M[3] - M[2] * M[3][0] // factor
M[5] = M[5] * factor // M[5][3]
M[6] = M[6] - M[5] * M[6][3] // factor
mask[3][0] = mask[6][3] = 0
M *= mask
# print((M//factor).astype(int),)

# 3rd
M[6] = M[6] * factor // M[6][6]
M[2] = M[2] - M[6] * M[2][6] // factor
M[3] = M[3] - M[6] * M[3][6] // factor
M[5] = M[5] - M[6] * M[5][6] // factor
mask[2][6] = mask[3][6] = mask[5][6] = 0
M *= mask
# print((M//factor).astype(int))

# 4th
M[3] = M[3] * factor // M[3][7]
M[2] = M[2] - M[3] * M[2][7] // factor
M[5] = M[5] - M[3] * M[5][7] // factor
M[6] = M[6] - M[3] * M[6][7] // factor
mask[2][7] = mask[5][7] = mask[6][7] = 0
M *= mask
# print((M//factor).astype(int))

# 5th
M[0] = M[0] - M[2] * M[0][0] // factor
M[1] = M[1] - M[2] * M[1][0] // factor
M[4] = M[4] - M[5] * M[4][3] // factor
M[7] = M[7] - M[5] * M[7][3] // factor
mask[0][0] = mask[1][0] = mask[4][3] = mask[7][3] = 0

M *= mask
print(M.astype(int))

T = np.array([[M[2][8], M[1][8], M[0][8]],
              [M[5][8], M[7][8], M[4][8]],
              [M[6][8], M[3][8],  factor]],
              dtype=np.longlong)

print(T.astype(int))
print((T // factor).astype(int))
q1 = (T @ p_temp[0])
q2 = (T @ p_temp[1])
q3 = (T @ p_temp[2])
q4 = (T @ p_temp[3])

print(q1 // q1[2])
print(q2 // q2[2])
print(q3 // q3[2])
print(q4 // q4[2])