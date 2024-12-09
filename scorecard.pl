
% get_player(PlayerID, PlayerName)
% Maps a player ID to the corresponding player name.
% get_player(PlayerID, PlayerName)
get_player(1, "You").
get_player(2, "Computer").
get_player(_, "X").  % For invalid player IDs.

% display_row(Index, Row)
display_row(Index, [Category, Score, PlayerID, Round]) :-
    get_player(PlayerID, PlayerName),
    format("~t~5|~w~t~15|~w~t~35|~d~t~45|~w~t~55|~d~n", [Index, Category, Score, PlayerName, Round]).

% display_scorecard_helper(Scorecard, Index)
display_scorecard_helper([], _).
display_scorecard_helper([Row|Rest], Index) :-
    display_row(Index, Row),
    NextIndex is Index + 1,
    display_scorecard_helper(Rest, NextIndex).

% display_scorecard(Scorecard)
display_scorecard(Scorecard) :-
    format("~nScorecard~n"),
    format("------------------------------------------------------------------------------~n"),
    format("~t~5|~w~t~15|~w~t~35|~w~t~45|~w~t~55|~w~n", ["Index", "Category", "Score", "Player", "Round"]),
    format("------------------------------------------------------------------------------~n"),
    display_scorecard_helper(Scorecard, 1).

% initialize_scorecard(Scorecard)
initialize_scorecard([
    ["Ones", 0, 0, 0],
    ["Twos", 0, 0, 0],
    ["Threes", 0, 0, 0],
    ["Fours", 0, 0, 0],
    ["Fives", 0, 0, 0],
    ["Sixes", 0, 0, 0],
    ["Three of a Kind", 0, 0, 0],
    ["Four of a Kind", 0, 0, 0],
    ["Full House", 0, 0, 0],
    ["Four Straight", 0, 0, 0],
    ["Five Straight", 0, 0, 0],
    ["Yahtzee", 0, 0, 0]
]).


% Check if there are three of a kind
hasThreeOfAKind(Dice) :-
    count_occurrences(Dice, Counts),
    member(Count, Counts),
    Count >= 3.

% Check if there are four of a kind
hasFourOfAKind(Dice) :-
    count_occurrences(Dice, Counts),
    member(Count, Counts),
    Count >= 4.

% Check if all dice are the same (Yahtzee)
hasYahtzee(Dice) :-
    count_occurrences(Dice, Counts),
    member(5, Counts).


% Check if there's a full house
hasFullHouse(Dice) :-
    count_occurrences(Dice, Counts),
    member(3, Counts),
    member(2, Counts).

% Check if there's a four straight (small straight)
% Check if there's a four straight (small straight) without duplicates
% Check if there's a four straight (small straight) without duplicates
hasFourStraight(Dice) :-
    sort(Dice, SortedDice),
    once((
        is_sublist([1, 2, 3, 4], SortedDice);
        is_sublist([2, 3, 4, 5], SortedDice);
        is_sublist([3, 4, 5, 6], SortedDice)
    )).

% Helper predicate to check if one list is a sublist of another
is_sublist(Sublist, List) :-
    append(_, Rest, List),
    append(Sublist, _, Rest).


% Check if there's a five straight (large straight)
hasFiveStraight(Dice) :-
    sort(Dice, SortedDice),
    (SortedDice = [1, 2, 3, 4, 5];
     SortedDice = [2, 3, 4, 5, 6]).

% Calculate score for a specific number in the upper section
calculateUpperSectionScore(Number, Dice, Score) :-
    include(==(Number), Dice, MatchingDice),
    sumlist(MatchingDice, Score).


% Sum all dice values
sumAllDice(Dice, Sum) :-
    sumlist(Dice, Sum).

% Determine available combinations to score 
availableCombinations(Dice, AvailableIndices) :-
    findall(Index, (between(1, 12, Index), checkCombination(Dice, Index)), AvailableIndices).

% Check if a specific combination index is available
checkCombination(Dice, Index) :-
    ( Index = 1 -> calculateUpperSectionScore(1, Dice, Score), Score > 0;  % Ones
      Index = 2 -> calculateUpperSectionScore(2, Dice, Score), Score > 0;  % Twos
      Index = 3 -> calculateUpperSectionScore(3, Dice, Score), Score > 0;  % Threes
      Index = 4 -> calculateUpperSectionScore(4, Dice, Score), Score > 0;  % Fours
      Index = 5 -> calculateUpperSectionScore(5, Dice, Score), Score > 0;  % Fives
      Index = 6 -> calculateUpperSectionScore(6, Dice, Score), Score > 0;  % Sixes
      Index = 7 -> hasThreeOfAKind(Dice);                                  % Three of a Kind
      Index = 8 -> hasFourOfAKind(Dice);                                   % Four of a Kind
      Index = 9 -> hasFullHouse(Dice);                                     % Full House
      Index = 10 -> hasFourStraight(Dice);                                  % Four Straight (Small)
      Index = 11 -> hasFiveStraight(Dice);                                 % Five Straight (Large)
      Index = 12 -> hasYahtzee(Dice)                                       % Yahtzee
    ).

scoreableCombinations(Dice, Scorecard, ScoreableCombinations) :-
    availableCombinations(Dice, AvailableIndices),
    findall(Index, (member(Index, AvailableIndices), \+ is_category_set(Scorecard, Index)), ScoreableCombinations).





% Check if a list is a sublist of another list
sublist([], _).
sublist([H|T1], [H|T2]) :-
    sublist(T1, T2).
sublist(Sublist, [_|T2]) :-
    sublist(Sublist, T2).


% FOR COUNT ONLY
% count_occurrences(+Dice, -Counts)
% Dice: List of dice rolls.
% Counts: List of counts for each face (1 to 6).
count_occurrences(Dice, Counts) :-
    count_each_face(Dice, [0, 0, 0, 0, 0, 0], Counts).

% count_each_face(+Dice, +CurrentCounts, -UpdatedCounts)
% Dice: List of dice rolls to process.
% CurrentCounts: Running tally of counts (initialized to [0, 0, 0, 0, 0, 0]).
% UpdatedCounts: Final tally of counts after processing all dice.
count_each_face([], Counts, Counts). % Base case: no more dice to process.
count_each_face([D|Rest], CurrentCounts, UpdatedCounts) :-
    nth1(D, CurrentCounts, CurrentCount),  % Get the current count for face D.
    NewCount is CurrentCount + 1,         % Increment the count for face D.
    replace(CurrentCounts, D, NewCount, TempCounts), % Update the counts list.
    count_each_face(Rest, TempCounts, UpdatedCounts). % Recur for the rest of the dice.

% replace(+List, +Index, +Element, -NewList)
% Replace the element at the given 1-based Index with Element in List.
replace([_|T], 1, Element, [Element|T]).
replace([H|T], Index, Element, [H|R]) :-
    Index > 1,
    Index1 is Index - 1,
    replace(T, Index1, Element, R).

% Display available combinations based on Dice using conditional logic
display_available_combinations(Dice, Scorecard) :-
    %write("Dice: "), write(Dice), nl,
    nl,write("Available Combinations(if any): "), nl, nl,
    findall(Name, (between(1, 12, Index), is_combination_available(Dice, Index, Scorecard, Name)), Names),
    %(Names \= [] -> write("No available combinations to score."), nl),
    maplist(format("Category No: ~w~n"), Names).

% is_combination_available(+Dice, +Index, +Scorecard, -Name)
% Checks if the combination is available and not already scored.
is_combination_available(Dice, Index, Scorecard, Name) :-
    \+ is_category_set(Scorecard, Index), % Ensure the category is not already scored.
    ( Index = 1 -> calculateUpperSectionScore(1, Dice, Score), Score > 0, format(atom(Name), "1. Ones - Score: ~d", [Score]);
      Index = 2 -> calculateUpperSectionScore(2, Dice, Score), Score > 0, format(atom(Name), "2. Twos - Score: ~d", [Score]);
      Index = 3 -> calculateUpperSectionScore(3, Dice, Score), Score > 0, format(atom(Name), "3. Threes - Score: ~d", [Score]);
      Index = 4 -> calculateUpperSectionScore(4, Dice, Score), Score > 0, format(atom(Name), "4. Fours - Score: ~d", [Score]);
      Index = 5 -> calculateUpperSectionScore(5, Dice, Score), Score > 0, format(atom(Name), "5. Fives - Score: ~d", [Score]);
      Index = 6 -> calculateUpperSectionScore(6, Dice, Score), Score > 0, format(atom(Name), "6. Sixes - Score: ~d", [Score]);
      Index = 7 -> hasThreeOfAKind(Dice), sumAllDice(Dice, Score), format(atom(Name), "7. Three of a Kind - Score: ~d", [Score]);
      Index = 8 -> hasFourOfAKind(Dice), sumAllDice(Dice, Score), format(atom(Name), "8. Four of a Kind - Score: ~d", [Score]);
      Index = 9 -> hasFullHouse(Dice), Score = 25, format(atom(Name), "9. Full House - Score: ~d", [Score]);
      Index = 10 -> hasFourStraight(Dice), Score = 30, format(atom(Name), "10. Four Straight - Score: ~d", [Score]);
      Index = 11 -> hasFiveStraight(Dice), Score = 40, format(atom(Name), "11. Five Straight - Score: ~d", [Score]);
      Index = 12 -> hasYahtzee(Dice), Score = 50, format(atom(Name), "12. Yahtzee - Score: ~d", [Score])
    ).



% is_category_set(+Scorecard, +CategoryNum)
% Checks if the score for the given category is greater than 0.
is_category_set(Scorecard, CategoryNum) :-
    nth1(CategoryNum, Scorecard, CategoryRow), % Get the row for the given category number.
    nth1(2, CategoryRow, Score),              % Extract the score from the second column.
    nonvar(Score),                            % Ensure the score is instantiated.
    Score > 0.                                % Check if the score is greater than 0.



% update_scorecard(+Scorecard, +CategoryNum, +Dice)
% Updates the Scorecard by calculating the score for the given category.
update_scorecard(Scorecard, CategoryNum, Dice, RoundNum, PlayerID, NewScorecard) :-
    % format("Scoring category ~w...~n", [CategoryNum]),
    % format("Dice: ~w~n", [Dice]),
    % format("PlayerID: ~w~n", [PlayerID]),
    % format("RoundNum: ~w~n", [RoundNum]),
    % format("Scorecard: ~w~n", [Scorecard]),
    % format("CategoryNum: ~w~n", [CategoryNum]),
    calculate_score(CategoryNum, Dice, Score),
    nl, format("Scored ~w points. ~n", [Score]),
    nth1(CategoryNum, Scorecard, CategoryRow),  % Get the row for the category.
    replace(CategoryRow, 2, Score, TempRow),    % Replace the score in the row.
    replace(TempRow, 3, PlayerID, TempRow2),  % Update the PlayerName in the row.
    replace(TempRow2, 4, RoundNum, UpdatedRow),  % Update the Round number in the row.
    replace(Scorecard, CategoryNum, UpdatedRow, NewScorecard). % Update the Scorecard with the new row.

% calculate_score(+CategoryNum, +Dice, -Score)
% Calculates the score for the given category.
calculate_score(CategoryNum, Dice, Score) :-
    ( CategoryNum = 1 -> calculateUpperSectionScore(1, Dice, Score);
      CategoryNum = 2 -> calculateUpperSectionScore(2, Dice, Score);
      CategoryNum = 3 -> calculateUpperSectionScore(3, Dice, Score);
      CategoryNum = 4 -> calculateUpperSectionScore(4, Dice, Score);
      CategoryNum = 5 -> calculateUpperSectionScore(5, Dice, Score);
      CategoryNum = 6 -> calculateUpperSectionScore(6, Dice, Score);
      CategoryNum = 7 -> (hasThreeOfAKind(Dice) -> sumAllDice(Dice, Score); Score = 0);
      CategoryNum = 8 -> (hasFourOfAKind(Dice) -> sumAllDice(Dice, Score); Score = 0);
      CategoryNum = 9 -> (hasFullHouse(Dice) -> Score = 25; Score = 0);
      CategoryNum = 10 -> (hasFourStraight(Dice) -> Score = 30; Score = 0);
      CategoryNum = 11 -> (hasFiveStraight(Dice) -> Score = 40; Score = 0);
      CategoryNum = 12 -> (hasYahtzee(Dice) -> Score = 50; Score = 0)
    ).

% %ask_category_to_score(+Scorecard, +Dice)
% Asks the user for a category number to score and updates the Scorecard accordingly.
ask_category_to_score(Scorecard, Dice, RoundNum, PlayerID, NewScorecard) :-
    scoreableCombinations(Dice, Scorecard, AvailableIndices),  % Find available combinations.
    %format("Available categories to score: ~w~n", [AvailableIndices]),
    (   AvailableIndices \= [] 
    ->  prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard)
    ;   write("No available categories to score. Please try again next round."), nl,
        NewScorecard = Scorecard
    ).

% get_score(dice, Score)
% Get the score for the dice
get_score(CategoryNum, Dice, Score) :-
    calculate_score(CategoryNum, Dice, Score).


% prompt_category(+Scorecard, +Dice, +AvailableIndices)
% Recursively prompts the user for a valid category number.
prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard) :-
    write("Enter the category number to score: "),
    read_line_to_string(user_input, Input),
    (   Input \= "" -> % Check that input is not empty
        (   atom_number(Input, CategoryNum), % Try converting input to a number
            member(CategoryNum, AvailableIndices) % Validate if the number is in available indices
        ->  update_scorecard(Scorecard, CategoryNum, Dice, RoundNum, PlayerID, NewScorecard),  % Update the Scorecard.
            nl,nl
            %write("Scorecard updated successfully!"), nl
        ;   write("Invalid category entered. Please try again."), nl, nl,
            prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard) % Recursive call on invalid input
        )
    ;   write("No input provided. Please try again."), nl, nl,
        prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard) % Recursive call if input is empty
    ).

% function to check if the scorecard is full
is_scorecard_full(Scorecard) :-
    \+ (between(1, 12, CategoryNum), \+ is_category_set(Scorecard, CategoryNum)).

% calculate_total_score(Scorecard, PlayerID, TotalScore) :-
%     findall(Score, (member([_, Score, Player, _], Scorecard), Player = PlayerID), Scores),
%     calculate_sum(Scores, TotalScore).


calculate_sum([], 0).
calculate_sum([H|T], Total) :-
    calculate_sum(T, SumRest),
    Total is H + SumRest.


% find the player with the loweest score
% find the score of human player, find the score of computer player
% compare the scores
% return the player with the lowest score, if the scores are equal, return the human player
player_with_lowest_score(Scorecard, PlayerID) :-
    calculate_total_score(Scorecard, 1, HumanScore),
    calculate_total_score(Scorecard, 2, ComputerScore),
    (HumanScore < ComputerScore -> PlayerID = 1; PlayerID = 2).

calculate_total_score(Scorecard, PlayerID, TotalScore) :-
    findall(Score, (member([_, Score, Player, _], Scorecard), Player = PlayerID), Scores),
    calculate_sum(Scores, TotalScore).


    % get_scores_for_categories(+Categories, +Dice, -Scores)
    % Given a list of Categories and Dice, return a list of corresponding scores.
    get_scores_for_categories([], _, []).
    get_scores_for_categories([CategoryNum|RestCategories], Dice, [Score|RestScores]) :-
        get_score(CategoryNum, Dice, Score),
        get_scores_for_categories(RestCategories, Dice, RestScores).


% Check if the lower section of the scorecard is full (no score == 0 in lower section categories)
is_lower_section_full(Scorecard) :-
    % Define the lower section categories
    LowerSection = [
        "Three of a Kind",
        "Four of a Kind",
        "Full House",
        "Four Straight",
        "Five Straight",
        "Yahtzee"
    ],
    % Check if all lower section scores are non-zero
    \+ (member([Category, Score, _, _], Scorecard),
        member(Category, LowerSection),
        Score =:= 0).

% Check if the upper section of the scorecard is full (no score == 0 in upper section categories)
is_upper_section_full(Scorecard) :-
    % Define the upper section categories
    UpperSection = [
        "Ones",
        "Twos",
        "Threes",
        "Fours",
        "Fives",
        "Sixes"
    ],
    % Check if all upper section scores are non-zero
    \+ (member([Category, Score, _, _], Scorecard),
        member(Category, UpperSection),
        Score =:= 0).


% checks if the given category is filled
% Define the is_category_filled function
is_category_filled([[_, Score, _, _] | _], 1) :-
    Score \= 0.

is_category_filled([_ | Rest], CategoryNum) :-
    CategoryNum > 1,
    NextCategoryNum is CategoryNum - 1,
    is_category_filled(Rest, NextCategoryNum).

is_category_filled([[_, 0, _, _] | _], 1) :-
    !, fail.


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

% % isThreeSequential(+Dice, -ThreeSequential)
% % Checks if there are three sequential dice values in the list.
% isThreeSequential(Dice, ThreeSequential) :-
%     remove_duplicates(Dice, UniqueDice),
%     sort(UniqueDice, SortedDice),
%     findThreeSequential(SortedDice, ThreeSequential).

% % findThreeSequential(+SortedDice, -ThreeSequential)
% % Finds three sequential dice values in a sorted list.
% findThreeSequential([A, B, C | _], [A, B, C]) :-
%     B =:= A + 1,
%     C =:= B + 1.
% findThreeSequential([_ | T], ThreeSequential) :-
%     findThreeSequential(T, ThreeSequential).

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
uniqueIndexAmongPairs([H | _T], Pair1, Pair2, Index, UniqueIndex) :-
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
% Recursive case: If the first element of list1 is found in list2, continue checking the rest of list1.
kept_indices_checker([H | T], List2) :-
    member(H, List2),  % Check that H is a member of List2.
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


% % giveTwoOfaKindIndices(+Dice, -TwoOfAKindIndices)
% % Finds the indices of dice that form a two of a kind.
giveTwoOfaKindIndices(Dice, TwoOfAKindIndices) :-
    findMatchingIndices(Dice, 2, TwoOfAKindIndices).

% giveTwoOfaKindIndices(+Dice, -TwoOfAKindIndices)
% Finds the indices of the first two-of-a-kind in Dice.
giveTwoOfaKindOrFourIndices(Dice, TwoOfAKindIndices) :-
    findall(Value, (
        member(Value, Dice),                   % Iterate over each value in Dice
        include(=(Value), Dice, Matches),      % Collect all matches for that value
        length(Matches, Count),
        Count >= 2                             % Ensure at least two occurrences
    ), [FirstTwoOfAKind | _]),                 % Take the first value with at least two occurrences
    findIndicess(FirstTwoOfAKind, Dice, 1, AllIndices),
    length(TwoOfAKindIndices, 2),             % Ensure exactly two indices are returned
    append(TwoOfAKindIndices, _, AllIndices), % Get the first two indices of the value
    !.                                         % Stop after finding the first two-of-a-kind.

% If no two-of-a-kind is found, return an empty list.
giveTwoOfaKindOrFourIndices(_, []).

% findIndices(+Value, +Dice, +StartIndex, -Indices)
% Finds all indices of Value in Dice starting from StartIndex.
findIndicess(_, [], _, []).  % Base case: empty Dice, no indices.
findIndicess(Value, [Value | Rest], Index, [Index | Indices]) :-
    NextIndex is Index + 1,
    findIndicess(Value, Rest, NextIndex, Indices).
findIndicess(Value, [_ | Rest], Index, Indices) :-
    NextIndex is Index + 1,
    findIndicess(Value, Rest, NextIndex, Indices).







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



% find_all_indices(+DiceValues, +ValuesToSearch, -Indices)
% Returns the indices of each value in ValuesToSearch as they appear in DiceValues.
% Only the first occurrence is taken, no duplicates.
find_all_indices(_, [], []).
find_all_indices(DiceValues, [Val|Vals], [Index|Indices]) :-
    nth1(Index, DiceValues, Val), !,
    find_all_indices(DiceValues, Vals, Indices).
find_all_indices(DiceValues, [_|Vals], Indices) :-
    find_all_indices(DiceValues, Vals, Indices).

% find_dice_values(+DiceVals, +Indices, -ReturnVal)
% Extracts values from DiceVals at positions specified in Indices.
find_dice_values(DiceVals, Indices, ReturnVal) :-
    findall(Value, (
        member(Index, Indices),     % Iterate over each index in Indices
        nth1(Index, DiceVals, Value)  % Get the value at the given index
    ), ReturnVal).


% find_category_name(+CategoryNum, -CategoryName)
% Maps a category number to its corresponding category name.
find_category_name(CategoryNum, CategoryName) :-
    Scorecard = [
        ["Ones", 1],
        ["Twos", 2],
        ["Threes", 3],
        ["Fours", 4],
        ["Fives", 5],
        ["Sixes", 6],
        ["Three of a Kind", 7],
        ["Four of a Kind", 8],
        ["Full House", 9],
        ["Four Straight", 10],
        ["Five Straight", 11],
        ["Yahtzee", 12]
    ],
    member([CategoryName, CategoryNum], Scorecard).



% find_potential_categories(+DiceValues, +Scorecard, +RollCount, -PotentialCategoryList)
% Determines potential categories based on dice values and roll count.
find_potential_categories(DiceValues, Scorecard, RollCount, PotentialCategoryList) :-
    (   RollCount == 0 ->
        findall(CategoryName,
            (   between(1, 12, CategoryNum),  % Iterate over categories 1 to 12
                \+ is_category_filled(Scorecard, CategoryNum),  % Check if category is not filled
                find_category_name(CategoryNum, CategoryName)  % Get the category name
            ),
            PotentialCategoryList)
    ;   RollCount == 1 ->
        findall(CategoryName,
                (   member(CategoryNum, [1,2,3,4,5,6]),  % Check upper section
                    \+ is_category_filled(Scorecard, CategoryNum),  % Ensure the category is not filled
                    find_category_name(CategoryNum, CategoryName)  % Map to category name
                ),
                PotentialCategoryList1),
        (   hasThreeOfAKind(DiceValues) ->
            findall(CategoryName,
                (   member(CategoryNum, [7, 8, 9, 12]),  % Check categories for Three of a Kind
                    \+ is_category_filled(Scorecard, CategoryNum),  % Ensure the category is not filled
                    find_category_name(CategoryNum, CategoryName)  % Map to category name
                ),
                PotentialCategoryList2)
        ;
            findall(CategoryName,
                (   member(CategoryNum, [11, 12]),  % Check categories for no Three of a Kind
                    \+ is_category_filled(Scorecard, CategoryNum),  % Ensure the category is not filled
                    find_category_name(CategoryNum, CategoryName)  % Map to category name
                ),
                PotentialCategoryList2)
        ), append(PotentialCategoryList1, PotentialCategoryList2, PotentialCategoryList)
    ;   RollCount == 3 ->
        scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
        findall(CategoryName,
            (   member(CategoryNum, CategoriesAvailableToScore),
                find_category_name(CategoryNum, CategoryName)
            ),
            PotentialCategoryList)
    ).

% display_potential_categories(+DiceValues, +Scorecard, +RollCount, -PotentialCategoryList)
% Calls find_potential_categories/4 and displays the potential categories.
display_potential_categories(DiceValues, Scorecard, RollCount, PotentialCategoryList) :-
    find_potential_categories(DiceValues, Scorecard, RollCount, PotentialCategoryList),
    nl,write("Potential Categories:"), nl,
    (   PotentialCategoryList = [] ->
        write("No potential categories available."), nl
    ;   forall(member(Category, PotentialCategoryList),
            format("- ~w~n", [Category]))
    ),nl,nl.



% find_wildcard_index(+DiceVals, -WildcardIndex)
% Identifies the position of the wildcard (_) in DiceVals based on given patterns.
find_wildcard_index(DiceVals, WildcardIndex) :-
    % Define all valid patterns with their wildcard indices
    Patterns = [
        ([1, 2, 3, _, 5], 4),
        ([_, 1, 2, 3, 5], 1),
        ([1, _, 2, 3, 5], 2),
        ([1, 2, _, 3, 5], 3),
        ([1, 2, 3, 4, _], 5),
        ([_, 2, 3, 4, 5], 1),
        ([2, _, 3, 4, 5], 2),
        ([2, 3, _, 4, 5], 3),
        ([2, 3, 4, _, 5], 4),
        ([_, 3, 4, 5, 6], 1),
        ([3, _, 4, 5, 6], 2),
        ([3, 4, _, 5, 6], 3),
        ([3, 4, 5, _, 6], 4),
        ([3, 4, 5, 6, _], 5),
        ([1, _, 3, 4, 5], 2),
        ([2, _, 4, 5, 6], 2),
        ([2, 3, 4, _, 6], 4)
    ],
    % Check if any pattern matches DiceVals
    member((Pattern, WildcardIndex), Patterns),
    matches_pattern(DiceVals, Pattern).

% matches_pattern(+DiceVals, +Pattern)
% Checks if DiceVals matches the pattern, treating _ as any value.
matches_pattern([], []).
matches_pattern([D | RestDice], [P | RestPattern]) :-
    (   var(P) -> true  % If pattern element is a variable (_), match any value
    ;   D =:= P         % Otherwise, ensure exact match
    ),
    matches_pattern(RestDice, RestPattern).


% main predicate to initialize and display the scorecard
scorecard :-
    initialize_scorecard(Scorecard),
    display_scorecard(Scorecard).


