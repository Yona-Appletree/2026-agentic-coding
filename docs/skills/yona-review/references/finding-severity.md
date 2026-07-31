# Finding Severity Reference

Use severity to communicate merge risk, not reviewer confidence.

## P0

Use for issues that should stop release immediately:

- Credential leak or exploitable security flaw
- Data loss or destructive migration bug
- Production deploy breakage
- Broken auth, tenant isolation, or device safety boundary
- Product-critical compiler/runtime path disabled

## P1

Use for likely user-visible or correctness failures:

- Valid user flow fails
- Invalid data is accepted
- Required validation is bypassed
- Backwards-incompatible API or persisted-data change
- Test suite misses a high-risk behavior touched by the diff
- Embedded, no-std, or target-specific build path is broken

## P2

Use for meaningful engineering risk:

- Repo pattern violation that makes testing or extension harder
- Missing edge-case coverage for non-critical behavior
- Accessibility or responsive issue in a touched UI path
- Observability or debugging gap that will matter during incidents
- Performance, allocation, binary-size, or latency regression without measurement

## P3

Use for minor tracked work:

- Small naming or clarity issue
- Low-risk cleanup
- Documentation gap that does not block understanding the change

When uncertain, choose the lower severity and write better evidence.
