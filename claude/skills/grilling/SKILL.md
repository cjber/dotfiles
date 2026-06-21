---
name: grilling
description: "Interview the user one question at a time to resolve a plan or design before any code is written. Use when the user wants to stress-test a plan, says 'grill me', 'grill this', 'poke holes', or hands over an ambiguous task where guessing would be costlier than asking. Adapted from mattpocock/skills."
argument-hint: "[plan, design, or task to interrogate]"
---

# Grilling

The most expensive failure mode is misalignment: you build the wrong
thing confidently because the task was underspecified and you guessed.
Grilling spends a few cheap questions up front to kill that.

Interview the user relentlessly about the plan or design until you both
reach a shared understanding. Walk down each branch of the decision tree,
resolving dependencies between decisions one at a time.

## Rules

1. **One question at a time.** Ask, wait for the answer, then ask the
   next. A batch of questions is bewildering and gets answered shallowly
   or not at all. Serial beats parallel here.
2. **Carry a recommended answer.** Every question states your default
   ("I'd lean X because Y - agree?"). This is collaboration, not a
   form to fill out; the user corrects a proposal faster than they
   author one from scratch.
3. **Check the code before asking.** If the answer is discoverable in
   the codebase (an existing convention, a type, how a sibling feature
   does it), go read it instead of asking. Only ask what the code can't
   tell you: intent, priorities, tradeoffs, scope.
4. **Follow dependencies.** Resolve the decision that unblocks the most
   downstream questions first. When an answer opens a new branch, walk
   it before backing out.
5. **Stop when the tree is resolved**, not after a fixed count. The exit
   condition is "no branch left that would change what gets built," then
   summarise the resolved design in a few lines and hand back.

## When to reach for it

- Before a non-trivial plan or PR where the spec has real ambiguity.
- When a planning skill (`/issue`, `/improve`) would otherwise have to
  guess at intent - grill first, then plan against the answers.
- When the user explicitly asks to be grilled / have a plan poked at.

Skip it for tasks with one obvious interpretation; per `feedback_skip_
askquestion_when_obvious`, if there's a clear default just state it and
proceed.
