% Load facts (nodes and leaves) from separate knowledge base file.
:- consult('knowledge_base.pl').

% if we are in a leaf 
decision_tree(Node, _, Node) :-
	leaf(Node).

% If condition succeeds, go to TrueBranch.
decision_tree(Node, PatientData, Result) :-
	node(Node, Condition, TrueBranch, _),
	call(Condition, PatientData, _),
	decision_tree(TrueBranch, PatientData, Result).

% If condition fails (negation-as-failure), go to FalseBranch.
decision_tree(Node, PatientData, Result) :-
	node(Node, Condition, _, FalseBranch),
	\+ call(Condition, PatientData, _),
	decision_tree(FalseBranch, PatientData, Result).