#!/usr/bin/env swipl
% Interactive triage session.
%
% Without arguments — asks the user for every attribute:
%   ./interactive.pl
%

:- consult('tree.pl').

outcome_label(icu,              'ICU  - Intensive Care Unit').
outcome_label(imc,              'IMC  - Intermediate Care (step-down)').
outcome_label(icu_imc,          'ICU or IMC  - requires further determination').
outcome_label(er_normal_ward,   'ER or Normal Ward  (patient declined ICU/IMC)').
outcome_label(emergency_surgery,'EMERGENCY SURGERY').
outcome_label(er,               'ER  - Emergency Room / outpatient follow-up').
outcome_label(normal_ward,      'Normal Ward').

% Read patient data from a JSON file. Keys with null values are omitted
% so that knowledge_base.pl will prompt for them interactively.
patient_from_args(Patient) :-
    current_prolog_flag(argv, [DataArg|_]),
    DataArg \= [],
    catch(
        atom_to_term(DataArg, Term, _),
        _,
        fail
    ),
    Term = [_|_],
    Patient = Term,
    !.
patient_from_args([]).

non_null_pair(_Key = Value) :- Value \= @(null).

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
    