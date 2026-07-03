#!/usr/bin/env bash
# Create the canonical labels used by the SOP and skills (see docs/agents/triage-labels.md).
# Idempotent — `--force` updates color/description if the label already exists.
set -euo pipefail

label() { gh label create "$1" --color "$2" --description "$3" --force; }

# Triage roles
label needs-triage    e4e669 "Maintainer needs to evaluate this issue"
label needs-info      d876e3 "Waiting on reporter for more information"
label ready-for-agent 0e8a16 "Fully specified, ready for an AFK agent"
label ready-for-human 1d76db "Requires human implementation"
label wontfix         ffffff "Will not be actioned"

# Kind
label kind:issue         c5def5 "Work item / slice"
label kind:prd           5319e7 "Product requirements document"
label kind:arch-followup fbca04 "Architecture follow-up candidate"

# Process state
label queued     bfdadc "Waiting on dependency or capacity"
label watch-only ededed "Filed for visibility; trigger condition not yet met"
label blocked    b60205 "Blocked by an external constraint"
label merged     6f42c1 "Landed on main"

# Severity
label severity:high   d93f0b "High severity"
label severity:medium fef2c0 "Medium severity"
label severity:low    e6f7d9 "Low severity"

# ponytail: prd:<slug> labels are per-feature and created ad hoc at §2.1 Gate 1.
echo "Done."
