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

## patient.json values

| Key                      | Accepted values                              |
|--------------------------|----------------------------------------------|
| `wishes`                 | `"icu_imc_wished"`, `"icu_imc_not_wished"`   |
| `intubated`              | `"yes"`, `"no"`                              |
| `inspiratory_stridor`    | `"yes"`, `"no"`                              |
| `abnormal_resp_rate`     | `"yes"`, `"no"`                              |
| `niv_needed`             | `"yes"`, `"no"`                              |
| `patient_status`         | `"b_problem_persists"`, `"stabilized_on_niv"`|
| `pneumothorax`           | `"yes"`, `"no"`                              |
| `external_bleeding`      | `"yes"`, `"no"`                              |
| `mottling`               | `"yes"`, `"no"`                              |
| `severe_bradycardia`     | `"yes"`, `"no"`                              |
| `ecg_abnormalities`      | `"yes"`, `"no"`                              |
| `vasopressors_needed`    | `"yes"`, `"no"`                              |
| `vasopressors_dose`      | `"high"`, `"low"`                            |
| `telemetry_available`    | `"yes"`, `"no"`                              |
| `intracranial_hemorrhage`| `"yes"`, `"no"`                              |
| `gcs_below_10`           | `"yes"`, `"no"`                              |
| `stroke`                 | `"yes"`, `"no"`                              |
| `outpatient_possible`    | `"yes"`, `"no"`                              |

Leave any key as `null` to be prompted for it during the session.

**Run automated tests:**

```bash
./inference_checks.sh
./run_with_data.sh
```
