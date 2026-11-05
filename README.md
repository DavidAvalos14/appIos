# Plantilla iOS

Plantilla base para apps SwiftUI que se compilan en GitHub Actions (sin Mac) y se prueban en Appetize.

## Flujo de trabajo

### 1. Clonar el repositorio (solo la primera vez)

```bash
git clone https://github.com/DavidAvalos14/appIos.git
cd appIos
```

### 2. Crear una rama nueva desde `main`

```bash
git checkout main
git pull origin main
git checkout -b nombre-de-tu-proyecto
```

### 3. Escribir el código

Crea o edita archivos `.swift` dentro de `Plantilla/` (todas las clases que necesites).
No hace falta registrarlos en ningún lado; XcodeGen los incluye solos.

### 4. Subir la rama

```bash
git add .
git commit -m "Describe tu cambio"
git push -u origin nombre-de-tu-proyecto
```

Cada push a cualquier rama dispara la GitHub Action.

### 5. Descargar el compilado

1. Entra a la pestaña **Actions** del repositorio: <https://github.com/DavidAvalos14/appIos/actions>
2. Abre la ejecución más reciente de tu rama y espera a que termine en verde.
3. En la sección **Artifacts** descarga `appetize-build` (es un `.zip`).

### 6. Probarlo en Appetize

1. Entra a <https://appetize.io/upload> (inicia sesión o crea una cuenta gratuita).
2. Sube el `.zip` descargado. Contiene la carpeta `Plantilla.app`, que es el formato de simulador que Appetize acepta.
3. Selecciona iPhone como dispositivo y abre la app en el navegador.

### Si la Action falla

Abre la ejecución fallida, copia el log del paso que falló y pídele a Copilot que corrija
el código o `project.yml`. Después vuelve a hacer commit y push.

## Cómo funciona

`project.yml` describe el proyecto y [XcodeGen](https://github.com/yonaskolb/XcodeGen) genera `Plantilla.xcodeproj` en cada ejecución.
Todo archivo dentro de `Plantilla/` se incluye automáticamente, así que **no hay que registrar archivos nuevos a mano**.

Solo edita `project.yml` para cambiar configuración: versión mínima de iOS, permisos (`INFOPLIST_KEY_*`), frameworks, etc.
Si la action falla, pídele a Copilot que revise el log y corrija `project.yml` o el código.
