# Principles of Agentic Engineering

The skills in this repo are the easy part. You can install them in five minutes. This document is the hard part: the way of working that makes them useful.

I wrote this because several people have asked me how I get the results I get with coding agents, and I realized I didn't have a good answer. "Something about how I talk to them" is not an answer. So I went back through my own repos — a year of solo and small-team work done almost entirely through agents — and looked for what I actually do. These principles are what I found.

A warning up front: none of these work as tips. They work as practice. A friend of mine took the same interview I did, with access to the same kinds of tools, and was rejected. The feedback was one line: it comes down to agentic depth, and how much practice each person has building with agents. Depth is the thing this document is trying to give you a head start on. It cannot give you the depth itself. You get that by doing the work and paying attention.

## 1. Understand what you're working with

Agents are not junior developers, and they are not magic. They are a new kind of collaborator with a specific shape, and most frustration with them comes from not knowing the shape.

Agents are:

- **Fast and parallelizable.** One agent can do a day of typing in an hour. Five agents can do it at once. This is the headline feature and the only one most people notice.
- **Amnesic.** Every session starts from zero. The agent that did brilliant work yesterday remembers none of it today. Anything you want carried forward, you must carry forward yourself — in files, not in your head.
- **Plausible at every quality level.** Agent output always *looks* right. Wrong agent code is more dangerous than wrong human code because it is better formatted and more confident. You cannot judge agent work by reading it the way you'd skim a trusted colleague's diff.
- **Path-of-least-resistance seekers.** When blocked, an agent will stub the function, suppress the warning, weaken the test, or fake the data — not out of malice, but because that's the shortest path to "done." You have to block these exits explicitly.
- **Eager to please.** An agent will agree with a bad plan enthusiastically. If you want pushback — and at decision points, you do — you have to ask for it directly.
- **Literal.** Agents do what the instructions say, including the parts that are stale or wrong. If your docs contradict each other, the agent will follow one of them, and you won't like which.
- **High-variance.** The same prompt on the same task can produce great work or mediocre work. Structure reduces variance far more than clever prompt wording does.

Everything else in this document is a response to this list.

## 2. Your attention is the scarce resource — spend it deliberately

Agents made implementation cheap. That means the bottleneck moved to you: your judgment, your focus, your ability to notice that something is off. Treat that as the scarce resource it now is.

Spend judgment on the things where humans and agents genuinely differ: architecture, UI and UX, how the app *feels*, scope, taste, what "good" means for this project. Do not spend it re-reviewing mechanical work that a test suite could have checked.

And spend some of it one level up: deciding *where* your judgment goes. Design review gates into the plan before work starts, at the points where a human call is actually needed — not sprinkled everywhere out of anxiety. Batch small confirmation questions so you can answer ten of them with "all yes." Take big questions one at a time. Mark settled decisions as settled — "decided, do not relitigate" — so neither you nor the agent burns attention re-arguing them.

If you find yourself exhausted after a day of agent work, this is usually the principle you're violating: you're spending judgment reactively, wherever the agent happens to drag your attention, instead of at gates you chose in advance.

## 3. Strategy and tactics are different things

Keep planning and implementation separate. Not because process is virtuous, but because they fail differently.

Planning is where the expensive mistakes live: wrong architecture, wrong scope, building the wrong thing. It's cheap to fix a plan and brutal to fix a codebase. So plan first, in prose, with the agent doing discovery — reading the code, surfacing questions, proposing answers — and you making the calls. Then implement against the finished plan, ideally in a fresh session whose only job is execution.

Mixing the two is the classic failure mode: you ask for a feature, the agent starts typing, and forty minutes later you're debugging an implementation of a design you never agreed to. The plan/implement split is what the `plan` and `implement` skills in this repo enforce. When I built my interview project in 36 minutes, the first five were planning — and those five minutes are why the other 31 worked.

## 4. Break work into self-contained chunks

Because agents are amnesic, every unit of work must carry its own context. A phase file should be executable by an agent that has read *only that file* plus whatever it explicitly references: the scope, the boundaries, the relevant conventions, the validation commands, the definition of done.

This feels redundant when you write it — you're restating things "everyone knows." But there is no everyone. There is one agent, in one session, with one context window, and it knows exactly what's in front of it. Restating a repo convention inside a phase file costs three lines. Leaving it out costs a wrong implementation and a review cycle.

The bonus is that self-contained chunks are what make parallelism possible. If each phase carries its own context, five agents can run five phases at once without stepping on each other. Chunking isn't overhead on the way to parallel work; it *is* the parallel work.

## 5. Files, not conversations

The conversation is ephemeral. It will be compacted, the session will die, the window will close. The filesystem is the system of record.

Anything that matters gets written to a file before continuing: discovery notes, decisions, scope changes the user made in chat, what was actually done, what was validated, what's left. My planning directories accumulate `notes.md` (the live discovery log), `plan.md` (the entrypoint), phase files, and `_DONE.md` (the honest record of what actually happened, deviations included).

This is what makes context switching survivable. When I run several agents in parallel, my job is coordination, and coordination is only possible because any session's state can be rehydrated from disk by me or by another agent. It's also what makes handoffs work — including handoffs to yourself next week, who remembers nothing either.

A good test: if your machine crashed right now, how much would you lose? If the answer is "the agent and I had figured out a bunch of stuff in chat," you're doing it wrong.

## 6. Make "done" checkable by machine

An agent in a tight verification loop doesn't need to be brilliant to end up correct. An agent without one can't be trusted no matter how brilliant it is — see "plausible at every quality level," above.

So every chunk of work ends with literal commands: run these tests, run this typecheck, run this build. Put them in the phase file so the agent runs them without being asked. Give agents the same feedback loop CI gives, locally, so failures surface in seconds instead of after a push. If the work is visual, make the visual state checkable too — snapshot tests, screenshots posted for review, whatever turns "looks fine to me" into evidence.

The companion rule is **honest failure**. When something can't be done — an API is bot-blocked, a data source is down — the right output is an explicit `unavailable`, not a plausible guess. Design your schemas, your plans, and your instructions so that failure is loud and visible. Agents will paper over gaps if papering over is allowed. Don't allow it.

## 7. Give autonomy explicit boundaries

People under-delegate to agents because they haven't defined where delegation ends. Define it, and you can delegate aggressively.

My skills carry the same short list of boundaries everywhere: do not expand scope. Do not suppress warnings or disable tests to get green. If validation fails twice on the same thing, stop and report. If fixing something would change a public API beyond the plan, stop and ask. If genuinely blocked, stop — don't improvise.

These aren't distrust; they're the *terms* of trust. Inside the fence, the agent runs free and I don't hover. At the fence, it stops and I engage. Freedom inside a fence beats hesitation in an open field — for the agent and for you.

The fence has to be closed on both sides, though, and this is the half people forget. A list of reasons to stop, with no matching statement of when to keep going, produces an agent that stops constantly — every phase boundary, every commit, every "implementation is done, shall I push?" — because pausing always looks like the safe choice. So I make the stop list *closed*: these are the only reasons to stop, and if your reason isn't on the list, keep going. Then I name the non-reasons explicitly, because they're the ones agents actually invent. Finishing a phase is not a reason. Committing is not a reason. Wanting to confirm the obvious next step is not a reason.

That's what makes the gates from principle 2 worth designing: they only save your attention if they're the *only* things that spend it.

## 8. Steal from industry

Software engineering process — code review, ADRs, conventional commits, CI gates, issue tracking, postmortems — represents millions of human-hours spent learning to coordinate fast-moving, imperfect, partially-informed agents. Those agents were called "people." The lessons transfer almost unchanged.

It's fashionable to say AI makes all that ceremony obsolete. My experience is the opposite: agents make the ceremony *cheap enough to actually do*. An agent will happily write the ADR, keep the changelog honest, and maintain the review artifact — the toil that made teams skip these practices is gone, and what's left is their value: durable memory and legible decisions.

So don't invent an agent workflow from scratch. Ask what a good engineering org already does about this problem, and have the agents do that.

## 9. Your process is a codebase — refactor it every time it fails

This is the principle that generates all the others, and the one I'd keep if I could only keep one.

When something goes wrong — the agent misunderstood, took a shortcut, broke a convention, wasted your evening — the instinct is to fix the code and move on. Fix the code, yes. But then ask: *what would have prevented this class of failure?* And put the answer somewhere an agent is required to look: the agents file, a skill, a plan template, a new validation step. The lesson isn't remembered; it's enforced.

Every team knows they should do retrospectives. Most retrospective output goes into a document that nothing enforces, and decays. The difference here is that your process artifacts are *executable* — agents actually follow them — and updating them costs nothing, because you delegate the update itself: "that went sideways; update the plan skill so it can't happen again" is a thirty-second instruction. I revise my skills, my agents file, and my templates constantly, almost always via the agents themselves.

Do this every time and your environment compounds. A year in, your setup has absorbed hundreds of corrections, and an agent working in it succeeds on the first try at things that fail everywhere else. This is what "agentic depth" actually is. It's not a talent. It's a ratchet, and you have to turn it.

A habit to start today: end any session where something annoyed you by asking the agent, "What should we change in the skill or the docs so that doesn't happen again?" — and let it make the edit.

## 10. Don't take the keyboard

When an agent can't do something, the tempting move is to just do it yourself. Sometimes that's right — especially with older models, and the frontier of "agents can't do this" moves every few months, so keep re-testing it. But doing it yourself should feel like a last resort, for the same reason a good lead doesn't grab a junior's keyboard: if you just do it, nothing learns.

With agents the point is sharper, because the agent *can't* learn — the next session is a blank slate regardless. What learns is the environment. Take the keyboard and the fix lands in the code and nowhere else. Ask instead "how do *I* need to change?" and the fix lands somewhere that improves every future session.

When an agent fails, run this diagnostic before touching the keyboard:

1. **Was context missing?** Then a doc or skill has a gap. Fill it.
2. **Was the feedback loop missing?** The agent had no way to know it was wrong. Add the test, the validation command, the check.
3. **Is the codebase illegible?** Agent-hostile code is usually human-hostile code with better excuses. Giant files, tangled modules, conventions that live only in your head — the agent is a canary. Fix the code's legibility and both species benefit.
4. **Is it genuinely beyond the model?** Fine — do it yourself, and write down that you did, so you notice when a model upgrade moves the line.

You are not the fallback implementer. You are the person who makes the next attempt succeed.

---

## The shape of the whole thing

If you compress all ten: **know your material, spend judgment deliberately, structure the work, verify mechanically, and make everything compound.**

The first four you can start doing this week, and they'll make you noticeably better. The last one — the compounding — is the difference between using agents and being good with them. It doesn't come from this document. It comes from treating every failure as a process bug, for months. The skills in this repo are just my ratchet, frozen at one point in time. Build your own.
