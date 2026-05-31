% Knowledge base: nodes and leaf facts for the decision tree

%node(Node, Condition, TrueBranch, FalseBranch).
node('A', condition_a, 'B', 'C').
node('C', condition_c, 'D', 'E').

leaf('B').
leaf('D').
leaf('E').
