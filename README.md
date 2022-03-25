# Pipelince CICD

## **Variables**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `SNYK_TOKEN` | Token de seguridad para Snyk Cloud | string | `null` | yes |
| `SONAR_ORGANIZATION` | Organizacion para Sonar Cloud | string | `null` | yes |
| `SONAR_TOKEN` | Token de seguridad para Sonar Cloud | string | `null` | yes |
| `DOCKER_USERNAME` | Usuario de Docker Hub | string | `null` | yes |
| `DOCKER_PASSWORD` | Contraseña de Docker Hub | string | `null` | yes |

## **Uso**

1. Creando imagenes de contenedores base y herramientas:

```bash
make base
```

2. Compilando código:

```bash
make build
```

3. Análisis de código estático con SonarCloud:

```bash
make sonar SONAR_ORGANIZATION=********** SONAR_TOKEN=**********
```

4. Análisis de dependencias de código con Snyk:

```bash
make snyk SNYK_TOKEN=**********
```

5. Empaquetando nueva version de imagen de contenedor:

```bash
make release
```

6. Pruebas funcionales con Postman y Newman:

```bash
make postman
```

7. Publicando imagen de contenedor en Docker Hub:

```bash
make publish DOCKER_USERNAME=********** DOCKER_PASSWORD=**********
```

## **Destruir**

Para eliminar toda la infraestructura y recursos asociados:

```bash
make destroy
```