# leader — 扫一遍本机，看有哪些 AI 命令行能拉来当工人（Windows PowerShell）
#
# 只读：不联网、不花任何额度、不修改任何文件。
# 只对「已知名单」里的命令跑 --help；生面孔一律只列不跑。
#
# 用法：powershell -ExecutionPolicy Bypass -File scan-crew.ps1
#
# ✅ 2026-08-20 已在真实 Windows（24H2 / PowerShell 5.1）实测并修复两处：
#    ① 本文件必须存成「UTF-8 带 BOM」。不带 BOM 时 PowerShell 5.1 按 GBK 解析，
#       双字节错位会吞掉紧跟中文后面的引号和美元号 —— 字符串提前闭合导致源码被当文本打印、
#       变量插值失效（实测输出成「位置:(claude.exe.Source)」）。改中文时别把 BOM 弄丢。
#    ② 判定标准从「只看有没有一次性模式」收紧为两条（见 $OneShot / $CanEdit）：
#       ollama 这类只会跑模型、不会改文件的运行时曾被误判为合格工人。

# 让老终端（代码页 936）也能正常吐中文和 ✅/⚠️ 这类符号
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$Known = @(
  'claude','codex','gemini','copilot','grok','cursor-agent','windsurf','amp','goose','crush',
  'opencode','aider','cline','roo','openhands','devin','warp','auggie','droid','plandex',
  'interpreter','sgpt','llm','ollama','qodo',
  'trae','qoder','qoderclicn','qodercn','qoder-cn','lingma','qwen','kimi','codegeex','codebuddy','comate','iflow','deepseek','minimax','codearts'
)

# 🔴 ai / code 必须卡词边界，否则 tail / wait / mail / recode / codegen 全会误报
$AiPat = '(^|[-_.])ai([-_.]|$)|gpt|llm|agent|(^|[-_])cod(e|er)([-_]|$)|code$|coder$|chat|bot$|claude|gemini|grok|qwen|kimi|copilot|cursor|trae|qoder|anthropic|openai|deepseek|moonshot|zhipu|minimax'
$Noise = 'ssh-agent|agentxtrap|codesign|codec|aircrack|(en|de)code'
$OneShot = '(^|[^a-z])(-p|--print|--prompt|--single|--non-?interactive|--headless)([^a-z]|$)|(^|\s)(exec|run)(\s|$)'
# 🔴 光有 -p / run / exec 不够：ollama run MODEL 也匹配，但它只是模型运行时，不会改文件。
#    再查一条"看得出会动文件"的证据，分出中间档，生死交给冒烟测试定。
#    注意词边界：ollama 帮助里有 "Modelfile"，不卡边界会被 file 误收。
$CanEdit = 'edit|write|patch|diff|apply|workspace|sandbox|repo(sitory)?|permission|(^|[^a-z])files?([^a-z]|$)|(^|[^a-z])(cwd|dir|directory)([^a-z]|$)'

Write-Output "================ leader 包工队扫描 ================"
Write-Output "（只读；下面第 ① 段会对已知 CLI 跑 --help，不消耗任何额度）"
Write-Output ""

Write-Output "───── ① 点名：已知的 AI 命令行 ─────"
$found = 0
foreach ($c in $Known) {
  # -CommandType Application：只认真实可执行文件，排掉内置关键字/函数造成的误报
  $cmd = Get-Command $c -CommandType Application -ErrorAction SilentlyContinue
  if (-not $cmd) { continue }
  $found++
  $help = ''
  try {
    $job = Start-Job -ScriptBlock { param($n) & $n --help 2>&1 | Out-String } -ArgumentList $c
    if (Wait-Job $job -Timeout 8) { $help = Receive-Job $job } else { Stop-Job $job }
    Remove-Job $job -Force
  } catch { $help = '' }

  if ($help -match $OneShot -and $help -match $CanEdit) {
    Write-Output "  ✅ $c —— 有一次性干活模式，也看得出能动文件，够格当工人（仍需冒烟）"
  } elseif ($help -match $OneShot) {
    Write-Output "  🟡 $c —— 有一次性干活模式，但没看出它能改文件（可能只是模型运行时，如 ollama）；冒烟时重点验"
  } else {
    Write-Output "  ⚠️  $c —— 装着，但没看到一次性干活模式（可能只是聊天工具，或 --help 打不开）"
  }
  Write-Output "        位置：$($cmd.Source)"
}
if ($found -eq 0) { Write-Output "  （名单里的一个都没装 —— 走光杆司令模式即可开工）" }

Write-Output ""
Write-Output "───── ② 翻抽屉：名单外的生面孔（只列不跑）─────"
Get-Command -CommandType Application, ExternalScript -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Name |
  ForEach-Object { $_ -replace '\.(exe|cmd|bat|ps1)$', '' } |
  Sort-Object -Unique |
  Where-Object { $_ -match $AiPat -and $_ -notmatch $Noise -and $Known -notcontains $_ } |
  Select-Object -First 40 |
  ForEach-Object { Write-Output "  ? $_" }
Write-Output "  （这些是靠名字猜的，可能有误伤；要不要试，由老板定）"

Write-Output ""
Write-Output "───── ③ 翻安装记录：命令名猜不到的漏网 ─────"
$installed = @()
foreach ($m in @('npm ls -g --depth=0', 'pipx list', 'winget list', 'scoop list', 'choco list --local-only')) {
  try { $installed += (Invoke-Expression $m 2>$null | Out-String) -split "`n" } catch {}
}
$installed | Where-Object { $_ -match $AiPat -and $_ -notmatch $Noise } |
  Sort-Object -Unique | Select-Object -First 30 |
  ForEach-Object { Write-Output "  · $($_.Trim())" }

Write-Output ""
Write-Output "───── ④ 翻小名：老板自己起的别名 ─────"
Get-Alias -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match $AiPat -or $_.Definition -match $AiPat } |
  ForEach-Object { Write-Output "  · $($_.Name) -> $($_.Definition)" }
if (Test-Path $PROFILE) {
  Select-String -Path $PROFILE -Pattern 'Set-Alias|function ' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -match $AiPat } |
    ForEach-Object { Write-Output "  · $($_.Line.Trim())" }
}

Write-Output ""
Write-Output "================ 扫完了 ================"
Write-Output "接下来（工头照做）："
Write-Output "  1. ✅ 那批：跑一次冒烟测试（空目录建文件、亲眼确认）才算上岗 —— 要花一点额度，先问老板。"
Write-Output "  1b. 🟡 那批：老板点头才试；冒烟时必须亲眼看到它建出文件，建不出就是模型运行时，不录用。"
Write-Output "  2. ⚠️ / ? 那批：只列给老板看，别擅自动。"
Write-Output "  3. 录用的按 crew.md「六、如何接入新 CLI」写进工种表。"
Write-Output "  4. 提醒老板：藏在非常规位置、或要先切环境才出现的工具扫不到 —— 想起来直接报名字。"
