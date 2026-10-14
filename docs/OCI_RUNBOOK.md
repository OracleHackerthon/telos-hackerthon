# OCI_RUNBOOK (담당: 정민)

비밀값(키 파일, 비밀번호, 접속 문자열)은 이 문서에 적지 않는다. 위치만 적는다.
`[미검증]` 표시는 목요일 리허설 후 실제 결과로 고친다.

## 리소스
| 항목 | 값 |
|---|---|
| 리전 | |
| VM | Oracle Linux, 사용자 `opc`, Shape: |
| 공인 IP | |
| SSH 키 위치 | 정민 노트북 `C:\Users\<이름>\.ssh\` |
| Autonomous DB | 이름: / 접속 정보: VM `deploy/.env` |

## 접속
```powershell
ssh -i "$env:USERPROFILE\.ssh\<키파일>.key" opc@<공인IP>
```
- 시간 초과: 인스턴스 상태(RUNNING), 공용 서브넷, Security List 22번 확인
- 네트워크가 22번을 막으면: 휴대폰 핫스팟, 또는 OCI 콘솔 Cloud Shell `[미검증]`
- Shape 변경은 재부팅을 일으키므로 대회 중에는 하지 않는다

## 최초 세팅 (VM, 한 번만)
```bash
# Docker
sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin   # 충돌 시 --allowerasing
sudo systemctl enable --now docker
sudo usermod -aG docker opc        # 재접속 필요

# 방화벽 (Oracle Linux 는 firewalld)
sudo firewall-cmd --permanent --add-service=http --add-service=https
sudo firewall-cmd --reload
```
- OCI 콘솔: 공용 서브넷 Security List Ingress에 TCP 80, 443 (Source 0.0.0.0/0)
- 메모리가 작으면 스왑 추가 `[미검증]`

## 저장소 받기
```bash
sudo dnf install -y git
git clone https://github.com/OracleHackerthon/<저장소>.git
cd <저장소>
cp .env.example deploy/.env && vi deploy/.env   # 값 채우기
chmod +x deploy/deploy.sh
```
공개 저장소라 Deploy Key 없이 clone 가능하다.

## 배포
```bash
cd ~/<저장소> && ./deploy/deploy.sh
```
- `git pull` → 이미지 빌드 → 실행 → `/api/health` 확인까지 자동
- 확인: 브라우저 `http://<공인IP>/api/health` → `{"ok":true,"data":{"web":"up","ai":"up"}}`
- DB 확인: `http://<공인IP>/api/db-check`

## 롤백
```bash
git log --oneline -5                       # 정상이던 커밋 확인
git checkout <커밋> && docker compose -f deploy/docker-compose.yml up -d --build
# 복구 후 다시 main 으로: git checkout main
```
정상 배포마다 태그를 단다: `git tag ok-<시각> && git push --tags`

## 장애 체크리스트
1. `docker compose -f deploy/docker-compose.yml ps` — 컨테이너가 다 떠 있는가
2. `docker compose -f deploy/docker-compose.yml logs --tail 50 web` (또는 `ai`, `caddy`)
3. `curl localhost/api/health` — VM 안에서는 되는가 (되면 방화벽/Security List 문제)
4. `ai: down` — ai 로그, `OPENAI_API_KEY` 확인
5. db-check 실패 — `DB_CONNECT_STRING`, ADB 네트워크 접근 설정 확인

## HTTPS
`deploy/.env` 의 `SITE_ADDRESS` 를 도메인으로 바꾸면 Caddy가 인증서를 자동 발급한다.
도메인이 없으면 `<IP를-하이픈으로>.sslip.io` 형식을 쓸 수 있다 `[미검증]`.

## Autonomous DB 연결 `[미검증]`
- 지갑 없는 TLS 접속 문자열을 `DB_CONNECT_STRING` 에 넣는 방식으로 시작한다.
- ADB 네트워크 접근 제어(ACL)에 VM 공인 IP 추가가 필요할 수 있다.
