# ABCD Triage Decision Tree

Prolog implementation of the ABCD triage decision tree (see `Visual decision tree_RR.pdf`).

## Files

- `tree.pl` — tree traversal logic
- `knowledge_base.pl` — nodes, leaves, and conditions
- `interactive.pl` — interactive triage session
- `patient.json` — patient data template; fill in known values, leave unknowns as `null`
- `inference_checks.sh` — automated test runner (direct tree queries with complete data, no prompts)
- `run_with_data.sh` — interactive triage with pre-filled data (automatic run-through)
- `run_patient_json.sh` — interactive triage with pre-filled patient data from JSON file

## Requirements

Install SWI-Prolog:

```bash
# Ubuntu
sudo apt install swi-prolog -y

# macOS
brew install swi-prolog
```

## Usage

### Interactive Triage (CLI)

**Fully interactive** (prompts for all attributes):

```bash
./interactive.pl
```

**With pre-filled data** (partial or complete, interactive for unknows):

```bash
./interactive.pl "[wishes-icu_imc_wished,intubated-yes]"
```

Missing attributes will trigger interactive prompts.

### Batch Testing

**Test runner with pre-filled data**:

```bash
./run_with_data.sh
```

Runs multiple test cases with predefined patient data sets. Each test can provide partial data plus piped answers for missing attributes.

**Test runner with JSON patient file**:

```bash
./run_patient_json.sh                 # uses patient.json by default
./run_patient_json.sh custom_file.json  # use a different JSON file
```

Converts JSON patient data to Prolog format and runs interactive triage. Automatically filters out `null` values.

**Automated inference tests** (complete data only, no prompts):

```bash
./inference_checks.sh
```

Direct tree queries with all attributes specified. Used for regression testing.

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

## Prolog Data Format

When using `interactive.pl` directly or via `run_with_data.sh`, patient data is expressed as a Prolog list of key-value pairs:

```prolog
[wishes-icu_imc_wished,intubated-yes,inspiratory_stridor-no]
```

Each pair follows the format `key-value` where:

- `key` is the attribute name (matches the `patient.json` keys)
- `value` is the attribute value (see [patient.json values](#patientjson-values) table)

**Examples:**

Complete data (no prompts):

```prolog
[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-yes,niv_needed-yes,patient_status-stabilized_on_niv]
```

Partial data (missing attributes trigger prompts):

```prolog
[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no]
```

The `run_patient_json.sh` script automatically converts JSON to this format.

```bash
./inference_checks.sh
./run_with_data.sh
```
