

% Automatically run tests when the file is loaded.
:- initialization(main).

% isFourSequential(+Dice, -FourSequential)
% Checks if there are four sequential dice values in the list.
isFourSequential(Dice, FourSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findFourSequential(SortedDice, FourSequential).

% findFourSequential(+SortedDice, -FourSequential)
% Finds four sequential dice values in a sorted list.
findFourSequential([A, B, C, D | _], [A, B, C, D]) :-
    B =:= A + 1,
    C =:= B + 1,
    D =:= C + 1.
findFourSequential([_ | T], FourSequential) :-
    findFourSequential(T, FourSequential).


% findIndicesOfSequence(+Dice, +Sequence, -Indices)
% Finds the indices of the sequence in the list of dice.
findIndicesOfSequence(Dice, Sequence, Indices) :-
    findIndicesHelper(Dice, Sequence, 1, Indices).

% findIndicesHelper(+Dice, +Sequence, +CurrentIndex, -Indices)
% Helper predicate to find the indices of the sequence.
findIndicesHelper(_, [], _, []).
findIndicesHelper([H | T], [H | SeqT], CurrentIndex, [CurrentIndex | Indices]) :-
    NextIndex is CurrentIndex + 1,
    findIndicesHelper(T, SeqT, NextIndex, Indices).
findIndicesHelper([_ | T], Sequence, CurrentIndex, Indices) :-
    NextIndex is CurrentIndex + 1,
    findIndicesHelper(T, Sequence, NextIndex, Indices).

% isThreeSequential(+Dice, -ThreeSequential)
% Checks if there are three sequential dice values in the list.
isThreeSequential(Dice, ThreeSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findThreeSequential(SortedDice, ThreeSequential).

% findThreeSequential(+SortedDice, -ThreeSequential)
% Finds three sequential dice values in a sorted list.
findThreeSequential([A, B, C | _], [A, B, C]) :-
    B =:= A + 1,
    C =:= B + 1.
findThreeSequential([_ | T], ThreeSequential) :-
    findThreeSequential(T, ThreeSequential).

% isThreeSequential(+Dice, -ThreeSequential)
% Checks if there are three sequential dice values in the list.
isThreeSequential(Dice, ThreeSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findThreeSequential(SortedDice, ThreeSequential).

% findThreeSequential(+SortedDice, -ThreeSequential)
% Finds three sequential dice values in a sorted list.
findThreeSequential([A, B, C | _], [A, B, C]) :-
    B =:= A + 1,
    C =:= B + 1.
findThreeSequential([_ | T], ThreeSequential) :-
    findThreeSequential(T, ThreeSequential).

% isTwoSequential(+Dice, -TwoSequential)
% Checks if there are two sequential dice values in the list.
isTwoSequential(Dice, TwoSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findTwoSequential(SortedDice, TwoSequential).

% findTwoSequential(+SortedDice, -TwoSequential)
% Finds two sequential dice values in a sorted list.
findTwoSequential([A, B | _], [A, B]) :-
    B =:= A + 1.
findTwoSequential([_ | T], TwoSequential) :-
    findTwoSequential(T, TwoSequential).


% checkUniqueAmongPairs(+Dice, -UniqueIndex)
% Checks if there is a unique element among two distinct pairs.
checkUniqueAmongPairs(Dice, UniqueIndex) :-
    collectPairs(Dice, Pairs),
    length(Pairs, 2),  % Ensure there are exactly two distinct pairs.
    Pairs = [Pair1, Pair2],
    uniqueIndexAmongPairs(Dice, Pair1, Pair2, 1, UniqueIndex).

% collectPairs(+Dice, -Pairs)
collectPairs(Dice, Pairs) :-
    collectPairsHelper(Dice, Dice, [], Pairs).

% collectPairsHelper(+Remaining, +FullList, +Seen, -Pairs)
collectPairsHelper([], _, Pairs, Pairs).
collectPairsHelper([H | T], FullList, Seen, Pairs) :-
    count_occurrences(H, FullList, Count),
    Count =:= 2, \+ member(H, Seen),
    collectPairsHelper(T, FullList, [H | Seen], Pairs).
collectPairsHelper([_ | T], FullList, Seen, Pairs) :-
    collectPairsHelper(T, FullList, Seen, Pairs).


% uniqueIndexAmongPairs(+Dice, +Pair1, +Pair2, +Index, -UniqueIndex)
% Finds the index of the unique element among two distinct pairs.
uniqueIndexAmongPairs([], _, _, _, -1).  % Base case: no unique element found.
uniqueIndexAmongPairs([H | T], Pair1, Pair2, Index, UniqueIndex) :-
    H \= Pair1,
    H \= Pair2,
    UniqueIndex = Index.
uniqueIndexAmongPairs([_ | T], Pair1, Pair2, Index, UniqueIndex) :-
    NextIndex is Index + 1,
    uniqueIndexAmongPairs(T, Pair1, Pair2, NextIndex, UniqueIndex).

% remove_duplicates(+List, -UniqueList)
% Removes duplicate elements from a list.
remove_duplicates([], []).
remove_duplicates([H | T], [H | Result]) :-
    \+ member(H, T),
    remove_duplicates(T, Result).
remove_duplicates([_ | T], Result) :-
    remove_duplicates(T, Result).


% count_occurrences(+Element, +List, -Count)
% Counts the occurrences of an element in a list.
count_occurrences(_, [], 0).
count_occurrences(Elem, [Elem | T], Count) :-
    count_occurrences(Elem, T, SubCount),
    Count is SubCount + 1.
count_occurrences(Elem, [_ | T], Count) :-
    count_occurrences(Elem, T, Count).


% Main predicate to run tests
main :-
    % Test isFourSequential
    writeln('Testing isFourSequential...'),
    isFourSequential([1, 2, 3, 4, 6], FourSeq),
    writeln('Input: [1, 2, 3, 4, 6]'),
    writeln('Output: '), writeln(FourSeq),
    
    % Test findIndicesOfSequence
    writeln('Testing findIndicesOfSequence...'),
    findIndicesOfSequence([1, 2, 3, 4, 5, 3], [3, 4], Indices),
    writeln('Input Dice: [1, 2, 3, 4, 5, 3]'),
    writeln('Sequence: [3, 4]'),
    writeln('Output Indices: '), writeln(Indices),
    
    % Test isThreeSequential
    writeln('Testing isThreeSequential...'),
    isThreeSequential([4, 5, 6, 8], ThreeSeq),
    writeln('Input: [4, 5, 6, 8]'),
    writeln('Output: '), writeln(ThreeSeq),
    
    % Test isTwoSequential
    writeln('Testing isTwoSequential...'),
    isTwoSequential([7, 6, 10], TwoSeq),
    writeln('Input: [7, 8, 10]'),
    writeln('Output: '), writeln(TwoSeq),
    
    % Test checkUniqueAmongPairs
    writeln('Testing checkUniqueAmongPairs...'),
    checkUniqueAmongPairs([1, 1, 2, 5, 5], UniqueIndex),
    writeln('Input: [1, 1, 2, 2, 3]'),
    writeln('Output (Unique Index): '), writeln(UniqueIndex),

    % End of tests
    writeln('All tests completed!').