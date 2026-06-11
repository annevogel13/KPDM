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
    