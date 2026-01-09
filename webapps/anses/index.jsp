<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Generador de Constancia ANSES</title>
        <style>
            :root {
                --primary: #0078d4;
                --secondary: #2b3e50;
                --bg: #f8f9fa;
            }

            body {
                font-family: 'Inter', system-ui, -apple-system, sans-serif;
                background-color: var(--bg);
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
            }

            .container {
                background: white;
                padding: 2.5rem;
                border-radius: 12px;
                box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
                width: 100%;
                max-width: 450px;
            }

            h1 {
                color: var(--secondary);
                font-size: 1.5rem;
                margin-bottom: 1.5rem;
                text-align: center;
            }

            .form-group {
                margin-bottom: 1rem;
            }

            label {
                display: block;
                margin-bottom: 0.5rem;
                font-weight: 500;
                font-size: 0.9rem;
            }

            input,
            select {
                width: 100%;
                padding: 0.75rem;
                border: 1px solid #ddd;
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 1rem;
            }

            .row {
                display: flex;
                gap: 1rem;
            }

            .row>.form-group {
                flex: 1;
            }

            .delivery-selection {
                display: flex;
                gap: 1rem;
                margin-bottom: 1rem;
                background: #eef2f6;
                padding: 10px;
                border-radius: 8px;
            }

            .delivery-selection label {
                display: flex;
                align-items: center;
                gap: 5px;
                cursor: pointer;
                margin: 0;
            }

            .delivery-selection input {
                width: auto;
                margin: 0;
            }

            button {
                width: 100%;
                padding: 0.85rem;
                background: var(--primary);
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: background 0.2s;
                margin-top: 1rem;
            }

            button:hover {
                background: #005a9e;
            }

            .hint {
                font-size: 0.8rem;
                color: #666;
                margin-top: 0.5rem;
                text-align: center;
            }

            #message {
                margin-top: 1rem;
                padding: 1rem;
                border-radius: 6px;
                display: none;
                text-align: center;
            }

            .success {
                background: #d4edda;
                color: #155724;
                display: block !important;
            }

            .error {
                background: #f8d7da;
                color: #721c24;
                display: block !important;
            }

            .hidden {
                display: none;
            }
        </style>
    </head>

    <body>
        <div class="container">
            <h1>Constancia ANSES</h1>
            <form id="ansesForm">
                <div class="form-group">
                    <label for="dni">Número de DNI</label>
                    <input type="number" id="dni" name="dni" placeholder="Ej: 20456789" required>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label for="nombre">Nombre(s)</label>
                        <input type="text" id="nombre" name="nombre" placeholder="JUAN" required>
                    </div>
                    <div class="form-group">
                        <label for="apellido">Apellido(s)</label>
                        <input type="text" id="apellido" name="apellido" placeholder="PEREZ" required>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <label for="sexo">Sexo</label>
                        <select id="sexo" name="sexo" required>
                            <option value="M">Masculino</option>
                            <option value="F">Femenino</option>
                            <option value="X">X (No binario)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="fecha_nacimiento">Fecha Nac. (DD/MM/AAAA)</label>
                        <input type="text" id="fecha_nacimiento" name="fecha_nacimiento" placeholder="01/01/1980"
                            required>
                    </div>
                </div>

                <label>Enviar por:</label>
                <div class="delivery-selection">
                    <label><input type="radio" name="delivery" value="whatsapp" checked onclick="toggleDelivery()">
                        WhatsApp</label>
                    <label><input type="radio" name="delivery" value="email" onclick="toggleDelivery()"> Email</label>
                </div>

                <div id="whatsapp-group" class="form-group">
                    <label for="whatsapp">WhatsApp (Destino)</label>
                    <input type="text" id="whatsapp" name="whatsapp" placeholder="+54911..." required>
                </div>

                <div id="email-group" class="form-group hidden">
                    <label for="email">Email (Destino)</label>
                    <input type="email" id="email" name="email" placeholder="ejemplo@correo.com">
                </div>

                <button type="submit" id="submitBtn">Generar y Enviar</button>
            </form>
            <div id="message"></div>
            <p class="hint">Nota: Se requiere completar todos los datos para ANSES.</p>
        </div>

        <script>
            function toggleDelivery() {
                const delivery = document.querySelector('input[name="delivery"]:checked').value;
                const waGroup = document.getElementById('whatsapp-group');
                const mailGroup = document.getElementById('email-group');
                const waInput = document.getElementById('whatsapp');
                const mailInput = document.getElementById('email');

                if (delivery === 'whatsapp') {
                    waGroup.classList.remove('hidden');
                    mailGroup.classList.add('hidden');
                    waInput.required = true;
                    mailInput.required = false;
                } else {
                    waGroup.classList.add('hidden');
                    mailGroup.classList.remove('hidden');
                    waInput.required = false;
                    mailInput.required = true;
                }
            }

            document.getElementById('ansesForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const btn = document.getElementById('submitBtn');
                const msg = document.getElementById('message');

                btn.disabled = true;
                btn.innerText = 'Procesando...';
                msg.className = '';
                msg.style.display = 'none';

                const delivery = document.querySelector('input[name="delivery"]:checked').value;
                const formData = {
                    dni: document.getElementById('dni').value,
                    nombre: document.getElementById('nombre').value.toUpperCase(),
                    apellido: document.getElementById('apellido').value.toUpperCase(),
                    sexo: document.getElementById('sexo').value,
                    fecha_nacimiento: document.getElementById('fecha_nacimiento').value,
                    method: delivery,
                    whatsapp: document.getElementById('whatsapp').value,
                    email: document.getElementById('email').value
                };

                try {
                    // This points to the n8n webhook
                    const response = await fetch('http://localhost:5678/webhook/anses-flow', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(formData)
                    });

                    if (response.ok) {
                        msg.innerText = '¡Solicitud enviada! Recibirás el comprobante en breve.';
                        msg.className = 'success';
                    } else {
                        msg.innerText = 'Error al procesar la solicitud. Verifica la conexión con n8n.';
                        msg.className = 'error';
                    }
                } catch (err) {
                    msg.innerText = 'Error de conexión: ' + err.message;
                    msg.className = 'error';
                } finally {
                    btn.disabled = false;
                    btn.innerText = 'Generar y Enviar';
                }
            });
        </script>
    </body>

    </html>