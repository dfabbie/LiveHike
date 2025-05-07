from flask import Flask, request, jsonify
from flask_cors import CORS
from db import init_db, execute_db, query_db
import uuid


app = Flask(__name__)
CORS(app)

init_db()

@app.route("/trails", methods=["GET"])
def get_trails():
    trails = query_db("SELECT * FROM trails")
    return jsonify([dict(row) for row in trails])

@app.route("/pins", methods=["GET"])
def get_pins():
    trail_name = request.args.get("trail_name")
    pins = query_db("SELECT * FROM pin_locations WHERE trail_name = ?", [trail_name])
    return jsonify([dict(row) for row in pins])

@app.route("/hazards/<pin_id>", methods=["GET"])
def get_hazard(pin_id):
    row = query_db("SELECT * FROM hazard_pins WHERE pin_location_id = ?", [pin_id], one=True)
    return jsonify(dict(row) if row else {})

@app.route("/wrong_turns/<pin_id>", methods=["GET"])
def get_wrong_turn(pin_id):
    row = query_db("SELECT * FROM wrong_turn_pins WHERE pin_location_id = ?", [pin_id], one=True)
    return jsonify(dict(row) if row else {})

@app.route("/trails", methods=["POST"])
def add_trail():
    data = request.get_json()
    trail_id = data.get("id") or str(uuid.uuid4())
    try:
        execute_db("""
            INSERT INTO trails (id, name, location, difficulty, length, elevation_gain)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            trail_id,
            data["name"],
            data.get("location"),
            data.get("difficulty"),
            data.get("length"),
            data.get("elevation_gain")
        ))
        return jsonify({"status": "success", "trail_id": trail_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/pins", methods=["POST"])
def add_pin():
    data = request.get_json()
    pin_id = data.get("id") or str(uuid.uuid4())
    try:
        execute_db("""
            INSERT INTO pin_locations (
                id, trail_name, type, latitude, longitude, created_by, verified_count, dismissed_count
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            pin_id,
            data["trail_name"],
            data["type"],
            data["latitude"],
            data["longitude"],
            data.get("created_by"),
            data.get("verified_count", 0),
            data.get("dismissed_count", 0)
        ))
        return jsonify({"status": "success", "pin_id": pin_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/hazards", methods=["POST"])
def add_hazard():
    data = request.get_json()
    hazard_id = data.get("id") or str(uuid.uuid4())
    try:
        execute_db("""
            INSERT INTO hazard_pins (
                id, pin_location_id, hazard_type, severity, description, image_url
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            hazard_id,
            data["pin_location_id"],
            data["hazard_type"],
            data.get("severity"),
            data.get("description"),
            data.get("image_url")
        ))
        return jsonify({"status": "success", "hazard_id": hazard_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/wrong_turns", methods=["POST"])
def add_wrong_turn():
    data = request.get_json()
    wrong_turn_id = data.get("id") or str(uuid.uuid4())
    try:
        execute_db("""
            INSERT INTO wrong_turn_pins (
                id, pin_location_id, description, correct_direction_description, image_url, landmarks
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            wrong_turn_id,
            data["pin_location_id"],
            data.get("description"),
            data.get("correct_direction_description"),
            data.get("image_url"),
            data.get("landmarks")
        ))
        return jsonify({"status": "success", "wrong_turn_id": wrong_turn_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True)
