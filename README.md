# ABCD Triage Decision Tree

Prolog implementation of the ABCD triage decision tree (see `Visual decision tree_RR.pdf`).

## Files

- `tree.pl` — tree traversal logic
- `knowledge_base.pl` — nodes, leaves, and conditions
- `interactive.pl` — interactive triage session (prompts for missing attributes)
- `patient.json` — patient data template; fill in known values, leave unknowns as `null`
- `inference_checks.sh` — automated test runner (queries `tree.pl` directly)
- `run_with_data.sh` — test runner using pre-filled patient data via `interactive.pl`

## Requirements

Install SWI-Prolog:

```bash
# Ubuntu
sudo apt install swi-prolog -y

# macOS
brew install swi-prolog
```

## Usage

**Interactive session** (prompts yes/no for each attribute):

```bash
./interactive.pl
```

**With pre-filled patient data** — fill in `patient.json` (leave unknowns as `null`), then:

```bash
./interactive.pl patient.json
```

**Run automated tests:**

```bash
./inference_checks.sh
./run_with_data.sh
```
