import math
import numpy as np
import itertools
from collections import defaultdict



def point_cloud_distance(cloud_1, cloud_2):
	raise('Point cloud distance is not yet implemented.')

def choose_y_slice(cloud_1, cloud_2, step_size=4):
	cloud_1 = sorted(cloud_1, key=lambda y: y[4])
	cloud_2 = sorted(cloud_2, key=lambda y: y[4])

	low_1 = min(cloud_1, key=lambda y: y[4])
	high_1 = max(cloud_1, key=lambda y: y[4])
	low_2 = min(cloud_2, key=lambda y: y[4])
	high_2 = max(cloud_2, key=lambda y: y[4])

	# TODO: figure out what granularity to use if sizes are disproportional
	slice_size = min(high_1 - low_1, high_2 - low_2) / step_size

	min_distance = math.inf

	i = 1
	while i * slice_size < (high_1 - low_1) + (high_2 - low_2):
		included_1 = [p for p in cloud_1 if p[4] < cloud_1[0][4] + i * slice_size]
		included_2 = [p for p in cloud_2 if p[4] > cloud_2[-1][4] - i * slice_size]

		shift_1 = -included_1[0][4]
		shift_2 = -included_2[0][4]
		distance_y = point_cloud_distance(translate_x_y(included_1, y_shift=shift_1), translate_x_y(included_2, y_shift=shift_2))

		if distance_y < min_distance:
			min_distance = distance_y

		i += 1

	return min_distance



def choose_x_slice(cloud_1, cloud_2, step_size=4):
	cloud_1 = sorted(cloud_1, key=lambda x: x[3])
	cloud_2 = sorted(cloud_2, key=lambda x: x[3])

	low_1 = min(cloud_1, key=lambda x: x[3])
	high_1 = max(cloud_1, key=lambda x: x[3])
	low_2 = min(cloud_2, key=lambda x: x[3])
	high_2 = max(cloud_2, key=lambda x: x[3])

	# TODO: figure out what granularity to use if sizes are disproportional
	slice_size = min(high_1 - low_1, high_2 - low_2) / step_size

	min_distance = math.inf

	i = 1
	while i * slice_size < (high_1 - low_1) + (high_2 - low_2):
		included_1 = [p for p in cloud_1 if p[3] < cloud_1[0][3] + i * slice_size]
		included_2 = [p for p in cloud_2 if p[3] > cloud_2[-1][3] - i * slice_size]

		shift_1 = -included_1[0][3]
		shift_2 = -included_2[0][3]
		distance_y = choose_y_slice(translate_x_y(included_1, x_shift=shift_1), translate_x_y(included_2, x_shift=shift_2), step_size)

		if distance_y < min_distance:
			min_distance = distance_y

		i += 1

	return min_distance


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
	max_x = 1000
	max_y = 1000
	max_z = 1000
	voxel_map_1 = defaultdict(list)
	voxel_map_2 = defaultdict(list)

	for point in cloud_1:
		voxel_map_1[math.floor(point[3]), math.floor(point[4]), math.floor(point[5])] = point
	for point in cloud_2:
		voxel_map_2[math.floor(point[3]), math.floor(point[4]), math.floor(point[5])] = point

	for top_corner in voxel_map_1:
		cur_x = top_corner[0]
		cur_y = top_corner[1]
		cur_z = top_corner[2]
		range_x = range(cur_x - voxel_x, cur_x + voxel_x)
		range_y = range(cur_y - voxel_y, cur_y + voxel_y)
		range_z = range(cur_z - voxel_z, cur_z + voxel_z)
		for tx, ty, tz in itertools.product(range_x, range_y, range_z):
			for point1 in voxel_map_1[top_corner]:
				if (tx, ty, tz) in voxel_map_2:
					total_distance += sum([cost(point1, point2) for point2 in voxel_map_2[(tx, ty, tz)]])
	return total_distance

if __name__ == "__main__":
	result = []
	with open("points1.txt", "rb") as fp:
		for i in fp.readlines():
			result.append(eval(i))
	print(result[0:10])
