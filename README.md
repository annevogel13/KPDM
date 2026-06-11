# ABCD Triage Decision Tree

Prolog implementation of the ABCD triage decision tree (see `Visual decision tree_RR.pdf`).

## Files

- `tree.pl` — tree traversal logic
- `knowledge_base.pl` — nodes, leaves, and conditions
- `interactive.pl` — interactive triage session
- `patient.json` — patient data template; fill in known values, leave unknowns as `null`
- `inference_checks.sh` — automated regression tests (complete data, no prompts)

## Requirements

Install SWI-Prolog (includes the JSON library):

```bash
# Ubuntu
sudo apt install swi-prolog-nox -y

# macOS
brew install swi-prolog
```

## Usage

### Interactive Triage (CLI)

**Fully interactive** (prompts for every attribute):

```bash
./interactive.pl
```

**With pre-filled patient data** (known values loaded from JSON, missing ones are prompted):

```bash
./interactive.pl patient.json
```

Fill in any values you already know in `patient.json` and leave the rest as `null`.

### Automated Tests

```bash
./inference_checks.sh
```

Runs 45 regression tests covering every branch of the tree. All data is supplied inline — no prompts triggered.

## Possible outcomes

| Outcome | Meaning |
|---|---|
| `icu` | ICU — Intensive Care Unit |
| `icu_intubated` | ICU — Intubation required |
| `imc` | IMC — Intermediate Care |
| `imc_neuro` | IMC — Intermediate Care (Neurology) |
| `imc_c_prob` | IMC — Intermediate Care (Cardiac monitoring) |
| `emergency_surgery` | Emergency Surgery |
| `ct_surgery` | CT Scan + Surgery planning |
| `er` | Emergency Room / Outpatient |
| `normal_ward` | Normal Ward |

## patient.json keys

| Key | Accepted values | Section |
|---|---|---|
| `intubated` | `"yes"`, `"no"` | A |
| `inspiratory_stridor` | `"yes"`, `"no"` | A |
| `abnormal_resp_rate` | `"yes"`, `"no"` | B |
| `lungs_vent_sym` | `"yes"`, `"no"` | B |
| `niv_needed` | `"yes"`, `"no"` | B |
| `b_stabilized` | `"yes"`, `"no"` | B |
| `patient_status` | `"b_problem_persists"`, `"stabilized_on_niv"` | B |
| `pneumothorax` | `"yes"`, `"no"` | B |
| `pers_abnormal_resp_rate` | `"yes"`, `"no"` | B |
| `external_bleeding` | `"yes"`, `"no"` | C |
| `neuro_normal` | `"yes"`, `"no"` | C |
| `mottling` | `"yes"`, `"no"` | C |
| `vasopressors_needed` | `"yes"`, `"no"` | C |
| `vasopressors_dose` | `"high"`, `"low"` | C |
| `arrhythmia` | `"yes"`, `"no"` | C |
| `severe_bradycardia` | `"yes"`, `"no"` | C |
| `bradycardia_hemodynamically_relevant` | `"yes"`, `"no"` | C |
| `tachycardia` | `"yes"`, `"no"` | C |
| `tachycardia_hemodynamically_relevant` | `"yes"`, `"no"` | C |
| `arrhythmia_hemodynamically_relevant` | `"yes"`, `"no"` | C |
| `cardioversion_possible` | `"yes"`, `"no"` | C |
| `cardioversion_stable` | `"yes"`, `"no"` | C |
| `ecg_abnormalities` | `"yes"`, `"no"` | C |
| `telemetry_available` | `"yes"`, `"no"` | C |
| `gcs_below_13` | `"yes"`, `"no"` | D |
| `intracranial_hemorrhage` | `"yes"`, `"no"` | D |
| `gcs_below_10` | `"yes"`, `"no"` | D |
| `stroke` | `"yes"`, `"no"` | D |
| `outpatient_possible` | `"yes"`, `"no"` | D |

Leave any key as `null` to be prompted for it during the session.
