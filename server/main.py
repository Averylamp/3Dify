from flask import Flask, request
from Dify_algorithm import rotate_z, choose_x_slice
import json
app = Flask(__name__)

@app.route("/")
def root():
    return "3dify"

@app.route("/ping")
def ping():
    return "pong"

def convert_points(points):
    for i in range(0, len(points)):
        points[i] = (points[i][3], points[i][4], points[i][5], points[i][0], points[i][1], points[i][2])


@app.route("/upload/photo", methods=["POST"])
def process_photo():
    input_data = request.data
    print(input_data)
    input_data = json.loads(input_data)
    # Example input data:
    # {0: [(r,g,b,x,y,z), (r,g,b,x,y,z)],
    #  1: [(r,g,b,x,y,z)]}
    points_1 = input_data["0"]
    points_2 = input_data["1"]

    # Amount to sample
    # sample_proportion = 0.05
    # points_1 = random.sample(points_1, math.floor(len(points_1) * sample_proportion))
    # print('sampled number of points_1:', len(points_1))
    # points_2 = random.sample(points_2, math.floor(len(points_2) * sample_proportion))
    # print('sampled number of points_2:', len(points_2))

    # Rotate 
    # Note: Assume user has rotated correctly.
    rotated_points_2 = rotate_z(points_2, 20)

    result = choose_x_slice(points_1, rotated_points_2)

    return {"0": (result[1], result[2]), "1": (result[3], result[4])}

if __name__ == "__main__":
    app.run(host="0.0.0.0")
