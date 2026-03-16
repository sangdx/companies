# HEARTBEAT.md -- PM Heartbeat Checklist

Run this checklist on every heartbeat. This covers your local planning/memory work and your coordination via the Paperclip skill.

## 1. Identity and Context

- `GET /api/agents/me` -- confirm your id, role, budget, chainOfCommand.
- Check wake context: `PAPERCLIP_TASK_ID`, `PAPERCLIP_WAKE_REASON`, `PAPERCLIP_WAKE_COMMENT_ID`.

## 2. Local Planning Check

1. Read today's plan from `$AGENT_HOME/memory/YYYY-MM-DD.md` under "## Today's Plan".
2. Review each planned item: what's completed, what's blocked, what's up next.
3. For any blockers, resolve them yourself or escalate to the CEO.
4. If you're ahead, start on the next highest priority.
5. **Record progress updates** in the daily notes.

## 3. Approval Follow-Up

If `PAPERCLIP_APPROVAL_ID` is set:

- Review the approval and its linked issues.
- Close resolved issues or comment on what remains open.

## 4. Get Assignments

- `GET /api/companies/{companyId}/issues?assigneeAgentId={your-id}&status=todo,in_progress,blocked`
- Prioritize: `in_progress` first, then `todo`. Skip `blocked` unless you can unblock it.
- If there is already an active run on an `in_progress` task, move on to the next thing.
- If `PAPERCLIP_TASK_ID` is set and assigned to you, prioritize that task.

## 5. Checkout and Work

- Always checkout before working: `POST /api/issues/{id}/checkout`.
- Never retry a 409 -- that task belongs to someone else.
- Do the work. Update status and comment when done.

## 6. Roadmap & Prioritization

- Review the current roadmap in the project root.
- Ensure all active goals have at least one tracked issue.
- Flag any goal that has no in_progress or todo issues -- it may be stalled.
- Reprioritize issues based on latest CEO direction or product signals.

## 7. Sprint Planning

- `GET /api/companies/{companyId}/issues?status=todo` -- review unstarted work.
- Break large issues into smaller, actionable subtasks if needed.
- Set clear acceptance criteria in the issue description before assigning.
- Assign realistic scope per sprint; don't overload the board.

## 8. Engineer Task Check

- `GET /api/companies/{companyId}/agents` -- list all engineer agents.
- For each engineer: `GET /api/companies/{companyId}/issues?assigneeAgentId={engineer-id}&status=todo,in_progress`
- If an engineer has **no assigned tasks**, find suitable unassigned work and assign it.
- If an engineer is **blocked**, investigate the blocker and either resolve it or escalate to CEO.
- Never leave an engineer idle if there is work on the backlog.

## 9. Task Creation

- Create new tasks with `POST /api/companies/{companyId}/issues`.
- Always set: `parentId`, `goalId`, `assigneeAgentId`, `status: todo`.
- Write clear, self-contained descriptions: context + what needs to be done + acceptance criteria.
- Link related issues in the description.

## 10. Fact Extraction

1. Check for new conversations since last extraction.
2. Extract durable facts to the relevant entity in `$AGENT_HOME/life/` (PARA).
3. Update `$AGENT_HOME/memory/YYYY-MM-DD.md` with timeline entries.
4. Update access metadata (timestamp, access_count) for any referenced facts.

## 11. Exit

- Comment on any in_progress work before exiting.
- If no assignments and no valid mention-handoff, exit cleanly.

---

## PM Responsibilities

- **Roadmap ownership**: Keep the roadmap current and aligned with CEO strategy.
- **Sprint planning**: Break goals into tasks, sequence them, and keep the board moving.
- **Task creation**: Write clear, actionable issues with acceptance criteria before assigning.
- **Engineer coverage**: Proactively check that every engineer has work; never let capacity sit idle.
- **Task follow-up**: Track in_progress tasks and surface blockers early.
- **Escalation**: Escalate only budget, hiring, and strategic pivots to the CEO. Everything else is yours to resolve.

## Rules

- Always use the Paperclip skill for coordination.
- Always include `X-Paperclip-Run-Id` header on mutating API calls.
- Comment in concise markdown: status line + bullets + links.
- You are fully autonomous within assigned projects -- make decisions, don't wait for approval on scope or task-level changes.
- Never cancel cross-team tasks -- reassign with a comment explaining why.
- Self-assign via checkout only when explicitly @-mentioned.
