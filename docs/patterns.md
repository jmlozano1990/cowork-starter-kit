# Known Patterns

_Recurring findings promoted from /retro pattern detection. Read by @dev (preservation) and @security (elevated attention)._

| Pattern | Severity | Cycles | Description | Detected |
|---------|----------|--------|-------------|----------|
| ADR-spec drift on parameterized artifacts | WARNING | v1.2, v2.0 (C8/B2/A3) | When a spec, ADR, or release artifact describes a parameterized list (category count, feature checklist, CHANGELOG entry), implementations ship with placeholder values or subsets instead of the final computed value. Mitigation: Phase 5 ADR-to-implementation parameterized-list diff as a standard checklist item. | 2026-05-07 |
