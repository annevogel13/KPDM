#!/usr/bin/env swipl
% Interactive triage session.
%
% Without arguments — asks the user for every attribute:
%   ./interactive.pl
%
% With a filled-in patient JSON file — uses known values, asks only for missing ones:
%   ./interactive.pl patient.json

:- use_module(library(http/json)).
:- consult('tree.pl').

outcome_label(icu,              'ICU  - Intensive Care Unit').
outcome_label(imc,              'IMC  - Intermediate Care (step-down)').
outcome_label(icu_imc,          'ICU or IMC  - requires further determination').
outcome_label(er_normal_ward,   'ER or Normal Ward  (patient declined ICU/IMC)').
outcome_label(emergency_surgery,'EMERGENCY SURGERY').
outcome_label(er,               'ER  - Emergency Room / outpatient follow-up').
outcome_label(normal_ward,      'Normal Ward').
outcome_label(imc_telemetry,    'Monitor on IMC to monitor after cardiac catheterization.').
outcome_label(imc_neuro,        'Monitor on IMC due to reduced GCS and or vasopressors needed.').
outcome_label(imc_C_prob,       'Monitor on IMC due to low dose vasopressors needed.').
outcome_label(icu_intubated,    'Intubate as GCS < 10 has high likelihood of lacking adverse-effects reflexes').
outcome_label(emergency_surgery_wish,      'Emergency surgery. Cave: Patient does not wish treatment on icu. Reevaluate patient wishes timely').
outcome_label(palliation,      'Patient has critical bleeding and does not consent to Intubation neccessary for surgery. Start palliation.').
outcome_label(reeval_treatment_term,      'Reevaluate treatment termination with next of kin. Patient does not wish invasive treatment on icu, critical external bleeding with requirement of immediate surgery with comorbid intracranial pathology with high probability of neurologic disability').
outcome_label(CT_surgery,       'Conduct emergency CT due to abnormal neurostatus before conducting Emergency surgery.').
% Read patient data from a JSON file. Keys with null values are omitted
% so that knowledge_base.pl will prompt for them interactively.
patient_from_args(Patient) :-
    current_prolog_flag(argv, [File|_]),
    exists_file(File),
    setup_call_cleanup(
        open(File, read, Stream),
        json_read(Stream, json(Pairs)),
        close(Stream)
    ),
    include(non_null_pair, Pairs, Filled),
    maplist(json_pair_to_patient, Filled, Patient),
    !.
patient_from_args([]).

non_null_pair(_Key = Value) :- Value \= @null.

json_pair_to_patient(Key = Value, Key-AtomValue) :-
    ( atom(Value) -> AtomValue = Value ; term_to_atom(Value, AtomValue) ).

:- initialization(main, main).

main :-
    patient_from_args(Patient),
    format('~n========================================~n'),
    format(' ABCD Triage Decision Support~n'),
    format('========================================~n'),
    ( Patient = [] ->
        format('Mode: fully interactive — answer each question below.~n')
    ;
        format('Pre-filled data: ~w~n', [Patient]),
        format('Missing attributes will be prompted.~n')
    ),
    reset_session,
    decision_tree(start, Patient, Result),
    outcome_label(Result, Label),
    format('~n----------------------------------------~n'),
    format(' Recommended care setting:~n  ~w~n', [Label]),
    format('----------------------------------------~n~n'),
    halt.
