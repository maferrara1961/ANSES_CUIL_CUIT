# Podman Enterprise Dev Environment

Este entorno está diseñado para desarrollo y testing sobre **macOS M1/M2 (Apple Silicon)** utilizando estándares **OCI (Podman)**.

## 🚀 Inicio Rápido (Automatización)
Para gestionar el ciclo de vida del entorno, utiliza el script **manage.sh**:

1.  **Iniciar (Deploy)**:
    ```bash
    ./scripts/manage.sh start
    ```
2.  **Detener todo (Stop clean)**:
    ```bash
    ./scripts/manage.sh stop
    ```
3.  **Reconstruir y Desplegar (Rebuild)**:
    *Reconstruye la UI (React) y las imágenes de Docker (Python Scraper).*
    ```bash
    ./scripts/manage.sh rebuild
    ```

> [!NOTE]
> El comando `rebuild` utiliza un contenedor temporal para compilar el frontend, por lo que no requieres tener Node.js instalado en tu máquina.

---

## 🛠 Accesos y Credenciales

| Servicio | URL / Acceso | Usuario | Password |
| :--- | :--- | :--- | :--- |
| **Nginx (Gateway)** | [http://localhost](http://localhost) | - | - |
| **Tomcat (App)** | [http://localhost/hello/](http://localhost/hello/) | - | - |
| **Grafana** | [http://localhost:3000](http://localhost:3000) | `admin` | `admin` |
| **Prometheus** | [http://localhost:9090](http://localhost:9090) | - | - |
| **n8n** | [http://localhost:5678](http://localhost:5678) | (Set up inicial) | - |
| **MS SQL Server** | `localhost,1433` | `sa` | `YourStrongPassword123!` |

---

## 💻 Comandos de Consola (Podman)

### Gestión de Estado
- **Ver status de servicios**:
  ```bash
  podman ps
```
- **Detener un servicio**:
  ```bash
  podman stop <nombre_contenedor>
```
- **Iniciar un servicio detenido**:
  ```bash
  podman start <nombre_contenedor>
```
- **Reiniciar un servicio**:
  ```bash
  podman restart <nombre_contenedor>
```

### Logs y Depuración
- **Ver logs en tiempo real**:
  ```bash
  podman logs -f <nombre_contenedor>
```
- **Entrar a la consola del contenedor**:
  ```bash
  podman exec -it <nombre_contenedor> /bin/bash (o /bin/sh)
```

---

## 📁 Estructura de Carpetas

- `/webapps`: Deja aquí tus archivos `.war` para despliegue automático en Tomcat.
- `/nginx`: Configuración del Proxy Inverso (`nginx.conf`).
- `/prometheus`: Configuración y reglas de alertas.
- `/grafana`: Aprovisionamiento de datasources.
- `/war_build`: Fuentes del Java "Hello World".

---

## 🔍 Solución de Problemas (Troubleshooting)

### Error: "host not found in upstream" en NGINX
Este error ocurre si Nginx intenta conectarse a un contenedor que no ha sido creado. 
- **Solución**: Asegúrate de que el nombre del contenedor en `nginx.conf` coincida con el nombre del pod en Podman. Se ha corregido comentando los servicios no activos por defecto.

### Tomcat no responde
- Verifica los logs: `podman logs tomcat`.
- Asegúrate de que el archivo `.war` esté en la carpeta `/webapps`.
