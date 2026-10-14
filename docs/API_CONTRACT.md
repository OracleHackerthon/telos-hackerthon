# API_CONTRACT

변경은 정민만 한다. 문서를 먼저 고치고, 그다음 코드를 고친다.

## 공통
- 응답 형식: `{ "ok": true, "data": ... }` 또는 `{ "ok": false, "error": "메시지" }`
- 경로
  - 화면 → web: `/api/<기능>` (Next.js, 영진)
  - web → ai: `http://ai:8000/<기능>` (FastAPI, 승연, 내부 전용)

## 템플릿 (복사해서 사용)
### <기능> — 상태: 초안 / 확정
- 화면 → web: `POST /api/<기능>` (담당: 영진)
  - 요청: `{ }`
  - 응답 data: `{ }`
  - 오류: 400 입력 누락 / 502 AI 실패
- web → ai: `POST /<기능>` (담당: 승연)
  - 요청: `{ }`
  - 응답 data: `{ }`

## 확정된 계약

### 샘플: ai-example — 상태: 확정 (연결 확인용, 당일 삭제)
- 화면 → web: `POST /api/ai-example`
  - 요청: `{ "text": "문장" }`
  - 응답 data: `{ "answer": "요약" }`
- web → ai: `POST /example`
  - 요청: `{ "text": "문장" }`
  - 응답 data: `{ "answer": "요약" }`

### health — 상태: 확정
- `GET /api/health` → data: `{ "web": "up", "ai": "up" | "down" }`
- `GET /api/db-check` → data: `{ "result": 1 }`

## 변경 이력
- (날짜 시각) 내용
