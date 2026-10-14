# MERGER_CHECKLIST (정민)

정민이 머지·CI·배포·제출 때 확인하는 점검표. 위에서부터 순서대로 본다.
하나라도 걸리면 머지(또는 배포)하지 않고 작성자에게 이유를 한 줄로 알린다.

---

## 0. 리듬
- 머지는 정해진 시각에 몰아서 한다 (예: 매시 정각). 수시로 머지하면 팀원 sync 가 계속 깨진다.
- 순서: **계약·공통 파일 PR → API(MOCK 포함) PR → 화면 PR**. 의존하는 쪽을 나중에 머지한다.
- 통합 배포는 2~3시간마다, 또는 큰 기능이 머지된 직후에 한다.

---

## 1. 머지 전 리뷰 (PR 하나마다)

### 1-1. CI (GitHub PR 화면 아래쪽)
| 체크 | 무엇을 검사하나 | 빨간불이면 |
|---|---|---|
| `review-note` | PR 본문에 `## 자체 리뷰` 와 `비밀값 없음: 예` 가 있는가 | 작성자에게 "`$submit` 으로 다시 올리거나 PR 본문을 고쳐 주세요". 본문만 고쳐도 다시 검사된다 |
| `web` | `npm ci` → `npm run lint` → `npm run build` (타입 검사 포함) | Details 로그 마지막 오류 줄을 작성자에게 전달 |
| `ai` | `pip install` → `python -c "import main"` (문법·import 오류) | 위와 같음 |
| `docker` | web, ai 이미지가 빌드되는가 | 대개 `package.json`/`requirements.txt`/Dockerfile 문제. 정민이 직접 본다 |

- 모두 초록이 아니면 머지 버튼이 막힌다 (Ruleset). **CI 를 우회해서 머지하지 않는다.**
- CI 가 확인하지 못하는 것: 화면이 실제로 동작하는가, 계약과 맞는가, 남의 경로를 건드렸는가 → 아래 1-2~1-4 에서 사람이 본다.

### 1-2. PR 본문 (자체 리뷰)
- [ ] 바뀐 것, 확인 방법이 적혀 있다
- [ ] 담당 경로만 변경: 예
- [ ] 비밀값 없음: 예
- [ ] 계약 일치: 예
- [ ] 남은 MOCK: 적혀 있다 (제목이 `[MOCK]` 이면 해당 파일이 적혀 있어야 한다)

### 1-3. Files changed 탭
| 확인 | 어떻게 보나 | 걸리면 |
|---|---|---|
| 소유권 | 바뀐 파일 경로가 작성자 담당인가 (AGENTS.md 표) | 남의 경로 변경분을 빼달라고 요청 |
| 비밀값 | `.env` 파일, `sk-`, `password`, 접속 문자열, `NEXT_PUBLIC_` + 비밀값 | **머지 금지.** 이미 push 됐으면 키를 즉시 재발급 |
| 계약 | `/api/<기능>` 경로, 요청·응답 필드 이름이 `API_CONTRACT.md` 와 같은가 | 코드가 아니라 계약을 먼저 맞춘다 |
| 연결 규칙 | 화면에서 `ai:8000`/`localhost:8000` 직접 호출, `openai` 를 `ai/llm.py` 밖에서 import, `oracledb` 를 `web/lib/db.ts` 밖에서 사용 | 수정 요청 |
| 패키지 | `package.json`, `package-lock.json`, `requirements.txt` 변경 | 의도한 것인지 확인. lock 파일이 같이 바뀌었는가. 버전 고정(`==`)인가 |
| 크기 | 바뀐 파일이 20개 넘거나 기능 2개 이상 섞임 | 나눠 달라고 요청 (시간 없으면 그대로 받되 동작 확인을 더 꼼꼼히) |
| 디버그 흔적 | `console.log`, `print`, 주석 처리된 큰 코드 | 가벼우면 머지 후 정민이 정리 |

### 1-4. Claude Code 로 함께 리뷰 (정민 PC, 저장소 루트)
```
gh pr checkout <번호>
```
그다음 Claude Code 에게:
```
PR #<번호>를 docs/MERGER_CHECKLIST.md 1-3 기준으로 리뷰해줘.
gh pr diff <번호> 로 변경을 보고, 걸리는 항목만 파일:줄과 함께 알려줘. 코드는 고치지 마.
```
- 화면 PR 이면 `cd web && npm run dev` 로 띄워 **확인 방법에 적힌 대로 직접 눌러 본다.**
- 확인이 끝나면 `git switch main` 으로 돌아온다.

### 1-5. 충돌
- PR 화면에 "This branch has conflicts" 가 뜨면 팀원에게 맡기지 않는다 (팀원 규칙상 충돌 해결 금지).
- 정민이 직접:
  ```
  gh pr checkout <번호>
  git merge origin/main
  # 충돌 파일 정리 → 빌드 확인
  git add <파일> && git commit && git push
  ```
- 같은 파일이 자주 충돌하면 소유권 표가 잘못된 것이다. AGENTS.md 를 고친다.

### 1-6. 머지
- **Squash and merge**. 제목을 `feat: <기능> (<이름>)` 형태로 정리하고, 본문의 자잘한 커밋 목록은 지운다.
- **Delete branch** 를 누른다.

---

## 2. 머지 직후
- [ ] main 의 CI 가 초록인지 확인 (Actions 탭, push 트리거). 빨간불이면 다음 머지를 멈추고 먼저 고친다.
- [ ] 팀 채팅에 공지:
  ```
  #<번호> <기능> 머지했습니다. 모두 $sync 해 주세요.
  (package.json 이 바뀐 경우) sync 후 npm install 이 필요합니다.
  ```
- [ ] `[MOCK]` PR 이었으면: `API_CONTRACT.md` 해당 항목 상태를 **MOCK** 으로 바꾸고, 화면 담당자에게 "연결 시작해도 됩니다" 라고 알린다.
- [ ] MOCK 을 실제로 바꾼 PR 이었으면: 상태를 **실제** 로 바꾼다.

---

## 3. 계약 관리 (정민만 수정)
- 새 기능: 담당자들과 요청·응답을 정해 `API_CONTRACT.md` 에 **확정** 으로 적고 PR → 머지 → 공지.
- 변경 요청이 오면: 화면·API 양쪽 담당자 모두에게 확인 → 문서 먼저 고치고 변경 이력에 시각과 내용 기록 → 양쪽에 알림.
- 현재 MOCK 현황 확인:
  ```
  git switch main && git pull
  grep -rn "MOCK" web/app web/lib ai --include=*.ts --include=*.tsx --include=*.py
  ```

---

## 4. 배포 (OCI VM)

### 4-1. 배포 전
- [ ] main 의 최신 CI 가 초록이다
- [ ] 지금이 심사·발표 시간이 아니다 (배포 중 1~2분 끊김)
- [ ] 마지막 정상 태그를 안다: `git tag -l "ok-*"` (롤백 대상)
- [ ] 이번 배포에 포함된 PR 목록을 안다: `git log --oneline <마지막 ok 태그>..origin/main`

### 4-2. 배포
```
ssh -i <키> <사용자>@<공인IP>
cd ~/<저장소> && ./deploy/deploy.sh
```
- 마지막 줄에 `배포 완료: <커밋>` 이 나와야 한다.
- 메모리가 작은 VM은 빌드가 오래 걸린다. SSH 가 끊길까 걱정되면:
  `nohup ./deploy/deploy.sh > deploy.log 2>&1 & tail -f deploy.log`

### 4-3. 배포 후 확인 (외부 브라우저에서)
| 확인 | 기대 결과 |
|---|---|
| `http://<주소>/api/health` | `{"ok":true,"data":{"web":"up","ai":"up"}}` |
| `http://<주소>/api/db-check` | `{"ok":true,"data":{"result":1}}` |
| 이번에 머지된 기능 화면 | PR "확인 방법" 대로 눌러서 동작 |
| 기존 핵심 기능 (데모 시나리오 1~2번) | 이전처럼 동작 |
| VM에서 `docker compose -f deploy/docker-compose.yml ps` | web, ai, caddy 모두 Up |

- 모두 통과하면 **정민 PC에서** 정상 태그:
  ```
  git fetch origin
  git tag ok-<MMDD-HHMM> origin/main
  git push origin ok-<MMDD-HHMM>
  ```
- 팀 채팅에 "배포 완료: <주소>, 포함 PR #a #b" 공지.

### 4-4. 실패 시
1. `OCI_RUNBOOK.md` 의 장애 체크리스트를 순서대로 본다 (ps → logs → VM 안에서 curl).
2. 10분 안에 원인을 못 찾으면 **먼저 롤백**하고 원인은 나중에 찾는다:
   ```
   git fetch --tags && git checkout ok-<마지막 정상>
   docker compose -f deploy/docker-compose.yml up -d --build
   ```
   복구 후 `git checkout main` 으로 돌려 둔다 (다음 deploy.sh 의 git pull 을 위해).
3. 원인 PR 을 찾으면 GitHub 에서 그 PR 의 **Revert** 버튼으로 되돌리는 PR 을 만들어 머지 → 다시 배포.

---

## 5. 제출 전 (토 14:30 마감, 13:30 부터 시작)
- [ ] 기능 머지 중단 공지 (13:30 이후 머지는 버그 수정만)
- [ ] MOCK 0건: `grep -rn "MOCK" web/app web/lib ai --include=*.ts --include=*.tsx --include=*.py` 결과 없음
  - 남아 있으면: 실제 구현이 불가능한 기능은 화면에서 숨기거나, 시연에 쓰지 않는다
- [ ] 샘플 코드 정리: `ai-example` 화면·API·`/example` 이 남아 있으면 제거하거나 숨김
- [ ] 비밀값 최종 확인: `git log -p | grep -nE "sk-|password=|PASSWORD=" ` 결과가 `.env.example` 의 빈 키 이름뿐
- [ ] 최종 배포 → 4-3 확인 전부 → 최종 태그 `ok-final`
- [ ] `DEMO_SCRIPT.md` 시연 순서를 배포된 주소에서 처음부터 끝까지 한 번 실행
- [ ] 녹화본 확보 (예원), 로컬 실행 가능 확인 (정민 PC에서 `docker compose -f deploy/docker-compose.yml up`)
- [ ] 제출물: 저장소 주소, 서비스 주소, (요구 시) 발표 자료 — 주최 측 양식 확인

---

## 6. 정민이 막히면
- 리뷰가 밀리면: 영진에게 1-1~1-3 만 보고 머지하도록 넘긴다 (영진은 백업 머지 담당).
- VM 이 응답 없음: OCI 콘솔에서 인스턴스 상태 확인 → Reboot (5~15분). 그동안은 로컬 실행으로 시연 준비.
