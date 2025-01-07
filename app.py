from flask import Flask, jsonify
import pyodbc

def get_db_connection():
    conn = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=dist-6-505.uopnet.plymouth.ac.uk;'
        'DATABASE=COMP2001_VSureshkumar;'  
        'UID=VSureshkumar;'  
        'PWD=FglB399+'  
    )
    return conn

app = Flask(__name__)

@app.route('/')
def home():
    return "Trail Management API is running!"

@app.route('/trails', methods=['GET'])
def get_trails():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM CW2.Trails")  # Updated table name
    rows = cursor.fetchall()
    conn.close()

    # Convert rows to a list of dictionaries
    trails = [{"TrailID": row[0], "TrailName": row[1], "Description": row[2]} for row in rows]
    return jsonify(trails)


if __name__ == '__main__':
    app.run(debug=True)
