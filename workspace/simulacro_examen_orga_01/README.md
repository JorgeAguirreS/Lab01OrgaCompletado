# Simulacro de Organización — 110 minutos, 100 puntos

**Para abrir el entorno, haga doble clic en `ABRIR_ENTORNO.cmd`.** Se abre VS Code con el examen y una terminal situada en la carpeta correcta. En VS Code, **Ctrl+Shift+B** ejecuta las pruebas visibles. La evaluación final se ejecuta aparte, cuando termine.

Abra esta carpeta como proyecto y lea [EXAMEN.md](EXAMEN.md). Edite solo sus seis archivos de estudiante y complete los `TODO EXAMEN`.

Requisitos: Windows, PowerShell 5.1 o 7 y `g++` de MinGW-w64 en el PATH. EasyMIPS está copiado dentro de esta carpeta. No se necesita Python para usar el simulacro.

```powershell
.\build.ps1                  # Compilar C++
.\check.ps1                  # Practica: recompila y ejecuta solo pruebas visibles
.\check.ps1 -Ejercicio 4     # Practicar un ejercicio
.\evaluar.ps1                # Solo al terminar: evaluacion completa
.\reiniciar.ps1 -Confirmar   # Respaldar y restaurar los archivos de estudiante
```

Si PowerShell bloquea los scripts, aplique únicamente a la terminal actual:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

El estado inicial compila y obtiene 0 puntos. Las salidas completas y el puntaje se guardan en `resultados/`. Evite abrir `evaluacion/` durante la sesión. No hay solucionario. Las copias del ejecutable y de la infraestructura son independientes del laboratorio original.
