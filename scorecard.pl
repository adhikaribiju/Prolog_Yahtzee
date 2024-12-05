%Do not use:
% - cut
% - assert, retract
% - repeat and any other such imperative construct.
 
% Use % to comment your code. The comment runs from the % to the end of the line
% Properly indent your code to make it readable
% Doing top-down design can save a lot of aggravation.

% Language Details
% random_between(1, 5, Val)

% returns 1 =< Val =< 5.
% Be careful with the order of \= operator, as well as =< and >= operators.
% To print a text message, you may want to use:

% printstring([]).
% printstring([H][T]) :- put(H), printstring(T).
% Call it as:
% printstring("******Here is a String******").

% print(term) prints any term (variable/constant/structure..)
% Use read(term) to read in a term.

% When running the program, at the keyboard, enter the term, followed by a period, and a carriage return.
% When defining a predicate with no arguments, do not use empty parentheses. E.g.,

% junk :- print(1), nl.
% Query it as follows:
% ?- junk.
% When entering a list at the keyboard as input to a read(X) clause, enter commas between elements of the list.

% E.g., instead of typing [3 + 4].
% enter [3, +, 4].
% Do not insert a space between the name of a predicate and the opening parenthesis of its argument list. SWI-Prolog flags this as an error. E.g.,:

% insertElement (X, [X | _]). <-- wrong
% insertElement(X, [X | _]). <-- right
% Do not start the name of a predicate with uppercase. This can result in spurious errors.
% Make sure the end of the file does not occur on the same line as the last line of your last clause. In other words, be sure to hit a return after every clause in your source file.


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

display_available_categories(Scorecard, DiceValues) :-
    format("Available Categories: ~n"), nl.


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
    write("Available Combinations: "), nl,
    findall(Name, (between(1, 12, Index), is_combination_available(Dice, Index, Scorecard, Name)), Names),
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
    calculate_score(CategoryNum, Dice, Score),
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

% ask_category_to_score(+Scorecard, +Dice)
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
            write("Scorecard updated successfully!"), nl
        ;   write("Invalid category entered. Please try again."), nl,
            prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard) % Recursive call on invalid input
        )
    ;   write("No input provided. Please try again."), nl,
        prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard) % Recursive call if input is empty
    ).

% function to check if the scorecard is full
is_scorecard_full(Scorecard) :-
    \+ (between(1, 12, CategoryNum), \+ is_category_set(Scorecard, CategoryNum)).

calculate_total_score(Scorecard, PlayerID, TotalScore) :-
    findall(Score, (member([_, Score, Player, _], Scorecard), Player = PlayerID), Scores),
    calculate_sum(Scores, TotalScore).


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



% main predicate to initialize and display the scorecard
scorecard :-
    initialize_scorecard(Scorecard),
    display_scorecard(Scorecard).
