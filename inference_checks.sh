#!/bin/sh

# Simple test runner for tree.pl decision-tree queries
# Usage: ./inference_checks.sh

run() {
  echo "== $1 =="
  swipl -q -s tree.pl -g "$2" 2>&1 || true
  echo
}

run "A true -> expect 'B'" "decision_tree('A',120,30,R), writeln(R), halt."
run "A false -> C true -> expect 'D'" "decision_tree('A',10,30,R), writeln(R), halt."
run "A false -> C false -> expect 'E'" "decision_tree('A',10,70,R), writeln(R), halt."
run "Start at leaf B -> expect 'B'" "decision_tree('B',0,0,R), writeln(R), halt."
run "Ungrounded input X -> expect runtime error or warning" "decision_tree('A',X,30,R), writeln(R), halt."
run "Missing node Z -> expect no result (failure)" "decision_tree('Z',120,30,R), writeln(R), halt."
