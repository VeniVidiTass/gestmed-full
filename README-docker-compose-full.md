# Docker Compose Completo - GestMed Full Stack

Questo docker-compose include tutti i servizi di tutti i submoduli del progetto GestMed.

## Servizi Inclusi

### GestMed WebApp
- **gestmed-postgres**: Database PostgreSQL per l'applicazione principale (porta 5432)
- **gestmed-backend**: API Backend Node.js (porta 3000)
- **gestmed-frontend**: Frontend Vue.js (porta 5173)
- **gestmed-adminer**: Interfaccia web per gestire il database (porta 8080)

### RabbitMQ Spike
- **rabbitmq**: Message broker RabbitMQ con management UI (porte 5672, 8083)
- **rabbit-mongo**: Database MongoDB per i servizi RabbitMQ (porta 27017)
- **mongo-express**: Interfaccia web per MongoDB (porta 8081)
- **rabbit-producer**: Producer Spring Boot (porta 8090) TODO: da togliere
- **rabbit-consumer-email**: Consumer per email
- **rabbit-consumer-sms**: Consumer per SMS
- **maildev**: Server email di test (porte 8082, 8025)

### WebSocket Alive
- **events-postgres**: Database PostgreSQL per eventi WebSocket (porta 5433)
- **events-app**: Applicazione Node.js con WebSocket (porta 3001)
- **events-pgadmin**: pgAdmin per gestire il database eventi (porta 5050)

## Come Utilizzare

### 1. Avvio di tutti i servizi
```bash
docker-compose -f docker-compose-full.yml up -d
```

### 2. Avvio di servizi specifici
```bash
# Solo GestMed WebApp
docker-compose -f docker-compose-full.yml up -d gestmed-postgres gestmed-backend gestmed-frontend gestmed-adminer

# Solo RabbitMQ services
docker-compose -f docker-compose-full.yml up -d rabbitmq rabbit-mongo mongo-express rabbit-producer rabbit-consumer-email rabbit-consumer-sms maildev

# Solo WebSocket Alive
docker-compose -f docker-compose-full.yml up -d events-postgres events-app events-pgadmin
```

### 3. Verifica dello stato
```bash
docker-compose -f docker-compose-full.yml ps
```

### 4. Visualizzazione dei log
```bash
# Tutti i servizi
docker-compose -f docker-compose-full.yml logs -f

# Servizio specifico
docker-compose -f docker-compose-full.yml logs -f gestmed-backend
```

### 5. Stop dei servizi
```bash
docker-compose -f docker-compose-full.yml down
```

### 6. Stop con rimozione dei volumi
```bash
docker-compose -f docker-compose-full.yml down -v
```

## URL di Accesso

| Servizio | URL | Credenziali |
|----------|-----|-------------|
| GestMed Frontend | http://localhost:5173 | - |
| GestMed Backend API | http://localhost:3000 | - |
| Adminer (GestMed DB) | http://localhost:8080 | Server: gestmed-postgres<br>Username: gestmed_user<br>Password: gestmed_password<br>Database: gestmed |
| RabbitMQ Management | http://localhost:8083 | Username: guest<br>Password: guest |
| Mongo Express | http://localhost:8081 | Username: admin<br>Password: admin |
| RabbitMQ Producer | http://localhost:8090 | - |
| MailDev | http://localhost:8082 | - |
| WebSocket Events App | http://localhost:3001 | - |
| pgAdmin (Events DB) | http://localhost:5050 | Email: admin@example.com<br>Password: admin |

## Configurazione Database in pgAdmin

### Per il database GestMed:
- Host: gestmed-postgres
- Port: 5432
- Database: gestmed
- Username: gestmed_user
- Password: gestmed_password

### Per il database Events:
- Host: events-postgres
- Port: 5432
- Database: events_db
- Username: postgres
- Password: password

## Note Importanti

1. **Porte**: Assicurati che tutte le porte elencate sopra siano libere sul tuo sistema
2. **Risorse**: L'avvio di tutti i servizi contemporaneamente richiede risorse significative
3. **Sviluppo**: Per lo sviluppo, è consigliabile avviare solo i servizi necessari
4. **Volumi**: I dati dei database sono persistiti in volumi Docker nominati

## Troubleshooting

### Problemi di porte occupate
Se una porta è già in uso, modifica il docker-compose-full.yml cambiando la porta esterna:
```yaml
ports:
  - "NUOVA_PORTA:PORTA_INTERNA"
```

### Problemi di memoria
Se hai problemi di memoria, avvia i servizi gradualmente:
1. Prima i database
2. Poi i backend
3. Infine i frontend

### Reset completo
Per un reset completo di tutti i dati:
```bash
docker-compose -f docker-compose-full.yml down -v
docker system prune -f
docker-compose -f docker-compose-full.yml up -d
```

### Avviare docker-compose multipli
Per evitare di avere un unico file docker-compose, rabbit-spike e websocket-alive hanno un file docker-compose separato.
Per avviare gestmed e rabbit-spike contemporaneamente, puoi usare:
```bash
docker-compose \
  -f docker-compose-webapp-alive-auth.yml \
  -f rabbit-spike/docker-compose-full.yml \
  -f websocket-alive/docker-compose-full.yml up -d
```
Per rimuovere i Servizi e i loro volumi:
```bash
docker-compose \
  -f docker-compose-webapp-alive-auth.yml \
  -f rabbit-spike/docker-compose-full.yml \
  -f websocket-alive/docker-compose-full.yml \
  down -v
```
