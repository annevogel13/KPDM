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

% A - Airway
node(start,                       is_intubated,                 breathing_lung_vent,          airway_stridor).
node(airway_stridor,               has_inspiratory_stridor,      airway_eval_itn,              breathing_abnormal_rate).
node(airway_eval_itn,              eval_itn,                     breathing_lung_vent,          breathing_abnormal_rate).

% A→B bridge: lung ventilation check after intubation / post-stridor eval
node(breathing_lung_vent,          lungs_vent_sym,               circulation_ext_bleeding,     breathing_pneumothorax).
node(breathing_lung_vent_Bprob,    lungs_vent_sym,               breathing_niv_needed,         breathing_pneumothorax_Bprob).

% B - Breathing
node(breathing_abnormal_rate,      has_abnormal_resp_rate,       breathing_lung_vent_Bprob,    breathing_lung_vent).
node(breathing_niv_needed,         niv_needed,                   b_reeval_status_niv,          reeval_B).
node(reeval_B,                     b_stabilized,                 circulation_ext_bleeding,     b_reeval_status_niv).
node(b_reeval_status_niv,          b_problem_persists,           icu,                          eval_C_NIV_B_ok).
node(breathing_pneumothorax,       has_pneumothorax,             circulation_ext_bleeding,     circulation_ext_bleeding).
node(breathing_pneumothorax_Bprob, has_pneumothorax,             resp_rate,                    circulation_ext_bleeding).
node(resp_rate,                    pers_abnormal_resp_rate,      breathing_niv_needed,         circulation_ext_bleeding).

% C - Circulation
%   eval_C_NIV_B_ok  - C entry after B stabilised on NIV (no neuro check before surgery)
%   d_before_surgery - neuro check before emergency surgery on standard bleeding path
node(eval_C_NIV_B_ok,              has_external_bleeding,        emergency_surgery,            circulation_mottling).
node(circulation_ext_bleeding,     has_external_bleeding,        d_before_surgery,             circulation_mottling).
node(d_before_surgery,             normal_neuro_stat,            emergency_surgery,            ct_surgery).

node(circulation_mottling,         has_mottling,                 reeval_c,                     circulation_arrythmia).
node(reeval_c,                     needs_vasopressors,           dose_vasopressors,            circulation_arrythmia).
node(dose_vasopressors,            vasopressors_high_dose,       vp_high_arrhythmia,           c_vp_low_arrhythmia).

% High-dose VP path: arrhythmia sub-evaluation within VP context
node(vp_high_arrhythmia,          has_arrhythmia,               c_brady_hem_rel,              circulation_ecg).
node(c_brady_hem_rel,             has_severe_bradycardia,       c_ecg_vp_high,                c_tachy_hem_rel).
node(c_tachy_hem_rel,             has_tachycardia,              c_ecg_vp_high,                c_other_arr_hem_rel).
node(c_other_arr_hem_rel,         cardioversion_poss,           c_cardioversion,              c_ecg_vp_high).

% Low-dose VP path
node(c_vp_low_arrhythmia,         has_arrhythmia,               circulation_arrythmia,        imc_c_prob).

% Arrhythmia tree (reached from: no mottling, no VP needed, or low-dose VP + arrhythmia)
node(circulation_arrythmia,       has_arrhythmia,               c_bradyarrythmia,             circulation_ecg).
node(c_bradyarrythmia,            has_severe_bradycardia,       brady_hem_rel,                c_tachyarrythmia).
node(brady_hem_rel,               bradycardia_rel,              c_ecg_vp_high,                monitor_brady).
node(monitor_brady,               has_ecg_abnormalities,        c_ecg_vp_high,                disability_gcs).
node(c_tachyarrythmia,            has_tachycardia,              tachy_hem_rel,                c_other_arrythmia).
node(c_other_arrythmia,           arrhythmia_rel,               c_cardioversion,              monitor_tachy).
node(tachy_hem_rel,               tachycardia_rel,              c_cardioversion,              monitor_tachy).
node(monitor_tachy,               has_ecg_abnormalities,        circulation_ecg,              disability_gcs).
node(c_cardioversion,             c_after_cardioversion,        circulation_ecg,              c_ecg_vp_high).

% ECG / cardiac catheterization entry points
node(circulation_ecg,             has_ecg_abnormalities,        cardiac_cath_vasopressors,    disability_gcs).
node(c_ecg_vp_high,               has_ecg_abnormalities,        cardiac_cath_vasopressors,    d_gcs_high_vp).

% Post cardiac catheterization
node(cardiac_cath_vasopressors,   cath_needs_vasopressors,      cardiac_cath_dose,            cardiac_cath_telemetry).
node(cardiac_cath_dose,           vasopressors_high_dose,       d_gcs_high_vp,                d_gcs_low_vp).
node(cardiac_cath_telemetry,      telemetry_available,          disability_gcs,               d_gcs_no_tel).

% D - Disability
%   Standard GCS-based path
node(disability_gcs,              gcs_below_13,                 disability_intracranial,      disability_stroke).
node(disability_intracranial,     has_intracranial_hemorrhage,  emergency_surgery,            gcs_below_10).
node(gcs_below_10,                gcs_below_10,                 icu_intubated,                imc_neuro).

%   High-VP D context (reached from c_ecg_vp_high or post-cath high-dose VP)
node(d_gcs_high_vp,               gcs_below_13,                 d_intracranial_high_vp,       d_stroke_high_vp).
node(d_intracranial_high_vp,      has_intracranial_hemorrhage,  emergency_surgery,            gcs_below_10_vp).
node(gcs_below_10_vp,             gcs_below_10,                 icu,                          icu_intubated).
node(d_stroke_high_vp,            has_stroke,                   imc,                          icu).

%   Low-VP D context (reached from post-cath low-dose VP)
node(d_gcs_low_vp,                gcs_below_13,                 disability_intracranial,      d_stroke_low_vp).
node(d_stroke_low_vp,             has_stroke,                   imc,                          imc_c_prob).

%   No-telemetry D context (reached from post-cath, no telemetry)
node(d_gcs_no_tel,                gcs_below_13,                 disability_intracranial,      disability_stroke).

node(disability_stroke,           has_stroke,                   imc,                          final_ranking_outpatient).
node(final_ranking_outpatient,    outpatient_treatment_possible, er,                          normal_ward).

% ---------------------------------------------------------------------------
% Outcome leaves
%   icu            - Intensive Care Unit
%   imc            - Intermediate Care (IMC / step-down)
%   imc_neuro      - IMC monitoring due to reduced GCS (and/or vasopressors)
%   imc_c_prob     - IMC monitoring due to low-dose vasopressors
%   icu_intubated  - Intubate: GCS < 10, high probability of absent protective reflexes
%   icu_imc        - ICU or IMC; requires further determination
%   emergency_surgery - immediate surgery required
%   ct_surgery     - emergency CT required before surgery (abnormal neuro + bleeding)
%   er             - Emergency Room / outpatient follow-up
%   normal_ward    - standard hospital ward
% ---------------------------------------------------------------------------

leaf(icu).
leaf(imc).
leaf(imc_neuro).
leaf(imc_c_prob).
leaf(icu_intubated).
leaf(emergency_surgery).
leaf(ct_surgery).
leaf(er).
leaf(normal_ward).

% ---------------------------------------------------------------------------
% Outcome labels (used by interactive.pl for display)
% ---------------------------------------------------------------------------

outcome_label(icu,              'ICU — Intensive Care Unit').
outcome_label(imc,              'IMC — Intermediate Care').
outcome_label(imc_neuro,        'IMC — Intermediate Care (Neurology)').
outcome_label(imc_c_prob,       'IMC — Intermediate Care (Cardiac monitoring)').
outcome_label(icu_intubated,    'ICU — Intubation required').
outcome_label(emergency_surgery,'Emergency Surgery').
outcome_label(ct_surgery,       'CT Scan + Surgery planning').
outcome_label(er,               'Emergency Room / Outpatient').
outcome_label(normal_ward,      'Normal Ward').

% ---------------------------------------------------------------------------
% User-prompting infrastructure
% ---------------------------------------------------------------------------

:- dynamic user_answer/2.

reset_session :-
    retractall(user_answer(_, _)).

ask_yes_no(Prompt, Answer) :-
    format('~n  ~w~n  [yes/no]: ', [Prompt]),
    ( read_line_to_string(user_input, Raw), Raw \= end_of_file ->
        ( normalize_yn(Raw, Answer) ->
            true
        ;
            format('  Please enter yes or no.~n'),
            ask_yes_no(Prompt, Answer)
        )
    ;
        format('~n[EOF] No input received. Exiting.~n'),
        halt(1)
    ).

normalize_yn(S, yes) :- string_lower(S, L), member(L, ["yes","y"]).
normalize_yn(S, no)  :- string_lower(S, L), member(L, ["no","n"]).

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
% Patient attribute keys and allowed values:
%   intubated                         - yes | no
%   inspiratory_stridor               - yes | no
%   lungs_vent_sym                    - yes | no
%   abnormal_resp_rate                - yes | no   (<12 or >20 breaths/min)
%   niv_needed                        - yes | no
%   b_stabilized                      - yes | no   (stable on O2/inhalative, no NIV)
%   patient_status                    - b_problem_persists | stabilized_on_niv
%   pneumothorax                      - yes | no
%   pers_abnormal_resp_rate           - yes | no   (persists after pneumothorax Rx)
%   external_bleeding                 - yes | no
%   neuro_normal                      - yes | no   (normal GCS/pupils/no stroke signs)
%   mottling                          - yes | no
%   vasopressors_needed               - yes | no
%   vasopressors_dose                 - high | low
%   arrhythmia                        - yes | no
%   severe_bradycardia                - yes | no   (<45 bpm)
%   tachycardia                       - yes | no   (>150 bpm)
%   bradycardia_hemodynamically_relevant  - yes | no
%   tachycardia_hemodynamically_relevant  - yes | no
%   arrhythmia_hemodynamically_relevant   - yes | no
%   cardioversion_possible            - yes | no
%   cardioversion_stable              - yes | no
%   ecg_abnormalities                 - yes | no
%   telemetry_available               - yes | no
%   intracranial_hemorrhage           - yes | no
%   gcs_below_13                      - yes | no   (Glasgow Coma Scale < 13)
%   gcs_below_10                      - yes | no   (Glasgow Coma Scale < 10)
%   stroke                            - yes | no
%   outpatient_possible               - yes | no
% ---------------------------------------------------------------------------

is_intubated(P, _) :-
    attr_or_ask(P, intubated, yes,
        'A - Airway | Is the patient intubated?').

has_inspiratory_stridor(P, _) :-
    attr_or_ask(P, inspiratory_stridor, yes,
        'A - Airway | Is there inspiratory stridor?').

eval_itn(P, _) :-
    attr_or_ask(P, inspiratory_stridor, yes,
        'A - Airway | High probability of airway collapse. May try inhalative Adrenalin first. Was the patient intubated?').

lungs_vent_sym(P, _) :-
    attr_or_ask(P, lungs_vent_sym, yes,
        'B - Breathing | Are both lungs ventilated symmetrically on auscultation?').

has_abnormal_resp_rate(P, _) :-
    attr_or_ask(P, abnormal_resp_rate, yes,
        'B - Breathing | Is the respiratory rate abnormal (< 12 or > 20 breaths/min)?').

niv_needed(P, _) :-
    attr_or_ask(P, niv_needed, yes,
        'B - Breathing | Consider NIV. Is Non-Invasive Ventilation (NIV) needed?').

b_stabilized(P, _) :-
    attr_or_ask(P, b_stabilized, yes,
        'B - Breathing | Does the patient stabilise on oxygen and inhalative medication (without NIV)?').

b_problem_persists(P, _) :-
    attr_or_ask(P, patient_status, b_problem_persists,
        'B - Breathing | Does the B-problem persist despite NIV (answer No if stabilised on NIV)?').

has_pneumothorax(P, _) :-
    attr_or_ask(P, pneumothorax, yes,
        'B - Breathing | Asymmetric auscultation is highly indicative of pneumothorax. Confirm sonographically and evaluate thoracic drainage. Is there pneumothorax or thoracic drainage?').

pers_abnormal_resp_rate(P, _) :-
    attr_or_ask(P, pers_abnormal_resp_rate, yes,
        'B - Breathing | Does the abnormal respiratory rate persist after treatment of pneumothorax?').

has_external_bleeding(P, _) :-
    attr_or_ask(P, external_bleeding, yes,
        'C - Circulation | Is there external bleeding requiring surgery?').

normal_neuro_stat(P, _) :-
    attr_or_ask(P, neuro_normal, yes,
        'D - Disability | Is the neurostatus normal? (No GCS < 13, no abnormal pupils, no stroke signs)').

has_mottling(P, _) :-
    attr_or_ask(P, mottling, yes,
        'C - Circulation | Is there mottling?').

needs_vasopressors(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'C - Circulation | Are vasopressors needed to treat the circulatory dysfunction?').

vasopressors_high_dose(P, _) :-
    attr_or_ask(P, vasopressors_dose, high,
        'C - Circulation | Is the vasopressor dose HIGH (> 10 mcg/min noradrenalin or any adrenalin) (answer No for low dose)?').

has_arrhythmia(P, _) :-
    attr_or_ask(P, arrhythmia, yes,
        'C - Circulation | Is there arrhythmia — severe bradycardia (< 45 bpm) or tachycardia (> 150 bpm)?').

has_severe_bradycardia(P, _) :-
    attr_or_ask(P, severe_bradycardia, yes,
        'C - Circulation | Is there severe bradycardia (heart rate < 45 bpm)?').

has_tachycardia(P, _) :-
    attr_or_ask(P, tachycardia, yes,
        'C - Circulation | Is there tachycardia (heart rate > 150 bpm)?').

bradycardia_rel(P, _) :-
    attr_or_ask(P, bradycardia_hemodynamically_relevant, yes,
        'C - Circulation | Is the bradycardia hemodynamically relevant?').

tachycardia_rel(P, _) :-
    attr_or_ask(P, tachycardia_hemodynamically_relevant, yes,
        'C - Circulation | Is the tachycardia hemodynamically relevant?').

arrhythmia_rel(P, _) :-
    attr_or_ask(P, arrhythmia_hemodynamically_relevant, yes,
        'C - Circulation | Is the arrhythmia hemodynamically relevant?').

cardioversion_poss(P, _) :-
    attr_or_ask(P, cardioversion_possible, yes,
        'C - Circulation | Is cardioversion possible?').

c_after_cardioversion(P, _) :-
    attr_or_ask(P, cardioversion_stable, yes,
        'C - Circulation | Is the patient stable after cardioversion?').

has_ecg_abnormalities(P, _) :-
    attr_or_ask(P, ecg_abnormalities, yes,
        'C - Circulation | Are there ECG abnormalities? [Yes -> cardiac catheterization]').

cath_needs_vasopressors(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Post cardiac catheterization | Are vasopressors needed after cardiac catheterization?').

telemetry_available(P, _) :-
    attr_or_ask(P, telemetry_available, yes,
        'Post cardiac catheterization | Is telemetry monitoring available?').

has_intracranial_hemorrhage(P, _) :-
    attr_or_ask(P, intracranial_hemorrhage, yes,
        'D - Disability | Conduct emergency cerebral CT (GCS abnormal). Is there intracranial hemorrhage?').

gcs_below_13(P, _) :-
    attr_or_ask(P, gcs_below_13, yes,
        'D - Disability | Is the Glasgow Coma Scale (GCS) score below 13?').

gcs_below_10(P, _) :-
    attr_or_ask(P, gcs_below_10, yes,
        'D - Disability | Is the Glasgow Coma Scale (GCS) score below 10?').

has_stroke(P, _) :-
    attr_or_ask(P, stroke, yes,
        'D - Disability | Is there a stroke?').

outpatient_treatment_possible(P, _) :-
    attr_or_ask(P, outpatient_possible, yes,
        'Final Ranking | Is outpatient treatment possible?').
