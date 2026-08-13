# leader-skill

让 Claude 当 Leader，把活派给其他 AI CLI（Codex / Grok / Kimi…）干。你只说需求，Claude 负责拆任务、派活、审查、合并，实际写代码的是便宜的模型。贵的额度做判断，便宜的额度做体力。

## 功能

- **拆任务**：扫描项目（BACKLOG、未解 bug），把需求拆成任务卡；需求含糊先问你，不用"合理默认"糊弄
- **隔离施工**：每个任务在独立的 git worktree 里做，工人碰不到主分支，也不允许执行 git 命令
- **派活**：按工种派给不同 CLI，多任务可并行；一个外部 CLI 都没装时，Claude 叫一个一次性的自己干活，流程不变
- **验收**：不看工人自我汇报，只看 git diff 和真实测试结果；不合格按规则返工（bug 换工种再修，功能开发同一工种最多打回两次）
- **两道闸门**：计划你确认才开工，合并你确认才执行
- **UI 任务**先生成设计稿，你拍板后才写代码

## 安装

```bash
# macOS / Linux
git clone https://github.com/wrngo/leader-skill ~/.claude/skills/leader
```

```powershell
# Windows（PowerShell）
git clone https://github.com/wrngo/leader-skill "$env:USERPROFILE\.claude\skills\leader"
```

要求：装有 git，你的项目是 git 仓库且至少有一次提交。目录名必须是 `leader`。

## 使用

1. 装好后说「扫描本机」。它检测你机器上有哪些 AI CLI 能当工人，输出三档名单：已上岗 / 装了没登录 / 疑似候选。只需做一次。
2. 之后说人话派活：
   - 「派活：把 backlog 里这几项做了」
   - 「这个 bug 找人修一下」
   - 中途可问「现在进度如何」「停掉 XX 那个活」「让它重做」

每次开工前它列出计划（几张卡、派给谁、烧谁的额度），你确认才执行；合并前再确认一次。

## 平台

macOS / Linux 日常在用。Windows 原生支持（PowerShell，不需要 WSL），但未在真实 Windows 机器实测，欢迎 issue 反馈。

## 说明

- 派出去的每个任务都在烧对应厂商的额度，计划里会写明派给谁。
- 加新 CLI：直接说「把 XX CLI 加进来」，它会确认能非交互调用、跑通冒烟测试后加进工种表。
- 卸载：删除 skill 目录即可。有残留的 worktree 和分支，让它「把 leader 留下的 worktree 清干净」。

## 文件

- `SKILL.md` — 完整工作手册（规则 + 流程）
- `crew.md` — 工种表：各 CLI 擅长什么、怎么调用、已知坑
- `scan-crew.sh` / `scan-crew.ps1` — 本机 AI CLI 扫描脚本（只读，不联网）

## English

**leader** turns Claude into a foreman: it splits your request into task cards, dispatches them to cheaper AI CLIs (Codex / Grok / Kimi) inside isolated git worktrees, reviews the real diff, runs the real tests, and merges — with your approval at the plan and merge gates. No worker CLIs installed? Claude dispatches a one-shot copy of itself instead.

Install: clone this repo as `leader` into your skill directory, then tell Claude "scan this machine" to see which CLIs can work. macOS / Linux / Windows (Windows untested).

## License

MIT
