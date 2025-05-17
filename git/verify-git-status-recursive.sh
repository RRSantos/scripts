#!/bin/bash

echo "Verificando repositórios Git por pushes pendentes..."

# Salva o diretório atual
BASE_DIR=$(pwd)

# Percorre todas as subpastas contendo um diretório .git
find . -type d -name ".git" | while read gitdir; do
  REPO_DIR=$(dirname "$gitdir")
  cd "$REPO_DIR" || continue

  echo -e "\n📁 Verificando repositório: $REPO_DIR"

  # Verifica se há push pendente
  # Atualiza os dados do repositório remoto sem fazer merge
  git fetch > /dev/null 2>&1

  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u} 2>/dev/null)
  BASE=$(git merge-base @ @{u} 2>/dev/null)

  if [ "$REMOTE" = "" ]; then
    echo "⚠️  Nenhum repositório remoto configurado para o branch atual."
  elif [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Tudo sincronizado com o remoto."
  elif [ "$LOCAL" = "$BASE" ]; then
    echo "⬇️  Precisa puxar commits do remoto."
  elif [ "$REMOTE" = "$BASE" ]; then
    echo "⬆️  Push pendente!"
  else
    echo "⚠️  Branch local e remoto divergiram."
  fi

  # Volta para o diretório base
  cd "$BASE_DIR"
done

echo -e "\n✅ Verificação concluída."
