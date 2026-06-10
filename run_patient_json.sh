#!/bin/sh
# Run interactive triage with patient data from a JSON file.
#
# Usage: ./run_patient_json.sh [patient.json]
#        ./run_patient_json.sh  # defaults to patient.json

json_to_prolog() {
    # Convert JSON object {"key":"value",...} to Prolog list [key-value,...]
    # Filters out null values
    jq -r 'to_entries | map(select(.value != null) | "\(.key)-\(.value)") | "[" + join(",") + "]"' "$1"
}

patient_file="${1:-patient.json}"

if [ ! -f "$patient_file" ]; then
    echo "Error: Patient file '$patient_file' not found" >&2
    exit 1
fi

# Convert JSON to Prolog format
prolog_data=$(json_to_prolog "$patient_file")

if [ -z "$prolog_data" ]; then
    echo "Error: Failed to parse JSON file" >&2
    exit 1
fi

echo "Running triage with data from $patient_file"
echo "Patient data: $prolog_data"
echo ""

# Run interactive.pl with the converted data
./interactive.pl "$prolog_data"
