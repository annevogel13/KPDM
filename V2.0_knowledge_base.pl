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
node(start,                     wishes_icu_imc,               airway_intubated,          airway_intubated_wish).

% A - Airway
node(airway_intubated_wish,     is_intubated,                 ITN_wish_B,              airway_stridor_wish).
node(airway_intubated,          is_intubated,                 breathing_lung_vent,       airway_stridor).
node(airway_stridor,            has_inspiratory_stridor,      airway_eval_itn,           breathing_abnormal_rate).
node(airway_stridor_wish,       has_inspiratory_stridor,      airway_eval_itn_wish,      breathing_abnormal_rate).
node(airway_eval_itn,           eval_itn,                     breathing_lung_vent,       breathing_abnormal_rate).
node(airway_eval_itn_wish,      eval_itn_wish,                breathing_lung_vent,       breathing_abnormal_rate_wish).

% B - Breathing
node(breathing_abnormal_rate,   has_abnormal_resp_rate,       breathing_lung_vent_Bprob, breathing_lung_vent).
node(breathing_abnormal_rate_wish,has_abnormal_resp_rate,     breathing_niv_needed_wish, breathing_pneumothorax).
node(breathing_niv_needed,      niv_needed,                   B_reeval_status_niv,       reeval_B).
node(breathing_niv_needed_wish, niv_needed_wish,              B_reeval_status_niv,       reeval_B_wish).
node(reeval_B,                  B_stabilized,                 circulation_ext_bleeding,  breathing_niv_needed).
node(reeval_B_wish,             B_stabilized,                 eval_C_wish,               eval_C_wish).
node(B_reeval_status_niv,       b_problem_persists,           eval_C_NIV_Bprob,          eval_C_NIV_B_ok).
node(breathing_pneumothorax,    has_pneumothorax,             eval_C_thxdr,              circulation_ext_bleeding).
node(breathing_pneumothorax_Bprob,has_pneumothorax,           resp_rate,                 circulation_ext_bleeding).
node(resp_rate,                 pers_abnormal_resp_rate,      breathing_niv_needed,      circulation_ext_bleeding).
node(ITN_wish_B,                lungs_vent_sym,               ITN_wish_C,                breathing_pneumothorax).
node(breathing_lung_vent,       lungs_vent_sym,               circulation_ext_bleeding,  breathing_pneumothorax).
node(breathing_lung_vent_Bprob, lungs_vent_sym,               breathing_niv_needed,      breathing_pneumothorax_Bprob).

% C - Circulation
node(eval_C_wish,               has_external_bleeding,        eval_ITN_wish,             circulation_mottling).
node(eval_ITN_wish,             wish_ITN_for_bleed,           emergency_surgery,         palliation).
node(eval_C_NIV_B_ok,           has_external_bleeding,        emergency_surgery,         circulation_mottling).
node(ITN_wish_C,                has_external_bleeding,        critical_Bleed_reeval_Icu, circulation_mottling).
node(circulation_ext_bleeding,  has_external_bleeding,        D_before_surgery,          circulation_mottling).
node(circulation_mottling,      has_mottling,                 reeval_C,                  circulation_arrythmia).
node(reeval_C,                  needs_vasopressors,           dose_vasopressors,         circulation_arrythmia).
node(dose_vasopressors,         vasopressors_high_dose,       VP_high_arrhythmia,        C_VP_low_arrythmia).
node(VP_high_arrhythmia,        has_arrythmia                 C_brady_hem_rel,           circulation_ecg).
node(C_brady_hem_rel,           has_severe_bradycardia        C_ecg_VP_high,             C_tachy_hem_rel).
node(C_tachy_hem_rel,           has_tachycardia               C_ecg_VP_high,             C_other_Arr_hem_rel).
node(circulation_arrythmia,     has_arrythmia                 C_bradyarrythmia,          circulation_ecg).
node(C_bradyarrythmia,          has_severe_bradycardia        brady_hem_rel,             C_tachyarrythmia).
node(brady_hem_rel,             bradycardia_rel               C_ecg_VP_high,             monitor_brady).
node(C_other_Arr_hem_rel,       Cardioversion_poss            C_cardioversion,           C_ecg_VP_high).
node(monitor_brady,             has_ecg_abnormalities,        C_ecg_VP_high,             disability_gcs_min_imc).
node(C_tachyarrythmia,          has_tachycardia               tachy_hem_rel,             C_other_arrythmia).
node(C_other_arrythmia,         arrythmia_rel                 C_cardioversion,           C_other_arrythmia).
node(tachy_hem_rel,             tachycardia_rel               C_cardioversion,           monitor_tachy).
node(monitor_tachy,             has_ecg_abnormalities,        circulation_ecg,           disability_gcs).
node(C_cardioversion,           C_after_Cardioversion         circulation_ecg,           C_ecg_VP_high).
node(circulation_ecg,           has_ecg_abnormalities,        cardiac_cath_vasopressors, disability_gcs).
node(C_ecg_VP_high,             has_ecg_abnormalities,        cardiac_cath_vasopressors, D_gcs_high_VP).

% Post cardiac catheterization (reached when ECG abnormalities are present)
node(cardiac_cath_vasopressors, cath_needs_vasopressors,      cardiac_cath_dose,         cardiac_cath_telemetry).
node(cardiac_cath_dose,         vasopressors_high_dose,       D_gcs_VP_high,             D_gcs_low_VP).
node(cardiac_cath_telemetry,    telemetry_available,          disability_gcs,            D_gcs_no_tel).

% D - Disability
node(critical_Bleed_reeval_Icu, pupils_abnormal,              reeval_treatment_term,     emergency_surgery_wish).
node(D_before_surgery,          normal_neuro_stat,            emergency_surgery,         CT_surgery).
node(disability_intracranial,   has_intracranial_hemorrhage,  emergency_surgery,         gcs_below_10).
node(D_intracranial_high_VP,    has_intracranial_hemorrhage,  emergency_surgery,         gcs_below_10_VP).
node(gcs_below_10,              gcs_below_10,                 imc_neuro,                 icu_intubated).
node(gcs_below_10_VP,           gcs_below_10,                 icu,                       icu_intubated).
node(disability_gcs,            gcs_below_13,                 disability_intracranial,   disability_stroke).
node(D_gcs_high_VP,             gcs_below_13,                 D_intracranial_high_VP,    D_stroke_high_VP).
node(D_gcs_low_VP,              gcs_below_13,                 disability_intracranial,   D_stroke_low_VP).
node(D_gcs_no_tel,              gcs_below_13,                 disability_intracranial,   disability_stroke).
node(disability_stroke,         has_stroke,                   imc,                       final_ranking_outpatient).
node(D_stroke_low_VP,           has_stroke,                   imc,                       imc_C_prob).
node(D_stroke_no_tel,           has_stroke,                   imc,                       imc_telemetry).
node(final_ranking_outpatient,  outpatient_treatment_possible,er,                        normal_ward).

% ---------------------------------------------------------------------------
% Outcome leaves
%   icu            - Intensive Care Unit
%   imc            - Intermediate Care (IMC / step-down)
%   reeval_icu     - Reevaluate Treatment on ICU in regards to patient wishes
%   icu_imc        - ICU or IMC; requires further determination
%   er_normal_ward - ER or Normal Ward (patient declined ICU/IMC level care)
%   emergency_surgery - immediate surgery required
%   er             - Emergency Room / outpatient follow-up
%   normal_ward    - standard hospital ward
% ---------------------------------------------------------------------------

leaf(icu).
leaf(imc).
leaf(imc_telemetry)
# outcome_label(imc_telemetry,      'Monitor on IMC to monitor after cardiac catheterization.').
leaf(imc_neuro).
# outcome_label(imc_neuro,      'Monitor on IMC due to reduced GCS and or vasopressors needed.').
leaf(imc_C_prob).
# outcome_label(imc_C_prob,      'Monitor on IMC due to low dose vasopressors needed.').
leaf(icu_intubated).
# outcome_label(icu_intubated,      'Intubate as GCS < 10 has high likelihood of lacking adverse-effects reflexes').
leaf(reeval_icu).
leaf(icu_imc).
leaf(er_normal_ward).
leaf(emergency_surgery).
leaf(emergency_surgery_wish).
# outcome_label(emergency_surgery_wish,      'Emergency surgery. Cave: Patient does not wish treatment on icu. Reevaluate patient wishes timely').
leaf(er).
leaf(normal_ward).
leaf(palliation).
# outcome_label(palliation,      'Patient has critical bleeding and does not consent to Intubation neccessary for surgery. Start palliation.').
leaf(reeval_treatment_term).
# outcome_label(reeval_treatment_term,      'Reevaluate treatment termination with next of kin. Patient does not wish invasive treatment on icu, critical external bleeding with requirement of immediate surgery with comorbid intracranial pathology with high probability of neurologic disability').
leaf(CT_surgery).
# outcome_label(CT_surgery,      'Conduct emergency CT due to abnormal neurostatus before conducting Emergency surgery.').

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
%   lungs_vent_sym       - yes | no   (no : reeval thoracic drainage (pneumothorax))
%   external_bleeding    - yes | no   (active bleeding requiring surgery)
%   mottling             - yes | no
%   severe_bradycardia   - yes | no   (heart rate <45 bpm)
%   arrythmia - yes/no
%   ecg_abnormalities    - yes | no
%   vasopressors_needed  - yes | no
%   vasopressors_dose    - high | low
%   telemetry_available  - yes | no
%   intracranial_hemorrhage - yes | no
%   gcs_below_13         - yes | no   (Glasgow Coma Scale <13)
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
        
eval_itn(P, _) :-
    attr_or_ask(P, inspiratory_stridor, yes,
        'A - Airway | Evaluate Intubation in patient with  high probability of airway collaps. May try inhalative Adrenalin first. Is the patient intubated?').

eval_itn_wish(P, _) :-
    attr_or_ask(P, inspiratory_stridor, yes,
        'A - Airway | Evaluate Intubation in patient with  high probability of airway collaps and no treatment wished on icu. May try inhalative Adrenalin first. If decision to intubation is made, patient wishes are changed to wishes_icu: yes. Is the patient intubated?').

has_abnormal_resp_rate(P, _) :-
    attr_or_ask(P, abnormal_resp_rate, yes,
        'B - Breathing | Is the respiratory rate abnormal (< 12 or > 20 breaths/min)?').

niv_needed(P, _) :-
    attr_or_ask(P, niv_needed, yes,
        'B - Breathing | Consider NIV. Is Non-Invasive Ventilation (NIV) needed?').

niv_needed_wish(P, _) :-
    attr_or_ask(P, niv_needed, yes,
        'B - Breathing | Consider NIV. Cave: Patient does not wish treatment on icu/imc. Reevaluate patient wishes or limit treatment options. Is Non-Invasive Ventilation (NIV) needed? In case of yes: patient wishes treatment on icu is considered yes. In case of no: treatment limitation with palliation is considered.').

B_stabilized(P, _) :-
    attr_or_ask(P, niv_needed, yes,
        'B - Breathing | Does the patient stabilize unter treatment with oxygen and (inhalative) medication?').

b_problem_persists(P, _) :-
    attr_or_ask(P, patient_status, b_problem_persists,
        'B - Breathing | Does the B-problem persist (answer No if stabilized on NIV)?').

lungs_vent_sym(P, _) :-
    attr_or_ask(P, lungs_vent_sym, yes,
        'B - Breathing |  Are both Lungs ventilated symmetrically in auscultation?').

has_pneumothorax(P, _) :-
    attr_or_ask(P, pneumothorax, yes,
        ' B -  Breathing | Asymmetrical ventilation of lungs is highly indicative of Pneumothorax. Confirm/Exclude sonographically and evaluate thoracic drainage. Is there there pneumothorax or thoracic drainage?').

pers_abnormal_resp_rate(P, _) :-
    attr_or_ask(P, pneumothorax, yes,
        ' B -  Breathing | Does the abnormal respiratory rate persist after treatment of Pneumothorax?').

has_external_bleeding(P, _) :-
    attr_or_ask(P, external_bleeding, yes,
        'C - Circulation | Is there external bleeding requiring surgery?').

wish_ITN_for_Bleed(P, _) :-
    attr_or_ask(P, external_bleeding, yes,
        'C - Circulation | The patient has critical bleeding neccessitating surgery and intubation. Reevaluate patient wishes with patient or next of kin. Is Intubation and emergency surgery wished? If yes: patient wishes for treatment on icu is considered yes. If no: Palliation is recommended.').

has_mottling(P, _) :-
    attr_or_ask(P, mottling, yes,
        'C - Circulation | Is there mottling?').

has_arrhythmia(P, _) :-
    attr_or_ask(P, arrythmia, yes,
        'C - Circulation | Is there arrythmia ie severe bradycardia (heart rate < 45 bpm) or tachycardia (heart rate >150bpm) ?').

has_severe_bradycardia(P, _) :-
    attr_or_ask(P, severe_bradycardia, yes,
        'C - Circulation | Is severe bradycardia (heart rate < 45 bpm) present?').

has_ecg_abnormalities(P, _) :-
    attr_or_ask(P, ecg_abnormalities, yes,
        'C - Circulation | Are there ECG abnormalities? [If Yes -> cardiac catheterization]').

needs_vasopressors(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Circulation | Are vasopressors needed to treat the circulatory dysfunction?').

Cardioversion_poss(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Circulation | Is Cardioversion possible?').

C_after_Cardioversion(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Circulation | Is the patient stable after cardioversion?').

cath_needs_vasopressors(P, _) :-
    attr_or_ask(P, vasopressors_needed, yes,
        'Post cardiac catheterization | Are vasopressors needed after cardiac catheterization?').

vasopressors_high_dose(P, _) :-
    attr_or_ask(P, vasopressors_dose, high,
        'Post cardiac catheterization | Is the vasopressor dose HIGH (>10mcg/min Noradrenalin or any Dose of Adrenalin) (answer No for low dose)?').

bradycardia_rel(P, _) :-
    attr_or_ask(P, bradycardia hemodynamically relevant, yes,
        'Circulation | Is the bradycardia hemodynamically relevant?').

tachycardia_rel(P, _) :-
    attr_or_ask(P, tachycardia hemodynamically relevant, yes,
        'Circulation | Is the tachycardia hemodynamically relevant?').

telemetry_available(P, _) :-
    attr_or_ask(P, telemetry_available, yes,
        'Post cardiac catheterization | Is telemetry monitoring available?').

pupils_abnormal(P, _) :-
    attr_or_ask(P, intracranial_hemorrhage, yes,
        'D - Disability | Are the pupils indicative for a brain pathology ie non-reactive pupils reactive or not equally dialated?').

has_intracranial_hemorrhage(P, _) :-
    attr_or_ask(P, intracranial_hemorrhage, yes,
        'D - Disability | Conduct emergency CT of the cerebrum as gcs is abnormal. Is there intracranial hemorrhage?').

gcs_below_13(P, _) :-
    attr_or_ask(P, gcs_below_13, yes,
        'D - Disability | Is the Glasgow Coma Scale (GCS) score below 13?').

has_stroke(P, _) :-
    attr_or_ask(P, stroke, yes,
        'D - Disability | Is there a new asymmetric movement of limbs or a new fascialis paresis or aphasia indicative of stroke?').

normal_neuro_stat(P, _) :-
    attr_or_ask(P, stroke, yes,
        'D - Disability | Does the patient have GCS < 13 or abnormal pupils or indications for stroke (new asymmetric movement of limbs or a new fascialis paresis or aphasia) ?').

outpatient_treatment_possible(P, _) :-
    attr_or_ask(P, outpatient_possible, yes,
        'Final Ranking | Is outpatient treatment possible?').
