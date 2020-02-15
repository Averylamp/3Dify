from flask import Flask, request
app = Flask(__name__)

@app.route("/")
def root():
    return "3dify"

@app.route("/upload/photo", methods=["POST"])
def process_photo():
    print(request.json)
    return {"TODO": 0}

if __name__ == "__main__":
    app.run()
