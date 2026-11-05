# Plantilla iOS

Plantilla base para apps SwiftUI que se compilan en GitHub Actions (sin Mac) y se prueban en Appetize.

## Flujo de trabajo

1. Crear una rama nueva desde `main`.
2. Escribir el código en `Plantilla/` (puedes crear tantas clases `.swift` como quieras).
3. Hacer push: la GitHub Action genera el proyecto Xcode y compila el `.app`.
4. Descargar el artifact `appetize-build` y subirlo a Appetize.

## Cómo funciona

`project.yml` describe el proyecto y [XcodeGen](https://github.com/yonaskolb/XcodeGen) genera `Plantilla.xcodeproj` en cada ejecución.
Todo archivo dentro de `Plantilla/` se incluye automáticamente, así que **no hay que registrar archivos nuevos a mano**.

Solo edita `project.yml` para cambiar configuración: versión mínima de iOS, permisos (`INFOPLIST_KEY_*`), frameworks, etc.
Si la action falla, pídele a Copilot que revise el log y corrija `project.yml` o el código.
