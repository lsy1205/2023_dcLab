import numpy as np
p = np.array([(23, 63), (40, 499), (788, 520), (698, 11)])
q = np.array([(0, 0), (0, 99), (99, 99), (99, 0)])

M = np.array([[p[0][0], p[0][1], 1, 0, 0, 0,  0,  0, q[0][0]],
             [p[1][0]-p[0][0], p[1][1]-p[0][1], 0,
                 0, 0, 0,  0,  0, q[1][0]-q[0][0]],
             [p[2][0]-p[0][0], p[2][1]-p[0][1], 0, 0, 0,
                 0, -p[2][0]*99, -p[2][1]*99, q[2][0]-q[0][0]],
             [p[3][0]-p[0][0], p[3][1]-p[0][1], 0, 0, 0,
                 0, -p[3][0]*99, -p[3][1]*99, q[3][0]-q[0][0]],
             [0, 0, 0, p[0][0], p[0][1], 1, 0, 0, q[0][1]],
             [0, 0, 0, p[1][0]-p[0][0], p[1][1]-p[0][1],
                 0, -p[1][0]*99, -p[1][1]*99, q[1][1]-q[0][1]],
             [0, 0, 0, p[2][0]-p[0][0], p[2][1]-p[0][1],
                 0, -p[2][0]*99, -p[2][1]*99, q[2][1]-q[0][1]],
             [0, 0, 0, p[3][0]-p[0][0], p[3][1]-p[0][1], 0, 0, 0, q[3][1]-q[0][1]]
              ], dtype=np.float)

# Q忘記減了
print(M.astype(int))

# 1st
M[1] = M[1] / M[1][1]
M[0] = M[0] - M[1] * M[0][1]
M[2] = M[2] - M[1] * M[2][1]
M[3] = M[3] - M[1] * M[3][1]

M[7] = M[7] / M[7][4]
M[4] = M[4] - M[7] * M[4][4]
M[5] = M[5] - M[7] * M[5][4]
M[6] = M[6] - M[7] * M[6][4]
print(M.astype(int))

# 2nd
M[2] = M[2] / M[2][0]
M[3] = M[3] - M[2] * M[3][0]
M[5] = M[5] / M[5][3]
M[6] = M[6] - M[5] * M[6][3]
print(M.astype(int))

# 3rd
M[6] = M[6] / M[6][6]
M[2] = M[2] - M[6] * M[2][6]
M[3] = M[3] - M[6] * M[3][6]
M[5] = M[5] - M[6] * M[5][6]
print(M.astype(int))

# 4th
M[3] = M[3] / M[3][7]
M[2] = M[2] - M[3] * M[2][7]
M[5] = M[5] - M[3] * M[5][7]
M[6] = M[6] - M[3] * M[6][7]
print(M.astype(int))

# 5th
M[0] = M[0] - M[2]*M[0][0]
M[1] = M[1] - M[2]*M[1][0]
M[4] = M[4] - M[5]*M[4][3]
M[7] = M[7] - M[5]*M[7][3]

print(M.astype(int))
