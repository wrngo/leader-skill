#!/usr/bin/env bash
# leader — 扫一遍本机，看有哪些 AI 命令行能拉来当工人（macOS / Linux）
#
# 只读：不联网、不花任何额度、不修改任何文件。
# 只对「已知名单」里的命令跑 --help（判断它有没有"一次性干活模式"）；
# 生面孔一律只列不跑，交给工头/老板决定要不要试。
#
# 用法：bash scan-crew.sh

set -u

KNOWN="claude codex gemini copilot grok cursor-agent windsurf amp goose crush
opencode aider cline roo openhands devin warp auggie droid plandex interpreter
sgpt llm ollama qodo trae qoder lingma qwen kimi codegeex codebuddy comate
iflow deepseek minimax codearts"

# 名字里带"AI 味"的模式（用于捞生面孔）
# 🔴 "ai" / "code" 必须卡在词边界上，否则 tail / wait / mail / rails / recode / codegen 全会误报（实测踩过）
AI_PAT='(^|[-_.])ai([-_.]|$)|gpt|llm|agent|(^|[-_])cod(e|er)([-_]|$)|code$|coder$|chat|bot$|claude|gemini|grok|qwen|kimi|copilot|cursor|trae|qoder|anthropic|openai|deepseek|moonshot|zhipu|minimax'
# 已知会误伤的系统命令
NOISE='ssh-agent|BTLE|KernelEvent|agentxtrap|codesign|codec|aircrack|chattr|pbcopy|xcode|mailagent|(en|de)code'

say() { printf '%s\n' "$*"; }

# 带看门狗的 --help：macOS 没有 timeout 命令，且要防止某些 CLI 卡住等输入
probe() {
  ( "$1" --help </dev/null 2>&1 & p=$!
    ( sleep 8; kill -9 "$p" 2>/dev/null ) >/dev/null 2>&1 & w=$!
    wait "$p" 2>/dev/null; kill -9 "$w" 2>/dev/null ) 2>/dev/null
}

ONESHOT='(^|[^a-z])(-p|--print|--prompt|--single|--non-?interactive|--headless)([^a-z]|$)|(^|[[:space:]])(exec|run)([[:space:]]|$)'

say "================ leader 包工队扫描 ================"
say "（只读；下面第 ① 段会对已知 CLI 跑 --help，不消耗任何额度）"
say ""

say "───── ① 点名：已知的 AI 命令行 ─────"
FOUND=0
for c in $KNOWN; do
  p=$(command -v "$c" 2>/dev/null)
  # 必须是硬盘上的真实文件：shell 关键字（如 continue）也会被 command -v 认领
  case "$p" in /*) ;; *) continue ;; esac
  FOUND=$((FOUND + 1))
  h=$(probe "$c")
  if printf '%s' "$h" | grep -qEi "$ONESHOT"; then
    say "  ✅ $c —— 有一次性干活模式，够格当工人"
  else
    say "  ⚠️  $c —— 装着，但没看到一次性干活模式（可能只是聊天工具，或 --help 打不开）"
  fi
  say "        位置：$p"
done
[ "$FOUND" -eq 0 ] && say "  （名单里的一个都没装 —— 走光杆司令模式即可开工）"

say ""
say "───── ② 翻抽屉：名单外的生面孔（只列不跑）─────"
KNOWN_RE="^($(printf '%s' "$KNOWN" | tr '\n' ' ' | tr -s ' ' | sed 's/ /|/g; s/|$//'))$"
{
  printf '%s\n' "$PATH" | tr ':' '\n'
  ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null   # 工具常只装在某一个 node 版本下
} | sort -u | while IFS= read -r d; do
  [ -d "$d" ] && ls -1 "$d" 2>/dev/null
done | sort -u \
  | grep -Ei "$AI_PAT" \
  | grep -Eiv "$NOISE" \
  | grep -Eiv "$KNOWN_RE" \
  | sed 's/^/  ? /' \
  | head -40
say "  （这些是靠名字猜的，可能有误伤；要不要试，由老板定）"

say ""
say "───── ③ 翻安装记录：命令名猜不到的漏网 ─────"
{
  npm ls -g --depth=0 2>/dev/null
  pnpm ls -g --depth=0 2>/dev/null
  bun pm ls -g 2>/dev/null
  pipx list 2>/dev/null
  uv tool list 2>/dev/null
  cargo install --list 2>/dev/null
  brew list --formula 2>/dev/null
} | grep -Ei "$AI_PAT" | grep -Eiv "$NOISE" | sort -u | sed 's/^/  · /' | head -30

say ""
say "───── ④ 翻小名：老板自己起的别名 ─────"
{
  alias 2>/dev/null
  grep -hE '^[[:space:]]*alias ' "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" 2>/dev/null
} | grep -Ei "$AI_PAT" | sort -u | sed 's/^/  · /' | head -20

say ""
say "================ 扫完了 ================"
say "接下来（工头照做）："
say "  1. ✅ 那批：跑一次冒烟测试（空目录建文件、亲眼确认）才算上岗 —— 要花一点额度，先问老板。"
say "  2. ⚠️ / ? 那批：只列给老板看，别擅自动。"
say "  3. 录用的按 crew.md「六、如何接入新 CLI」写进工种表。"
say "  4. 提醒老板：藏在非常规位置、或要先切环境才出现的工具扫不到 —— 想起来直接报名字。"
