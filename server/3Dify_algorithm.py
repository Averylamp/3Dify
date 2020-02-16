import itertools
from collections import defaultdict
import math
import numpy as np
import random
import time

# def point_cloud_distance(cloud_1, cloud_2):
# 	hello = sorted(cloud_1)
# 	return random.random()

times = []
# numVoxels = 40


def choose_y_slice(cloud_1, cloud_2, step_size=4):

	cloud_1 = sorted(cloud_1, key=lambda y: y[4])
	cloud_2 = sorted(cloud_2, key=lambda y: y[4])
	
	low_1 = min([y[4] for y in cloud_1])
	high_1 = max([y[4] for y in cloud_1])
	low_2 = min([y[4] for y in cloud_2])
	high_2 = max([y[4] for y in cloud_2])

	# TODO: figure out what granularity to use if sizes are disproportional
	slice_size = min(high_1 - low_1, high_2 - low_2) / step_size

	min_distance = math.inf

	i = 1
	while i * slice_size < (high_1 - low_1) + (high_2 - low_2):
		included_1 = [p for p in cloud_1 if p[4] < cloud_1[0][4] + i * slice_size]
		included_2 = [p for p in cloud_2 if p[4] > cloud_2[-1][4] - i * slice_size]

		shift_1 = -included_1[0][4]
		shift_2 = -included_2[0][4]
		start = time.time()
		distance_y = point_cloud_distance(translate_x_y(included_1, y_shift=shift_1), translate_x_y(included_2, y_shift=shift_2))
		times.append(time.time() - start)
		
		if distance_y < min_distance:
			min_distance = distance_y

		i += 1
	print('final i:', i)
	return min_distance



def choose_x_slice(cloud_1, cloud_2, step_size=4):
	cloud_1 = sorted(cloud_1, key=lambda x: x[3])
	cloud_2 = sorted(cloud_2, key=lambda x: x[3])

	low_1 = min([x[3] for x in cloud_1])
	high_1 = max([x[3] for x in cloud_1])
	low_2 = min([x[3] for x in cloud_2])
	high_2 = max([x[3] for x in cloud_2])

	# TODO: figure out what granularity to use if sizes are disproportional
	slice_size = min(high_1 - low_1, high_2 - low_2) / step_size

	min_distance = math.inf
	min_shift_1 = math.inf
	min_shift_2 = math.inf

	i = 1
	# print(datetime.now())
	while i * slice_size < (high_1 - low_1) + (high_2 - low_2):
		included_1 = [p for p in cloud_1 if p[3] < cloud_1[0][3] + i * slice_size]
		included_2 = [p for p in cloud_2 if p[3] > cloud_2[-1][3] - i * slice_size]

		shift_1 = -included_1[0][3]
		shift_2 = -included_2[0][3]
		distance_y = choose_y_slice(translate_x_y(included_1, x_shift=shift_1), translate_x_y(included_2, x_shift=shift_2), step_size)
		print('distance_y:', distance_y)

		if distance_y < min_distance:
			min_distance = distance_y
			min_shift_1 = shift_1
			min_shift_2 = shift_2

		i += 1
	print(sum(times))
	print('i:', i)
	print('final_distance:', min_distance)
	return ((min_shift_1, min_distance), (min_shift_2, min_distance))


# NAIVE - Returns the aggregate distance between two point clouds
# O(n^2)
def naive_distance(cloud_1, cloud_2):
	total_distance = 0
	for point in cloud_1:
		smallest = None
		min_cost = math.inf
		for potential in cloud_2:
			current_cost = cost(point, potential)
			if current_cost < min_cost:
				smallest = potential
				min_cost = current_cost
		total_distance += min_cost
	return total_distance

# TODO: adjust weights
# Input: points, represented as (r, g, b, x, y, z)
#        weights to penalize rgb and physical distance differences
#
# Return the cost between two points
# O(1)
def cost(p1, p2, w1=1, w2=1):
	rgb_cost = (p2[0] - p1[0])**2 + (p2[1] - p1[1])**2 + (p2[2] - p1[2])**2
	distance_cost = (p2[3] - p1[3])**2 + (p2[4] - p1[4])**2 + (p2[5] - p1[5])**2
	return w1 * rgb_cost + w2 * distance_cost

# Input: list of points, represented as (r, g, b, x, y, z)
#
# O(n)
def get_x_y_means(points):
	x_mean = np.mean([p[3] for p in points])
	y_mean = np.mean([p[4] for p in points])
	return x_mean, y_mean

# Input: list of points, represented as (r, g, b, x, y, z)
# Return rotated list of points, represented as tuples
#
# O(n)
def rotate_z(points, degrees):
	x_mean, y_mean = get_x_y_means(points)

	# Translate points such that they are centered around z-axis
	translated_points = [(p[0], p[1], p[2], p[3] - x_mean, p[4] - y_mean, p[5]) for p in points]

	# Rotate around z-axis
	rotated_points = [(t[0], t[1], t[2], t[3] * math.cos(math.radians(degrees)) - t[4] * math.sin(math.radians(degrees)), t[3] * math.sin(math.radians(degrees)) + t[4] * math.cos(math.radians(degrees)), t[5]) for t in translated_points]

	# Translate points to un-center
	uncentered_points = [(r[0], r[1], r[2], r[3] + x_mean, r[4] + y_mean, r[5]) for r in rotated_points]
	return uncentered_points

# Return translated list of points
# O(n)
def translate_x_y(points, x_shift=0, y_shift=0):
	return [(p[0], p[1], p[2], p[3] + x_shift, p[4] + y_shift, p[5]) for p in points]


# Decimal step generator
# def drange(start, stop, step):
#     r = start
#     while r < stop:
# 		yield r
# 		r += step

# Return aggregate distance between two point clouds.
# Voxelize 3D space and calculate approximate total distance using the cost function.
def distance_voxelized(cloud_1, cloud_2):
	total_distance = 0
	voxel_x = 1
	voxel_y = 1
	voxel_z = 1
	max_x = numVoxels
	max_y = numVoxels
	max_z = numVoxels
	voxel_map_1 = defaultdict(list)
	voxel_map_2 = defaultdict(list)

	for point in cloud_1:
		voxel_map_1[math.floor(point[3]), math.floor(point[4]), math.floor(point[5])].append(point)
	for point in cloud_2:
		voxel_map_2[math.floor(point[3]), math.floor(point[4]), math.floor(point[5])].append(point)

	for top_corner in voxel_map_1:
		cur_x = top_corner[0]
		cur_y = top_corner[1]
		cur_z = top_corner[2]
		range_x = range(cur_x - voxel_x, cur_x + voxel_x)
		range_y = range(cur_y - voxel_y, cur_y + voxel_y)
		range_z = range(cur_z - voxel_z, cur_z + voxel_z)
		for tx, ty, tz in itertools.product(range_x, range_y, range_z):
			if (tx, ty, tz) in voxel_map_2:
				p1 = voxel_map_1[top_corner][0]
				p2 = voxel_map_2[(tx, ty, tz)][0]
				total_distance += cost(p1, p2)
	return total_distance

def round_nearest(x, a):
    return round(round(x / a) * a, -int(math.floor(math.log10(a))))

def point_cloud_distance(cloud_1, cloud_2, round_val=0.003):
	cloud_dict = {}

	for point in cloud_1:
		index = (round_nearest(point[3], round_val), round_nearest(point[4], round_val), round_nearest(point[5], round_val))
		cloud_dict[index] = (point[0], point[1], point[2])

	total_distance = 0
	for point in cloud_2:
		index = (round_nearest(point[3], round_val), round_nearest(point[4], round_val), round_nearest(point[5], round_val))
		if index in cloud_dict:
			total_distance += (point[0] - cloud_dict[index][0])**2 + (point[1] - cloud_dict[index][1])**2 + (point[2] - cloud_dict[index][2])**2
			break
		found = False
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				for k in [-1, 0, 1]:
					if found: break
					neighbor = (index[0] + i, index[1] + j, index[2] + k)
					if neighbor in cloud_dict:
						total_distance += (point[0] - cloud_dict[neighbor][0])**2 + (point[1] - cloud_dict[neighbor][1])**2 + (point[2] - cloud_dict[neighbor][2])**2
						found = True
		if not found:
			total_distance += 0.5 # arbitrary

	return total_distance



if __name__ == "__main__":

	# points_1 object is left alone, points_2 is rotated and translated
	points_1 = []
	points_2 = []

	# Read in points
	with open("points1.txt", "rb") as fp:
		for i in fp.readlines():
			l = eval(i)
			points_1.append((l[3], l[4], l[5], l[0], l[1], l[2]))
	print('total number of points_1, original:', len(points_1))

	with open("points2.txt", "rb") as fp:
		for i in fp.readlines():
			l = eval(i)
			points_2.append((l[3], l[4], l[5], l[0], l[1], l[2]))
	print('total number of points_2, original:', len(points_2))

	# Amount to sample
	sample_proportion = 0.05
	points_1 = random.sample(points_1, math.floor(len(points_1) * sample_proportion))
	print('sampled number of points_1:', len(points_1))
	points_2 = random.sample(points_2, math.floor(len(points_2) * sample_proportion))
	print('sampled number of points_2:', len(points_2))

	# Rotate 
	rotated_points_2 = rotate_z(points_2, 20)
	choose_x_slice(points_1, rotated_points_2)

    # result1 = []
    # result2 = []
    # with open("points1.txt", "rb") as fp:
    #     for i in fp.readlines():
    #         result1.append(eval(i))
    #         cur = result1[-1]
    #         result1[-1] = (cur[3], cur[4], cur[5], cur[0] * numVoxels, cur[1] * numVoxels, cur[2] * numVoxels)
    # with open("points2.txt", "rb") as fp:
    #     for i in fp.readlines():
    #         result2.append(eval(i))
    #         cur = result2[-1]
    #         result2[-1] = (cur[3], cur[4], cur[5], cur[0] * numVoxels, cur[1] * numVoxels, cur[2] * numVoxels)
    # print(result1[0:10])
    # start_time = time.time()
    # # print(naive_distance(result1, result2))
    # # print("--- %s seconds ---" % (time.time() - start_time))
    # print(distance_voxelized(result1, result2))
    # print(time.time()-start_time)

