---
name: yona-postmortem
description: Run a blameless incident post-mortem — reconstruct the timeline from artifacts, draft the incident entry, file every action item into an enforcement surface, and land it by PR. Use after production impact on a deployed surface, or when asked for a post-mortem, incident review, or incident write-up.
---

# Yona Postmortem

Use this skill when a change or operation impacted a deployed surface —
the live service, fielded devices, or real user data (dogfood data is
user data) — or when the user asks for a post-mortem or incident review.
Run it while context is hot: same day, ideally in the session that drove
the response, because that session holds the whole timeline.

Triage first — an incident is the third genus, not a synonym:

- A *mechanism* failed (the system did Y when it should have done Z) →
  the repo's defect registry.
- A *condition* stands (a known gap being lived with) → the debt
  registry.
- An *event* hurt a deployed surface → an incident. An incident needs no
  defect — code doing exactly what it was designed to do can still take
  down production. When a defect exists too, file both and cross-link.

## Registry location

1. The registry lives at `<repo-root>/docs/incidents/`, one dated file
   per incident: `YYYY-MM-DD-slug.md`, dated by when impact began.
2. If the directory or its `README.md` does not exist, bootstrap it:
   create the README with the registry contract (the three-registry
   triage above, the filing bar, the severity rubric, the blameless
   rules, the entry template, and an index table). The lp2025 repo's
   `docs/incidents/README.md` is the reference copy.
3. The repo's README is the per-repo authority for filing bar and
   severity wording; this skill defers to it wherever they differ.

## Process

1. **Reconstruct the timeline from artifacts, not memory.** Machine
   events get exact UTC timestamps; human events stay approximate.

   ```bash
   gh pr view <n> --json mergedAt,createdAt
   gh run list --branch <branch> --limit 20   # CI turn-green times
   git log --format='%h %cI %s' <range>
   ```

   Session transcripts count as artifacts for when a report or
   diagnosis happened.
2. **State impact honestly**: who/what, for how long, and what remedy
   users had meanwhile — including "none" or "only destructive ones."
3. **Grade severity by fraction and function, as if at scale.**
   Headcount belongs in the Impact paragraph, never in the grade: "all
   existing content unavailable for 100% of users" is the same grade at
   two users as at two million. Scale: `minor | severe | critical`
   (critical = data loss, security breach, or wholly unusable;
   irreversible harm is automatically critical). Duration never changes
   the grade — report it separately. When torn between grades, grade
   **up**: an incident graded up buys the rehearsal for the bigger
   version of itself.
4. **List contributing causes — plural, systemic, blameless.** Name
   conditions, never actors: "the merge raced the in-flight upgrader,"
   not "X merged too early." For an agentic team the rule is
   operational: agent carelessness is never a cause, because agents do
   not carry lessons between sessions — standing instructions do. Phrase
   every cause as the *missing standing thing*, and test each one with:
   "what standing instruction or gate, had it existed, would have caught
   this with a different driver?"
5. **Record what went well and where we got lucky.** Luck is a cause
   that hasn't fired yet; each lucky line is a candidate cause of the
   next incident.
6. **File action items, each naming its enforcement surface** — the
   standing thing that now exists or will: an agents-guide rule, a CI
   gate, a corpus fixture, an ADR deferred-table row, a debt file, a
   memory entry, a skill. An action item whose only artifact is a
   paragraph in the incident doc is a smell — future agents load the
   guides and the gates; they do not re-read old post-mortems. Items
   completed during the response stay listed, checked. Open items get a
   home outside the doc (deferred table, debt file, task chip) in the
   same change.
7. **Land it by PR** — review of the post-mortem IS the ratification of
   its causes and action items. Update the registry index in the same
   commit. Small, cheap enforcement edits (a one-paragraph rule in the
   agents guide) ride the same PR; larger ones get their own tracked
   home.
8. **Close out**: when the last open action item lands, flip the entry's
   `status: actions-open` → `closed` in whatever change completed it.

## Entry template

Use the repo README's template verbatim. If bootstrapping, this is the
canonical shape:

```markdown
---
status: actions-open    # actions-open | closed
date: YYYY-MM-DD        # when impact began
severity: severe        # minor | severe | critical
duration: <impact window ("5h 10m")>
related: []             # defects, debt, ADRs, PRs
---
# <one-line title, past tense, impact-first>

**Impact** — who/what/how long, and the remedy users had meanwhile.
**Timeline** — UTC, artifact-anchored; human events approximate.
**Contributing causes** — numbered, systemic, blameless.
**What went well / where we got lucky** — both lists, honestly.
**Action items** — checkboxes; every line names its enforcement surface.
```

## Final response

Lead with severity, duration, and the one-line impact. Then the causes
as a short numbered list, the action items with their enforcement
surfaces and states, and the PR link. Do not paraphrase the whole
document — the reader will open it; give them the shape and the things
that need their decision (severity grade, contested causes, open
items).
