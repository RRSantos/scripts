Write-Host "`n🔍 Verificando repositórios Git por pushes pendentes..." -ForegroundColor Cyan

# Salva o diretório atual
$baseDir = Get-Location

# Encontra todos os diretórios com .git
$repos = Get-ChildItem -Recurse -Directory -Force -Filter ".git" | ForEach-Object { $_.Parent }

foreach ($repo in $repos) {
    Set-Location $repo.FullName
    Write-Host "`n📁 Verificando repositório: $($repo.FullName)" -ForegroundColor Yellow

    # Tenta buscar dados do remoto
    try {
        git fetch | Out-Null
    } catch {
        Write-Host "⚠️  Falha ao executar 'git fetch'. Pulando..." -ForegroundColor Red
        continue
    }

    # Pega o nome do branch atual
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $remoteBranch = "origin/$currentBranch"

    # Verifica se o branch remoto existe
    $remoteExists = git rev-parse --verify $remoteBranch 2>$null

    if (-not $remoteExists) {
        Write-Host "⚠️  Nenhum branch remoto configurado para o branch atual." -ForegroundColor DarkYellow
        continue
    }

    $local = git rev-parse HEAD
    $remote = git rev-parse $remoteBranch
    $base = git merge-base HEAD $remoteBranch

    if ($local -eq $remote) {
        Write-Host "✅ Tudo sincronizado com o remoto." -ForegroundColor Green
    } elseif ($local -eq $base) {
        Write-Host "⬇️  Precisa puxar commits do remoto." -ForegroundColor Blue
    } elseif ($remote -eq $base) {
        Write-Host "⬆️  Push pendente!" -ForegroundColor Magenta
    } else {
        Write-Host "⚠️  Branch local e remoto divergiram." -ForegroundColor Red
    }
}

Set-Location $baseDir
Write-Host "`n✅ Verificação concluída." -ForegroundColor Cyan
