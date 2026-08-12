# leader — AI 工头带队，AI 包工队施工

让一个 AI 当工头：你只说"我要什么"，它负责扫盘、拆任务、写任务书，把活派进隔离的"样板间"施工，最后亲手验收、合并、交房。你中途不碰键盘。

**装完就能用**——一个外部 AI 工具都没有也能跑（工头叫一个"一次性的自己"进样板间干活，见[光杆司令模式](#光杆司令模式)）。
装了别家 CLI 之后才是完全体：贵的脑子只做判断（拆活、验收），便宜的脑子做体力（实现、杂活）。

---

## 一句话安装

把下面这句话发给 Claude Code（或任何能读文件、能跑命令的 AI 命令行）：

> 把 https://github.com/wrngo/leader-skill 装成我的 leader skill（克隆到 skill 目录并命名为 `leader`），装好后执行「检查包工队到岗情况」。

想自己动手也行：

**macOS / Linux**

```bash
git clone https://github.com/wrngo/leader-skill ~/.claude/skills/leader
```

**Windows（PowerShell）**

```powershell
git clone https://github.com/wrngo/leader-skill "$env:USERPROFILE\.claude\skills\leader"
```

> 目录名必须是 `leader`（仓库名多了 `-skill`，上面的命令已经把它改好了）。

## 装完先做这一件事

对 AI 说：**「检查包工队到岗情况」**

它会**跑一遍仓库里的扫描脚本**（`scan-crew.sh` / `scan-crew.ps1`），把你这台机器翻一遍，看有多少 AI 命令行能拉来当工人——不是只照一份写死的名单喊人，而是四路并行：

1. 按一份 40 来家的常见名单点名（Claude / Codex / Gemini / Copilot / Grok / Cursor / Trae / Qoder / Kimi / 通义 / opencode / aider …）
2. 把你机器上所有能敲的命令翻一遍，捞出带 AI 味的生面孔
3. 翻各家安装记录——命令名猜不到也能看见它躺在那儿
4. 翻你自己起的简称

捞到的挨个问一句"你会不会一句话干完活就走"——**只有会的才有资格当工人**，纯聊天式的直接淘汰。

然后给你一份三档名单：**✅ 已上岗 / ⚠️ 装了但没登录 / ❓ 疑似候选（只列出来，不擅自动）**。
试工（在空文件夹里真建一个文件、亲眼确认）会花一丁点额度，**要你点头才做**；录用的会自动写进工种表，下次直接能派。

前三步全程不花钱、不联网。这一步只需做一次。

（如果一个外部 CLI 都没有：它会直接告诉你"走光杆司令模式"，照样能开工。）

---

## 它会对你的项目做什么（先看完这段再决定装不装）

- **会**在你项目文件夹**旁边**新建一间"样板间"（git worktree）和一个新分支，活干完就拆掉。
- **会**在样板间里调用别家 AI 命令行，并关掉它们的逐次权限询问——因为已经锁死在样板间目录内，碰不到你的主工作区。
- **不会**动你的主分支：合并前一定先问你。
- **不会**碰生产/正式环境：这是一条独立红线，没有你当次明确放行绝不越过。
- **计划做完先给你过目，你回「派」才真正开工**——不会闷头就把别家的额度烧掉。
- 每份任务书里都硬性禁止：写库 / 迁移 / 删数据 / 联网提交 / 改鉴权护栏。

## 前置条件

- **工头**：一个能读文件、能跑命令的 AI 命令行（默认 Claude Code；换别家见[换工头](#换工头进阶)）
- **git**，且你的项目已经是 git 仓库、至少有过一次提交（样板间靠它开）
- **工人**：**可选**。装得越多越省钱：
  - [Cursor CLI](https://cursor.com)（`cursor-agent`）——体力活、调研
  - [Codex CLI](https://github.com/openai/codex)——功能开发、UI 实现
  - [Kimi CLI](https://www.kimi.com/code)——偶尔的孤立小活
  - 一个都没有 → 自动走光杆司令模式，功能不缺，只是省不下钱

## 平台

- **macOS / Linux**：作者日常在用。
- **Windows：原生支持，不需要装 WSL。** 开样板间的做法两边完全一样；查工具、递任务书、记结果、看成没成这几处，`crew.md` 里配了 PowerShell 版模板。
  ⚠️ **未在真实 Windows 机器上实测**，是逐条对照写的——欢迎开 issue 反馈。上岗前那道冒烟测试会当场暴露写法问题，不会让你带着错的命令一路跑下去。
  ⚠️ Windows 上少一层系统级沙箱，隔离主要靠样板间，所以任务书里那几条禁令在 Windows 上分量更重。

---

## 日常使用

说人话就能触发：

- 「派活：把 backlog 里这几项做了」
- 「排个计划派下去」
- 「这个 bug 找人修一下」

中途随时插手，也是说人话：

- 「现在进度如何」——工头汇报各卡状态
- 「停掉 XX 那个活」——立刻叫停对应工人
- 「XX 做得不对，让它重做」——打回返工

交房时你拿到的是一份人话报告，大概长这样：

```
三张卡全过，一次返工。
· 导出按钮 —— Codex 做的，一次过
· 列表排序 bug —— 先 Codex 没修好，换 Grok 一轮修好了
· 文案批量替换 —— Grok 做的，一次过
剩下的问题：导出大文件超过 50MB 会卡，我没动，要不要单开一张卡？
下一步：要我合进主线吗？
```

## 光杆司令模式

手上一个外部 CLI 都没有（或者都没到岗）时，工头不会罢工：它会**叫一个"一次性的自己"进样板间干活，自己站在门外只管验收**。样板间照开、任务书照写、验收照样只认真实改动和真跑，一点不放水。

好处是零安装、立刻能用；**代价要说清楚**：同一个牌子自己审自己有共同盲区——它会犯的那类错，它自己往往也认不出来。所以本套流程里"bug 换个工种再修一轮"这招在光杆模式下失效。**装上第二家 CLI 才是完全体。**

## 扩编（加新 CLI）

对 AI 说：「把 XX CLI 加进包工队」。

它会按 `crew.md` 第六节的协议走：确认能非交互调用 → 补工种表 → 写调用模板 → **冒烟测试通过才算上岗**。

这里刻意**不维护一张"支持哪些工具"的名单**（那种名单永远追不上新出的工具），而是写死一套**自证流程**：任何 CLI 来了，现场问它怎么跑、跑一次冒烟、亲眼看见结果才认。名单会过期，流程不会。

## 换工头（进阶）

默认工头是 Claude，但 `SKILL.md` 本质是一份**工具无关**的操作手册——任何能读文件、能跑命令的 agent（Codex、Kimi、opencode……）都能照着当工头。手册里的"我"，就是**正在读它的那个 AI**。

换帅做两件事：

1. **把手册交给新工头**：其他 CLI 没有 Claude Code 的自动加载机制，把 `SKILL.md` + `crew.md` 的内容贴进它的 prompt / 规则文件。
2. **Claude 降格为工人**：`crew.md` 里备好了模板，Claude 转任"疑难杂症专家"——病根诊断、方案取舍、别人啃不动的硬骨头升级给它。

一个提醒：这套设计的前提是「**最聪明的脑子当工头**」——拆任务、写任务书、验收把关是质量命门。换帅前建议先拿几张小卡试一轮，重点看新工头**验收能不能看住**（比如能不能识破"读源码字符串冒充行为断言"的假测试），再决定放不放权。

## 花费提醒

工头本身花的是你当前 AI 的额度；**派出去的每一张卡都在烧对应厂商的额度**。所以：

- 计划阶段有确认闸门，你看清楚要派几张卡、派给谁，再决定开不开工。
- 想只看计划不开工，直接说「只出计划，先别派」。

## 卸载 / 清理

删掉 skill 目录即可。如果之前跑到一半留下了样板间和分支，对 AI 说「把 leader 留下的样板间清干净」，它会拆房、删临时分支；`.leader/` 是任务书存放处，可直接删。

## 文件结构

- `SKILL.md` — 铁律 + 完整流程（认岗 → 扫盘 → 派活 → 验收 → 返工 → 合并 → 交房）
- `crew.md` — 工种表：谁擅长什么、怎么调用（含 Windows 版）、已知坑、实战记录、新 CLI 接入协议
- `scan-crew.sh` / `scan-crew.ps1` — 扫本机有哪些 AI 命令行能当工人（只读，不联网、不花额度、不改文件）

## 核心机制速览

- **95% 把握度才开工**：需求含糊先问你，不用"合理默认"糊弄
- **计划要你点头才派活**，合并也要你点头
- **包工队绝不碰 git**：提交合并全由工头亲手做
- **不信自我汇报**：只认真实改动 + 真实测试 + 真实运行
- **隔离样板间**：每个活一间，互不干扰
- **返工双轨制**：bug 跨工种轮转（事不过三），功能开发同工种最多打回两次
- **UI 先图后码**：草图 → 示意稿你拍板 → 才写代码

---

## English (short)

**leader** turns your AI CLI into a foreman. You say what you want; it scans the repo, splits the work into task cards, dispatches them to other AI CLIs (Cursor's Grok / Codex / Kimi) inside isolated git worktrees, then reviews the real diff, runs the real tests, and merges — with your approval at the plan and merge gates.

Works with zero worker CLIs installed ("solo mode": the foreman spawns a one-shot copy of itself as the worker). Works on macOS, Linux and Windows (PowerShell templates included, no WSL needed — Windows path is written but not yet field-tested).

Install: clone this repo into your skill directory as `leader`, then tell your AI: *"check the crew roll call"*.

Docs are in Chinese for now — the manual is plain Markdown, so ask your AI to translate it in place if you prefer English.

## License

MIT
