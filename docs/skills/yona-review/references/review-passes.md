# Review Passes

Use only the passes relevant to the diff and repo.

## Correctness

- Does the implementation satisfy the apparent user story?
- Are empty, duplicate, missing, malformed, and boundary inputs handled?
- Are async, ordering, retry, interrupt, or race behaviors safe?
- Does the code preserve existing wire formats, persisted data, and public contracts?

## Tests

- Do tests fail before the fix and pass after it?
- Are important edge cases covered at the right layer?
- Did the change weaken, skip, or over-mock existing tests?
- Are target-specific tests included when the diff touches target-specific behavior?

## Repo Conventions

- Does the change follow local file organization and naming patterns?
- Does it use nearby helpers instead of introducing a parallel abstraction?
- Are tests placed and structured according to local conventions?
- Are repo agent instructions, style docs, and validation commands respected?

## Embedded And Runtime

- Does the change preserve `no_std` and target constraints where required?
- Are allocation, latency, stack, binary size, and code size considered when relevant?
- Does the change keep compile/runtime paths available on the intended device?
- Are hardware, emulator, or cross-target validation commands included when needed?

## Security And Operations

- Are secrets, logs, and diagnostics safe?
- Are auth, ownership, and capability boundaries preserved?
- Are config defaults, missing env vars, and rollback behavior clear?
- Are logs and metrics useful enough for debugging?
- Are database transactions and migrations safe to run and to roll back?

## Frontend

- Is the touched UI accessible, keyboard-operable, responsive, and free of text overlap?
- Does it follow existing component and interaction patterns?
- Are loading, empty, disabled, error, and success states handled?
- Does it build the actual tool or workflow rather than a decorative shell?
