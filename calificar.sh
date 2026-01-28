#!/bin/bash

# ============================================
# SCRIPT DE CALIFICACIÓN AUTOMÁTICA
# Examen: Replicación Bidireccional SymmetricDS
# Puntuación Total: 100 puntos
# ============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Variables de puntuación
TOTAL_SCORE=0
MAX_SCORE=100

# Desglose de puntos
DOCKER_COMPOSE_POINTS=0
DOCKER_COMPOSE_MAX=20

CONTAINERS_POINTS=0
CONTAINERS_MAX=20

DATABASES_POINTS=0
DATABASES_MAX=15

SYMMETRICDS_POINTS=0
SYMMETRICDS_MAX=15

REPLICATION_POINTS=0
REPLICATION_MAX=30

# Variables de configuración
WAIT_TIME=15

# ============================================
# Funciones auxiliares
# ============================================

print_header() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}============================================${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}>>> $1${NC}"
}

print_test() {
    echo -n "  → $1 ... "
}

print_pass() {
    local points=$1
    echo -e "${GREEN}✓ (+${points}pts)${NC}"
}

print_fail() {
    echo -e "${RED}✗ (0pts)${NC}"
    if [ ! -z "$1" ]; then
        echo -e "    ${YELLOW}  Razón: $1${NC}"
    fi
}

print_info() {
    echo -e "${YELLOW}ℹ  $1${NC}"
}

# ============================================
# SECCIÓN 1: Docker Compose (20 puntos)
# ============================================

validate_docker_compose() {
    print_header "SECCIÓN 1: DOCKER COMPOSE (20 puntos)"
    local section_score=0
    
    # Test 1: Archivo existe (5pts)
    print_test "1.1. Archivo docker-compose.yml existe"
    if [ -f "docker-compose.yml" ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Archivo docker-compose.yml no encontrado"
        DOCKER_COMPOSE_POINTS=$section_score
        return 1
    fi
    
    # Test 2: Sintaxis YAML válida (5pts)
    print_test "1.2. Sintaxis YAML es válida"
    if docker compose config > /dev/null 2>&1; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Error en sintaxis YAML"
        DOCKER_COMPOSE_POINTS=$section_score
        return 1
    fi
    
    # Test 3: Servicios requeridos (10pts - 2.5 por servicio)
    print_test "1.3. Servicio postgres-america definido"
    if docker compose config 2>/dev/null | grep -q "postgres-america:"; then
        print_pass 2.5
        ((section_score+=2))
    else
        print_fail "Servicio postgres-america no encontrado"
    fi
    
    print_test "1.4. Servicio mysql-europe definido"
    if docker compose config 2>/dev/null | grep -q "mysql-europe:"; then
        print_pass 2.5
        ((section_score+=3))
    else
        print_fail "Servicio mysql-europe no encontrado"
    fi
    
    print_test "1.5. Servicio symmetricds-america definido"
    if docker compose config 2>/dev/null | grep -q "symmetricds-america:"; then
        print_pass 2.5
        ((section_score+=2))
    else
        print_fail "Servicio symmetricds-america no encontrado"
    fi
    
    print_test "1.6. Servicio symmetricds-europe definido"
    if docker compose config 2>/dev/null | grep -q "symmetricds-europe:"; then
        print_pass 2.5
        ((section_score+=3))
    else
        print_fail "Servicio symmetricds-europe no encontrado"
    fi
    
    DOCKER_COMPOSE_POINTS=$section_score
    echo ""
    echo -e "${BLUE}  Subtotal Sección 1: ${BOLD}$DOCKER_COMPOSE_POINTS / $DOCKER_COMPOSE_MAX puntos${NC}"
}

# ============================================
# SECCIÓN 2: Contenedores Corriendo (20 puntos)
# ============================================

validate_containers() {
    print_header "SECCIÓN 2: CONTENEDORES EN EJECUCIÓN (20 puntos)"
    local section_score=0
    
    print_info "Levantando servicios Docker..."
    if ! docker compose up -d > /dev/null 2>&1; then
        print_fail "Error al levantar servicios"
        CONTAINERS_POINTS=0
        return 1
    fi
    
    print_info "Esperando inicialización (60 segundos)..."
    sleep 60
    
    # Test 1: PostgreSQL corriendo (5pts)
    print_test "2.1. Contenedor postgres-america está corriendo"
    if docker compose ps | grep -q "postgres-america.*Up"; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Contenedor postgres-america no está corriendo"
    fi
    
    # Test 2: MySQL corriendo (5pts)
    print_test "2.2. Contenedor mysql-europe está corriendo"
    if docker compose ps | grep -q "mysql-europe.*Up"; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Contenedor mysql-europe no está corriendo"
    fi
    
    # Test 3: SymmetricDS América corriendo (5pts)
    print_test "2.3. Contenedor symmetricds-america está corriendo"
    if docker compose ps | grep -q "symmetricds-america.*Up"; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Contenedor symmetricds-america no está corriendo"
    fi
    
    # Test 4: SymmetricDS Europa corriendo (5pts)
    print_test "2.4. Contenedor symmetricds-europe está corriendo"
    if docker compose ps | grep -q "symmetricds-europe.*Up"; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Contenedor symmetricds-europe no está corriendo"
    fi
    
    CONTAINERS_POINTS=$section_score
    echo ""
    echo -e "${BLUE}  Subtotal Sección 2: ${BOLD}$CONTAINERS_POINTS / $CONTAINERS_MAX puntos${NC}"
}

# ============================================
# SECCIÓN 3: Bases de Datos (15 puntos)
# ============================================

validate_databases() {
    print_header "SECCIÓN 3: CONEXIÓN A BASES DE DATOS (15 puntos)"
    local section_score=0
    
    # Test 1: Conexión PostgreSQL (5pts)
    print_test "3.1. Conexión a PostgreSQL funciona"
    if docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT 1;" > /dev/null 2>&1; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "No se puede conectar a PostgreSQL"
    fi
    
    # Test 2: Tablas existen en PostgreSQL (5pts)
    print_test "3.2. Tablas de negocio existen en PostgreSQL"
    local pg_tables=$(docker exec postgres-america psql -U symmetricds -d globalshop -t -c \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('products','inventory','customers','promotions');" 2>/dev/null | tr -d ' ')
    if [ "$pg_tables" = "4" ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Faltan tablas en PostgreSQL (encontradas: $pg_tables/4)"
    fi
    
    # Test 3: Conexión MySQL (5pts)
    print_test "3.3. Conexión a MySQL funciona"
    if docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT 1;" > /dev/null 2>&1; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "No se puede conectar a MySQL"
    fi
    
    DATABASES_POINTS=$section_score
    echo ""
    echo -e "${BLUE}  Subtotal Sección 3: ${BOLD}$DATABASES_POINTS / $DATABASES_MAX puntos${NC}"
}

# ============================================
# SECCIÓN 4: SymmetricDS (15 puntos)
# ============================================

validate_symmetricds() {
    print_header "SECCIÓN 4: SYMMETRICDS CONFIGURACIÓN (15 puntos)"
    local section_score=0
    
    # Test 1: Tablas SymmetricDS en PostgreSQL (5pts)
    print_test "4.1. Tablas SymmetricDS creadas en PostgreSQL"
    local sym_tables=$(docker exec postgres-america psql -U symmetricds -d globalshop -t -c \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'sym_%';" 2>/dev/null | tr -d ' ')
    if [ "$sym_tables" -gt 30 ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Tablas SymmetricDS insuficientes en PostgreSQL ($sym_tables < 30)"
    fi
    
    # Test 2: Tablas SymmetricDS en MySQL (5pts)
    print_test "4.2. Tablas SymmetricDS creadas en MySQL"
    local sym_tables_mysql=$(docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -N -e \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='globalshop' AND table_name LIKE 'sym_%';" 2>/dev/null)
    if [ "$sym_tables_mysql" -gt 30 ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Tablas SymmetricDS insuficientes en MySQL ($sym_tables_mysql < 30)"
    fi
    
    # Test 3: Grupos de nodos configurados (5pts)
    print_test "4.3. Grupos de nodos configurados"
    local node_groups=$(docker exec postgres-america psql -U symmetricds -d globalshop -t -c \
        "SELECT COUNT(*) FROM sym_node_group;" 2>/dev/null | tr -d ' ')
    if [ "$node_groups" -ge 2 ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "Grupos de nodos insuficientes ($node_groups < 2)"
    fi
    
    SYMMETRICDS_POINTS=$section_score
    echo ""
    echo -e "${BLUE}  Subtotal Sección 4: ${BOLD}$SYMMETRICDS_POINTS / $SYMMETRICDS_MAX puntos${NC}"
}

# ============================================
# SECCIÓN 5: Replicación (30 puntos)
# ============================================

validate_replication() {
    print_header "SECCIÓN 5: REPLICACIÓN BIDIRECCIONAL (30 puntos)"
    local section_score=0
    
    print_info "Esperando tiempo adicional para replicación ($WAIT_TIME segundos)..."
    sleep $WAIT_TIME
    
    # Limpiar datos de prueba previos
    docker exec postgres-america psql -U symmetricds -d globalshop -c \
        "DELETE FROM products WHERE product_id IN ('CALIFICA-PG-001', 'CALIFICA-MY-001');" > /dev/null 2>&1
    docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e \
        "DELETE FROM products WHERE product_id IN ('CALIFICA-PG-001', 'CALIFICA-MY-001');" > /dev/null 2>&1
    sleep 5
    
    # Test 1: INSERT PostgreSQL → MySQL (10pts)
    print_test "5.1. INSERT: PostgreSQL → MySQL"
    docker exec postgres-america psql -U symmetricds -d globalshop -c \
        "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) 
         VALUES ('CALIFICA-PG-001', 'Test Calificacion PG', 'Test', 100.00, 'Test replication', true);" > /dev/null 2>&1
    
    sleep $WAIT_TIME
    
    local count_mysql=$(docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -N -e \
        "SELECT COUNT(*) FROM products WHERE product_id = 'CALIFICA-PG-001';" 2>/dev/null)
    
    if [ "$count_mysql" = "1" ]; then
        print_pass 10
        ((section_score+=10))
    else
        print_fail "Dato no replicado a MySQL (encontrados: $count_mysql)"
    fi
    
    # Test 2: INSERT MySQL → PostgreSQL (10pts)
    print_test "5.2. INSERT: MySQL → PostgreSQL"
    docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e \
        "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) 
         VALUES ('CALIFICA-MY-001', 'Test Calificacion MY', 'Test', 150.00, 'Test replication', 1);" > /dev/null 2>&1
    
    sleep $WAIT_TIME
    
    local count_pg=$(docker exec postgres-america psql -U symmetricds -d globalshop -t -A -c \
        "SELECT COUNT(*) FROM products WHERE product_id = 'CALIFICA-MY-001';" 2>/dev/null)
    
    if [ "$count_pg" = "1" ]; then
        print_pass 10
        ((section_score+=10))
    else
        print_fail "Dato no replicado a PostgreSQL (encontrados: $count_pg)"
    fi
    
    # Test 3: UPDATE bidireccional (5pts)
    print_test "5.3. UPDATE: PostgreSQL → MySQL"
    docker exec postgres-america psql -U symmetricds -d globalshop -c \
        "UPDATE products SET base_price = 99.99 WHERE product_id = 'CALIFICA-PG-001';" > /dev/null 2>&1
    
    sleep $WAIT_TIME
    
    local updated_price=$(docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -N -e \
        "SELECT base_price FROM products WHERE product_id = 'CALIFICA-PG-001';" 2>/dev/null)
    
    if [ "$updated_price" = "99.99" ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "UPDATE no replicado (precio: $updated_price != 99.99)"
    fi
    
    # Test 4: DELETE bidireccional (5pts)
    print_test "5.4. DELETE: MySQL → PostgreSQL"
    docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e \
        "DELETE FROM products WHERE product_id = 'CALIFICA-MY-001';" > /dev/null 2>&1
    
    sleep $WAIT_TIME
    
    local deleted_count=$(docker exec postgres-america psql -U symmetricds -d globalshop -t -A -c \
        "SELECT COUNT(*) FROM products WHERE product_id = 'CALIFICA-MY-001';" 2>/dev/null)
    
    if [ "$deleted_count" = "0" ]; then
        print_pass 5
        ((section_score+=5))
    else
        print_fail "DELETE no replicado (registros encontrados: $deleted_count)"
    fi
    
    REPLICATION_POINTS=$section_score
    echo ""
    echo -e "${BLUE}  Subtotal Sección 5: ${BOLD}$REPLICATION_POINTS / $REPLICATION_MAX puntos${NC}"
}

# ============================================
# Reporte Final
# ============================================

generate_report() {
    print_header "REPORTE FINAL DE CALIFICACIÓN"
    
    TOTAL_SCORE=$((DOCKER_COMPOSE_POINTS + CONTAINERS_POINTS + DATABASES_POINTS + SYMMETRICDS_POINTS + REPLICATION_POINTS))
    
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${BOLD}          DESGLOSE DE PUNTUACIÓN                    ${NC}${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} %-40s ${YELLOW}%4d${NC}/${GREEN}%4d${NC} ${CYAN}│${NC}\n" "1. Docker Compose" $DOCKER_COMPOSE_POINTS $DOCKER_COMPOSE_MAX
    printf "${CYAN}│${NC} %-40s ${YELLOW}%4d${NC}/${GREEN}%4d${NC} ${CYAN}│${NC}\n" "2. Contenedores en Ejecución" $CONTAINERS_POINTS $CONTAINERS_MAX
    printf "${CYAN}│${NC} %-40s ${YELLOW}%4d${NC}/${GREEN}%4d${NC} ${CYAN}│${NC}\n" "3. Conexión a Bases de Datos" $DATABASES_POINTS $DATABASES_MAX
    printf "${CYAN}│${NC} %-40s ${YELLOW}%4d${NC}/${GREEN}%4d${NC} ${CYAN}│${NC}\n" "4. SymmetricDS Configuración" $SYMMETRICDS_POINTS $SYMMETRICDS_MAX
    printf "${CYAN}│${NC} %-40s ${YELLOW}%4d${NC}/${GREEN}%4d${NC} ${CYAN}│${NC}\n" "5. Replicación Bidireccional" $REPLICATION_POINTS $REPLICATION_MAX
    echo -e "${CYAN}├─────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} ${BOLD}%-40s${NC} ${YELLOW}${BOLD}%4d${NC}/${GREEN}${BOLD}%4d${NC} ${CYAN}│${NC}\n" "CALIFICACIÓN FINAL" $TOTAL_SCORE $MAX_SCORE
    echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"
    
    echo ""
    
    # Determinar nivel
    local percentage=$((TOTAL_SCORE * 100 / MAX_SCORE))
    
    if [ $percentage -ge 90 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${BOLD}   CALIFICACIÓN: EXCELENTE (A) - ${percentage}%              ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    elif [ $percentage -ge 80 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${BOLD}   CALIFICACIÓN: BUENO (B) - ${percentage}%                  ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
    elif [ $percentage -ge 70 ]; then
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${BOLD}   CALIFICACIÓN: ACEPTABLE (C) - ${percentage}%             ${NC}${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════╝${NC}"
    elif [ $percentage -ge 60 ]; then
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${BOLD}   CALIFICACIÓN: SUFICIENTE (D) - ${percentage}%            ${NC}${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${BOLD}   CALIFICACIÓN: INSUFICIENTE (F) - ${percentage}%          ${NC}${RED}║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════╝${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}Retroalimentación:${NC}"
    echo ""
    
    if [ $DOCKER_COMPOSE_POINTS -lt $DOCKER_COMPOSE_MAX ]; then
        echo -e "  ${YELLOW}→${NC} Docker Compose: Revisa la estructura del archivo y los servicios definidos"
    fi
    
    if [ $CONTAINERS_POINTS -lt $CONTAINERS_MAX ]; then
        echo -e "  ${YELLOW}→${NC} Contenedores: Asegúrate de que todos los servicios se levanten correctamente"
    fi
    
    if [ $DATABASES_POINTS -lt $DATABASES_MAX ]; then
        echo -e "  ${YELLOW}→${NC} Bases de Datos: Verifica las credenciales y que las tablas estén creadas"
    fi
    
    if [ $SYMMETRICDS_POINTS -lt $SYMMETRICDS_MAX ]; then
        echo -e "  ${YELLOW}→${NC} SymmetricDS: Configura correctamente los grupos de nodos y triggers"
    fi
    
    if [ $REPLICATION_POINTS -lt $REPLICATION_MAX ]; then
        echo -e "  ${YELLOW}→${NC} Replicación: La replicación bidireccional no está funcionando completamente"
        echo -e "     ${YELLOW}•${NC} Revisa los logs: ${CYAN}docker compose logs symmetricds-america${NC}"
        echo -e "     ${YELLOW}•${NC} Revisa los logs: ${CYAN}docker compose logs symmetricds-europe${NC}"
    fi
    
    if [ $TOTAL_SCORE -eq $MAX_SCORE ]; then
        echo -e "  ${GREEN}✓${NC} ${BOLD}¡Excelente trabajo! Todas las pruebas pasaron correctamente.${NC}"
    fi
    
    echo ""
    
    # Guardar reporte
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="calificacion_${timestamp}.txt"
    
    {
        echo "======================================================"
        echo "  REPORTE DE CALIFICACIÓN AUTOMÁTICA - ABDD"
        echo "======================================================"
        echo "Fecha: $(date)"
        echo ""
        echo "PUNTUACIÓN DETALLADA:"
        echo "  1. Docker Compose:           $DOCKER_COMPOSE_POINTS / $DOCKER_COMPOSE_MAX"
        echo "  2. Contenedores:             $CONTAINERS_POINTS / $CONTAINERS_MAX"
        echo "  3. Bases de Datos:           $DATABASES_POINTS / $DATABASES_MAX"
        echo "  4. SymmetricDS:              $SYMMETRICDS_POINTS / $SYMMETRICDS_MAX"
        echo "  5. Replicación:              $REPLICATION_POINTS / $REPLICATION_MAX"
        echo "  ──────────────────────────────────────────"
        echo "  TOTAL:                       $TOTAL_SCORE / $MAX_SCORE"
        echo ""
        echo "  Porcentaje:                  ${percentage}%"
        echo "======================================================"
    } > "$report_file"
    
    echo -e "${GREEN}${BOLD}Reporte guardado en:${NC} $report_file"
    echo ""
}

# ============================================
# Limpieza
# ============================================

cleanup() {
    print_header "LIMPIEZA"
    print_info "Deteniendo contenedores..."
    docker compose down -v > /dev/null 2>&1
    echo -e "${GREEN}✓ Ambiente limpio${NC}"
}

# ============================================
# Función Principal
# ============================================

main() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║      SISTEMA DE CALIFICACIÓN AUTOMÁTICA - ABDD            ║"
    echo "║      Replicación Bidireccional con SymmetricDS            ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}Este script calificará automáticamente el examen.${NC}"
    echo -e "${YELLOW}Puntuación máxima: ${BOLD}100 puntos${NC}"
    echo ""
    echo -e "${BLUE}Desglose de puntos:${NC}"
    echo -e "  • Docker Compose:           $DOCKER_COMPOSE_MAX pts"
    echo -e "  • Contenedores:             $CONTAINERS_MAX pts"
    echo -e "  • Bases de Datos:           $DATABASES_MAX pts"
    echo -e "  • SymmetricDS:              $SYMMETRICDS_MAX pts"
    echo -e "  • Replicación:              $REPLICATION_MAX pts"
    echo ""
    read -p "Presiona ENTER para continuar o Ctrl+C para cancelar..."
    
    # Ejecutar validaciones
    validate_docker_compose || true
    validate_containers || true
    validate_databases || true
    validate_symmetricds || true
    validate_replication || true
    
    # Generar reporte
    generate_report
    
    # Limpiar
    cleanup
    
    # Retornar código de salida basado en puntuación
    if [ $TOTAL_SCORE -ge 60 ]; then
        exit 0
    else
        exit 1
    fi
}

# Ejecutar
main
