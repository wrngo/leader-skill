# 工种表（crew）— 谁擅长什么、怎么叫、有什么坑

> 加新 CLI 只需在本文件加一行表格 + 一段「调用模板」+ 一段「已知坑」，SKILL.md 不用改（完整流程见文末「如何接入新 CLI」）。
> 每加一个新工种，**必须先做冒烟测试**（让它在一个空目录建一个文件），亲眼看到文件真的出现才算接入成功。

> 🔧 **使用前必读（配置）**：下面表格和调用模板里的 CLI 命令、模型名（`cursor-grok-4.6-xhigh` / `gpt-5.6-sol` / `kimi-code/k3`）都是**示例默认值**，换成你自己账号里实际安装、实际可用的。没装的工种直接把对应行删掉或标注「未安装」，派活时跳过它。报"未知模型 / unknown model"就是这里没对上——去查该 CLI 的可用模型列表再改，别硬试。

## 零、先认自己（工头开工前必做）

1. **我是谁**：正在读这份表的那个 CLI 就是工头。默认 Claude，但换成 Codex / Kimi / opencode 等照样成立——把下表「工头」那一行理解成"我自己"。
2. **我站在什么系统上**：macOS / Linux → 用下面每个模板的 **bash 栏**；Windows → 用 **PowerShell 栏**（**不需要 WSL**）。
3. **一个外部工人都没有**：走「二、调用模板」最后的**光杆司令模板**——我叫一个一次性的自己进样板间干活，验收流程一字不改。

## 零点五、扫本机有哪些人能用（到岗检查第一步，SKILL 流程 0 调用）

目标：**别只照花名册喊人**——新 CLI 天天出，写死的名单必然漏。四条路一起走，全程**不花钱、不联网、不改任何文件**。

### 首选：直接跑现成脚本（别每次现场手拼命令）

> 📁 **路径以本 skill 实际安装目录为准**（下面的 `<leader 目录>` = 你正在读的这份 crew.md 所在的那个文件夹）。
> Claude Code 装的话通常是 `~/.claude/skills/leader/`；换 Qoder / Codex 当工头时**不是**这个路径，别照抄——
> 找不到就搜一下文件名：`find ~ -name scan-crew.sh 2>/dev/null` / `Get-ChildItem $env:USERPROFILE -Recurse -Filter scan-crew.ps1 -EA SilentlyContinue`。

```bash
bash "<leader 目录>/scan-crew.sh"          # macOS / Linux
```
```powershell
powershell -ExecutionPolicy Bypass -File "<leader 目录>\scan-crew.ps1"   # Windows
```
> 🔴 **Windows 脚本必须保持「UTF-8 带 BOM」存盘**。丢了 BOM，PowerShell 5.1 会按 GBK 读，
> 中文全乱码、字符串会被读断，导致源码被当文本打印出来（2026-08-20 实测踩到，已修）。改中文后确认 BOM 还在。

脚本一次跑完下面四路并直接输出分档结果。**下面的手写命令是脚本跑不起来时的备份**（或者需要临时改花样时照着改）。

### 路① 点名（快，认熟脸）

```bash
# macOS / Linux
for c in claude codex gemini copilot grok cursor-agent windsurf amp goose crush \
         opencode aider cline roo continue openhands devin warp auggie droid \
         plandex interpreter sgpt llm ollama qodo \
         trae qoder qoderclicn qodercn qoder-cn lingma qwen kimi codegeex codebuddy comate iflow deepseek minimax codearts; do
  p=$(command -v "$c" 2>/dev/null); case "$p" in /*) echo "HIT $c -> $p";; esac
done
```
> 🔴 必须用 `case "$p" in /*)` 只认绝对路径：`continue` / `test` 这类名字是 shell 自带关键字，`command -v` 会返回它本身，不加这层过滤就会误报"装了 Continue"。（本机实测踩到过。）
```powershell
# Windows PowerShell
@('claude','codex','gemini','copilot','grok','cursor-agent','windsurf','amp','goose','crush',
  'opencode','aider','cline','roo','continue','openhands','devin','warp','auggie','droid',
  'plandex','interpreter','sgpt','llm','ollama','qodo',
  'trae','qoder','qoderclicn','qodercn','qoder-cn','lingma','qwen','kimi','codegeex','codebuddy','comate','iflow','deepseek','minimax','codearts') |
ForEach-Object { $p=(Get-Command $_ -CommandType Application -ErrorAction SilentlyContinue).Source; if ($p) { "HIT $_ -> $p" } }
# 加 -CommandType Application：只认真实可执行文件，排掉内置关键字/函数造成的误报
```
> 名单是**加速器不是依据**，喊错免费（没人应而已）。发现名单缺了谁，当场补进这段。

### 路② 翻抽屉（慢，认生面孔）

把 PATH 里所有能敲的命令名全列出来，挑带 AI 味的：

```bash
# macOS / Linux
echo "$PATH" | tr ':' '\n' | while read -r d; do [ -d "$d" ] && ls -1 "$d" 2>/dev/null; done \
 | sort -u | grep -Ei 'ai|gpt|llm|agent|cod(e|er)|chat|bot|claude|gemini|grok|qwen|kimi|copilot|cursor|trae|qoder'
# 用 nvm 的还要扫各个 node 版本（工具常只装在某一个版本下）
ls -1 ~/.nvm/versions/node/*/bin 2>/dev/null | sort -u
```
```powershell
# Windows PowerShell
Get-Command -CommandType Application,ExternalScript |
  Select-Object -ExpandProperty Name | Sort-Object -Unique |
  Select-String -Pattern 'ai|gpt|llm|agent|cod(e|er)|chat|bot|claude|gemini|grok|qwen|kimi|copilot|cursor|trae|qoder'
```
> ⚠️ 这一路**噪音大**（`decode`、`aircrack` 之类会命中）。只列不跑，由我肉眼过一遍再决定谁值得问。

### 路③ 翻安装记录（补上"命令名猜不到"的漏网）

```bash
# macOS / Linux — 有哪个跑哪个，报错忽略
npm ls -g --depth=0 2>/dev/null; pnpm ls -g --depth=0 2>/dev/null; bun pm ls -g 2>/dev/null
pipx list 2>/dev/null; uv tool list 2>/dev/null; cargo install --list 2>/dev/null
brew list --formula 2>/dev/null
```
```powershell
# Windows PowerShell
npm ls -g --depth=0; pipx list; winget list; scoop list; choco list --local-only
```
> 包名里带 AI 味但命令名对不上的，从这里能看见。

### 路④ 翻小名（老板自己起的别名）

```bash
alias 2>/dev/null; grep -hE '^\s*alias ' ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile 2>/dev/null
```
```powershell
Get-Alias; if (Test-Path $PROFILE) { Select-String -Path $PROFILE -Pattern 'Set-Alias|function ' }
```

### 资格认定（不花钱，决定它配不配当工人）

对每个命中的候选跑 `--version` 和 `--help`，**只看一件事：有没有"给一段活、干完就退出"的一次性模式**（常见标志：`-p` / `--print` / `--prompt` / `exec` / `run` / `--non-interactive` / `--headless` / `-q`）。
- **没有这个模式 → 直接淘汰**（交互式聊天工具当不了工人，别硬塞）。
- 有 → 进候选名单，把那个参数记下来，后面照「二、调用模板」的五件事拼命令。

### 出三档名单 + 记账

汇报给老板时**必须分三档**，别混成一堆：

| 档 | 含义 | 下一步 |
|---|---|---|
| ✅ 已上岗 | 装了 + 登录了 + 冒烟通过 | 直接派活 |
| ⚠️ 装了没登录 / 没额度 | 命令在，但试跑报未登录 | 告诉老板"登录一下就能用"，先标注跳过 |
| ❓ 疑似候选 | 名字/包名像，也有一次性模式，但没试过 | **只列不跑**，问老板要不要试工 |

- 🔴 **试工（冒烟测试）要花一点额度，必须老板点头才做**：空目录建一个文件 → 亲眼确认文件真实存在且内容正确 → 才算录用。
- 录用后按「六、如何接入新 CLI」把它写进本文件（工种行 + 调用模板 + 已知坑），下次直接能派。
- **漏网是常态**：装在非常规位置、要先切环境才出现（如某些工具只在某个 node 版本下）、或纯图形界面无命令行的，扫不到。汇报时主动加一句"你要是还装了别的，报个名字我直接加"。

## 一、能力/成本表

| 工种 | 命令 | 计费参考 | 派什么 | 不派什么 |
|---|---|---|---|---|
| **Grok**（Cursor CLI，Grok 4.6 Extra High） | `cursor-agent` | Cursor 包月，额度通常充足 → 优先消耗 | 重复体力活：批量改名/替换、按现成模式补样板代码、补单测、写死板文档、格式整理、机械迁移；**已定位到具体行的小 bug 修补**；**搜索 / 调研 / 竞品与资料搜集**；bug 跨工种轮转的第二棒 | 需要拿主意的设计、跨模块架构、含糊需求 |
| **Codex**（`codex exec`，OpenAI 订阅） | `codex` | 订阅制，额度有限 → 省着用在硬活 | 前端/后端功能开发、UI 交互实现（**先图后码**，见下）、要做设计取舍的模块、多文件协同改动；**功能回归 / 交互类 bug 的第一棒** | 一眼能干完的体力活（浪费额度）；纯资料搜集（交给 Grok） |
| **Grok CLI**（xAI 官方，`grok`） | `grok` | **xAI 包月，额度充足**（Tao 2026-08-26 确认）→ 和 Cursor 一样可放心消耗，别当按量计费省着用 | 与 Cursor-Grok 同类的体力活/调研；Cursor 额度用光时的替补 | ⚠️ **和 Cursor-Grok 是同一颗脑子**（都是 Grok），bug 卡"换工种"轮转时**这两家互换不算换脑子**，要换就换到别的品牌 |
| **opencode**（`opencode run`，固定 GLM-5.3-Flash · 推理档 max） | `opencode` | 按 opencode 账号计费，GLM-5.3-Flash 单价很低（约为主力模型的零头）→ 额度吃紧时的第一替补 | 体力活与中文语境的活：批量改名替换、补样板代码、补单测、中文文档整理、机械迁移；**已定位到具体行的小修**；**bug 轮转的换脑子人选之一**（GLM 与 Grok / Codex 不同源）；光杆司令模式的候补工人 | 跨模块架构设计、含糊需求、需要拿主意的方案取舍（这些回工头）；⚠️ **和 Qoder CN 可能是同一颗脑子**（Qoder CN 若也配成 GLM，两家互换不算换脑子） |
| **Kimi**（`kimi` CLI，K3 Max） | `kimi` | 额度较少 → 只偶尔用一次，只派不太复杂的活 | 单个明确的小任务：一个文件内的小修补、独立小工具/小脚本、能一次说清楚的孤立活 | 多文件协同、需要跨轮返工磨的活（额度撑不住反复打回）、任何拿不准一次能不能过的任务 |
| **Qoder CN**（`qoderclicn`，接国产模型：Qwen / DeepSeek / GLM / Kimi / MiniMax） | `qoderclicn` | 按 Qoder 账号计费，额度另算 → Cursor/Codex 吃紧时的主力替补 | 体力活与中文语境的活：批量改名替换、补样板代码、补单测、中文文档/文案整理、机械迁移；**已定位到具体行的小修**；**bug 轮转的「第三个脑子」——它背后是国产模型，和 Grok / Codex 不同源，Codex→Grok 两轮啃不动时换它比同源互换有意义** | 跨模块架构设计、含糊需求、需要拿主意的方案取舍（这些回工头） |
| **工头**（= 正在读这份表的 AI，默认 Claude） | —（当工人时用自己的一次性模式，见调用模板） | 老板的注意力 = 最稀缺资源 | 扫盘+拆活排期、写任务书、**验收审查**、bug 病根诊断、跨工种两轮仍啃不动的接手、疑难杂症亲手修、合并与收尾 | 大段体力实现（我做完就没精力验收了） |

> **换谁当工头都成立**（见 README「换工头」）：手册里的「我」就是读它的那个 AI，工头职责（拆活/验收/合并）跟着人走。被换下来的那家降格为工人——Claude 降下来时定位是「疑难杂症专家」（病根诊断、方案取舍、别人啃不动的硬骨头），用下面的 `claude -p` 模板派。
> **谁当工头，谁就自带光杆司令能力**：这些 CLI 全都有一次性非交互模式，所以工头永远至少有一个工人可用——它自己。

> 🔴 **Tao 2026-08-28 定：本项目默认优先派 Grok（Cursor CLI）**。除非这张卡明显更适合别人
> （如需要大段设计取舍 → Codex；需要换个脑子的第二轮 bug 轮转 → 别的品牌），否则第一选择就是 Grok。
> opencode(GLM) 曾于 2026-08-28 一度降为备选：同日两次卡死（一次启动拉模型清单超时吊住，一次连三个字的问候都九十秒无响应）。
> **同日查明并已恢复**：「启动就吊住」这一类根本不是它的锅，是派活命令没关输入口——加上 `< /dev/null`（见下面调用模板第 ④ 条）后同一条命令从 5 分钟不动变成 18 秒干完，连跑三次稳定复现。**opencode 恢复为正常工人**，中文语境的活、体力活、bug 轮转换脑子人选都可以正常派给它，不必再当备胎。

**分派口诀**：
- 能写清"改哪个文件哪一行、改成什么样"的 → Grok；
- 只能写清"要达到什么效果"的功能/UI → Codex；
- **搜索 / 调研 / 竞品资料** → Grok；
- 一次能说清楚、且输不起返工的孤立小活 → 偶尔用 Kimi；
- 连"要什么效果"都要先想明白的 → 我先想，再决定派给谁。

**Bug 分派口诀**（与 SKILL 返工铁律配套）：
1. **已定位到具体行的小修** → Grok；
2. **功能回归 / 交互类、能复现但病根未钉死** → 先 Codex 一轮；不过 → Grok 一轮；仍不行 → Qoder CN 换个国产脑子一轮；还不行 → Claude；
3. **病根不清 / 两轮已啃不动 / 方案层取舍** → Claude 自己上（可先诊断再拆小修给别人）。

## 二、调用模板

**每个模板不管什么系统，都必须做到这六件事**（记住这六件事，比记住某一行命令重要）：
① 真的进到样板间目录里；② 用该 CLI 的一次性非交互模式；③ 把任务书喂给它；④ **把没用到的输入口关掉（`< /dev/null`）**；⑤ 输出落盘到 scratchpad；⑥ 报出成没成（退出码）。

🔴 **第 ④ 条是 2026-08-28 实测出来的坑，别省**：工头如果是 Claude Code，派活是走它的 Bash 工具跑的，而这个工具留给子进程的输入口**是一根永远不会关闭的管子**。很多 CLI（opencode 实测中招）启动时会先探一眼输入口有没有东西喂进来——在真人终端里那是键盘，它一看就知道没有、直接往下走；在 Bash 工具里它却会一直等那根管子给个"到此为止"的信号，而这个信号永远不来，于是进程活着、不报错、输出文件 0 字节，一直吊到超时。**表现和网络卡死一模一样，但原因完全不同**：分辨方法是看它自己的日志，网络卡死会紧跟一条 models.dev 超时的 ERROR，输入口卡死则是停在 `init` 后什么都没有。加一句 `< /dev/null` 等于当场告诉它"没人给你喂东西"，就正常了。任务书本来就是用 `< 任务书` 或 `"$(cat 任务书)"` 喂的，关掉不影响。同一条命令实测：不加 → 5 分钟不动；加了 → 18 秒干完。

**方言对照（bash → PowerShell）**：

| 要做的事 | macOS / Linux | Windows PowerShell |
|---|---|---|
| 进目录 | `cd "$WT"` | `Set-Location $WT` |
| 把任务书喂进去 | `cmd < file` | `Get-Content -Raw file \| cmd`（PowerShell **没有** `<` 这个写法） |
| 把任务书当参数传 | `"$(cat file)"` | `(Get-Content -Raw file)` |
| 关掉没用的输入口 | `< /dev/null` | `$null \| cmd ...`（PowerShell 没有 `<`） |
| 输出连错误一起落盘 | `> out.txt 2>&1` | `> out.txt 2>&1`（一样） |
| 看成没成 | `echo "exit=$?"` | `echo "exit=$LASTEXITCODE"` |
| 限时 | ❌ 别用 `timeout` | ❌ 更别用（Windows 上同名命令是"干等"） |

### Grok（cursor-agent）
```bash
# macOS / Linux
cd "$WT"                                   # 必须真的 cd 进去，别只靠 --workspace
cursor-agent -p --model cursor-grok-4.6-xhigh --force \
  --output-format text < "<scratchpad>/task-<slug>.md" \
  > "<scratchpad>/grok-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
Get-Content -Raw "<scratchpad>/task-<slug>.md" |
  cursor-agent -p --model cursor-grok-4.6-xhigh --force --output-format text `
  > "<scratchpad>/grok-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- `-p` = 非交互打印模式；`--force` = 不弹权限询问（因为已锁在 worktree 里）。
- 想审计它到底动了哪些工具：把 `--output-format text` 换成 `stream-json`，输出里每个 `tool_call` 都能看到实际路径和写入内容。
- **打回重做**（仅功能/实现卡的同工种续跑）：加 `--continue`（续上一轮）或 `--resume <session_id>`（session_id 在 stream-json 的第一行 `init` 里）。bug 卡换工种时开新任务书，不必续 session。

### Kimi（kimi CLI）
```bash
# macOS / Linux
cd "$WT"                                   # 必须真的 cd 进去
kimi -p "$(cat "<scratchpad>/task-<slug>.md")" -m kimi-code/k3 \
  --output-format text < /dev/null > "<scratchpad>/kimi-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
kimi -p (Get-Content -Raw "<scratchpad>/task-<slug>.md") -m kimi-code/k3 `
  --output-format text > "<scratchpad>/kimi-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- 如果 `kimi` 不在 PATH 里，换成实际安装路径。
- `-p`（prompt 一次性模式）下**不能**加 `-y`/`--auto`（会直接报错 "Cannot combine --prompt with --auto/--yolo"）——但实测 `-p` 模式本身就是非交互免审批的，不用额外挂旗子。
- 想拉满档位：在 kimi 的配置文件里把对应模型的 `default_effort` 设为 `max`，就不用每次拼参数。
- **额度不多，只偶尔派一次**：优先派"一次能说清楚、不需要来回打回"的孤立小活；一旦感觉这活可能要返工，改派 Grok/Codex 或我自己上，别拿稀缺额度去赌。
- **打回重做**：`kimi -S <session_id> -p "<补充要求>"`（session id 在跑完的输出里）。

### Grok CLI（xAI 官方 `grok`）— 冒烟通过 2026-08-12
```bash
# macOS / Linux
cd "$WT"
grok -p "$(cat '<scratchpad>/task-<slug>.md')" --always-approve \
  < /dev/null > "<scratchpad>/grokcli-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
grok -p (Get-Content -Raw "<scratchpad>/task-<slug>.md") --always-approve `
  > "<scratchpad>/grokcli-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- `-p/--single` = 单轮提问，打完就退出；`--always-approve` = 不逐次弹权限（已锁在样板间内）。
- 另有 `grok agent` 子命令（无 UI headless 跑），需要机读输出时配 `--output-format`。
- **打回重做**：`grok -c -p "<补充要求>"`（续当前目录上一轮会话）。
- 🔴 **别拿它当"换个脑子"用**：它和 Cursor-Grok 是同一家模型，bug 卡轮转要换到别的品牌才有意义。
- ⚠️ **`grok models` 会假报「You are not authenticated」**（2026-08-25 实测）：这个子命令读不到登录态，
  但 `grok -p` 本身是登录好的、能正常干活。**别拿 `grok models` 的输出判断它有没有登录**——
  看 `~/.grok/auth.json` 在不在、或者直接跑一次冒烟建文件。
- 选模型与档位：`-m grok-4.6 --reasoning-effort high`（`--effort` 是它的别名）。可用模型只有
  `grok-4.6`（默认）和 `grok-4.5`，别照搬 Cursor 那套带档位后缀的模型名。

### opencode（`opencode run`）— 冒烟通过 2026-08-12，固定模型档位后复测通过 2026-08-26
```bash
# macOS / Linux
cd "$WT"
opencode run -m opencode-go/glm-5.3-flash --variant max --auto \
  "$(cat '<scratchpad>/task-<slug>.md')" \
  < /dev/null \
  > "<scratchpad>/opencode-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
$null | opencode run -m opencode-go/glm-5.3-flash --variant max --auto `
  (Get-Content -Raw "<scratchpad>/task-<slug>.md") `
  > "<scratchpad>/opencode-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- 🔴 **派活必须显式带 `-m opencode-go/glm-5.3-flash --variant max`**（Tao 2026-08-26 定）。opencode 只是个壳，不写死模型就跟着老板上次在界面里选的走，"表现忽好忽坏"根本没法归因。`--variant` 是它的推理档位开关，glm-5.3-flash 支持 `low / high / max`，我们固定用 `max`。
- ⚠️ **写错的模型名 / 档位名它不报错，是默默忽略**（实测 `--variant zzzbogus` 照跑不误）。所以拼完命令自己核一眼字符串，别指望它拦你。要查有哪些模型：`opencode models`。
- `--auto` = 自动放行工具权限。工人是在一次性隔离样板间里干活，不加它可能卡在询问上干等；别在正式项目目录裸跑。
- 冒烟实测：`run` 一次性模式能正常建文件、能正常收任务书。
- 🔴 **会在启动阶段静默吊死**（2026-08-27 实测）：`opencode run` 启动时要去拉 models.dev 的模型清单，
  这一步联网超时后它**既不退出也不继续**，表现是「进程活着、CPU 约 1%、输出文件 0 字节、35 分钟一个文件没动」。
  **即使已经用 `-m` 显式指定了模型，这个拉取仍在启动路径上**，指定模型救不了。
  判定与排查：读 `~/.local/share/opencode/log/opencode.log`，按 `run=<id>` 分组看——
  正常的 run 有 `loop / stream / step=N` 一路往下；卡住的 run 停在 `init` 附近，
  紧跟一条 `ERROR "Failed to fetch models.dev" cause=TimeoutError`，之后再无日志。
  处置：直接 `pkill -f "opencode run"` 停掉，换人或工头自己接手；网络不稳时别把关键路径上的卡派给它。
- 🔴 **同样是「停在 init 一动不动」，还有第二个完全不同的病因，别混着治**（2026-08-28 实测复现并已修）：
  日志里停在 `init` 之后**紧跟 models.dev 超时 ERROR** = 网络病，按上一条处置；
  停在 `init` 之后**一条日志都没有** = 输入口没关的病，加 `< /dev/null` 就好（见本章开头第 ④ 条）。
  两者在外面看是同一副样子（进程活着、输出 0 字节），只有翻日志才分得开。**先加 `< /dev/null` 排除掉后者，再去怀疑网络。**

### Qoder CN（`qoderclicn -p`）— 冒烟通过 2026-08-19
```bash
# macOS / Linux
cd "$WT"                                   # 必须真的 cd 进去
qoderclicn -p "$(cat '<scratchpad>/task-<slug>.md')" -m Qwen3.8-Max \
  --permission-mode bypass_permissions -o text \
  < /dev/null > "<scratchpad>/qoder-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
qoderclicn -p (Get-Content -Raw "<scratchpad>/task-<slug>.md") -m Qwen3.8-Max `
  --permission-mode bypass_permissions -o text `
  > "<scratchpad>/qoder-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- 它是 Claude Code 的同构 CLI，参数几乎一一对应：`-p` 非交互、`-c` 续跑、`-r <id>` 恢复、`-o/--output-format`、`--add-dir`。
- `--permission-mode bypass_permissions` = 不逐次弹权限（已锁在样板间里）；等价的还有 `--dangerously-skip-permissions`，优先用前者。
- **模型必须显式指定**：`--list-models` 可查当前账号可用清单（实测：`Auto` / `Qwen3.8-Max` / `Qwen3.7-Max` / `Qwen3.7-Plus` / `Qwen3.7-Flash` / `DeepSeek-V4-Pro` / `DeepSeek-V4-Flash` / `GLM-5.3` / `GLM-5.2` / `Kimi-K2.7-Code` / `MiniMax-M2.7`）。默认给体力活派 `Qwen3.8-Max`；想换脑子做 bug 轮转可派 `DeepSeek-V4-Pro`；`Auto` 会替你挑，归因困难，派活别用。
- 还有 `--reasoning-effort <level>` 可拉档位，硬一点的活值得加。
- **打回重做**：`qoderclicn -c -p "<补充要求>"`（续当前目录上一轮）。
- ⚠️ 它自带 `--worktree` 开样板间的能力——**别用**，样板间一律由工头开，免得它自己另起一份、我在错的目录验收。
- 🔴 **同样绝不让它碰 git**（同 Codex 铁律）：任务书里写死"只改文件，不 add / 不 commit / 不切分支"。

### Codex（codex exec）
```bash
# macOS / Linux
# 用 nvm 管理 node 的话，先切到装了 codex 的版本；不用 nvm 可跳过这两行
source ~/.nvm/nvm.sh; nvm use <你的node版本> >/dev/null; hash -r
# 功能开发默认 sol；任务卡可覆盖（例如探索用 terra：-m gpt-5.6-terra）
codex exec -C "$WT" -s workspace-write -m gpt-5.6-sol \
  -o "<scratchpad>/codex-<slug>.last.txt" \
  - < "<scratchpad>/task-<slug>.md"
echo "exit=$?"
```
```powershell
# Windows PowerShell（不需要那两行 nvm；Windows 版 node/nvm 各装各的）
Get-Content -Raw "<scratchpad>/task-<slug>.md" |
  codex exec -C $WT -s workspace-write -m gpt-5.6-sol `
  -o "<scratchpad>/codex-<slug>.last.txt" -
echo "exit=$LASTEXITCODE"
```
- ⚠️ **Windows 上系统级沙箱可能不生效**（`-s workspace-write` 这类开关各平台实现不同）。真正兜底的是样板间隔离 + 任务书里的禁令，所以 Windows 上那几条禁令必须写足，验收也别偷懒。
- **模型偏好**：功能开发优先 `gpt-5.6-sol`（体感一次到位率更高）。codex 全局默认模型可能和你想派的不一致——**派活必须用 `-m` 显式指定**，别只靠全局默认。任务卡若指定其他模型，以任务卡为准。
- **内置生图（CLI 也有，不是只有桌面版）**：工具名 `image_generation`。适用：UI/页面布局草图、缺省占位图、视觉方向探索。任务书须写死落盘路径（优先样板间内如 `docs/ui-design/<slug>-sketch.png`）；验收 = 路径存在 + 读图确认内容对题。🔴 勿用 codex 全局生图目录盲 `find | tail` 当"刚生成的那张"。
- **UI 工序**：生图草图 → 过目 →（位置类再出 HTML 示意稿等老板确认）→ 再开写码轮；细节见 SKILL「2b」。

### Claude（claude -p）— 当 Claude 是工人时（别人做工头，或光杆司令自己叫自己）
```bash
# macOS / Linux
cd "$WT"                                   # 必须真的 cd 进去
claude -p "$(cat '<scratchpad>/task-<slug>.md')" \
  --permission-mode acceptEdits \
  --output-format text > "<scratchpad>/claude-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
claude -p (Get-Content -Raw "<scratchpad>/task-<slug>.md") `
  --permission-mode acceptEdits `
  --output-format text > "<scratchpad>/claude-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- `-p` = 非交互打印模式。
- 🔴 **必须带 `--permission-mode acceptEdits`**：不带的话写文件会被权限系统拦住（提示"写入被权限拦截，需要批准"），非交互模式下没人能批，冒烟直接失败（2026-08-20 Windows 实测；加上后一次通过）。这个档位**只放开改文件、不放开跑命令**，且它已锁在 worktree 里。别图省事换成 `--dangerously-skip-permissions`。
- **别人做工头时**：Claude 定位是「疑难杂症专家」，不是体力工——bug 病根诊断、方案取舍、其他工种两轮啃不动的硬骨头才升级给它。
- **打回重做**：`claude -c -p "<补充要求>"`（续当前目录上一轮会话）。
- 冒烟测试（空目录建文件）通过后才算上岗，同其他工种。

### 🧍 光杆司令模板（没有任何外部工人时，工头叫一个"一次性的自己"）

**通用做法**（不管工头是哪家）：找到本 CLI 的一次性非交互模式，照上面「五件事」拼一条命令，工人 = 我自己，验收 = 我自己在门外照常审。

| 工头是 | 叫自己当工人的写法 |
|---|---|
| Claude Code | 上面的 `claude -p` 模板 |
| Codex | 上面的 `codex exec` 模板 |
| Kimi | 上面的 `kimi -p` 模板 |
| Cursor CLI | 上面的 `cursor-agent -p` 模板 |
| Qoder CN | 上面的 `qoderclicn -p` 模板 |
| opencode | 上面的 `opencode run` 模板（记得带 `-m opencode-go/glm-5.3-flash --variant max` **和 `< /dev/null`**） |
| 其他 | **现场自证**：跑 `--help` 找它的一次性模式（常见是 `run` / `-p` / `--print` / `exec`），按五件事拼好，**跑一次冒烟测试**通过才用 |

**光杆模式下必须守住的两条**（否则这个模式就是自欺欺人）：
- 🔴 **验收一点不放水**：还是开样板间、还是只认 `git diff` + 真跑测试 + 真实运行。"是我自己写的所以我知道对"是最典型的翻车理由。
- 🔴 **同品牌自审有共同盲区**：bug 卡"换个工种再修一轮"这招在光杆模式下**失效**。同一张 bug 卡自己打回两轮仍不过 → 停下来告诉老板"建议装第二家 CLI 换个脑子"，别无限循环烧额度。

## 三、已知坑（实测）

**Grok / cursor-agent：**
- 🔴 **在名字带一长串怪字符的临时目录里跑，它会把路径写歪**——实测它把 `…/-Users-xxx/0c63…/scratchpad/x` 写成了 `…/-Users-xxx-0c63…/scratchpad/x`，文件落到了隔壁凭空新建的目录里，而它汇报"已写好"。**所以：只在正常的项目目录 / git worktree 里派活给它，绝不在临时目录里让它写文件**（任务书由我写好放进去，不需要它写）。
- 🔴 **自述不可信**（同 Codex）：上面那次它报"已创建 hello.txt"，目标目录里根本没有。**一律以 `git status` / `git diff` / 实跑为准。**
- 它默认会读工作区的规则文件，回话会按里面的称呼说话，别被这个"很懂事"的语气骗了。
- 没有 `timeout` 命令的系统（如 macOS）：别写 `timeout 180 cursor-agent …`，会直接报命令不存在；要限时就用后台跑 + 轮询。
- 🔴 **会整轮网络失败且退出码仍是 0**：输出文件里只有一行 `Error: [aborted] Client network socket disconnected before secure TLS connection was established`，工作区一个文件都没动。**回收时先看输出文件是不是这种一行错误 + `git status` 是否为空**，别当成"它做完了但没改动"。连挂两次就换工种（这不是它做错，是连不上，同工种再试意义不大）。

**Grok CLI / Cursor / Kimi / Qoder 共通（2026-08-19 实测踩到）：**
- 🔴 **工人会把仓库 `CLAUDE.md` 里"复杂任务先出 Plan 等老板同意"当成对自己的约束，于是只交了一份计划就停住、一个文件没动**（本次 Grok CLI 实测，退出码仍是 0）。任务卡里必须写死一句：**"你是工头派来的工人，这张卡就是已批准的计划，不用再等任何人点头，直接执行；仓库里那条先出计划的规矩是老板与工头之间的，不适用于你。"** 已停住的用该 CLI 的续跑参数（`grok -c -p` / `cursor-agent --continue` / `qoderclicn -c -p`）补一句"执行"即可，不用重开卡。

**批量正则改测试文件（2026-08-19 实测，任何工种都会踩）：**
- 🔴 **正则会把你刚写的 helper 自己也替换掉**，helper 变成自我递归，跑测试时当场把内存吃爆（tsc 与 playwright 同时 OOM）。任务卡里凡是"把某写法批量换成新 helper"的活，必须加一句：**先确认 helper 自身不在匹配范围内，替换后先跑一次最小用例再跑全量。**

**工头自己在验收时最容易犯的一条（2026-08-20 实测踩到）：**
- 🔴 **做"故意打死实现看用例会不会红"的反证之前，先在样板间里 commit 一次**。工人交的活是**未提交状态**，反证完用 `git checkout HEAD -- <file>` 还原，还原的是**改动前的原文**——一条命令把工人刚写的实现整个抹掉（本次靠上下文里存着完整文件才重建回来）。先提交，反证后再 checkout 才安全；或者破坏前先 `cp` 一份到 scratchpad。

**线上取证 / 发布（2026-08-20 现场踩出）：**
- 🔴 **去线上产物里 grep 验"功能到底上没上"时，关键词必须挑字符串字面量**（用户可见文案、路由表、对象字面量的键），**别挑函数名或变量名**——生产构建会把它们压掉，扑空会被误读成"功能没上去"。
- 🔴 **别人构建的产物不要直接拿去发布**，哪怕源码同一个 commit：实测同源码两次构建的 BUILD_ID 不同（产物不是逐字节可复现的）。要复用只能复用**有人真跑过全套验证的那一份**；省一次上传，不值得拿"发出去的东西没人验过"来换。

**Codex：**
- 🔴 绝不让它碰 git（它会自作主张做分支手术），见 SKILL 铁律。
- 🔴 **大陆网络下从官方 npm 源装会卡死**（2026-08-20 Windows 实测：下 `@openai/codex-win32-x64` 二进制 10 分钟零进度）。换国内源 8 秒装完：
  ```
  npm i -g @openai/codex --registry=https://registry.npmmirror.com
  ```
  （同一条在 macOS / Linux 也适用，只是二进制包名不同，npm 会自己挑。）
- 🔴 **npm 全局壳可能损坏**：实测出现过全局目录只剩 `.codex-*` 残留、`codex.cmd` 不存在，命令直接消失——不是没装也不是没登录，处置见「六、如何接入新 CLI」第 1 步的第三种状态。
- 🔴 不带 `-m` 时吃全局默认模型，和「功能开发用 sol」的体感偏好不一致——模板已强制 `-m`。
- 🔴 生图验收别信汇报路径；全局生图目录批次多，盲取最新一张容易张冠李戴。

**Gemini CLI（`gemini`）— 装了但当前不可用：**
- 🔴 2026-08-12 实测：能装能跑，但一开工就报 `IneligibleTierError`（个人版 Code Assist 已不再支持该客户端，官方要求迁移到 Antigravity）。**命令在 ≠ 能干活**——这正是"只查装没装不够、必须试跑"的活样本。
- 🔴 **它失败时退出码仍是 0**（同 Grok 的网络失败坑）：只看"成没成"会误判成通过，必须看输出内容 + 目标文件是否真出现。

**Grok CLI / opencode（首次冒烟共同观察，2026-08-12）：**
- 两家都**读了工作区的规则文件**，回话时用老板的昵称、甚至照抄了"下一步"格式——**语气懂事不代表干得对**，一律以文件真实存在 + 内容正确为准（本次两家都真建了文件，通过）。

**opencode（固定 GLM-5.3-Flash · 推理档 max，2026-08-26 复测通过）：**
- 🔴 **模型名和推理档写错它不报错，默默按默认跑**：实测 `--variant zzzbogus` 照样正常出活，退出码 0。所以派活命令里的 `-m opencode-go/glm-5.3-flash --variant max` 要自己核一眼字符串，别指望它拦你——写错了只会表现为"这轮怎么感觉笨了点"，事后根本查不出来。
- 模型全名带 `opencode-go/` 前缀，只写 `glm-5.3-flash` 找不到人。可用清单：`opencode models`。
- 推理档只有 `low / high / max` 三挡（`opencode` 自带的模型元数据里写着），没有 `medium`、也没有 `xhigh`。
- 非交互跑要带 `--auto` 放行工具权限，否则可能卡在询问上干等；只在一次性隔离样板间里用。
- 这颗脑子是 GLM（智谱），和 Grok / Codex 不同源，可以当 bug 轮转的换脑子人选；但**如果 Qoder CN 也配成了 GLM，这两家互换就不算换脑子**。

**Qoder CN（`qoderclicn`）— 冒烟通过 2026-08-19：**
- 冒烟实测：空目录 + `-p` + `-m Qwen3.8-Max` + `bypass_permissions`，文件真实落地、内容准确、退出码 0。
- 🔴 **命令名不叫 `qoder`**：本机实际是 `qoderclicn`（另有 `qodercn` / `qoder-cn` 两个入口指向同一套）。只按 `qoder` 点名会漏掉它——扫描名单已补齐这三个名字。
- 🔴 **它是 Claude Code 的同构克隆**：参数长得一样不代表行为一样（模型是国产的），别把 Claude 的手感直接套上去；一律以 `git diff` + 实跑验收。
- 多文件协同、长任务未实测过，先从小活派起。

**Windows（未在真机实测，按平台差异写死，踩到请补充）：**
- 🔴 **PowerShell 没有 `< file` 这种喂输入的写法**，照抄 bash 模板会直接报错——用 `Get-Content -Raw file | cmd`。
- 🔴 **`timeout` 在 Windows 上是"干等 N 秒"，不是"限时杀掉"**——写了不但不限时，还会白等。要限时一律后台跑 + 轮询。
- 看退出码用 `$LASTEXITCODE`，不是 `$?`（PowerShell 里 `$?` 只是 true/false）。
- 查命令装没装用 `Get-Command`，不是 `which`。
- 系统级沙箱开关可能不生效，隔离靠样板间 + 任务书禁令（见 Codex 模板下的提醒）。
- **每个工种在 Windows 上到底有没有原生版，由到岗检查现场判定**，别预设——没有就标「未安装」跳过，实在一个都没有就走光杆司令模式。

**Kimi：**
- 跟 Grok/Codex 一样，会读到规则文件、开口用昵称称呼你——**语气懂事不代表可信**，一样要靠 `git diff` + 实跑验收，别被这层"人味"降低警惕。
- 冒烟测试只验过"单文件、单指令"这种最简单场景：`-p` 非交互模式下文件真实落地，内容准确，退出码 0。多文件协同活没实测过，先别派。

## 三点五、Qoder CN 首次实战记录（coread F78，2026-08-19）

一张中等难度的功能卡（页面加搜索 + 类型筛选、新增纯函数文件、单测 + e2e），**一次过，未返工**。

- **照现成写法走，不自作聪明**：明确要求"归一化规则与 `lib/shelf.ts` 一致、UI 类名照搬书架某段"，它逐条对齐，注释风格也跟着写"为什么"而不是"做了什么"。
- **主动报备偏差**：示意稿画的是文字按钮、任务卡要求照搬图标按钮，两者冲突时它按卡执行并**在汇报里单列这条**；另外自己加的一个"查看全部"按钮也主动标注"示意稿没画，不要可删"。给它写清"列出你拿不准的地方"很有效。
- **没有源码字符串断言**（任务卡里明令禁止过，见 Codex 那条坑），测试是真的跑行为。
- **红→绿反证如实**：它报的红数（单测 7 红 / e2e 2 红）与工头独立复跑完全一致。
- **诚实度**：主动说明任务卡里引用的一个参考文件在它的样板间里不存在（工头给的是尚未合并的分支产物），改参考了另一条现成 spec——这类"上级给错信息"的反馈很值钱。
- 结论：**中等难度功能开发可以放心派**；架构取舍类仍回工头。

## 三点六、工头自己的一条教训：老板报的症状往往比真因轻（2026-08-19/20 连中两次）

- 报「重进书看到上一页」→ 真因是**每重进一次就把阅读进度倒着写回服务器**（数据在退化，不只是显示错）。
- 报「好句库不能写」→ 真因是**那一页断网连读都读不了**（拉不到列表直接 return，白板一块）。
- **做法**：收到非技术出身的老板的反馈，默认**先往下挖一层再定方案**——先问"这个症状最坏可能意味着什么"，用真实数据/取证确认，再写任务卡。照字面症状派活，容易只修表皮、下一轮又被同一件事打回。
- 交房报告里要**点名**这种"顺手挖出更糟一层"的发现，别让它淹没在功能条目里——那是这轮最有价值的产出。

## 四、首战实战记录（某共读 App 项目，2026-08-04）

**Grok 实际表现**：两条活各返工一次，但**都如实报告了失败**（"改完没效果"），没有假报完成——比 Codex 的自述可信度高一些，不过仍必须实测。它会主动加日志探针定位根因（一个浮条 bug 的真因就是它用日志挖出来的），这点很好用。**但它给的修复方案可能引入新缺陷**：第二轮为了保住浮条给背板加了"命中划线就不关"，结果做出了会删错划线的 P0——**方案层面的取舍必须 Claude 自己审，不能只看"测试过了"**。

**Codex 实际表现**：一次过，代码质量最好（纯函数抽离、停止条件齐全、单测断言与实现严格对应）。**但它只按字面需求实现，不会质疑前提**——它把自动续滚挂在 `touchmove` 上，逻辑完全正确，可 Android 原生选字手柄根本不产生 touchmove，真机上整个功能等于没做。**派活时要把"目标平台的真实事件模型"写进任务书**，别只写"实现 XX 功能"。

**Claude 自己踩的坑**（写任务书/验收时）：
- 指定复用某个现成函数前，**必须拿真实数据先跑一遍**确认有效（白跑过一轮：让复用的清洗函数阈值是 120 字，而脏标题只有 80 字）。
- 写"完成说明"时**别凭印象编 API 名和示例**，先 grep 函数名 + 读单测断言（BACKLOG 描述整段写错，合并后 grep 才发现）。
- **跑会清库的 e2e 前，先查该库是不是正在使用的环境**（这次实测清掉了测试环境里的真实数据）。
- e2e 全量跑出的红，**必须用 stash 对照基线**再下结论，别把既有的红算成自己的回归。

## 五、第二次实战记录（同一项目，2026-08-10/11）

**Codex 表现**：
- 汇报**诚实度高**：全量测试有 5 条别人的既有红，它明确写「均在未改动文件、单独复跑仍失败、未越界修改」，没冒领也没掩盖。
- **主动做红→绿反证**（先破坏实现证明用例会红，再改回来），是目前唯一自觉做这件事的工种。任务书里写死这条要求很值。
- 🔴 **但它会写"源码字符串断言"充数**（`expect(pageSource).toContain("annotation.style === 'dashed'")`）——读源码文本做 `toContain`，证明不了运行时行为。验收时要专门挑出这种，追加真实浏览器探针。
- 🔴 **一个交互功能首轮上线后被真机打回两个 P0**：探针只覆盖了「删线转虚线」，没覆盖「转成虚线之后用户还能怎么操作」。**教训：交互类功能的任务书要写「新状态产生之后，用户在这个新状态上还会做什么」，并要求为那些后续动作也写探针。**

**Grok 表现**：
- 交出了本批最有价值的产出之一：**主动报告了一个上级没让它找的安全缺口**（`localPath('..')` 能逃出缓存目录），且严格遵守「不要自己改实现，报告即可」的约束。给它划清"发现 vs 动手"的边界，它守得住。
- 有张卡返工两轮都是**需求本身在变**，不是它做错——这种要在汇报里跟老板说清楚，别让人以为工具不行。
- 它列的「拿不准/可能洗过头」清单质量很高（`Harry Potter (Book 1)` 会丢分册号就是它自己指出来的，老板据此改了需求）。**任务书里固定加一条「列出你判为拿不准的例子」很划算。**

**Claude 自己踩的坑**：
- 🔴 **派活命令漏了 `cd <worktree> &&`**，直接在主仓库启动了 cursor-agent，差点污染刚合并完准备发布的主线（已紧急停止，未造成损失）。
- **部署取证方法有前提**：「新版独有 chunk 200 / 旧版独有 404」在改动只碰单个页面时会取空（公共 chunk 文件名没变），要改用页面级产物（`static/chunks/app/<route>/page-*.js`）比对。第一次取证取到空值却差点当成通过。

## 六、如何接入新 CLI（给 AI 的操作协议）

老板说「把 XX CLI 加进包工队」时，按以下步骤做，不要跳步：

1. **确认可非交互调用**：先查该 CLI 是否已安装、已登录（`which xx` / `xx --version` / 跑 `--help`），找到它的一次性非交互模式（如 `-p` / `exec` / `--print`）。结果只可能是下面三种之一，**分开处置，别混为一谈**：
   - **没装** → 停下，告诉老板官方安装命令，不要擅自全局安装。
   - **装了但没登录** → 停下，告诉老板去登录，别替他填任何账号密码。
   - 🔴 **装了但命令损坏**（2026-08-20 Windows 实测踩到）：安装记录里查得到这个包，但可执行文件不见了、或一敲就报"不是内部或外部命令"（实测 codex：全局目录只剩 `.codex-*` 残留、`codex.cmd` 没了）。**症状像"没装"，但直接重装往往还会踩同一个坑**。处置：① 先确认是哪种——`npm ls -g --depth=0` / `winget list` 能看到包但命令敲不出来，就是这种；② 把残留清掉再按上面的国内源重装；③ 重装完必须重开一个终端再验 `--version`（旧终端的 PATH 缓存会骗人）；④ 修不好就当"没装"处理，先跳过它派活，别卡住整条流水线。
2. **补工种表**：按「一、能力/成本表」的格式加一行。**「派什么 / 不派什么」先问老板对这个 CLI 的定位**（体力活？硬活？备用？），再结合它的模型特点填，别自己拍脑袋。
3. **写调用模板**：仿照「二、调用模板」写一段，照「五件事」逐条落实：进目录、非交互参数、任务书怎么喂进去、输出落盘到 scratchpad、报退出码，外加"打回重做怎么续"（continue/resume 类参数）。**老板在 Windows 上就写 PowerShell 版**（照方言对照表转）。模型名让老板定或用 CLI 默认，写进模板注释。
   - 顺手记一条：**这家 CLI 当工头时怎么叫自己当工人**（就是它的一次性模式那条命令）——光杆司令模式要用。
4. **冒烟测试（必做，不许省）**：开一个临时空目录，让它建一个文件（如 `hello.txt`），然后**亲眼确认文件真实存在且内容正确**（不是信它汇报）。
   - 🔴 **冒烟被权限拦住不等于它不行**：很多 CLI 非交互模式下写文件默认要人批准，而非交互模式里没人能批，于是"看起来失败了"。先给它加上各自的放行参数再判死刑——Claude 是 `--permission-mode acceptEdits`，Qoder 是 `--permission-mode bypass_permissions`，其他家查 `--help` 里 permission / sandbox / yes / approve 之类的词（2026-08-20 Windows 实测：Claude 就是这么从"冒烟失败"变成"一次通过"的）。
   - 🔴 **扫描给了 🟡 的（有一次性模式但看不出会改文件，如 ollama）**：冒烟就是它的生死线——建不出文件就是模型运行时，不是 coding agent，**不录用**，在工种表里标注清楚免得下次又被扫出来。通过才算接入成功，把测试日期和结果记进它的「已知坑」小节。
5. **记已知坑**：接入过程中踩到的任何坑（参数冲突、路径问题、网络表现），当场记进「三、已知坑」。
6. **汇报上岗**：一句话告诉老板新工种叫什么、派什么活、冒烟结果。
