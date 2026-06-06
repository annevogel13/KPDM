#!/bin/sh

# Test runner for the ABCD triage decision tree.
# Patient data is passed as a Key-Value list (second argument).
# All keys are supplied, so no user prompts are triggered.
# Usage: ./inference_checks.sh

run() {
  printf '== %s ==\n' "$1"
  swipl -q -s tree.pl -g "$2" 2>&1 || true
  echo
}

# ── Root ────────────────────────────────────────────────────────────────────

run "Patient declines ICU/IMC -> expect er_normal_ward" \
  "decision_tree(start,[wishes-icu_imc_not_wished],R),writeln(R),halt."

# ── A – Airway ───────────────────────────────────────────────────────────────

run "Intubated -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-yes],R),writeln(R),halt."

run "Inspiratory stridor (not intubated) -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-yes],R),writeln(R),halt."

# ── B – Breathing ────────────────────────────────────────────────────────────

run "Abnormal resp rate, NIV needed, B-problem persists -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-yes,niv_needed-yes,patient_status-b_problem_persists],R),writeln(R),halt."

run "Abnormal resp rate, NIV needed, stabilized on NIV -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-yes,niv_needed-yes,patient_status-stabilized_on_niv],R),writeln(R),halt."

run "Abnormal resp rate, no NIV needed -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-yes,niv_needed-no],R),writeln(R),halt."

run "Normal resp rate, pneumothorax/thoracic drainage -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-yes],R),writeln(R),halt."

# ── C – Circulation ──────────────────────────────────────────────────────────

run "External bleeding needing surgery -> expect emergency_surgery" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-yes],R),writeln(R),halt."

run "Mottling -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-yes],R),writeln(R),halt."

run "Severe bradycardia (<45 bpm) -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-yes],R),writeln(R),halt."

run "ECG abnormalities, vasopressors needed, high dose -> expect icu" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-yes,vasopressors_needed-yes,vasopressors_dose-high],R),writeln(R),halt."

run "ECG abnormalities, vasopressors needed, low dose -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-yes,vasopressors_needed-yes,vasopressors_dose-low],R),writeln(R),halt."

run "ECG abnormalities, no vasopressors, telemetry available -> expect normal_ward" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-yes,vasopressors_needed-no,telemetry_available-yes],R),writeln(R),halt."

run "ECG abnormalities, no vasopressors, no telemetry -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-yes,vasopressors_needed-no,telemetry_available-no],R),writeln(R),halt."

# ── D – Disability ───────────────────────────────────────────────────────────

run "Intracranial hemorrhage -> expect emergency_surgery" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-no,intracranial_hemorrhage-yes],R),writeln(R),halt."

run "GCS < 10 -> expect icu_imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-no,intracranial_hemorrhage-no,gcs_below_10-yes],R),writeln(R),halt."

run "Stroke, no other critical findings -> expect imc" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-no,intracranial_hemorrhage-no,gcs_below_10-no,stroke-yes],R),writeln(R),halt."

run "Stable patient, outpatient treatment possible -> expect er" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-no,intracranial_hemorrhage-no,gcs_below_10-no,stroke-no,outpatient_possible-yes],R),writeln(R),halt."

run "Stable patient, no outpatient option -> expect normal_ward" \
  "decision_tree(start,[wishes-icu_imc_wished,intubated-no,inspiratory_stridor-no,abnormal_resp_rate-no,pneumothorax-no,external_bleeding-no,mottling-no,severe_bradycardia-no,ecg_abnormalities-no,intracranial_hemorrhage-no,gcs_below_10-no,stroke-no,outpatient_possible-no],R),writeln(R),halt."
