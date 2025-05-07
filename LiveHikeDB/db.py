import sqlite3

DB_NAME = "livehike.db"

def get_db():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    with get_db() as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS trails (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                location TEXT,
                difficulty TEXT,
                length REAL,
                elevation_gain INTEGER
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS pin_locations (
                id TEXT PRIMARY KEY,
                trail_name TEXT NOT NULL,
                type TEXT CHECK(type IN ('Hazard', 'Wrong Turn', 'Wildlife')) NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                created_by TEXT,
                updated_at TEXT,
                verified_count INTEGER DEFAULT 0,
                dismissed_count INTEGER DEFAULT 0
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS hazard_pins (
                id TEXT PRIMARY KEY,
                pin_location_id TEXT NOT NULL,
                hazard_type TEXT NOT NULL,
                severity TEXT,
                description TEXT,
                image_url TEXT,
                FOREIGN KEY(pin_location_id) REFERENCES pin_locations(id) ON DELETE CASCADE
            );
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS wrong_turn_pins (
                id TEXT PRIMARY KEY,
                pin_location_id TEXT NOT NULL,
                description TEXT,
                correct_direction_description TEXT,
                image_url TEXT,
                landmarks TEXT,
                FOREIGN KEY(pin_location_id) REFERENCES pin_locations(id) ON DELETE CASCADE
            );
        """)

def query_db(query, args=(), one=False):
    with get_db() as conn:
        cur = conn.execute(query, args)
        rv = cur.fetchall()
        return (rv[0] if rv else None) if one else rv

def execute_db(query, args=()):
    with get_db() as conn:
        conn.execute(query, args)
        conn.commit()
