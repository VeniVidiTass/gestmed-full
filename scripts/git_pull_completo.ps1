# This script pulls the latest changes from the remote repository and updates submodules.

Write-Host "Pulling main repository..." -ForegroundColor Green
git pull

Write-Host "Updating submodules..." -ForegroundColor Green
git submodule update --remote --merge

Write-Host "Checking submodule status..." -ForegroundColor Green
git submodule foreach git status

Write-Host "Operation completed!" -ForegroundColor Green
