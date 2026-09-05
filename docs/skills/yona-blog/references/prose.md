# Prose Register

The failure this file guards against: a post that is correct, well
structured, and reads like a model wrote it. Readers notice, and the
noticing costs the post its credibility before the argument starts.

Every pattern below is a documented marker of machine-written text.
The target repo may carry its own rules in `AGENTS.md` or `CLAUDE.md`;
those win where they conflict. This file is the portable default.

## The one-line version

Say the thing. When a literal phrase is available, use it.

## Patterns to remove

**Hedged intensifiers and the knowing narrator.** The writer winks at
the reader instead of stating the claim.

- "The shape of the code is almost suspiciously simple:" becomes
  "The shape is simple:".
- "That third part matters more than it looks like it should" becomes
  "That third part does the most work."
- Delete on sight: almost suspiciously, deceptively, surprisingly,
  quietly (as a flourish, not as a description of silent behavior),
  genuinely, honestly, truly, actually (as emphasis).

**Mannered prose.** Metaphor and flourish in place of direct statement.
Anthropic's own definition: instead of "a parameter worth varying" the
mannered writer produces "a dial worth turning"; instead of "this still
matters", "this earns its keep". The phrase exists to display the writer,
and the metaphor drags in connotations the writer did not choose.

- "several rectangles conspiring" becomes "several separate rectangles".
- "not little actors with private lives" becomes "have no behavior and
  no identity".
- "earns its keep" becomes "pays off".

**Self-labeled significance.** Announcing that a point is important
instead of making it land.

- "This is the punchline:", "Here's the trick:", "The key insight is",
  "Notice what quietly disappeared." Cut the label; keep the sentence
  after it.

**Throat-clearing and codas.** "It's worth noting", "In other words",
"At its core", "In summary", "Overall". A paragraph that ends by
restating itself.

**Negated contrast.** "Not X but Y", "it's not just X, it's Y". Allowed
only when X is something the reader believed. Otherwise say Y.

**Tricolons and closing fragments.** "One name. One schema. One place
to look." Models default to threes because three sounds finished.
Once per blog, not once per post.

**Em dashes.** The single most recognized tell. Use commas, periods,
colons, or parentheses. A post should have zero or close to it.

**Tailing participles.** A present participle hung on the end of a
sentence to add unearned weight: "..., highlighting the importance
of ...".

**Bold-label bullet lists.** "**Term.** Explanation." repeated five
times is a template. Bullets are for real enumerations; an argument
stays in paragraphs.

**Uniform rhythm.** Same-length sentences and same-length paragraphs
read as extruded. Vary both.

**Headings with attitude.** "Caveats, honestly", questions, emoji.
Headings are plain nouns.

**Copula avoidance.** "serves as", "features", "boasts" where "is" or
"has" is meant.

## Vocabulary

Never: delve, leverage, robust, seamless, landscape, navigate, harness,
foster, crucial, pivotal, game-changer, elegant, beautifully, unlock,
empower, journey, tapestry, nuanced, "at scale" as decoration.

Prefer the short word: use, not utilize; method, not methodology; so,
not "in order to"; because, not "due to the fact that".

## What to keep

These are the voice, and stripping them produces a different kind of
machine text: the flat, hedgeless corporate kind.

- First person and stated opinions. "I tend not to." "I like this for."
- Contractions.
- Named tradeoffs and numbered failure modes.
- A quip that is a joke rather than a flourish ("Discipline is not my
  favorite build tool").
- Grounded specifics: real counts, real file names, real call sites.
- Code that carries the argument on its own.

## Audit pass

Run before handing back any draft or revision, and again after a
revision pass, because rewriting introduces new instances.

1. Grep the post for the banned vocabulary, the intensifiers, em dashes,
   "not just", and "worth noting". Fix each hit or justify it.
2. Read the opening paragraph and the closing paragraph. If either
   sounds like a product page or a chatbot, rewrite it.
3. Look at list shape. Any list of bold-label bullets that is really an
   argument goes back to paragraphs.
4. Check headings for attitude.
5. Check the closing line for a tricolon.

## Sources

- Anthropic, "Prompting Claude Fable 5.1", section Writing density:
  the mannered-prose definition above, recommended as paste-in prompt
  text.
- Wikipedia, "Signs of AI writing": the WikiProject AI Cleanup catalog
  of vocabulary, structural, and formatting tells.
- yzhao062/agent-style: 21 writing rules for coding agents, including
  the em dash, transition-word, and paragraph-coda rules.
- conorbronsdon/avoid-ai-writing: tiered vocabulary list and the
  audit-then-rewrite procedure this file's audit pass follows.
