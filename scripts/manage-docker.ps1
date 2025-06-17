# Script PowerShell per gestire il Docker Compose completo
# Gestione semplificata di tutti i servizi GestMed

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "clean", "gestmed", "rabbit", "websocket", "help")]
    [string]$Action,
    
    [string]$Service = ""
)

$ComposeFile = "docker-compose-full.yml"

function Show-Help {
    Write-Host "=== Script di Gestione Docker Compose GestMed ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Utilizzo: .\manage-docker.ps1 -Action <azione> [-Service <servizio>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Azioni disponibili:" -ForegroundColor Cyan
    Write-Host "  start     - Avvia tutti i servizi o servizi specifici"
    Write-Host "  stop      - Ferma tutti i servizi"
    Write-Host "  restart   - Riavvia tutti i servizi"
    Write-Host "  status    - Mostra lo stato dei servizi"
    Write-Host "  logs      - Mostra i log (aggiungi -Service per servizio specifico)"
    Write-Host "  clean     - Ferma tutto e rimuove volumi"
    Write-Host "  gestmed   - Avvia solo i servizi GestMed WebApp"
    Write-Host "  rabbit    - Avvia solo i servizi RabbitMQ"
    Write-Host "  websocket - Avvia solo i servizi WebSocket"
    Write-Host "  help      - Mostra questo aiuto"
    Write-Host ""
    Write-Host "Esempi:" -ForegroundColor Yellow
    Write-Host "  .\manage-docker.ps1 -Action start"
    Write-Host "  .\manage-docker.ps1 -Action gestmed"
    Write-Host "  .\manage-docker.ps1 -Action logs -Service gestmed-backend"
    Write-Host "  .\manage-docker.ps1 -Action status"
}

function Start-AllServices {
    Write-Host "🚀 Avvio di tutti i servizi..." -ForegroundColor Green
    docker-compose -f $ComposeFile up -d
    Show-ServiceURLs
}

function Start-GestMedServices {
    Write-Host "🏥 Avvio servizi GestMed WebApp..." -ForegroundColor Green
    docker-compose -f $ComposeFile up -d gestmed-postgres gestmed-backend gestmed-frontend gestmed-adminer
    Write-Host "✅ Servizi GestMed avviati!" -ForegroundColor Green
    Write-Host "🌐 Frontend: http://localhost:5173" -ForegroundColor Cyan
    Write-Host "🔧 API: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "🗄️ Adminer: http://localhost:8080" -ForegroundColor Cyan
}

function Start-RabbitServices {
    Write-Host "🐰 Avvio servizi RabbitMQ..." -ForegroundColor Green
    docker-compose -f $ComposeFile up -d rabbitmq rabbit-mongo mongo-express rabbit-producer rabbit-consumer-email rabbit-consumer-sms maildev
    Write-Host "✅ Servizi RabbitMQ avviati!" -ForegroundColor Green
    Write-Host "🐰 RabbitMQ Management: http://localhost:8083" -ForegroundColor Cyan
    Write-Host "🍃 Mongo Express: http://localhost:8081" -ForegroundColor Cyan
    Write-Host "📧 MailDev: http://localhost:8082" -ForegroundColor Cyan
    Write-Host "🏭 Producer: http://localhost:8090" -ForegroundColor Cyan
}

function Start-WebSocketServices {
    Write-Host "🔌 Avvio servizi WebSocket..." -ForegroundColor Green
    docker-compose -f $ComposeFile up -d events-postgres events-app events-pgadmin
    Write-Host "✅ Servizi WebSocket avviati!" -ForegroundColor Green
    Write-Host "🔌 WebSocket App: http://localhost:3001" -ForegroundColor Cyan
    Write-Host "🗄️ pgAdmin: http://localhost:5050" -ForegroundColor Cyan
}

function Stop-AllServices {
    Write-Host "🛑 Fermando tutti i servizi..." -ForegroundColor Yellow
    docker-compose -f $ComposeFile down
    Write-Host "✅ Tutti i servizi fermati!" -ForegroundColor Green
}

function Restart-AllServices {
    Write-Host "🔄 Riavvio di tutti i servizi..." -ForegroundColor Yellow
    docker-compose -f $ComposeFile restart
    Write-Host "✅ Tutti i servizi riavviati!" -ForegroundColor Green
}

function Show-Status {
    Write-Host "📊 Stato dei servizi:" -ForegroundColor Cyan
    docker-compose -f $ComposeFile ps
}

function Show-Logs {
    if ($Service -ne "") {
        Write-Host "📋 Log del servizio $Service:" -ForegroundColor Cyan
        docker-compose -f $ComposeFile logs -f $Service
    } else {
        Write-Host "📋 Log di tutti i servizi:" -ForegroundColor Cyan
        docker-compose -f $ComposeFile logs -f
    }
}

function Clean-Everything {
    Write-Host "🧹 Pulizia completa (fermando servizi e rimuovendo volumi)..." -ForegroundColor Red
    $confirmation = Read-Host "Sei sicuro? Tutti i dati saranno persi! (y/N)"
    if ($confirmation -eq "y" -or $confirmation -eq "Y") {
        docker-compose -f $ComposeFile down -v
        docker system prune -f
        Write-Host "✅ Pulizia completata!" -ForegroundColor Green
    } else {
        Write-Host "❌ Operazione annullata." -ForegroundColor Yellow
    }
}

function Show-ServiceURLs {
    Write-Host ""
    Write-Host "🌐 URL dei Servizi:" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "GestMed Frontend:        http://localhost:5173" -ForegroundColor Cyan
    Write-Host "GestMed Backend API:     http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Adminer (GestMed DB):    http://localhost:8080" -ForegroundColor Cyan
    Write-Host "RabbitMQ Management:     http://localhost:8083" -ForegroundColor Cyan
    Write-Host "Mongo Express:           http://localhost:8081" -ForegroundColor Cyan
    Write-Host "RabbitMQ Producer:       http://localhost:8090" -ForegroundColor Cyan
    Write-Host "MailDev:                 http://localhost:8082" -ForegroundColor Cyan
    Write-Host "WebSocket Events App:    http://localhost:3001" -ForegroundColor Cyan
    Write-Host "pgAdmin (Events DB):     http://localhost:5050" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
}

# Verifica che Docker sia in esecuzione
try {
    docker version | Out-Null
} catch {
    Write-Host "❌ Docker non è in esecuzione o non è installato!" -ForegroundColor Red
    exit 1
}

# Verifica che il file docker-compose esista
if (-not (Test-Path $ComposeFile)) {
    Write-Host "❌ File $ComposeFile non trovato!" -ForegroundColor Red
    exit 1
}

# Esegui l'azione richiesta
switch ($Action) {
    "start" { Start-AllServices }
    "stop" { Stop-AllServices }
    "restart" { Restart-AllServices }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "clean" { Clean-Everything }
    "gestmed" { Start-GestMedServices }
    "rabbit" { Start-RabbitServices }
    "websocket" { Start-WebSocketServices }
    "help" { Show-Help }
    default { 
        Write-Host "❌ Azione non riconosciuta: $Action" -ForegroundColor Red
        Show-Help
    }
}
