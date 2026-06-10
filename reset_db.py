import sqlite3

new_hash = "scrypt:32768:8:1$iFk0h8qCsyF9eF3b$42684c3caf30c0fff05faf3444139f2a75fb3e2ba005e0185936766c2fde5c18ab1e287ac9ea68924e1d4d90a2f15e230fcbf826bbcd8522e2267e202153b543"

conn = sqlite3.connect("knowledge_group.db")
cur = conn.cursor()

cur.execute(
    "UPDATE users SET password=? WHERE role='admin'",
    (new_hash,)
)

conn.commit()
print("Admin password updated.")
conn.close()