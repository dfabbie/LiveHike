import os
from db import init_db, execute_db
import uuid

if os.path.exists("livehike.db"):
    os.remove("livehike.db")

init_db()

trails = [
    {
        "id": "big_c_trail",
        "name": "Big C Trail",
        "location": "Berkeley, CA",
        "difficulty": "Moderate",
        "length": 1.5,
        "elevation_gain": 250
    },
    {
        "id": "fire_trail",
        "name": "Strawberry Canyon Fire Trail",
        "location": "Berkeley, CA",
        "difficulty": "Easy",
        "length": 3.0,
        "elevation_gain": 400
    },
    {
        "id": "panoramic_trail",
        "name": "Panoramic Hill Trail",
        "location": "Berkeley, CA",
        "difficulty": "Hard",
        "length": 4.2,
        "elevation_gain": 600
    }
]

for t in trails:
    execute_db("""
        INSERT OR REPLACE INTO trails (id, name, location, difficulty, length, elevation_gain)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (t["id"], t["name"], t["location"], t["difficulty"], t["length"], t["elevation_gain"]))

sample_pins = [
    {
        "trail": "Big C Trail",
        "type": "Hazard",
        "lat": 37.8751,
        "lon": -122.2431,
        "created_by": "alice",
        "hazard_type": "Fallen Tree",
        "severity": "High",
        "description": "Large tree blocking main path",
        "image_url": None
    },
    {
        "trail": "Strawberry Canyon Fire Trail",
        "type": "Wrong Turn",
        "lat": 37.8763,
        "lon": -122.2442,
        "created_by": "bob",
        "description": "Trail split with no sign, many go the wrong way",
        "correct_direction_description": "Stick to the left where the trail is wider",
        "image_url": None,
        "landmarks": "Large bush, erosion marker"
    },
    {
        "trail": "Panoramic Hill Trail",
        "type": "Hazard",
        "lat": 37.8730,
        "lon": -122.2452,
        "created_by": "carol",
        "hazard_type": "Loose Rocks",
        "severity": "Medium",
        "description": "Rockslide area near the switchbacks",
        "image_url": None
    },
    {
        "trail": "Panoramic Hill Trail",
        "type": "Wrong Turn",
        "lat": 37.8744,
        "lon": -122.2465,
        "created_by": "dave",
        "description": "Fork that leads down to residential area",
        "correct_direction_description": "Stay on the uphill trail toward the eucalyptus grove",
        "image_url": None,
        "landmarks": "Wooden fence, sharp bend"
    }
]

for pin in sample_pins:
    pin_id = str(uuid.uuid4())
    execute_db("""
        INSERT INTO pin_locations (
            id, trail_name, type, latitude, longitude, created_by
        ) VALUES (?, ?, ?, ?, ?, ?)
    """, (
        pin_id,
        pin["trail"],
        pin["type"],
        pin["lat"],
        pin["lon"],
        pin["created_by"]
    ))

    if pin["type"] == "Hazard":
        execute_db("""
            INSERT INTO hazard_pins (
                id, pin_location_id, hazard_type, severity, description, image_url
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            str(uuid.uuid4()),
            pin_id,
            pin["hazard_type"],
            pin["severity"],
            pin["description"],
            pin["image_url"]
        ))

    elif pin["type"] == "Wrong Turn":
        execute_db("""
            INSERT INTO wrong_turn_pins (
                id, pin_location_id, description, correct_direction_description, image_url, landmarks
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            str(uuid.uuid4()),
            pin_id,
            pin["description"],
            pin["correct_direction_description"],
            pin["image_url"],
            pin["landmarks"]
        ))

print("Database reset and seeded with Swift-aligned demo data.")
