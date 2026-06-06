% Knowledge base: nodes, leaves, conditions, and user-prompting logic.
%
% tree.pl calls conditions as: call(Condition, PatientData, _)
% PatientData is a list of Key-Value pairs: [key1-val1, key2-val2, ...]
%
% Behavior per condition:
%   - Key present in PatientData  -> use the stored value (no prompt)
%   - Key absent from PatientData -> ask the user yes/no, cache the answer
%
% ---------------------------------------------------------------------------
% Tree nodes  node(NodeId, Condition, TrueBranch, FalseBranch)
% ---------------------------------------------------------------------------

% Root: patient wishes
node(start,                     wishes_icu_imc,               airway_intubated,          er_normal_ward).

% A - Airway
node(airway_intubated,          is_intubated,                 icu,                       airway_stridor).
node(airway_stridor,            has_inspiratory_stridor,      icu,                       breathing_abnormal_rate).

% B - Breathing
node(breathing_abnormal_rate,   has_abnormal_resp_rate,       breathing_niv_needed,      breathing_pneumothorax).
node(breathing_niv_needed,      niv_needed,                   breathing_patient_status,  imc).
node(breathing_patient_status,  b_problem_persists,           icu,                       imc).
node(breathing_pneumothorax,    has_pneumothorax,             imc,                       circulation_ext_bleeding).

% C - Circulation
node(circulation_ext_bleeding,  has_external_bleeding,        emergency_surgery,         circulation_mottling).
node(circulation_mottling,      has_mottling,                 icu,                       circulation_bradycardia).
node(circulation_bradycardia,   has_severe_bradycardia,       icu,                       circulation_ecg).
node(circulation_ecg,           has_ecg_abnormalities,        cardiac_cath_vasopressors, disability_intracranial).

% Post cardiac catheterization (reached when ECG abnormalities are present)
node(cardiac_cath_vasopressors, needs_vasopressors,           cardiac_cath_dose,         cardiac_cath_telemetry).
node(cardiac_cath_dose,         vasopressors_high_dose,       icu,                       imc).
node(cardiac_cath_telemetry,    telemetry_available,          normal_ward,               imc).

% D - Disability
node(disability_intracranial,   has_intracranial_hemorrhage,  emergency_surgery,         disability_gcs).
node(disability_gcs,            gcs_below_10,                 icu_imc,                   disability_stroke).
node(disability_stroke,         has_stroke,                   imc,                       final_ranking_outpatient).
node(final_ranking_outpatient,  outpatient_treatment_possible, er,                       normal_ward).

% ---------------------------------------------------------------------------
% Outcome leaves
%   icu            - Intensive Care Unit
%   imc            - Intermediate Care (IMC / step-down)
%   icu_imc        - ICU or IMC; requires further determination
%   er_normal_ward - ER or Normal Ward (patient declined ICU/IMC level care)
%   emergency_surgery - immediate surgery required
%   er             - Emergency Room / outpatient follow-up
%   normal_ward    - standard hospital ward
% ---------------------------------------------------------------------------

leaf(icu).
leaf(imc).
leaf(icu_imc).
leaf(er_normal_ward).
leaf(emergency_surgery).
leaf(er).
leaf(normal_ward).

% ---------------------------------------------------------------------------
% User-prompting infrastructure
% ---------------------------------------------------------------------------

% Cache answers given during a session so the same question is never asked twice.
:- dynamic user_answer/2.

reset_session :-
    retractall(user_answer(_, _)).

ask_yes_no(Prompt, Answer) :-
    format('~n  ~w~n  [yes/no]: ', [Prompt]),
    read_line_to_string(user_input, Raw),
    ( normalize_yn(Raw, Answer) ->
        true
    ;
        format('  Please enter yes or no.~n'),
        ask_yes_no(Prompt, Answer)
    ).

normalize_yn(S, yes) :- string_lower(S, L), member(L, ["yes","y"]).
normalize_yn(S, no)  :- string_lower(S, L), member(L, ["no","n"]).

% attr_or_ask(+Patient, +Key, +ExpectedValue, +Prompt)
%
% If Key is present in Patient: succeed iff its value equals ExpectedValue.
% If Key is absent: ask the user (or replay the cached answer); succeed iff yes.
attr_or_ask(Patient, Key, Expected, Prompt) :-
    ( memberchk(Key-_, Patient) ->
        memberchk(Key-Expected, Patient)
    ;
        ( user_answer(Key, Cached) ->
            Ans = Cached
        ;
            ask_yes_no(Prompt, Ans),
            assertz(user_answer(Key, Ans))
        ),
        Ans = yes
    ).

% ---------------------------------------------------------------------------
% Conditions  condition(PatientData, _)
%
% The second argument is the unused Beta slot kept by tree.pl's call/3.
% Each condition delegates to attr_or_ask/4 with its question text.
%
% Patient attribute keys and allowed values:
%   wishes               - icu_imc_wished | icu_imc_not_wished
%   intubated            - yes | no
%   inspiratory_stridor  - yes | no
%   abnormal_resp_rate   - yes | no   (rate <12 or >20 breaths/min)
%   niv_needed           - yes | no   (Non-Invasive Ventilation required)
%   patient_status       - b_problem_persists | stabilized_on_niv
%   pneumothorax         - yes | no   (pneumothorax or thoracic drainage)
%   external_bleeding    - yes | no   (active bleeding requiring surgery)
%   mottling             - yes | no
%   severe_bradycardia   - yes | no   (heart rate <45 bpm)
%   ecg_abnormalities    - yes | no
%   vasopressors_needed  - yes | no
%   vasopressors_dose    - high | low
%   telemetry_available  - yes | no
%   intracranial_hemorrhage - yes | no
%   gcs_below_10         - yes | no   (Glasgow Coma Scale <10)
%   stroke               - yes | no
%   outpatient_possible  - yes | no
% ---------------------------------------------------------------------------

wishes_icu_imc(P, _) :-
    attr_or_ask(P, wishes, icu_imc_wished,
        'Does the patient wish ICU/IMC level care?').

is_intubated(P, _) :-
    attr_or_ask(P, intubated, yes,
        'A - Airway | Is the patient intubated?').

has_inspiratory_stridor(P, _) :-
    attr_or_ask(P, inspiratory_stridor, yes,
        'A - Airway | Is there inspiratory stridor?').

has_abnormal_resp_rate(P, _) :-
    attr_or_ask(P, abnormal_resp_rate, yes,
        'B - Breathing | Is the respiratory rate abnormal (< 12 or > 20 breaths/min)?').

niv_needed(P, _) :-
    attr_or_ask(P, niv_needed, yes,
        'B - Breathing | Is Non-Invasive Ventilation (NIV) needed?').

b_problem_persists(P, _) :-
    attr_or_ask(P, patient_status, b_problem_persists,
        'B - Breathing | Does the B-problem persist (answer No if stabilized on NIV)?').

has_pneumothorax(P, _) :-
    attr_or_ask(P, pneumothorax, yes,
        'B - Breathing | Is there pneumothorax or thoracic drainage?').

has_external_bleeding(P, _) :-
    attr_or_ask(P, external_bleeding, yes,
        'C - Circulation | Is there external bleeding requiring surgery?').

has_mottling(P, _) :-
    attr_or_ask(P, mottling, yes,
        'C - Circulation | Is there mottling?').

has_severe_bradycardia(P, _) :-
    attr_or_ask(P, severe_bradycardia, yes,
        'C - Circulation | Is there severe bradycardia (heart rate < 45 bpm)?').

has_ecg_abnormalities(P, _) :-
    attr_or_ask(P, ecg_abnormalities, yes,
        'C - Circulation | Are there ECG abnormalities? [Yes -> cardiac catheterization]').

needs_vasopressors(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Post cardiac catheterization | Are vasopressors needed?').

vasopressors_high_dose(P, _) :-
    attr_or_ask(P, vasopressors_dose, high,
        'Post cardiac catheterization | Is the vasopressor dose HIGH (answer No for low dose)?').

telemetry_available(P, _) :-
    attr_or_ask(P, telemetry_available, yes,
        'Post cardiac catheterization | Is telemetry monitoring available?').

has_intracranial_hemorrhage(P, _) :-
    attr_or_ask(P, intracranial_hemorrhage, yes,
        'D - Disability | Is there intracranial hemorrhage?').

gcs_below_10(P, _) :-
    attr_or_ask(P, gcs_below_10, yes,
        'D - Disability | Is the Glasgow Coma Scale (GCS) score below 10?').

has_stroke(P, _) :-
    attr_or_ask(P, stroke, yes,
        'D - Disability | Is there a stroke?').

outpatient_treatment_possible(P, _) :-
    attr_or_ask(P, outpatient_possible, yes,
        'Final Ranking | Is outpatient treatment possible?').
