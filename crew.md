# 工种表（crew）— 谁擅长什么、怎么叫、有什么坑

> 加新 CLI 只需在本文件加一行表格 + 一段「调用模板」+ 一段「已知坑」，SKILL.md 不用改（完整流程见文末「如何接入新 CLI」）。
> 每加一个新工种，**必须先做冒烟测试**（让它在一个空目录建一个文件），亲眼看到文件真的出现才算接入成功。

> 🔧 **使用前必读（配置）**：下面表格和调用模板里的 CLI 命令、模型名（`cursor-grok-4.5-high` / `gpt-5.6-sol` / `kimi-code/k3`）都是**示例默认值**，换成你自己账号里实际安装、实际可用的。没装的工种直接把对应行删掉或标注「未安装」，派活时跳过它。报"未知模型 / unknown model"就是这里没对上——去查该 CLI 的可用模型列表再改，别硬试。

## 零、先认自己（工头开工前必做）

1. **我是谁**：正在读这份表的那个 CLI 就是工头。默认 Claude，但换成 Codex / Kimi / opencode 等照样成立——把下表「工头」那一行理解成"我自己"。
2. **我站在什么系统上**：macOS / Linux → 用下面每个模板的 **bash 栏**；Windows → 用 **PowerShell 栏**（**不需要 WSL**）。
3. **一个外部工人都没有**：走「二、调用模板」最后的**光杆司令模板**——我叫一个一次性的自己进样板间干活，验收流程一字不改。

## 零点五、扫本机有哪些人能用（到岗检查第一步，SKILL 流程 0 调用）

目标：**别只照花名册喊人**——新 CLI 天天出，写死的名单必然漏。四条路一起走，前三条**不花钱、不联网**。

### 路① 点名（快，认熟脸）

```bash
# macOS / Linux
for c in claude codex gemini copilot grok cursor-agent windsurf amp goose crush \
         opencode aider cline roo continue openhands devin warp auggie droid \
         plandex interpreter sgpt llm ollama qodo \
         trae qoder lingma qwen kimi codegeex codebuddy comate iflow deepseek minimax codearts; do
  p=$(command -v "$c" 2>/dev/null); case "$p" in /*) echo "HIT $c -> $p";; esac
done
```
> 🔴 必须用 `case "$p" in /*)` 只认绝对路径：`continue` / `test` 这类名字是 shell 自带关键字，`command -v` 会返回它本身，不加这层过滤就会误报"装了 Continue"。（本机实测踩到过。）
```powershell
# Windows PowerShell
@('claude','codex','gemini','copilot','grok','cursor-agent','windsurf','amp','goose','crush',
  'opencode','aider','cline','roo','continue','openhands','devin','warp','auggie','droid',
  'plandex','interpreter','sgpt','llm','ollama','qodo',
  'trae','qoder','lingma','qwen','kimi','codegeex','codebuddy','comate','iflow','deepseek','minimax','codearts') |
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
| **Grok**（Cursor CLI，Grok 4.5 High） | `cursor-agent` | Cursor 包月，额度通常充足 → 优先消耗 | 重复体力活：批量改名/替换、按现成模式补样板代码、补单测、写死板文档、格式整理、机械迁移；**已定位到具体行的小 bug 修补**；**搜索 / 调研 / 竞品与资料搜集**；bug 跨工种轮转的第二棒 | 需要拿主意的设计、跨模块架构、含糊需求 |
| **Codex**（`codex exec`，OpenAI 订阅） | `codex` | 订阅制，额度有限 → 省着用在硬活 | 前端/后端功能开发、UI 交互实现（**先图后码**，见下）、要做设计取舍的模块、多文件协同改动；**功能回归 / 交互类 bug 的第一棒** | 一眼能干完的体力活（浪费额度）；纯资料搜集（交给 Grok） |
| **Grok CLI**（xAI 官方，`grok`） | `grok` | 按 xAI 账号计费 | 与 Cursor-Grok 同类的体力活/调研；Cursor 额度用光时的替补 | ⚠️ **和 Cursor-Grok 是同一颗脑子**（都是 Grok），bug 卡"换工种"轮转时**这两家互换不算换脑子**，要换就换到别的品牌 |
| **opencode**（`opencode`） | `opencode` | 取决于你在它里面配的模型 | 灵活替补：它是个壳，背后接哪家模型由你配；光杆司令模式的候补工人 | 需要稳定手感的关键活（背后模型可变，表现随配置漂移） |
| **Kimi**（`kimi` CLI，K3 Max） | `kimi` | 额度较少 → 只偶尔用一次，只派不太复杂的活 | 单个明确的小任务：一个文件内的小修补、独立小工具/小脚本、能一次说清楚的孤立活 | 多文件协同、需要跨轮返工磨的活（额度撑不住反复打回）、任何拿不准一次能不能过的任务 |
| **工头**（= 正在读这份表的 AI，默认 Claude） | —（当工人时用自己的一次性模式，见调用模板） | 老板的注意力 = 最稀缺资源 | 扫盘+拆活排期、写任务书、**验收审查**、bug 病根诊断、跨工种两轮仍啃不动的接手、疑难杂症亲手修、合并与收尾 | 大段体力实现（我做完就没精力验收了） |

> **换谁当工头都成立**（见 README「换工头」）：手册里的「我」就是读它的那个 AI，工头职责（拆活/验收/合并）跟着人走。被换下来的那家降格为工人——Claude 降下来时定位是「疑难杂症专家」（病根诊断、方案取舍、别人啃不动的硬骨头），用下面的 `claude -p` 模板派。
> **谁当工头，谁就自带光杆司令能力**：这些 CLI 全都有一次性非交互模式，所以工头永远至少有一个工人可用——它自己。

**分派口诀**：
- 能写清"改哪个文件哪一行、改成什么样"的 → Grok；
- 只能写清"要达到什么效果"的功能/UI → Codex；
- **搜索 / 调研 / 竞品资料** → Grok；
- 一次能说清楚、且输不起返工的孤立小活 → 偶尔用 Kimi；
- 连"要什么效果"都要先想明白的 → 我先想，再决定派给谁。

**Bug 分派口诀**（与 SKILL 返工铁律配套）：
1. **已定位到具体行的小修** → Grok；
2. **功能回归 / 交互类、能复现但病根未钉死** → 先 Codex 一轮；不过 → Grok 一轮；仍不行 → Claude；
3. **病根不清 / 两轮已啃不动 / 方案层取舍** → Claude 自己上（可先诊断再拆小修给别人）。

## 二、调用模板

**每个模板不管什么系统，都必须做到这五件事**（记住这五件事，比记住某一行命令重要）：
① 真的进到样板间目录里；② 用该 CLI 的一次性非交互模式；③ 把任务书喂给它；④ 输出落盘到 scratchpad；⑤ 报出成没成（退出码）。

**方言对照（bash → PowerShell）**：

| 要做的事 | macOS / Linux | Windows PowerShell |
|---|---|---|
| 进目录 | `cd "$WT"` | `Set-Location $WT` |
| 把任务书喂进去 | `cmd < file` | `Get-Content -Raw file \| cmd`（PowerShell **没有** `<` 这个写法） |
| 把任务书当参数传 | `"$(cat file)"` | `(Get-Content -Raw file)` |
| 输出连错误一起落盘 | `> out.txt 2>&1` | `> out.txt 2>&1`（一样） |
| 看成没成 | `echo "exit=$?"` | `echo "exit=$LASTEXITCODE"` |
| 限时 | ❌ 别用 `timeout` | ❌ 更别用（Windows 上同名命令是"干等"） |

### Grok（cursor-agent）
```bash
# macOS / Linux
cd "$WT"                                   # 必须真的 cd 进去，别只靠 --workspace
cursor-agent -p --model cursor-grok-4.5-high --force \
  --output-format text < "<scratchpad>/task-<slug>.md" \
  > "<scratchpad>/grok-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
Get-Content -Raw "<scratchpad>/task-<slug>.md" |
  cursor-agent -p --model cursor-grok-4.5-high --force --output-format text `
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
  --output-format text > "<scratchpad>/kimi-<slug>.out.txt" 2>&1
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
  > "<scratchpad>/grokcli-<slug>.out.txt" 2>&1
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

### opencode（`opencode run`）— 冒烟通过 2026-08-12
```bash
# macOS / Linux
cd "$WT"
opencode run "$(cat '<scratchpad>/task-<slug>.md')" \
  > "<scratchpad>/opencode-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
opencode run (Get-Content -Raw "<scratchpad>/task-<slug>.md") `
  > "<scratchpad>/opencode-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- 冒烟实测：`run` 一次性模式**默认就能写文件**，没弹权限。
- 它背后接哪家模型由老板在 opencode 里配（`opencode models` 可查）——**派活前先确认当前模型是谁**，否则"表现忽好忽坏"根本没法归因。

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
  --output-format text > "<scratchpad>/claude-<slug>.out.txt" 2>&1
echo "exit=$?"
```
```powershell
# Windows PowerShell
Set-Location $WT
claude -p (Get-Content -Raw "<scratchpad>/task-<slug>.md") `
  --output-format text > "<scratchpad>/claude-<slug>.out.txt" 2>&1
echo "exit=$LASTEXITCODE"
```
- `-p` = 非交互打印模式。写文件等操作按本机 Claude Code 的权限设置走，需要时在允许的范围内放行（它已锁在 worktree 里）。
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
| 其他（opencode 等） | **现场自证**：跑 `--help` 找它的一次性模式（常见是 `run` / `-p` / `--print` / `exec`），按五件事拼好，**跑一次冒烟测试**通过才用 |

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

**Codex：**
- 🔴 绝不让它碰 git（它会自作主张做分支手术），见 SKILL 铁律。
- 🔴 不带 `-m` 时吃全局默认模型，和「功能开发用 sol」的体感偏好不一致——模板已强制 `-m`。
- 🔴 生图验收别信汇报路径；全局生图目录批次多，盲取最新一张容易张冠李戴。

**Gemini CLI（`gemini`）— 装了但当前不可用：**
- 🔴 2026-08-12 实测：能装能跑，但一开工就报 `IneligibleTierError`（个人版 Code Assist 已不再支持该客户端，官方要求迁移到 Antigravity）。**命令在 ≠ 能干活**——这正是"只查装没装不够、必须试跑"的活样本。
- 🔴 **它失败时退出码仍是 0**（同 Grok 的网络失败坑）：只看"成没成"会误判成通过，必须看输出内容 + 目标文件是否真出现。

**Grok CLI / opencode（首次冒烟共同观察，2026-08-12）：**
- 两家都**读了工作区的规则文件**，回话时用老板的昵称、甚至照抄了"下一步"格式——**语气懂事不代表干得对**，一律以文件真实存在 + 内容正确为准（本次两家都真建了文件，通过）。

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

1. **确认可非交互调用**：先查该 CLI 是否已安装、已登录（`which xx` / `xx --version` / 跑 `--help`），找到它的一次性非交互模式（如 `-p` / `exec` / `--print`）。没装或要登录 → 停下，告诉老板先装/先登录，给出官方安装命令，不要擅自全局安装。
2. **补工种表**：按「一、能力/成本表」的格式加一行。**「派什么 / 不派什么」先问老板对这个 CLI 的定位**（体力活？硬活？备用？），再结合它的模型特点填，别自己拍脑袋。
3. **写调用模板**：仿照「二、调用模板」写一段，照「五件事」逐条落实：进目录、非交互参数、任务书怎么喂进去、输出落盘到 scratchpad、报退出码，外加"打回重做怎么续"（continue/resume 类参数）。**老板在 Windows 上就写 PowerShell 版**（照方言对照表转）。模型名让老板定或用 CLI 默认，写进模板注释。
   - 顺手记一条：**这家 CLI 当工头时怎么叫自己当工人**（就是它的一次性模式那条命令）——光杆司令模式要用。
4. **冒烟测试（必做，不许省）**：开一个临时空目录，让它建一个文件（如 `hello.txt`），然后**亲眼确认文件真实存在且内容正确**（不是信它汇报）。通过才算接入成功，把测试日期和结果记进它的「已知坑」小节。
5. **记已知坑**：接入过程中踩到的任何坑（参数冲突、路径问题、网络表现），当场记进「三、已知坑」。
6. **汇报上岗**：一句话告诉老板新工种叫什么、派什么活、冒烟结果。
