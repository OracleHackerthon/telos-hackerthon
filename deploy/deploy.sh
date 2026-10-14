#!/usr/bin/env bash
# VM에서 실행: 최신 main 을 받아 다시 빌드하고 상태를 확인한다.
#   cd ~/<저장소> && ./deploy/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f deploy/.env ]; then
  echo "deploy/.env 가 없습니다. .env.example 을 복사해 값을 채우세요." >&2
  exit 1
fi

git pull --ff-only
docker compose -f deploy/docker-compose.yml up -d --build
docker image prune -f >/dev/null

echo "상태 확인 중..."
for i in $(seq 1 30); do
  if curl -fsS http://localhost/api/health; then
    echo
    echo "배포 완료: $(git rev-parse --short HEAD)"
    exit 0
  fi
  sleep 2
done

echo "상태 확인 실패. 로그: docker compose -f deploy/docker-compose.yml logs --tail 50" >&2
exit 1
