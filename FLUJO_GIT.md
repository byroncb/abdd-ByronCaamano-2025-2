# 🔀 Flujo de Trabajo con Git

## 📋 Instrucciones para el Estudiante

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/pedrocobe/abdd-2025-2.git
cd abdd-2025-2
```

### Paso 2: Crear tu Rama Personal

```bash
# Formato: student/nombre_apellido_cedula
git checkout -b student/tu_nombre_tu_apellido_tu_cedula

# Ejemplo:
# git checkout -b student/juan_perez_0123456789
```

### Paso 3: Completar el Examen

Trabaja en tu rama personal y completa:

1. **Crear `docker-compose.yml`**
```bash
# El archivo NO existe, créalo desde cero
nano docker-compose.yml
# O usa tu editor favorito
```

2. **Completar configuración América**
```bash
nano symmetricds/america/symmetric.properties
nano symmetricds/america/engines/america.properties
```

3. **Completar configuración Europa**
```bash
nano symmetricds/europe/symmetric.properties
nano symmetricds/europe/engines/europe.properties
```

### Paso 4: Probar Localmente

```bash
# Levantar arquitectura
docker-compose up -d

# Verificar
docker-compose ps

# Ver logs si hay problemas
docker-compose logs -f

# Limpiar
docker-compose down -v
```

### Paso 5: Hacer Commit y Push

```bash
# Agregar archivos
git add docker-compose.yml
git add symmetricds/

# Commit
git commit -m "Completar examen - [Tu Nombre]"

# Push a tu rama
git push origin student/tu_nombre_tu_apellido_tu_cedula
```

### Paso 6: Notificar al Profesor

Una vez subida tu rama, notifica al profesor que has terminado.

---

## 👨‍🏫 Instrucciones para el Profesor

### Preparación Inicial (Una sola vez)

```bash
# 1. Clonar el repositorio
git clone https://github.com/pedrocobe/abdd-2025-2.git
cd abdd-2025-2

# 2. Verificar que estás en main
git branch
```

### Calificar a los Estudiantes

Por cada estudiante:

```bash
# 1. Actualizar todas las ramas
git fetch --all

# 2. Ver todas las ramas de estudiantes
git branch -r | grep student/

# 3. Cambiar a la rama del estudiante
git checkout student/nombre_apellido_cedula

# Ejemplo:
# git checkout student/juan_perez_0123456789

# 4. Ejecutar calificación automática (100 puntos)
./calificar.sh

# Esto validará:
# - Docker Compose (20pts)
# - Contenedores corriendo (20pts)
# - Bases de datos (15pts)
# - SymmetricDS (15pts)
# - Replicación bidireccional (30pts)

# 5. Ver resultado y reporte generado
# El script genera calificacion_[timestamp].txt

# 6. Volver a main para el siguiente estudiante
git checkout main
```

### Script Automatizado para Calificar Múltiples Estudiantes

```bash
# Crear script helper
cat > calificar_todos.sh << 'EOF'
#!/bin/bash

# Obtener todas las ramas de estudiantes
STUDENT_BRANCHES=$(git branch -r | grep 'origin/student/' | sed 's/origin\///')

echo "======================================"
echo "CALIFICACIÓN AUTOMÁTICA - TODOS"
echo "======================================"
echo ""

for BRANCH in $STUDENT_BRANCHES; do
    STUDENT_NAME=$(echo $BRANCH | sed 's/student\///')
    
    echo "======================================"
    echo "Calificando: $STUDENT_NAME"
    echo "======================================"
    
    # Cambiar a la rama del estudiante
    git checkout $BRANCH
    
    # Verificar que docker-compose.yml existe
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ ERROR: docker-compose.yml no encontrado"
        echo "Calificación: 0/100"
        echo ""
        continue
    fi
    
    # Limpiar ambiente
    docker-compose down -v > /dev/null 2>&1
    
    # Ejecutar validación
    ./validation/validate.sh > /tmp/resultado_${STUDENT_NAME}.txt 2>&1
    RESULTADO=$?
    
    # Limpiar
    docker-compose down -v > /dev/null 2>&1
    
    if [ $RESULTADO -eq 0 ]; then
        echo "✅ APROBADO - Todas las pruebas pasaron"
    else
        echo "❌ REPROBADO - Algunas pruebas fallaron"
    fi
    
    # Guardar resultado
    cp /tmp/resultado_${STUDENT_NAME}.txt resultados/
    
    echo ""
    sleep 2
done

# Volver a main
git checkout main

echo "======================================"
echo "CALIFICACIÓN COMPLETADA"
echo "======================================"
echo "Ver resultados en: resultados/"
EOF

chmod +x calificar_todos.sh

# Crear directorio de resultados
mkdir -p resultados

# Ejecutar
./calificar_todos.sh
```

### Revisión Manual de una Rama Específica

```bash
# Cambiar a la rama del estudiante
git checkout student/nombre_apellido_cedula

# Ver qué archivos modificó/creó
git diff main --name-only

# Ver contenido de sus cambios
git diff main

# Ver su docker-compose.yml
cat docker-compose.yml

# Ver sus configuraciones
cat symmetricds/america/symmetric.properties
cat symmetricds/america/engines/america.properties
cat symmetricds/europe/symmetric.properties
```

---

## 📊 Sistema de Calificación con Git

### Criterios de Evaluación

**validate.sh verifica:**
- ✅ INSERT bidireccional (PostgreSQL ↔ MySQL)
- ✅ UPDATE bidireccional
- ✅ DELETE bidireccional
- ✅ Replicación de 4 tablas

**Si pasa todas las pruebas: 100/100**
**Si falla alguna prueba: Revisar logs y asignar puntos parciales**

### Puntos Parciales (si validate.sh falla)

Puedes usar `grade.sh` para puntuación detallada:

```bash
git checkout student/nombre_apellido_cedula
./grade.sh
```

Esto genera un reporte con:
- Docker Compose: /40 pts
- Config América: /30 pts
- Config Europa: /30 pts
- BONUS Funcional: /20 pts

---

## 🔄 Flujo Visual

```
ESTUDIANTE                          PROFESOR
    │                                   │
    │ 1. git clone                      │
    │ 2. git checkout -b student/...    │
    │ 3. Completar archivos             │
    │ 4. Probar localmente              │
    │ 5. git commit                     │
    │ 6. git push origin student/...    │
    ├──────────────────────────────────>│
    │                                   │ 7. git fetch --all
    │                                   │ 8. git checkout student/...
    │                                   │ 9. ./validation/validate.sh
    │                                   │ 10. Ver resultado
    │                                   │ 11. git checkout main
    │                                   │ 12. Siguiente estudiante
    │                                   ▼
```

---

## ⚠️ Reglas Importantes

### Para Estudiantes:

1. **Solo trabaja en tu rama** - No modifiques `main`
2. **Nombra tu rama correctamente** - `student/nombre_apellido_cedula`
3. **No copies código de otros** - Se detectará con `git diff`
4. **Prueba antes de hacer push** - Usa `docker-compose up -d`
5. **No incluyas volúmenes de Docker en el commit** - Solo configuración

### Para el Profesor:

1. **Nunca trabajes directamente en las ramas de estudiantes** - Solo lectura
2. **Siempre vuelve a main** después de calificar
3. **Limpia contenedores** entre cada calificación: `docker-compose down -v`
4. **Guarda los reportes** en la carpeta `resultados/`

---

## 📝 .gitignore Configurado

El proyecto ya tiene `.gitignore` que excluye:

```
# Docker Compose file (estudiantes lo crean)
docker-compose.yml

# Archivos de profesor (no versionar en main)
grade.sh
docker-compose.EXAMPLE.yml
SOLUTION_REFERENCE.md
TEACHER_GUIDE.md
RESUMEN_PROFESOR.md
*.txt

# Datos de Docker
*-data/
volumes/
```

**PERO** en las ramas de estudiantes, `docker-compose.yml` SÍ se incluye (cada estudiante hace force add).

---

## 🎯 Comandos Rápidos

### Estudiante:
```bash
# Configuración inicial
git clone https://github.com/pedrocobe/abdd-2025-2.git
cd abdd-2025-2
git checkout -b student/nombre_apellido_cedula

# Trabajar...

# Entregar
git add -f docker-compose.yml  # Force add porque está en .gitignore
git add symmetricds/
git commit -m "Completar examen"
git push origin student/nombre_apellido_cedula
```

### Profesor:
```bash
# Calificar un estudiante
git fetch --all
git checkout student/nombre_apellido_cedula
./validation/validate.sh
docker-compose down -v
git checkout main

# Calificar todos (automatizado)
./calificar_todos.sh
```

---

## ✅ Ventajas de este Flujo

✅ **Trazabilidad** - Cada estudiante tiene su rama
✅ **Comparación fácil** - `git diff main` muestra sus cambios
✅ **Sin conflictos** - Cada uno trabaja en su rama
✅ **Histórico** - Se mantiene todo el historial de commits
✅ **Automatizable** - Script para calificar todos
✅ **Reproducible** - Puedes volver a cualquier rama cuando quieras

---

## 🆘 Problemas Comunes

### "docker-compose.yml is listed in .gitignore"

Solución:
```bash
git add -f docker-compose.yml
```

El `-f` fuerza agregar el archivo aunque esté en .gitignore.

### "Branch already exists"

Solución:
```bash
# Si ya existe, cámbiala a ella
git checkout student/tu_nombre_apellido_cedula

# O bórrala y créala de nuevo
git branch -D student/tu_nombre_apellido_cedula
git checkout -b student/tu_nombre_apellido_cedula
```

### "Cannot push to origin"

Verifica que tienes permisos en el repo o que tu rama está configurada:
```bash
git push -u origin student/tu_nombre_apellido_cedula
```

---

Versión: 1.0
Fecha: Enero 2026
