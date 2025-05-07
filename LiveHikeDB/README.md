LiveHike Local Database (Flask + SQLite)
========================================

This project provides a local Flask + SQLite backend for the LiveHike iOS app. It allows you to store and retrieve trail information, hazard pins, and wrong turn pins using HTTP requests.

Setup Instructions
------------------

1. Navigate to the backend directory:

    cd livehike-backend

2. Create a Python virtual environment:

    python3 -m venv venv
    source venv\Scripts\activate         

3. Install dependencies:

    pip install -r requirements.txt

4. Start the Flask server (this must be done before running the seed script):

    python app.py

5. Seed the database (optional):

    python seed.py

    Note: This will delete the existing `livehike.db` file and recreate the database with demo data.

HTTP Endpoints
--------------

GET /trails  
Returns all trails in the database.

    curl http://127.0.0.1:5000/trails

GET /pins?trail_name=<trail_name>  
Returns all pins associated with a given trail.

    curl "http://127.0.0.1:5000/pins?trail_name=Big%20C%20Trail"

GET /hazards/<pin_id>  
Returns detailed info for a specific hazard pin.

    curl http://127.0.0.1:5000/hazards/<pin_id>

GET /wrong_turns/<pin_id>  
Returns detailed info for a specific wrong turn pin.

    curl http://127.0.0.1:5000/wrong_turns/<pin_id>

POST /trails  
Adds a new trail.

    curl -X POST http://127.0.0.1:5000/trails -H "Content-Type: application/json" -d '{
      "name": "New Trail",
      "location": "Berkeley, CA",
      "difficulty": "Easy",
      "length": 1.2,
      "elevation_gain": 150
    }'

POST /pins  
Adds a new pin to a trail.

    curl -X POST http://127.0.0.1:5000/pins -H "Content-Type: application/json" -d '{
      "trail_name": "Big C Trail",
      "type": "Hazard",
      "latitude": 37.875,
      "longitude": -122.243,
      "created_by": "tester"
    }'

POST /hazards  
Adds hazard details to a hazard pin.

    curl -X POST http://127.0.0.1:5000/hazards -H "Content-Type: application/json" -d '{
      "pin_location_id": "<insert-pin-id>",
      "hazard_type": "Fallen Tree",
      "severity": "High",
      "description": "Blockage near start",
      "image_url": null
    }'

POST /wrong_turns  
Adds wrong turn details to a wrong turn pin.

    curl -X POST http://127.0.0.1:5000/wrong_turns -H "Content-Type: application/json" -d '{
      "pin_location_id": "<insert-pin-id>",
      "description": "Wrong fork",
      "correct_direction_description": "Take left uphill path",
      "image_url": null,
      "landmarks": "Small signpost"
    }'

