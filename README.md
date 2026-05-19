# 🏢 Innovatech Chile - DevOps & Microservices Architecture

![Arquitectura](https://img.shields.io/badge/Architecture-2--Tier%20Microservices-blue)
![Infraestructura](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions)
![Despliegue](https://img.shields.io/badge/Deploy-Docker%20Compose-2496ED?logo=docker)
![Nube](https://img.shields.io/badge/Cloud-AWS-232F3E?logo=amazon-aws)

## 📖 Descripción del Proyecto

Este repositorio contiene la infraestructura como código (IaC), el pipeline CI/CD y los servicios de la aplicación de **Innovatech Chile**, una solución de software orientada a la gestión de ventas y despachos en el sector retail. 

El proyecto fue diseñado y desplegado bajo estrictos principios DevOps, pasando de una arquitectura monolítica tradicional a una **Arquitectura Distribuida en Dos Capas (2-Tier)**, garantizando escalabilidad, alta disponibilidad y máxima seguridad mediante el aislamiento de subredes.

## 🏗️ Arquitectura de la Solución

El sistema se despliega en **Amazon Web Services (AWS)** utilizando una separación física y lógica para cumplir con el principio de *Seguridad en Profundidad*:

1. **Frontend (Subred Pública):**
   * Contiene la interfaz gráfica en React (servida mediante Nginx).
   * Es accesible desde Internet exclusivamente a través de un **Application Load Balancer (ALB)**.
   * Actúa como un Bastion Host (SSH Proxy) para permitir despliegues seguros hacia la red privada.

2. **Backend & Base de Datos (Subred Privada):**
   * Totalmente aislado del exterior; sin acceso directo a Internet.
   * Contiene los microservicios RESTful (Ventas y Despachos) en Spring Boot.
   * Aloja la base de datos relacional MySQL.
   * Cuenta con un **EBS Volume (Elastic Block Store)** acoplado para persistencia de datos independiente del ciclo de vida de la instancia.

## ⚙️ Tecnologías Utilizadas

* **Gestión de Contenedores:** Docker, Docker Compose, Amazon ECR.
* **Infraestructura como Código (IaC):** Terraform.
* **Integración y Despliegue Continuo (CI/CD):** GitHub Actions.
* **Cloud Computing:** AWS (VPC, EC2, ALB, NAT Gateway, EBS, ECR).
* **Desarrollo:** React (Frontend), Java Spring Boot (Backend), MySQL (Data).

## 🚀 Pipeline CI/CD (GitHub Actions)

El proceso de entrega continua está automatizado al 100% al integrar código a la rama `deploy`.

1. **Build & Push:** Construcción multi-stage de las tres imágenes Docker y subida segura al registro de contenedores privado de Amazon (ECR).
2. **Deploy Frontend:** Conexión SSH a la instancia EC2 pública para ejecutar un pull de imágenes e instanciar el contenedor de interfaz usando un archivo `docker-compose.yml` centralizado.
3. **Deploy Backend (Proxy SSH):** Uso de la máquina pública como puente encriptado (Proxy) para saltar hacia la instancia privada y levantar selectivamente los contenedores de Spring Boot y MySQL.

## 🛠️ Instrucciones de Despliegue Local

Si deseas probar el proyecto de forma local utilizando Docker Compose:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/DylanMarchant24/DevOps.git
   cd DevOps
   ```
2. Crea el archivo `.env` en la raíz (usa `.env.example` como referencia) y configura tus credenciales de base de datos.
3. Levanta el stack de microservicios:
   ```bash
   docker-compose up --build
   ```
4. Accede al frontend en `http://localhost:8080`.

## ☁️ Despliegue en AWS (Terraform)

Para levantar la infraestructura de producción desde cero:

1. Configura tus credenciales temporales de AWS Learner Lab (`aws configure`).
2. Entra a la carpeta de infraestructura:
   ```bash
   cd infra
   ```
3. Ejecuta los comandos de Terraform:
   ```bash
   terraform init
   terraform apply
   ```
4. Copia las IPs generadas (Outputs) en las variables `EC2_FRONT_HOST` y `EC2_BACK_HOST` dentro de los *Secrets and Variables* de tu repositorio en GitHub para permitir que el pipeline CI/CD finalice el trabajo.
