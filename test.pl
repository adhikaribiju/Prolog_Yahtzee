% Function to calculate indices of dice to keep
find_dices_to_keep_indices(DiceValues, DicesToKeep, DicesToKeepInd) :-
    find_dices_to_keep_indices_helper(DiceValues, DicesToKeep, [], DicesToKeepInd).

% Helper function with accumulator
find_dices_to_keep_indices_helper(_, [], Acc, Acc). % Base case: No more values to match
find_dices_to_keep_indices_helper(DiceValues, [Keep|Rest], Acc, DicesToKeepInd) :-
    nth1(Index, DiceValues, Keep), % Find the first index where the value matches
    \+ member(Index, Acc),         % Ensure the index is not already included
    find_dices_to_keep_indices_helper(DiceValues, Rest, [Index|Acc], DicesToKeepInd). % Recursively process the rest

% Test runner with display logic
run_tests :-
    writeln('Running Tests...'),
    test_case([1, 2, 3, 4, 5], [2, 4], 'Test 1'),
    test_case([1, 2, 2, 4, 5], [2, 2], 'Test 2'),
    test_case([3, 6, 3, 1, 5], [3, 5, 1], 'Test 3'),
    test_case([3, 6, 3, 1, 5], [7], 'Test 4'),
    test_case([3, 6, 3, 1, 5], [], 'Test 5'),
    test_case([3, 6, 3, 1, 5], [3, 6, 3, 1, 5], 'Test 6'),
    writeln('All tests completed.').

% Test case handler with display
test_case(DiceValues, DicesToKeep, TestName) :-
    format("~n~w:~n", [TestName]),
    format("Dice Values: ~w~n", [DiceValues]),
    format("Dices to Keep: ~w~n", [DicesToKeep]),
    (   find_dices_to_keep_indices(DiceValues, DicesToKeep, DicesToKeepInd)
    ->  format("Kept Dice Indices: ~w~n", [DicesToKeepInd]),
        writeln('Result: Passed')
    ;   writeln('Result: Failed')
    ).
    
% Automatically run tests on initialization
:- initialization(run_tests).
