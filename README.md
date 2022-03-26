# Pipelince CICD

## **Variables**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `SNYK_TOKEN` | Token de seguridad para Snyk Cloud | string | `null` | yes |
| `SONAR_ORGANIZATION` | Organizacion para Sonar Cloud | string | `null` | yes |
| `SONAR_TOKEN` | Token de seguridad para Sonar Cloud | string | `null` | yes |
| `DOCKER_USERNAME` | Usuario de Docker Hub | string | `null` | yes |
| `DOCKER_PASSWORD` | Contraseña de Docker Hub | string | `null` | yes |

## **Requisitos**

1. Creando imagenes de contenedor con herramientas:

```bash
make base
```

2. Creando infraestructura cloud necesaria (VPC + EKS):

```bash
make cluster
```

## **Uso**

1. Análisis de código estático con SonarCloud:

```bash
make sonar SONAR_ORGANIZATION=********** SONAR_TOKEN=**********
```

2. Compilando código:

```bash
make build
```

3. Análisis de dependencias de código con Snyk:

```bash
make snyk SNYK_TOKEN=**********
```

4. Empaquetando nueva version de imagen de contenedor:

```bash
make release
```

5. Pruebas funcionales con Postman y Newman:

```bash
make postman
```

6. Publicando nueva imagen de contenedor en Docker Hub:

```bash
make publish DOCKER_USERNAME=********** DOCKER_PASSWORD=**********
```

7. Desplegando nueva version de contenedor con ayuda de Helm:

```bash
make deploy
```

## **Destruir**

Para eliminar toda la infraestructura y recursos asociados:

```bash
make destroy
```