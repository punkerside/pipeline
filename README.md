# Pipelince CICD

## **Variables**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `SONAR_ORGANIZATION` | Organizacion para SonarCloud | string | `null` | no |
| `SONAR_TOKEN` | Token de seguridad para SonarCloud | string | `null` | no |

## **Uso**

1. Creando imagenes de contenedores base y herramientas:

```bash
make base
```