import sqlite3
from typing import List, Tuple, Optional, Dict

class HazardDatabase:
    def __init__(self, db_name: str = "hazards.db"):
        self.conn = sqlite3.connect(db_name)
        self.create_table()

    def create_table(self):
        with self.conn:
        # Create users table
            self.conn.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT NOT NULL UNIQUE,
                    email TEXT NOT NULL UNIQUE
                );
            """)
            
            # Create hazards table with foreign key to users
            self.conn.execute("""
                CREATE TABLE IF NOT EXISTS hazards (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    location TEXT NOT NULL,
                    description TEXT,
                    user_id INTEGER NOT NULL,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                );
            """)

    def add_hazard(self, name: str, location: str, description: str, user_id: int) -> int:
        with self.conn:
            cursor = self.conn.execute("""
                INSERT INTO hazards (name, location, description, user_id)
                VALUES (?, ?, ?, ?);
            """, (name, location, description, user_id))
            return cursor.lastrowid

    def get_all_hazards(self) -> List[Dict]:
        cursor = self.conn.execute("SELECT * FROM hazards;")
        return [self._row_to_dict(row) for row in cursor.fetchall()]

    def get_hazards_by_user(self, user_id: int) -> List[Dict]:
        cursor = self.conn.execute("SELECT * FROM hazards WHERE user_id = ?;", (user_id,))
        return [self._row_to_dict(row) for row in cursor.fetchall()]

    def update_hazard(self, hazard_id: int, name: Optional[str], location: Optional[str], description: Optional[str]) -> bool:
        existing = self.conn.execute("SELECT * FROM hazards WHERE id = ?;", (hazard_id,)).fetchone()
        if not existing:
            return False

        name = name or existing[1]
        location = location or existing[2]
        description = description or existing[3]

        with self.conn:
            self.conn.execute("""
                UPDATE hazards
                SET name = ?, location = ?, description = ?
                WHERE id = ?;
            """, (name, location, description, hazard_id))
        return True

    def delete_hazard(self, hazard_id: int) -> bool:
        with self.conn:
            cursor = self.conn.execute("DELETE FROM hazards WHERE id = ?;", (hazard_id,))
            return cursor.rowcount > 0

    def _row_to_dict(self, row: Tuple) -> Dict:
        return {
            "id": row[0],
            "name": row[1],
            "location": row[2],
            "description": row[3],
            "user_id": row[4]
        }

# Example usage:
if __name__ == "__main__":
    db = HazardDatabase()
