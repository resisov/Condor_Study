import random
import math
import sys

N=sys.argv[1]
N = int(N)
n=0

for i in range(N):
	
	x = random.random()
	y = random.random()
	c = math.sqrt(x**2+y**2)

	if c <= 1:
		n+=1


pi = 4*(float(n)/float(N))
print(N ,n)
print("Pi: {:.9f}".format(pi))
