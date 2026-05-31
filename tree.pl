% Semicolon-free corrected decision tree implementation

% Load facts (nodes and leaves) from separate knowledge base file.
:- consult('knowledge_base.pl').

% Conditions used by the decision nodes.

condition_a(Alfa, _) :-
	Alfa > 99.

condition_c(_, Beta) :-
	Beta < 50.

% if we are in a leaf 
decision_tree(Node, _, _, Node) :-
	leaf(Node).

% If condition succeeds, go to TrueBranch.
decision_tree(Node, Alfa, Beta, Result) :-
	node(Node, Condition, TrueBranch, _),
	call(Condition, Alfa, Beta),
	decision_tree(TrueBranch, Alfa, Beta, Result).

% If condition fails (negation-as-failure), go to FalseBranch.
decision_tree(Node, Alfa, Beta, Result) :-
	node(Node, Condition, _, FalseBranch),
	\+ call(Condition, Alfa, Beta),
	decision_tree(FalseBranch, Alfa, Beta, Result).
