// MOCK: test - 실제 구현 전 임시 응답
import { ok, fail } from "@/lib/api";

export async function POST(req: Request) {
  const body: unknown = await req.json().catch(() => null);
  if (
    !body ||
    typeof body !== "object" ||
    !("text" in body) ||
    typeof body.text !== "string" ||
    !body.text.trim()
  ) {
    return fail("text 가 비어 있거나 문자열이 아닙니다", 400);
  }

  return ok({ answer: "테스트 응답입니다." });
}
