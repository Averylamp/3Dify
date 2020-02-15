import math
import numpy as np


# Returns the aggregate distance between two point clouds
# O(n^2)
def distance(cloud_1, cloud_2):
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

