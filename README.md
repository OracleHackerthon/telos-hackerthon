# TELOS Starter

Oracle TELOS Challenge 2026 팀 스타터. 사람용 안내서입니다 (에이전트 규칙은 `AGENTS.md`).

```
브라우저 → web (Next.js: 화면 + /api) → ai (FastAPI: AI 처리) → OpenAI
                      └→ Autonomous DB
```

| 사람 | 역할 | 주로 만지는 곳 |
|---|---|---|
| 예원 | 프론트·발표 | `web/app/**/page.tsx`, `web/components/`, `docs/DEMO_SCRIPT.md` |
| 영진 | API·DB (예비 머지) | `web/app/api/`, `web/lib/db.ts` |
| 승연 | AI·EDA | `ai/`, `research/` |
| 정민 | 인프라·배포·통합(머지) | `deploy/`, `.github/`, 공통 파일, `docs/` |

## 1. 설치 체크리스트 (PowerShell, 목요일 저녁까지)

```powershell
winget install OpenJS.NodeJS.LTS
winget install Git.Git
winget install GitHub.cli
winget install Python.Python.3.12
```
설치 후 **PowerShell을 새로 열고** 확인:
```powershell
node -v          # v20.9 이상
git --version
gh --version
python --version
```

GitHub와 저장소:
```powershell
gh auth login                                   # 브라우저 인증
git config --global user.name "이름"
git config --global user.email "깃허브 이메일"
gh repo clone telos-hackerthon/<저장소>
```
- `telos-hackerthon` 조직 초대 메일을 먼저 수락하세요.

AI 코딩 도구:
- 예원·영진: `npm install -g @openai/codex` → `codex login` (개인 ChatGPT 계정)
- 승연: Codex + 개인 OpenAI API 키 (사용 한도를 꼭 설정)
- `~/.codex/AGENTS.md` (개인 전역 규칙)가 있다면 대회 기간에는 비워 두세요. 팀 규칙과 섞입니다.
- **주최 측 OpenAI 키는 서비스 코드에만** 씁니다. Codex에 넣지 않습니다.

## 2. 로컬 실행

**web (예원·영진)**
```powershell
cd web
npm install
Copy-Item ..\.env.example .env.local    # AI_SERVICE_URL=http://localhost:8000
npm run dev                             # http://localhost:3000
```

**ai (승연, web 작업자도 연결 확인 시 실행)**
```powershell
cd ai
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item ..\.env.example .env          # OPENAI_API_KEY 채우기
uvicorn main:app --reload --port 8000
```
- `Activate.ps1` 실행이 막히면: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

연결 확인: http://localhost:3000 에서 문장을 보내 요약이 오면 성공. `http://localhost:3000/api/health` 에서 `"ai":"up"` 확인.

## 3. 작업 흐름

```powershell
git switch main; git pull
git switch -c feat/<기능>
# Codex 에게: "docs/PLAN.md 의 <기능> 체크리스트대로 구현해"
cd web; npm run build; npm run lint     # web 작업 시 반드시 통과
git status                              # .env 가 섞이지 않았는지 확인
git add <내 폴더>
git commit -m "feat: <설명>"
git push -u origin feat/<기능>
gh pr create --fill
```
- 머지는 정민이 매시 정각에 합니다. CI가 초록불이어야 머지됩니다.
- 머지 공지가 오면 `git switch main; git pull` 후 내 브랜치에 반영: `git switch feat/<기능>; git merge main`
- 다른 사람 폴더나 공통 파일을 바꿔야 하면 직접 고치지 말고 정민에게 요청하세요.
- 키를 실수로 push했다면 지우는 걸로는 안 됩니다. **즉시 알리고 키를 재발급**합니다.

## 4. 문서
- `docs/PLAN.md` 무엇을, 누가, 언제까지
- `docs/API_CONTRACT.md` 화면↔API↔AI 주고받는 형태
- `docs/OCI_RUNBOOK.md` 배포·장애 대응
- `docs/DEMO_SCRIPT.md` 발표·시연

## 5. 정민: 스타터 마무리 (한 번만)
shadcn/ui 초기화는 이 저장소에 아직 포함되어 있지 않습니다. 정민 노트북에서:
```powershell
cd web
npx shadcn@latest init --defaults
npx shadcn@latest add button card input textarea label sonner
npm run build
```
결과를 PR로 올려 머지합니다.
