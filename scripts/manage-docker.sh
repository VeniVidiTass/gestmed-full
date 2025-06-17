#!/bin/bash

# Script Bash per gestire il Docker Compose completo
# Gestione semplificata di tutti i servizi GestMed

set -e  # Exit on any error

COMPOSE_FILE="docker-compose-full.yml"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Emoji (compatibili con la maggior parte dei terminali)
ROCKET="🚀"
HOSPITAL="🏥"
RABBIT="🐰"
PLUG="🔌"
STOP="🛑"
RELOAD="🔄"
CHART="📊"
LOG="📋"
CLEAN="🧹"
CHECK="✅"
CROSS="❌"
WORLD="🌐"
GEAR="🔧"
DATABASE="🗄️"
LEAF="🍃"
EMAIL="📧"
FACTORY="🏭"

function show_help() {
    echo -e "${GREEN}=== Script di Gestione Docker Compose GestMed ===${NC}"
    echo ""
    echo -e "${YELLOW}Utilizzo: ./manage-docker.sh <azione> [servizio]${NC}"
    echo ""
    echo -e "${CYAN}Azioni disponibili:${NC}"
    echo "  start     - Avvia tutti i servizi o servizi specifici"
    echo "  stop      - Ferma tutti i servizi"
    echo "  restart   - Riavvia tutti i servizi"
    echo "  status    - Mostra lo stato dei servizi"
    echo "  logs      - Mostra i log (aggiungi servizio per servizio specifico)"
    echo "  clean     - Ferma tutto e rimuove volumi"
    echo "  gestmed   - Avvia solo i servizi GestMed WebApp"
    echo "  rabbit    - Avvia solo i servizi RabbitMQ"
    echo "  websocket - Avvia solo i servizi WebSocket"
    echo "  help      - Mostra questo aiuto"
    echo ""
    echo -e "${YELLOW}Esempi:${NC}"
    echo "  ./manage-docker.sh start"
    echo "  ./manage-docker.sh gestmed"
    echo "  ./manage-docker.sh logs gestmed-backend"
    echo "  ./manage-docker.sh status"
}

function start_all_services() {
    echo -e "${GREEN}${ROCKET} Avvio di tutti i servizi...${NC}"
    docker-compose -f $COMPOSE_FILE up -d
    show_service_urls
}

function start_gestmed_services() {
    echo -e "${GREEN}${HOSPITAL} Avvio servizi GestMed WebApp...${NC}"
    docker-compose -f $COMPOSE_FILE up -d gestmed-postgres gestmed-backend gestmed-frontend gestmed-adminer
    echo -e "${GREEN}${CHECK} Servizi GestMed avviati!${NC}"
    echo -e "${CYAN}${WORLD} Frontend: http://localhost:5173${NC}"
    echo -e "${CYAN}${GEAR} API: http://localhost:3000${NC}"
    echo -e "${CYAN}${DATABASE} Adminer: http://localhost:8080${NC}"
}

function start_rabbit_services() {
    echo -e "${GREEN}${RABBIT} Avvio servizi RabbitMQ...${NC}"
    docker-compose -f $COMPOSE_FILE up -d rabbitmq rabbit-mongo mongo-express rabbit-producer rabbit-consumer-email rabbit-consumer-sms maildev
    echo -e "${GREEN}${CHECK} Servizi RabbitMQ avviati!${NC}"
    echo -e "${CYAN}${RABBIT} RabbitMQ Management: http://localhost:8083${NC}"
    echo -e "${CYAN}${LEAF} Mongo Express: http://localhost:8081${NC}"
    echo -e "${CYAN}${EMAIL} MailDev: http://localhost:8082${NC}"
    echo -e "${CYAN}${FACTORY} Producer: http://localhost:8090${NC}"
}

function start_websocket_services() {
    echo -e "${GREEN}${PLUG} Avvio servizi WebSocket...${NC}"
    docker-compose -f $COMPOSE_FILE up -d events-postgres events-app events-pgadmin
    echo -e "${GREEN}${CHECK} Servizi WebSocket avviati!${NC}"
    echo -e "${CYAN}${PLUG} WebSocket App: http://localhost:3001${NC}"
    echo -e "${CYAN}${DATABASE} pgAdmin: http://localhost:5050${NC}"
}

function stop_all_services() {
    echo -e "${YELLOW}${STOP} Fermando tutti i servizi...${NC}"
    docker-compose -f $COMPOSE_FILE down
    echo -e "${GREEN}${CHECK} Tutti i servizi fermati!${NC}"
}

function restart_all_services() {
    echo -e "${YELLOW}${RELOAD} Riavvio di tutti i servizi...${NC}"
    docker-compose -f $COMPOSE_FILE restart
    echo -e "${GREEN}${CHECK} Tutti i servizi riavviati!${NC}"
}

function show_status() {
    echo -e "${CYAN}${CHART} Stato dei servizi:${NC}"
    docker-compose -f $COMPOSE_FILE ps
}

function show_logs() {
    local service=$1
    if [ -n "$service" ]; then
        echo -e "${CYAN}${LOG} Log del servizio $service:${NC}"
        docker-compose -f $COMPOSE_FILE logs -f "$service"
    else
        echo -e "${CYAN}${LOG} Log di tutti i servizi:${NC}"
        docker-compose -f $COMPOSE_FILE logs -f
    fi
}

function clean_everything() {
    echo -e "${RED}${CLEAN} Pulizia completa (fermando servizi e rimuovendo volumi)...${NC}"
    echo -n "Sei sicuro? Tutti i dati saranno persi! (y/N): "
    read -r confirmation
    if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
        docker-compose -f $COMPOSE_FILE down -v
        docker system prune -f
        echo -e "${GREEN}${CHECK} Pulizia completata!${NC}"
    else
        echo -e "${YELLOW}${CROSS} Operazione annullata.${NC}"
    fi
}

function show_service_urls() {
    echo ""
    echo -e "${GREEN}${WORLD} URL dei Servizi:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}GestMed Frontend:        http://localhost:5173${NC}"
    echo -e "${CYAN}GestMed Backend API:     http://localhost:3000${NC}"
    echo -e "${CYAN}Adminer (GestMed DB):    http://localhost:8080${NC}"
    echo -e "${CYAN}RabbitMQ Management:     http://localhost:8083${NC}"
    echo -e "${CYAN}Mongo Express:           http://localhost:8081${NC}"
    echo -e "${CYAN}RabbitMQ Producer:       http://localhost:8090${NC}"
    echo -e "${CYAN}MailDev:                 http://localhost:8082${NC}"
    echo -e "${CYAN}WebSocket Events App:    http://localhost:3001${NC}"
    echo -e "${CYAN}pgAdmin (Events DB):     http://localhost:5050${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Verifica che Docker sia in esecuzione
if ! docker version &> /dev/null; then
    echo -e "${RED}${CROSS} Docker non è in esecuzione o non è installato!${NC}"
    exit 1
fi

# Verifica che il file docker-compose esista
if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}${CROSS} File $COMPOSE_FILE non trovato!${NC}"
    exit 1
fi

# Gestione argomenti
ACTION=$1
SERVICE=$2

# Verifica che sia stato fornito almeno un argomento
if [ -z "$ACTION" ]; then
    echo -e "${RED}${CROSS} Devi specificare un'azione!${NC}"
    show_help
    exit 1
fi

# Esegui l'azione richiesta
case $ACTION in
    "start")
        start_all_services
        ;;
    "stop")
        stop_all_services
        ;;
    "restart")
        restart_all_services
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$SERVICE"
        ;;
    "clean")
        clean_everything
        ;;
    "gestmed")
        start_gestmed_services
        ;;
    "rabbit")
        start_rabbit_services
        ;;
    "websocket")
        start_websocket_services
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}${CROSS} Azione non riconosciuta: $ACTION${NC}"
        show_help
        exit 1
        ;;
esac
