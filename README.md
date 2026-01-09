# Podman Enterprise Dev Environment

Este entorno está diseñado para desarrollo y testing sobre **macOS M1/M2 (Apple Silicon)** utilizando estándares **OCI (Podman)**.

## 🚀 Inicio Rápido

Para desplegar o actualizar todo el stack, ejecuta:
```bash
./scripts/setup-env.sh
```
*El script es idempotente: si los contenedores ya existen, los recreará para aplicar cambios.*

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
