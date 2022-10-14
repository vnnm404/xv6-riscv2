from cProfile import label
from matplotlib import legend
import matplotlib.pyplot as plt

p = []
for i in range(3, 9):
  with open(f'p{i}.txt') as f:
    p.append(list(map(int, f.read().split(','))))

# print(p)
for i in range(5):
  plt.plot(p[i])

plt.legend(['p3', 'p4', 'p5', 'p6', 'p7'])
plt.xlabel('Ticks')
plt.ylabel('Priority')
plt.show()