# Academia 304D — Aplicación de Gestión de Asistencia

Aplicación full-stack para gestión de usuarios y asistencia académica. Desarrollada con **React (Vite)** en el frontend y **Spring Boot** en el backend, contenerizada con Docker y desplegada automáticamente en AWS EC2 mediante GitHub Actions.

---

## Arquitectura general

```
Internet
   │
   ▼
EC2 Frontend (pública)          EC2 Backend (subred privada)
┌─────────────────────┐         ┌─────────────────────────────┐
│  contenedor nginx   │────────▶│  contenedor Spring Boot      │
│  puerto 80          │         │  puerto 8080                 │
└─────────────────────┘         │         │                    │
                                │  contenedor MySQL            │
                                │  puerto 3306                 │
                                │  volumen: mysql_data         │
                                └─────────────────────────────┘
```

- Solo el **frontend** es accesible desde internet (IP pública).
- El **backend** vive en subred privada y solo recibe tráfico del frontend.
- Los datos de MySQL persisten en un **named volume** `mysql_data` que sobrevive reinicios de contenedores.

---

## Requisitos para correr localmente

- Docker Desktop instalado y corriendo
- Git

---

## Cómo correr el proyecto localmente

**1. Clonar el repositorio**
```bash
git clone https://github.com/TU-USUARIO/academia-304d.git
cd academia-304d
```

**2. Crear el archivo de variables de entorno**

Crea un archivo `.env` en la raíz del proyecto con este contenido:
```
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=asistencia_db
```

**3. Levantar todos los servicios**
```bash
docker compose up --build
```

**4. Acceder a la aplicación**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080

**5. Detener los servicios**
```bash
docker compose down
```

> Para detener Y eliminar los datos de la base de datos:
> ```bash
> docker compose down -v
> ```

---

## Variables de entorno

| Variable | Descripción | Ejemplo |
|---|---|---|
| `MYSQL_ROOT_PASSWORD` | Contraseña root de MySQL | `root` |
| `MYSQL_DATABASE` | Nombre de la base de datos | `asistencia_db` |
| `SPRING_DATASOURCE_URL` | URL de conexión (la setea docker-compose) | `jdbc:mysql://mysql:3306/asistencia_db` |

---

## Persistencia de datos

Se utiliza un **named volume** llamado `mysql_data` para persistir la base de datos MySQL.

Se eligió named volume (en lugar de bind mount) porque:
- No depende de un path específico del sistema operativo del host.
- Docker gestiona el ciclo de vida del volumen de forma independiente al contenedor.
- Es la práctica recomendada para bases de datos en entornos contenerizados.

---

## Pipeline CI/CD

El pipeline se activa automáticamente al hacer `git push` a la rama **`deploy`**.

**Flujo completo:**
```
push a rama deploy
       │
       ▼
1. Checkout del código
       │
       ▼
2. Configurar credenciales AWS (desde GitHub Secrets)
       │
       ▼
3. Login en Amazon ECR
       │
       ▼
4. Build + Push imagen backend → ECR
4. Build + Push imagen frontend → ECR
       │
       ▼
5. SSH a EC2 backend → docker pull + docker compose up
5. SSH a EC2 frontend → docker pull + docker compose up
```

**Secrets requeridos en GitHub (Settings → Secrets → Actions):**

| Secret | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Clave de acceso AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Clave secreta AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sesión AWS Academy (expira con cada lab) |
| `AWS_ACCOUNT_ID` | ID numérico de la cuenta AWS (12 dígitos) |
| `EC2_BACKEND_HOST` | IP pública de la instancia EC2 del backend |
| `EC2_FRONTEND_HOST` | IP pública de la instancia EC2 del frontend |
| `EC2_SSH_KEY` | Contenido completo del archivo .pem de acceso a EC2 |

---

## Estructura del repositorio

```
academia-304d/
├── backend/
│   ├── Dockerfile          # Multi-stage: Maven builder → JRE runner (usuario no-root)
│   ├── src/                # Código fuente Spring Boot
│   └── pom.xml
├── frontend/
│   ├── Dockerfile          # Multi-stage: Node builder → nginx runner
│   ├── nginx.conf          # Configuración de nginx
│   └── src/                # Código fuente React
├── .github/
│   └── workflows/
│       └── cd.yml          # Pipeline CI/CD GitHub Actions
├── docker-compose.yml      # Stack completo: mysql + backend + frontend
├── .env                    # Variables de entorno (no se sube a git)
└── README.md
```

---

## Tecnologías utilizadas

- **Frontend:** React 18 + Vite + nginx
- **Backend:** Spring Boot 3 + Java 21
- **Base de datos:** MySQL 8
- **Contenerización:** Docker + Docker Compose
- **Registro de imágenes:** Amazon ECR
- **Infraestructura:** AWS EC2
- **CI/CD:** GitHub Actions