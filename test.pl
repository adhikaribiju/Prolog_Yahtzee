% save_to_file(+Scorecard, +RoundNo)
% Saves the Scorecard and RoundNo to a user-specified file in the required format.
save_to_file(Scorecard, RoundNo) :-
    write("Enter the name of the file (with .txt extension): "),
    read_line_to_string(user_input, FileName), % Get the file name from the user
    convert_scorecard(Scorecard, ProcessedValues), % Process the scorecard into the required format
    Data = [RoundNo, ProcessedValues], % Combine RoundNo and ProcessedValues
    open(FileName, write, Stream), % Open the file for writing
    write(Stream, Data), % Write the data to the file
    write(Stream, '.'), % Add a period at the end
    close(Stream), % Close the file
    format("Scorecard saved to ~w successfully.~n", [FileName]).

% convert_scorecard(+Scorecard, -ProcessedValues)
% Converts the Scorecard into the required format for writing to a file.
convert_scorecard([], []).
convert_scorecard([[_, 0, _, _]|Rest], [[0]|ProcessedRest]) :-
    % If Score is 0, write [0].
    convert_scorecard(Rest, ProcessedRest).
convert_scorecard([[_, Score, 1, Round]|Rest], [[Score, human, Round]|ProcessedRest]) :-
    % If PlayerID is 1, map to 'human'.
    convert_scorecard(Rest, ProcessedRest).
convert_scorecard([[_, Score, 2, Round]|Rest], [[Score, computer, Round]|ProcessedRest]) :-
    % If PlayerID is 2, map to 'computer'.
    convert_scorecard(Rest, ProcessedRest).

main:-
Scorecard = [
       ["Ones", 1, 1, 1],
       ["Twos", 0, 0, 0],
       ["Threes", 9, 2, 2],
       ["Fours", 16, 1, 2],
       ["Fives", 15, 2, 4],
       ["Sixes", 12, 1, 4],
       ["Three of a Kind", 15, 1, 3],
       ["Four of a Kind", 7, 2, 3],
       ["Full House", 0, 0, 0],
       ["Four Straight", 0, 0, 0],
       ["Five Straight", 0, 0, 0],
       ["Yahtzee", 50, 1, 5]
   ],
   RoundNo = 6,
   save_to_file(Scorecard, RoundNo).



   % Things to implement:
    keptIndicesChecker(keptDicesInd indicesToKeep)
    indicesToReroll 
    doReRoll dice indicesToReroll

giveFourOfaKindIndices
giveThreeOfaKindIndices
giveTwoOfaKindIndices


% *********************************************************************
% Function Name: keptIndicesChecker
% Purpose: To check if the kept indices are valid.
% Parameters: list1 (list) - The list of kept indices.
%             list2 (list) - The list of all indices.
% Return Value: True if all kept indices are valid, else false.
% Algorithm:
% 1. Check if the list1 is empty.
% 2. If list1 is empty, return true (no common elements found).
% 3. Check if the first element of list1 is in list2.
% 4. If an element of list1 is in list2, return false.
% 5. Recur with the rest of list1.
% Reference: none
% *********************************************************************

% Base case: If the first list (list1) is empty, it is valid, so return true.
kept_indices_checker([], _).
% Recursive case: If the first element of list1 is found in list2, the indices are invalid, return false (fail).
kept_indices_checker([H | T], List2) :-
    \+ member(H, List2),  % Check that H is not a member of List2.
    kept_indices_checker(T, List2).  % Recur with the rest of list1.


% *********************************************************************
% Function Name: custom_remove
% Purpose: To remove specific elements from a list.
% Parameters: lst (list) - The list to remove elements from.
%             items_to_remove (list) - The list of elements to remove.
% Return Value: A list with the specified elements removed.
% Algorithm:
% 1. Check if the list is empty.
% 2. If the list is empty, return an empty list.
% 3. Check if the first element is in the items_to_remove list.
% 4. If the element is in the items_to_remove list, skip it and continue with the rest of the list.
% 5. If the element is not in the items_to_remove list, keep it and continue with the rest of the list.
% Reference: none
% *********************************************************************
% custom_remove/3: Removes specified elements from a list.
custom_remove([], _, []) :- !.
custom_remove([H | T], ItemsToRemove, NewList) :-
    member(H, ItemsToRemove),
    !,
    custom_remove(T, ItemsToRemove, NewList).
custom_remove([H | T], ItemsToRemove, [H | NewList]) :-
    custom_remove(T, ItemsToRemove, NewList).


% giveFourOfaKindIndices(+Dice, -FourOfAKindIndices)
% Finds the indices of dice that form a four of a kind.
giveFourOfaKindIndices(Dice, FourOfAKindIndices) :-
    findMatchingIndices(Dice, 4, FourOfAKindIndices).


% giveThreeOfaKindIndices(+Dice, -ThreeOfAKindIndices)
% Finds the indices of dice that form a three of a kind.
giveThreeOfaKindIndices(Dice, ThreeOfAKindIndices) :-
    findMatchingIndices(Dice, 3, ThreeOfAKindIndices).


% giveTwoOfaKindIndices(+Dice, -TwoOfAKindIndices)
% Finds the indices of dice that form a two of a kind.
giveTwoOfaKindIndices(Dice, TwoOfAKindIndices) :-
    findMatchingIndices(Dice, 2, TwoOfAKindIndices).


% findMatchingIndices(+Dice, +MatchCount, -MatchingIndices)
% Finds the indices of dice values that match a specific count.
findMatchingIndices(Dice, MatchCount, MatchingIndices) :-
    findMatchingIndicesHelper(Dice, Dice, MatchCount, [], MatchingIndices).

% Helper predicate for findMatchingIndices
findMatchingIndicesHelper([], _, _, _, []).  % Base case: no remaining dice.

findMatchingIndicesHelper([Value | Rest], Dice, MatchCount, SeenValues, MatchingIndices) :-
    countOccurrences(Value, Dice, Occurrences),
    \+ member(Value, SeenValues),  % Ensure the value has not already been processed.
    Occurrences >= MatchCount,  % Check if it matches the required count.
    findIndices(Value, Dice, 1, Indices),
    collect_first_n(Indices, MatchCount, CollectedIndices),
    findMatchingIndicesHelper(Rest, Dice, MatchCount, [Value | SeenValues], RemainingIndices),
    append(CollectedIndices, RemainingIndices, MatchingIndices).

findMatchingIndicesHelper([Value | Rest], Dice, MatchCount, SeenValues, MatchingIndices) :-
    (member(Value, SeenValues); countOccurrences(Value, Dice, Occurrences), Occurrences < MatchCount),
    findMatchingIndicesHelper(Rest, Dice, MatchCount, SeenValues, MatchingIndices).



% countOccurrences(+Value, +Dice, -Count)
% Counts the occurrences of a specific value in a list of dice.
countOccurrences(_, [], 0).  % Base case: empty list.

countOccurrences(Value, [Value | Rest], Count) :-
    countOccurrences(Value, Rest, SubCount),
    Count is SubCount + 1.

countOccurrences(Value, [_ | Rest], Count) :-
    countOccurrences(Value, Rest, Count).

% collect_first_n(+List, +N, -Collected)
% Collects the first N elements from a list.
collect_first_n(_, 0, []) :- !.  % Base case: collected required number of elements.
collect_first_n([], _, []).  % Base case: no more elements to collect.
collect_first_n([H | T], N, [H | Collected]) :-
    N1 is N - 1,
    collect_first_n(T, N1, Collected).

% findIndices(+Value, +Dice, +Index, -Indices)
% Finds the indices of a specific value in a list of dice.
findIndices(_, [], _, []).  % Base case: empty list.

findIndices(Value, [Value | Rest], Index, [Index | Indices]) :-
    NextIndex is Index + 1,
    findIndices(Value, Rest, NextIndex, Indices).

findIndices(Value, [_ | Rest], Index, Indices) :-
    NextIndex is Index + 1,
    findIndices(Value, Rest, NextIndex, Indices).


% removeValue(+Value, +Dice, -RemainingDice)
% Removes all occurrences of a specific value from a list.
removeValue(_, [], []).  % Base case: empty list.

removeValue(Value, [Value | Rest], RemainingDice) :-
    removeValue(Value, Rest, RemainingDice).

removeValue(Value, [H | Rest], [H | RemainingDice]) :-
    removeValue(Value, Rest, RemainingDice).






isFourSequential
findIndicesOfSequence

isThreeSequential
isTwoSequential

checkUniqueAmongPairs












