from flask import Flask, jsonify, send_from_directory
from flask_swagger_ui import get_swaggerui_blueprint
import pyodbc
import os

# Database connection function
def get_db_connection():
    conn = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=dist-6-505.uopnet.plymouth.ac.uk;'
        'DATABASE=COMP2001_VSureshkumar;'  
        'UID=VSureshkumar;'  
        'PWD=FglB399+'  
    )
    return conn

# Initialize Flask app
app = Flask(__name__, static_folder='static')  # Explicitly set the static folder

# Swagger setup
SWAGGER_URL = '/swagger'  # Swagger UI endpoint
API_URL = '/static/swagger.json'  # Path to Swagger JSON file

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,  # Swagger UI endpoint
    API_URL,      # Swagger file URL
    config={'app_name': "Trail Management API"}
)

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

@app.route('/')
def home():
    return "Trail Management API is running!"

@app.route('/trails', methods=['GET'])
def get_trails():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM CW2.Trails")  # Adjust table name if needed
    rows = cursor.fetchall()
    conn.close()

    # Convert rows to a list of dictionaries
    trails = [{"TrailID": row[0], "TrailName": row[1], "Description": row[2]} for row in rows]
    return jsonify(trails)

# Route to serve Swagger JSON file
@app.route('/static/<path:filename>')
def serve_static_file(filename):
    return send_from_directory('static', filename)

if __name__ == '__main__':
    # Ensure the "static" directory exists
    if not os.path.exists('static'):
        os.mkdir('static')
    
    # Ensure "swagger.json" exists in the static folder
    if not os.path.exists(os.path.join('static', 'swagger.json')):
        with open(os.path.join('static', 'swagger.json'), 'w') as f:
            f.write("""
{
  "swagger": "2.0",
  "info": {
    "title": "Trail Management API",
    "description": "API documentation for the Trail Management application",
    "version": "1.0.0"
  },
  "host": "127.0.0.1:5000",
  "basePath": "/",
  "schemes": ["http"],
  "paths": {
    "/trails": {
      "get": {
        "summary": "Get all trails",
        "responses": {
          "200": {
            "description": "A list of trails",
            "schema": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "TrailID": {"type": "integer"},
                  "TrailName": {"type": "string"},
                  "Description": {"type": "string"}
                }
              }
            }
          }
        }
      }
    }
  }
}
""")

    app.run(debug=True)
