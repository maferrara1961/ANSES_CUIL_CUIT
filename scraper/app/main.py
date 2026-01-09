from flask import Flask, request, jsonify
import asyncio
from scraper import get_anses_cuil

app = Flask(__name__)

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
