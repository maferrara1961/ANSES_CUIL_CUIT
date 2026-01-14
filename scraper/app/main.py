from flask import Flask, request, jsonify
import asyncio
from scraper import get_anses_cuil
import json
import os

app = Flask(__name__)
CONFIG_FILE = 'config.json'

def load_config():
    if not os.path.exists(CONFIG_FILE):
        return {}
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading config: {e}")
        return {}

def save_config(data):
    try:
        with open(CONFIG_FILE, 'w') as f:
            json.dump(data, f, indent=4)
        return True
    except Exception as e:
        print(f"Error saving config: {e}")
        return False

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/api/config', methods=['GET'])
def get_config():
    return jsonify(load_config()), 200

@app.route('/api/config', methods=['POST'])
def update_config():
    data = request.json
    if not data:
        return jsonify({"success": False, "error": "No data provided"}), 400
    
    current_config = load_config()
    current_config.update(data)
    
    if save_config(current_config):
        return jsonify({"success": True, "message": "Configuration saved"}), 200
    else:
        return jsonify({"success": False, "error": "Failed to save configuration"}), 500


@app.route('/fetch-cuil', methods=['POST'])
def fetch_cuil():
    data = request.json
    
    dni = data.get('dni')
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    sexo = data.get('sexo')
    fecha_nacimiento = data.get('fecha_nacimiento')

    if not all([dni, nombre, apellido, sexo, fecha_nacimiento]):
        return jsonify({"success": False, "error": "Missing required fields"}), 400

    # Run the async scraper in the event loop
    try:
        result = asyncio.run(get_anses_cuil(dni, nombre, apellido, sexo, fecha_nacimiento))
        print(f"Scraper result for {dni}: {result.get('success')}")
        if not result.get("success"):
            print(f"Scraper error detail: {result.get('error')}")
    except Exception as e:
        print(f"Main API Error: {str(e)}")
        result = {"success": False, "error": str(e)}
    
    if result.get("success"):
        return jsonify(result), 200
    else:
        return jsonify(result), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
