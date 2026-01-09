<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Hello World Podman</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0f2f5; color: #1c1e21; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #0078d4; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Hello World!</h1>
        <p>Esta es una app desplegada en <strong>Apache Tomcat</strong> corriendo sobre <strong>Podman</strong>.</p>
        <p>Arquitectura: Enterprise Dev Environment (macOS M1)</p>
        <p>Timestamp: <%= new java.util.Date() %></p>
    </div>
</body>
</html>
