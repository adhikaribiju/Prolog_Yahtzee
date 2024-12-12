


% *********************************************************************
% Predicate Name: get_player
% Description: Get the name of the player based on the player ID.
% Parameters:
%   - PlayerID: ID of the player.
%   - PlayerName: Name of the player.
% Algorithm:
%   - If the player ID is 1, return "You".
%   - If the player ID is 2, return "Computer".
%   - For invalid player IDs, return "X".
% Reference: None
% *********************************************************************
get_player(1, "You").
get_player(2, "Computer").
get_player(_, "X").  % For invalid player IDs.



% *********************************************************************
% Predicate Name: display_row
% Description: Displays a row in the scorecard.
% Parameters:
%   - Index: Index of the current row.
%   - Row: List containing the category, score, player ID, and round number.
% Algorithm:
%   - Get the player name from the player ID.
%   - Display the row with the category, score, player, and round number.
% Reference: None
% *********************************************************************
display_row(Index, [Category, Score, PlayerID, Round]) :-
    get_player(PlayerID, PlayerName),
    format("~t~5|~w~t~15|~w~t~35|~d~t~45|~w~t~55|~d~n", [Index, Category, Score, PlayerName, Round]).



% *********************************************************************
% Predicate Name: display_scorecard_helper
% Description: Helper predicate to display the scorecard.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - Index: Index of the current row.
% Algorithm:
%   - Base case: If the list is empty, return.
%   - Display the current row and recur with the rest of the list.
% Reference: None
% *********************************************************************
display_scorecard_helper([], _).
display_scorecard_helper([Row|Rest], Index) :-
    display_row(Index, Row),
    NextIndex is Index + 1,
    display_scorecard_helper(Rest, NextIndex).



% *********************************************************************
% Predicate Name: display_scorecard
% Description: Displays the scorecard to the user.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Display the scorecard with the category, score, player, and round number.
% Reference: None
% *********************************************************************
display_scorecard(Scorecard) :-
    format("~nScorecard~n"),
    format("------------------------------------------------------------------------------~n"),
    format("~t~5|~w~t~15|~w~t~35|~w~t~45|~w~t~55|~w~n", ["Index", "Category", "Score", "Player", "Round"]),
    format("------------------------------------------------------------------------------~n"),
    display_scorecard_helper(Scorecard, 1).



% *********************************************************************
% Predicate Name: initialize_scorecard
% Description: Initializes the scorecard with default values.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Initialize the scorecard with default values.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: hasThreeOfAKind
% Description: Check if there is a three of a kind in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Count the occurrences of each face in the list of dice.
%   - Check if there is a three of a kind.
% Reference: None
% *********************************************************************
hasThreeOfAKind(Dice) :-
    count_occurrences(Dice, Counts),
    member(Count, Counts),
    Count >= 3.


% *********************************************************************
% Predicate Name: hasFourOfAKind
% Description: Check if there is a four of a kind in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Count the occurrences of each face in the list of dice.
%   - Check if there is a four of a kind.
% Reference: None
% *********************************************************************
hasFourOfAKind(Dice) :-
    count_occurrences(Dice, Counts),
    member(Count, Counts),
    Count >= 4.


% *********************************************************************
% Predicate Name: hasYahtzee
% Description: Check if there is a Yahtzee in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Count the occurrences of each face in the list of dice.
%   - Check if there is a Yahtzee.
% Reference: None
% *********************************************************************
hasYahtzee(Dice) :-
    count_occurrences(Dice, Counts),
    member(5, Counts).




% *********************************************************************
% Predicate Name: hasFullHouse
% Description: Check if there is a full house in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Count the occurrences of each face in the list of dice.
%   - Check if there is a three of a kind and a pair.
% Reference: None
% *********************************************************************
hasFullHouse(Dice) :-
    count_occurrences(Dice, Counts),
    member(3, Counts),
    member(2, Counts).



% *********************************************************************
% Predicate Name: hasFourStraight
% Description: Check if there is a four straight in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Sort the list of dice.
%   - Check if the sorted list is a four straight.
% Reference: None
% *********************************************************************
hasFourStraight(Dice) :-
    sort(Dice, SortedDice),
    once((
        is_sublist([1, 2, 3, 4], SortedDice);
        is_sublist([2, 3, 4, 5], SortedDice);
        is_sublist([3, 4, 5, 6], SortedDice)
    )).


% *********************************************************************
% Predicate Name: is_sublist
% Description: Check if a list is a sublist of another list.
% Parameters:
%   - Sublist: List to check if it is a sublist.
%   - List: List to check if it contains the sublist.
% Algorithm:
%   - Base case: If the sublist is empty, return true.
%   - If the heads of the lists match, recur with the rest of the lists.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
is_sublist(Sublist, List) :-
    append(_, Rest, List),
    append(Sublist, _, Rest).


% *********************************************************************
% Predicate Name: hasFiveStraight
% Description: Check if there is a five straight in the list of dice.
% Parameters:
%   - Dice: List of dice values.
% Algorithm:
%   - Sort the list of dice.
%   - Check if the sorted list is a five straight.
% Reference: None
% *********************************************************************
hasFiveStraight(Dice) :-
    sort(Dice, SortedDice),
    (SortedDice = [1, 2, 3, 4, 5];
     SortedDice = [2, 3, 4, 5, 6]).



% *********************************************************************
% Predicate Name: calculateUpperSectionScore
% Description: Calculate the score for the upper section of the scorecard.
% Parameters:
%   - Number: Number to calculate the score for.
%   - Dice: List of dice values.
%   - Score: Calculated score for the number.
% Algorithm:
%   - Find all dice that match the number.
%   - Calculate the sum of the matching dice.
% Reference: None
% *********************************************************************
calculateUpperSectionScore(Number, Dice, Score) :-
    include(==(Number), Dice, MatchingDice),
    sumlist(MatchingDice, Score).


% *********************************************************************
% Predicate Name: sumAllDice
% Description: Calculate the sum of all dice values.
% Parameters:
%   - Dice: List of dice values.
%   - Sum: Sum of all dice values.
% Algorithm:
%   - Calculate the sum of all dice values and put it in the Sum variable.
% Reference: None
% *********************************************************************
sumAllDice(Dice, Sum) :-
    sumlist(Dice, Sum).



% *********************************************************************
% Predicate Name: availableCombinations
% Description: Find available combinations to score.
% Parameters:
%   - Dice: List of dice values.
%   - AvailableIndices: List of available combinations to score.
% Algorithm:
%   - Find all available combinations and add them to the list.
% Reference: None
% *********************************************************************
availableCombinations(Dice, AvailableIndices) :-
    findall(Index, (between(1, 12, Index), checkCombination(Dice, Index)), AvailableIndices).



% *********************************************************************
% Predicate Name: checkCombination
% Description: Check if a combination is available to score.
% Parameters:
%   - Dice: List of dice values.
%   - Index: Index of the category to check.
% Algorithm:
%   - Check if the combination is available to score.
% Reference: None
% *********************************************************************
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


% *********************************************************************
% Predicate Name: scoreableCombinations
% Description: Find available combinations to score.
% Parameters:
%   - Dice: List of dice values.
%   - Scorecard: List of rows in the scorecard.
%   - ScoreableCombinations: List of available combinations to score.
% Algorithm:
%   - Find available combinations.
%   - Filter out combinations that are already scored.
% Reference: None
% *********************************************************************
scoreableCombinations(Dice, Scorecard, ScoreableCombinations) :-
    availableCombinations(Dice, AvailableIndices),
    findall(Index, (member(Index, AvailableIndices), \+ is_category_set(Scorecard, Index)), ScoreableCombinations).


% *********************************************************************
% Predicate Name: sublist
% Description: Check if a list is a sublist of another list.
% Parameters:
%   - Sublist: List to check if it is a sublist.
%   - List: List to check if it contains the sublist.
% Algorithm:
%   - Base case: If the sublist is empty, return true.
%   - If the heads of the lists match, recur with the rest of the lists.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
sublist([], _).
sublist([H|T1], [H|T2]) :-
    sublist(T1, T2).
sublist(Sublist, [_|T2]) :-
    sublist(Sublist, T2).



% *********************************************************************
% Predicate Name: count_occurrences
% Description: Count the occurrences of each face in a list of dice.
% Parameters:
%   - Dice: List of dice values.
%   - Counts: List of counts for each face (1 to 6).
% Algorithm:
%   - Initialize the counts for each face to 0.
%   - Count the occurrences of each face in the list of dice.
% Reference: None
% *********************************************************************
count_occurrences(Dice, Counts) :-
    count_each_face(Dice, [0, 0, 0, 0, 0, 0], Counts).


% *********************************************************************
% Predicate Name: count_each_face
% Description: Count the occurrences of each face in a list of dice.
% Parameters:
%   - Dice: List of dice values.
%   - Counts: List of counts for each face (1 to 6).
%   - UpdatedCounts: Updated list of counts for each face.
% Algorithm:
%   - Base case: If the list of dice is empty, return the counts.
%   - Get the current count for the face and increment it.
%   - Replace the current count with the new count.
%   - Recur with the rest of the dice.
% Reference: None
% *********************************************************************
count_each_face([], Counts, Counts). % Base case: no more dice to process.
count_each_face([D|Rest], CurrentCounts, UpdatedCounts) :-
    nth1(D, CurrentCounts, CurrentCount),  % Get the current count for face D.
    NewCount is CurrentCount + 1,         % Increment the count for face D.
    replace(CurrentCounts, D, NewCount, TempCounts), 
    count_each_face(Rest, TempCounts, UpdatedCounts). % do the same for rest of the dice.



% *********************************************************************
% Predicate Name: replace
% Description: Replace an element at a specific index in a list.
% Parameters:
%   - List: List to update.
%   - Index: Index to update.
%   - Element: New element to insert.
%   - Result: Updated list.
% Algorithm:
%   - Base case: If the index is 1, replace the head of the list.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
replace([_|T], 1, Element, [Element|T]).
replace([H|T], Index, Element, [H|R]) :-
    Index > 1,
    Index1 is Index - 1,
    replace(T, Index1, Element, R).


% *********************************************************************
% Predicate Name: display_available_combinations
% Description: Display available combinations to score.
% Parameters:
%   - Dice: List of dice values.
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Find available combinations.
%   - Display the available combinations.
% Reference: None
% *********************************************************************
display_available_combinations(Dice, Scorecard) :-
    %write("Dice: "), write(Dice), nl,
    nl,write("Available Combinations(if any): "), nl, nl,
    findall(Name, (between(1, 12, Index), is_combination_available(Dice, Index, Scorecard, Name)), Names),
    %(Names \= [] -> write("No available combinations to score."), nl),
    maplist(format("Category No: ~w~n"), Names).


% *********************************************************************
% Predicate Name: is_combination_available
% Description: Check if a combination is available to score.
% Parameters:
%   - Dice: List of dice values.
%   - Index: Index of the category to check.
%   - Scorecard: List of rows in the scorecard.
%   - Name: Name of the category.
% Algorithm:
%   - Check if the category is not already scored.
%   - Calculate the score for the given category based on the dice.
%   - Format the name of the category.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: is_category_set
% Description: Check if a category is set in the scorecard.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - CategoryNum: Index of the category to check.
% Algorithm:
%   - Get the row for the given category number.
%   - Extract the score from the second column.
%   - Ensure the score is instantiated and greater than 0.
% Reference: None
% *********************************************************************
is_category_set(Scorecard, CategoryNum) :-
    nth1(CategoryNum, Scorecard, CategoryRow), % Get the row for the given category number.
    nth1(2, CategoryRow, Score),              % Extract the score from the second column.
    nonvar(Score),                            % Ensure the score is instantiated.
    Score > 0.                                % Check if the score is greater than 0.





% *********************************************************************
% Predicate Name: update_scorecard
% Description: Update the scorecard with the score for a specific category.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - CategoryNum: Index of the category to score.
%   - Dice: List of dice values.
%   - RoundNum: Current round number.
%   - PlayerID: ID of the current player.
%   - NewScorecard: Updated Scorecard after scoring a category.
% Algorithm:
%   - Calculate the score for the given category.
%   - Update the scorecard with the new score.
% Reference: None
% *********************************************************************
update_scorecard(Scorecard, CategoryNum, Dice, RoundNum, PlayerID, NewScorecard) :-
    calculate_score(CategoryNum, Dice, Score),
    nl, format("Scored ~w points. ~n", [Score]),
    nth1(CategoryNum, Scorecard, CategoryRow),
    replace(CategoryRow, 2, Score, TempRow),    % Replace the score in the row.
    replace(TempRow, 3, PlayerID, TempRow2), 
    replace(TempRow2, 4, RoundNum, UpdatedRow),  % Update the Round number in the row.
    replace(Scorecard, CategoryNum, UpdatedRow, NewScorecard). % Update the Scorecard with the new row.



% *********************************************************************
% Predicate Name: calculate_score
% Description: Calculate the score for a specific category.
% Parameters:
%   - CategoryNum: Index of the category to score.
%   - Dice: List of dice values.
%   - Score: Calculated score for the category.
% Algorithm:
%   - Calculate the score for the given category.
% Reference: None
% *********************************************************************
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




% *********************************************************************
% Predicate Name: ask_category_to_score
% Description: Asks the user to enter a category number to score.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - Dice: List of dice values.
%   - RoundNum: Current round number.
%   - PlayerID: ID of the current player.
%   - NewScorecard: Updated Scorecard after scoring a category.
% Algorithm:
%   - Find available combinations.
%   - If there are available combinations, prompt the user to enter a category number.
%   - If there are no available combinations, display a message and return the original Scorecard.
% Reference: None
% *********************************************************************
ask_category_to_score(Scorecard, Dice, RoundNum, PlayerID, NewScorecard) :-
    scoreableCombinations(Dice, Scorecard, AvailableIndices),  % Find available combinations.
    %format("Available categories to score: ~w~n", [AvailableIndices]),
    (   AvailableIndices \= [] 
    ->  prompt_category(Scorecard, Dice, AvailableIndices, RoundNum, PlayerID, NewScorecard)
    ;   write("No available categories to score. Please try again next round."), nl,
        NewScorecard = Scorecard
    ).




% *********************************************************************
% Predicate Name: get_score
% Description: Get the score for a specific category.
% Parameters:
%   - CategoryNum: Index of the category to score.
%   - Dice: List of dice values.
%   - Score: Calculated score for the category.
% Algorithm:
%   - Calculate the score for the given category.
% Reference: None
% *********************************************************************
get_score(CategoryNum, Dice, Score) :-
    calculate_score(CategoryNum, Dice, Score).




% *********************************************************************
% Predicate Name: prompt_category
% Description: Prompts the user to enter a category number to score.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - Dice: List of dice values.
%   - AvailableIndices: List of available category indices.
%   - RoundNum: Current round number.
%   - PlayerID: ID of the current player.
%   - NewScorecard: Updated Scorecard after scoring a category.
% Algorithm:
%   - Ask the user to enter a category number.
%   - Validate the input and update the Scorecard.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: is_scorecard_full
% Description: Checks if the scorecard is full.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Check if all categories are set.
% Reference: None
% *********************************************************************
is_scorecard_full(Scorecard) :-
    \+ (between(1, 12, CategoryNum), \+ is_category_set(Scorecard, CategoryNum)).




% *********************************************************************
% Predicate Name: calculate_sum
% Description: Calculate the sum of a list of numbers.
% Parameters:
%   - List: List of numbers to sum.
%   - Total: Sum of the numbers.
% Algorithm:
%   - Base case: If the list is empty, the sum is 0.
%   - Calculate the sum of the rest of the list and add the head.
% Reference: None
% *********************************************************************
calculate_sum([], 0).
calculate_sum([H|T], Total) :-
    calculate_sum(T, SumRest),
    Total is H + SumRest.


% *********************************************************************
% Predicate Name: player_with_highest_score
% Description: Find the player with the highest score.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - PlayerID: ID of the player with the highest score.
% Algorithm:
%   - Calculate the total score for each player.
%   - Compare the total scores and return the player with the highest score.
% Reference: None
% *********************************************************************
player_with_lowest_score(Scorecard, PlayerID) :-
    calculate_total_score(Scorecard, 1, HumanScore),
    calculate_total_score(Scorecard, 2, ComputerScore),
    (HumanScore < ComputerScore -> PlayerID = 1; PlayerID = 2).



% *********************************************************************
% Predicate Name: calculate_total_score
% Description: Calculate the total score for a player.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - PlayerID: ID of the player to calculate the score for.
%   - TotalScore: Total score for the player.
% Algorithm:
%   - Find all scores for the player.
%   - Calculate the sum of the scores.
% Reference: None
% *********************************************************************
calculate_total_score(Scorecard, PlayerID, TotalScore) :-
    findall(Score, (member([_, Score, Player, _], Scorecard), Player = PlayerID), Scores),
    calculate_sum(Scores, TotalScore).




% *********************************************************************
% Predicate Name: get_scores_for_categories
% Description: Get the scores for a list of categories.
% Parameters:
%   - Categories: List of category numbers.
%   - Dice: List of dice values.
%   - Scores: List of scores for the categories.
% Algorithm:
%   - Base case: If the list of categories is empty, return an empty list.
%   - Get the score for the first category and recur with the rest of the list.
% Reference: None
% *********************************************************************
get_scores_for_categories([], _, []).
get_scores_for_categories([CategoryNum|RestCategories], Dice, [Score|RestScores]) :-
    get_score(CategoryNum, Dice, Score),
    get_scores_for_categories(RestCategories, Dice, RestScores).



% *********************************************************************
% Predicate Name: is_lower_section_full
% Description: Checks if the lower section of the scorecard is full.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Define the lower section categories.
%   - Check if all lower section scores are non-zero.
% Reference: None
% *********************************************************************
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


% *********************************************************************
% Predicate Name: is_upper_section_full
% Description: Checks if the upper section of the scorecard is full.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
% Algorithm:
%   - Define the upper section categories.
%   - Check if all upper section scores are non-zero.
% Reference: None
% *********************************************************************
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


% *********************************************************************
% Predicate Name: is_category_filled
% Description: Checks if a category is filled in the scorecard.
% Parameters:
%   - Scorecard: List of rows in the scorecard.
%   - CategoryNum: Index of the category to check.
% Algorithm:
%   - Base case: If the list is empty, return false.
%   - If the score for the category is non-zero, return true.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
is_category_filled([[_, Score, _, _] | _], 1) :-
    Score \= 0.
is_category_filled([_ | Rest], CategoryNum) :-
    CategoryNum > 1,
    NextCategoryNum is CategoryNum - 1,
    is_category_filled(Rest, NextCategoryNum).
is_category_filled([[_, 0, _, _] | _], 1) :-
    false.



% *********************************************************************
% Predicate Name: isFourSequential
% Description: Checks if there are four sequential dice values in the list.
% Parameters:
%   - Dice: List of dice values.
%   - FourSequential: List of four sequential dice values.
% Algorithm:
%   - Remove duplicates from the list.
%   - Sort the list.
%   - Find four sequential dice values in the sorted list.
% Reference: None
% *********************************************************************
isFourSequential(Dice, FourSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findFourSequential(SortedDice, FourSequential).



% *********************************************************************
% Predicate Name: findFourSequential
% Description: Finds four sequential dice values in a sorted list.
% Parameters:
%   - SortedDice: Sorted list of dice values.
%   - FourSequential: List of four sequential dice values.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the first four elements are sequential, return them.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
findFourSequential([A, B, C, D | _], [A, B, C, D]) :-
    B =:= A + 1,
    C =:= B + 1,
    D =:= C + 1.
findFourSequential([_ | T], FourSequential) :-
    findFourSequential(T, FourSequential).




% *********************************************************************
% Predicate Name: findIndicesOfSequence
% Description: Finds the indices of a sequence in a list.
% Parameters:
%   - Dice: List of dice values.
%   - Sequence: Sequence of dice values to find.
%   - Indices: List of indices of the sequence in the list.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the head of the sequence, find the indices of the rest of the sequence.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
findIndicesOfSequence(Dice, Sequence, Indices) :-
    findIndicesHelper(Dice, Sequence, 1, Indices).



% *********************************************************************
% Predicate Name: findIndicesHelper
% Description: Helper predicate to find the indices of a sequence in a list.
% Parameters:
%   - Dice: List of dice values.
%   - Sequence: Sequence of dice values to find.
%   - CurrentIndex: Current index in the list.
%   - Indices: List of indices of the sequence in the list.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the head of the sequence, find the indices of the rest of the sequence.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
findIndicesHelper(_, [], _, []).
findIndicesHelper([H | T], [H | SeqT], CurrentIndex, [CurrentIndex | Indices]) :-
    NextIndex is CurrentIndex + 1,
    findIndicesHelper(T, SeqT, NextIndex, Indices).
findIndicesHelper([_ | T], Sequence, CurrentIndex, Indices) :-
    NextIndex is CurrentIndex + 1,
    findIndicesHelper(T, Sequence, NextIndex, Indices).


% *********************************************************************
% Predicate Name: isThreeSequential
% Description: Checks if there are three sequential dice values in the list.
% Parameters:
%   - Dice: List of dice values.
%   - ThreeSequential: List of three sequential dice values.
% Algorithm:
%   - Remove duplicates from the list.
%   - Sort the list.
%   - Find three sequential dice values in the sorted list.
% Reference: None
% *********************************************************************
isThreeSequential(Dice, ThreeSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findThreeSequential(SortedDice, ThreeSequential).



% *********************************************************************
% Predicate Name: findThreeSequential
% Description: Finds three sequential dice values in a sorted list.
% Parameters:
%   - SortedDice: Sorted list of dice values.
%   - ThreeSequential: List of three sequential dice values.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the first three elements are sequential, return them.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
findThreeSequential([A, B, C | _], [A, B, C]) :-
    B =:= A + 1,
    C =:= B + 1.
findThreeSequential([_ | T], ThreeSequential) :-
    findThreeSequential(T, ThreeSequential).



% *********************************************************************
% Predicate Name: isTwoSequential
% Description: Checks if there are two sequential dice values in the list.
% Parameters:
%   - Dice: List of dice values.
%   - TwoSequential: List of two sequential dice values.
% Algorithm:
%   - Remove duplicates from the list.
%   - Sort the list.
%   - Find two sequential dice values in the sorted list.
% Reference: None
% *********************************************************************
isTwoSequential(Dice, TwoSequential) :-
    remove_duplicates(Dice, UniqueDice),
    sort(UniqueDice, SortedDice),
    findTwoSequential(SortedDice, TwoSequential).



% *********************************************************************
% Predicate Name: findTwoSequential
% Description: Finds two sequential dice values in a sorted list.
% Parameters:
%   - SortedDice: Sorted list of dice values.
%   - TwoSequential: List of two sequential dice values.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the first two elements are sequential, return them.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
findTwoSequential([A, B | _], [A, B]) :-
    B =:= A + 1.
findTwoSequential([_ | T], TwoSequential) :-
    findTwoSequential(T, TwoSequential).




% *********************************************************************
% Predicate Name: checkUniqueAmongPairs
% Description: Checks if a value is unique among two distinct pairs.
% Parameters:
%   - Dice: List of dice values.
%   - UniqueIndex: Index of the unique value.
% Algorithm:
%   - Collect pairs of dice values.
%   - Ensure there are exactly two distinct pairs.
%   - Find the index of the unique value among the pairs.
% Reference: None
% *********************************************************************
checkUniqueAmongPairs(Dice, UniqueIndex) :-
    collectPairs(Dice, Pairs),
    length(Pairs, 2),  % Ensure there are exactly two distinct pairs.
    Pairs = [Pair1, Pair2],
    uniqueIndexAmongPairs(Dice, Pair1, Pair2, 1, UniqueIndex).



% *********************************************************************
% Predicate Name: collectPairs
% Description: Collects pairs of dice values from a list of dice.
% Parameters:
%   - Dice: List of dice values.
%   - Pairs: List of pairs of dice values.
% Algorithm:
%   - Find all values with exactly two occurrences.
%   - Collect the first two occurrences of each value.
% Reference: None
% *********************************************************************
collectPairs(Dice, Pairs) :-
    collectPairsHelper(Dice, Dice, [], Pairs).


% *********************************************************************
% Predicate Name: collectPairsHelper
% Description: Helper predicate to collect pairs from a list of dice.
% Parameters:
%   - Dice: List of dice values.
%   - FullList: Full list of dice values.
%   - Seen: List of dice values already seen.
%   - Pairs: List of pairs of dice values.
% Algorithm:
%   - Base case: If the list is empty, return the list of pairs.
%   - If the head of the list has exactly two occurrences and has not been seen before, add it to the list of pairs.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
collectPairsHelper([], _, Pairs, Pairs).
collectPairsHelper([H | T], FullList, Seen, Pairs) :-
    count_occurrences(H, FullList, Count),
    Count =:= 2, \+ member(H, Seen),
    collectPairsHelper(T, FullList, [H | Seen], Pairs).
collectPairsHelper([_ | T], FullList, Seen, Pairs) :-
    collectPairsHelper(T, FullList, Seen, Pairs).


% *********************************************************************
% Predicate Name: uniqueIndexAmongPairs
% Description: Finds the index of a unique element among two distinct pairs.
% Parameters:
%   - Dice: List of dice values.
%   - Pair1: First pair of dice values.
%   - Pair2: Second pair of dice values.
%   - Index: Current index in the list.
%   - UniqueIndex: Index of the unique element.
% Algorithm:
%   - Base case: If the list is empty, return -1.
%   - If the head of the list is not in either pair, it is unique.
% Reference: None
% *********************************************************************
uniqueIndexAmongPairs([], _, _, _, -1).  % Base case: no unique element found.
uniqueIndexAmongPairs([H | _T], Pair1, Pair2, Index, UniqueIndex) :-
    H \= Pair1,
    H \= Pair2,
    UniqueIndex = Index.
uniqueIndexAmongPairs([_ | T], Pair1, Pair2, Index, UniqueIndex) :-
    NextIndex is Index + 1,
    uniqueIndexAmongPairs(T, Pair1, Pair2, NextIndex, UniqueIndex).



% *********************************************************************
% Predicate Name: remove_duplicates
% Description: Removes duplicate elements from a list.
% Parameters:
%   - List: List to remove duplicates from.
%   - Result: List with duplicates removed.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list is not in the tail, keep it.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
remove_duplicates([], []).
remove_duplicates([H | T], [H | Result]) :-
    \+ member(H, T),
    remove_duplicates(T, Result).
remove_duplicates([_ | T], Result) :-
    remove_duplicates(T, Result).



% *********************************************************************
% Predicate Name: count_occurrences
% Description: Counts the occurrences of an element in a list.
% Parameters:
%   - Elem: Element to count.
%   - List: List to search.
%   - Count: Number of occurrences of the element.
% Algorithm:
%   - Base case: If the list is empty, return 0.
%   - If the head of the list matches the element, increment the count.
%   - Recur with the rest of the list.
% Reference: None
% *********************************************************************
count_occurrences(_, [], 0).
count_occurrences(Elem, [Elem | T], Count) :-
    count_occurrences(Elem, T, SubCount),
    Count is SubCount + 1.
count_occurrences(Elem, [_ | T], Count) :-
    count_occurrences(Elem, T, Count).




% *********************************************************************
% Predicate Name: kept_indices_checker
% Description: Checks if the indices in list1 are kept in list2.
% Parameters:
%   - List1: List of indices to check.
%   - List2: List of indices to check against.
% Algorithm:
%   - Base case: If the first list is empty, return true.
%   - If the first element of list1 is found in list2, continue checking the rest of list1.
% Reference: None
% *********************************************************************
kept_indices_checker([], _).
% Recursive case: If the first element of list1 is found in list2, continue checking the rest of list1.
kept_indices_checker([H | T], List2) :-
    member(H, List2),  % Check that H is a member of List2.
    kept_indices_checker(T, List2).  % Recur with the rest of list1.



% *********************************************************************
% Predicate Name: custom_remove
% Description: Removes elements from a list.
% Parameters:
%   - List: List to remove elements from.
%   - ItemsToRemove: List of elements to remove.
%   - NewList: List with elements removed.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list is in ItemsToRemove, skip it.
%   - If the head of the list is not in ItemsToRemove, keep it.
% Reference: None
% *********************************************************************
custom_remove([], _, []). 
custom_remove([H | T], ItemsToRemove, NewList) :-
    member(H, ItemsToRemove),  % If H is in ItemsToRemove, skip it
    custom_remove(T, ItemsToRemove, NewList).
custom_remove([H | T], ItemsToRemove, [H | NewList]) :-
    \+ member(H, ItemsToRemove),  % If H is not in ItemsToRemove, keep it
    custom_remove(T, ItemsToRemove, NewList).




% *********************************************************************
% Predicate Name: giveFourOfaKindIndices
% Description: Finds the indices of dice that form a four of a kind.
% Parameters:
%   - Dice: List of dice values.
%   - FourOfAKindIndices: List of indices of dice that form a four of a kind.
% Algorithm:
%   - Find all values with exactly four occurrences.
%   - Find the first four indices of the value.
% Reference: None
% *********************************************************************
giveFourOfaKindIndices(Dice, FourOfAKindIndices) :-
    findMatchingIndices(Dice, 4, FourOfAKindIndices).



% *********************************************************************
% Predicate Name: giveThreeOfaKindIndices
% Description: Finds the indices of dice that form a three of a kind.
% Parameters:
%   - Dice: List of dice values.
%   - ThreeOfAKindIndices: List of indices of dice that form a three of a kind.
% Algorithm:
%   - Find all values with exactly three occurrences.
%   - Find the first three indices of the value.
% Reference: None
% *********************************************************************
giveThreeOfaKindIndices(Dice, ThreeOfAKindIndices) :-
    findMatchingIndices(Dice, 3, ThreeOfAKindIndices).


% *********************************************************************
% Predicate Name: giveTwoOfaKindIndices
% Description: Finds the indices of dice that form a two of a kind.
% Parameters:
%   - Dice: List of dice values.
%   - TwoOfAKindIndices: List of indices of dice that form a two of a kind.
% Algorithm:
%   - Find all values with exactly two occurrences.
%   - Find the first two indices of the value.
% Reference: None
% *********************************************************************
giveTwoOfaKindIndices(Dice, TwoOfAKindIndices) :-
    findMatchingIndices(Dice, 2, TwoOfAKindIndices).

% *********************************************************************
% Predicate Name: giveTwoOfaKindOrFourIndices
% Description: Finds the indices of dice that form a two of a kind or a four of a kind.
% Parameters:
%   - Dice: List of dice values.
%   - TwoOfAKindIndices: List of indices of dice that form a two of a kind.
% Algorithm:
%   - Find all values with at least two occurrences.
%   - Take the first value with at least two occurrences.
%   - Find the first two indices of the value.
% Reference: None
% *********************************************************************
giveTwoOfaKindOrFourIndices(Dice, TwoOfAKindIndices) :-
    findall(Value, (
        member(Value, Dice),                   % Iterate over each value in Dice
        include(=(Value), Dice, Matches),      % Collect all matches for that value
        length(Matches, Count),
        Count >= 2                             % Ensure at least two occurrences
    ), TwoOfAKindCandidates),                  % Collect all values with at least two occurrences
    TwoOfAKindCandidates = [FirstTwoOfAKind | _], % Take the first value with at least two occurrences
    findIndicess(FirstTwoOfAKind, Dice, 1, AllIndices),
    length(TwoOfAKindIndices, 2),             % Ensure exactly two indices are returned
    append(TwoOfAKindIndices, _, AllIndices). % Get the first two indices of the value
giveTwoOfaKindOrFourIndices(_, []).



% *********************************************************************
% Predicate Name: findIndicess
% Description: Finds the indices of a value in a list.
% Parameters:
%   - Value: Value to find indices of.
%   - List: List to find indices in.
%   - Index: Current index in the list.
%   - Indices: List of indices of the value.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the value, add its index to the list.
%   - If the head of the list does not match the value, skip it.
% Reference: None
% *********************************************************************
findIndicess(_, [], _, []).  % Base case: empty Dice, no indices.
findIndicess(Value, [Value | Rest], Index, [Index | Indices]) :-
    NextIndex is Index + 1,
    findIndicess(Value, Rest, NextIndex, Indices).
findIndicess(Value, [_ | Rest], Index, Indices) :-
    NextIndex is Index + 1,
    findIndicess(Value, Rest, NextIndex, Indices).




% *********************************************************************
% Predicate Name: findMatchingIndices
% Description: Finds the indices of dice values that match a specific count.
% Parameters:
%   - Dice: List of dice values.
%   - MatchCount: Number of occurrences to match.
%   - MatchingIndices: List of indices of dice values that match the count.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the required count, add its indices to the list.
%   - If the head of the list does not match the required count, skip it.
% Reference: None
% *********************************************************************
findMatchingIndices(Dice, MatchCount, MatchingIndices) :-
    findMatchingIndicesHelper(Dice, Dice, MatchCount, [], MatchingIndices).


% *********************************************************************
% Predicate Name: findMatchingIndicesHelper
% Description: Finds the indices of dice values that match a specific count.
% Parameters:
%   - Dice: List of dice values.
%   - MatchCount: Number of occurrences to match.
%   - MatchingIndices: List of indices of dice values that match the count.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the required count, add its indices to the list.
%   - If the head of the list does not match the required count, skip it.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: countOccurrences
% Description: Counts the occurrences of a value in a list.
% Parameters:
%   - Value: Value to count occurrences of.
%   - List: List to count occurrences in.
%   - Count: Number of occurrences of the value.
% Algorithm:
%   - Base case: If the list is empty, return 0.
%   - If the head of the list matches the value, increment the count.
%   - If the head of the list does not match the value, skip it.
% Reference: None
% *********************************************************************
countOccurrences(_, [], 0).  % Base case: empty list.
countOccurrences(Value, [Value | Rest], Count) :-
    countOccurrences(Value, Rest, SubCount),
    Count is SubCount + 1.
countOccurrences(Value, [_ | Rest], Count) :-
    countOccurrences(Value, Rest, Count).



% *********************************************************************
% Predicate Name: collect_first_n
% Description: Collects the first N elements from a list.
% Parameters:
%   - List: List to collect elements from.
%   - N: Number of elements to collect.
%   - Collected: List of collected elements.
% Algorithm:
%   - Base case: If the list is empty or N is 0,, return an empty list.
%   - If N is greater than 0, collect the first element and recur with N-1.
% Reference: None
% *********************************************************************
collect_first_n(_, 0, []).  % Base case: collected required number of elements
collect_first_n([], _, []).  % Base case: no more elements to collect
collect_first_n([H | T], N, [H | Collected]) :-
    N1 is N - 1,
    collect_first_n(T, N1, Collected).



% *********************************************************************
% Predicate Name: findIndices
% Description: Finds the indices of a value in a list.
% Parameters:
%   - Value: Value to find indices of.
%   - List: List to find indices in.
%   - Index: Current index in the list.
%   - Indices: List of indices of the value.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the value, add its index to the list.
%   - If the head of the list does not match the value, skip it.
% Reference: None
% *********************************************************************
findIndices(_, [], _, []).  % Base case: empty list.
findIndices(Value, [Value | Rest], Index, [Index | Indices]) :-
    NextIndex is Index + 1,
    findIndices(Value, Rest, NextIndex, Indices).
findIndices(Value, [_ | Rest], Index, Indices) :-
    NextIndex is Index + 1,
    findIndices(Value, Rest, NextIndex, Indices).


% *********************************************************************
% Predicate Name: removeValue
% Description: Removes a specific value from a list.
% Parameters:
%   - Value: Value to remove.
%   - List: List to remove the value from.
%   - RemainingDice: List with the value removed.
% Algorithm:
%   - Base case: If the list is empty, return an empty list.
%   - If the head of the list matches the value, skip it.
%   - If the head of the list does not match the value, keep it.
% Reference: None
% *********************************************************************
removeValue(_, [], []).  % Base case: empty list.
removeValue(Value, [Value | Rest], RemainingDice) :-
    removeValue(Value, Rest, RemainingDice).
removeValue(Value, [H | Rest], [H | RemainingDice]) :-
    removeValue(Value, Rest, RemainingDice).



% *********************************************************************
% Predicate Name: find_all_indices
% Description: Finds all indices of a value in a list.
% Parameters:
%   - DiceValues: List of dice values.
%   - Val: Value to find indices of.
%   - Indices: List of indices of the value.
% Algorithm:
%   - Iterate over each element in DiceValues.
%   - If the element matches the value, add its index to the list.
% Reference: None
% *********************************************************************
find_all_indices(_, [], []).
find_all_indices(DiceValues, [Val|Vals], [Index|Indices]) :-
    nth1(Index, DiceValues, Val), !,
    find_all_indices(DiceValues, Vals, Indices).
find_all_indices(DiceValues, [_|Vals], Indices) :-
    find_all_indices(DiceValues, Vals, Indices).


% *********************************************************************
% Predicate Name: find_dice_values
% Description: Finds the values of dice at specific indices.
% Parameters:
%   - DiceVals: List of dice values.
%   - Indices: List of indices to find values at.
%   - ReturnVal: List of values at the given indices.
% Algorithm:
%   - Iterate over each index in Indices.
%   - Find the value at the given index in DiceVals.
% Reference: None
% *********************************************************************
find_dice_values(DiceVals, Indices, ReturnVal) :-
    findall(Value, (
        member(Index, Indices),     % Iterate over each index in Indices
        nth1(Index, DiceVals, Value)  % Get the value at the given index
    ), ReturnVal).


% *********************************************************************
% Predicate Name: find_category_name
% Description: Finds the name of a category based on its number.
% Parameters:
%   - CategoryNum: Number of the category.
%   - CategoryName: Name of the category.
% Algorithm:
%   - Define a scorecard with category numbers and names.
%   - Find the category name based on the category number.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: find_potential_categories
% Description: Finds the potential categories to score based on dice values and roll count.
% Parameters:
%   - DiceValues: List of dice values.
%   - Scorecard: List of rows in the scorecard.
%   - RollCount: Number of rolls made in the current turn.
%   - PotentialCategoryList: List of potential categories to score.
% Algorithm:
%   - Based on the roll count, find potential categories to score.
%   - Return the list of potential categories.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: display_potential_categories
% Description: Displays the potential categories based on dice values and roll count.
% Parameters:
%   - DiceValues: List of dice values.
%   - Scorecard: List of rows in the scorecard.
%   - RollCount: Number of rolls made in the current turn.
%   - PotentialCategoryList: List of potential categories to score.
% Algorithm:
%   - Find potential categories based on dice values and roll count.
%   - Display the potential categories.
% Reference: None
% *********************************************************************
display_potential_categories(DiceValues, Scorecard, RollCount, PotentialCategoryList) :-
    find_potential_categories(DiceValues, Scorecard, RollCount, PotentialCategoryList),
    nl,write("Potential Categories:"), nl,
    (   PotentialCategoryList = [] ->
        write("No potential categories available."), nl
    ;   forall(member(Category, PotentialCategoryList),
            format("- ~w~n", [Category]))
    ),nl,nl.



% *********************************************************************
% Predicate Name: find_wildcard_index
% Description: Finds the index of the wildcard in a list of dice values.
% Parameters:
%   - DiceVals: List of dice values.
%   - WildcardIndex: Index of the wildcard in DiceVals.
% Algorithm:
%   - Define all valid patterns with their wildcard indices.
%   - Check if any pattern matches DiceVals.
% Reference: None
% *********************************************************************
find_wildcard_index(DiceVals, WildcardIndex) :-
    % Define all valid patterns with their wildcard indices
    Patterns = [
        ([1, 2, 3, _, 5], 4),
        ([2, _, 3, 4, 5], 2),
        ([3, 4, 5, _, 6], 4)
    ],
    % Check if any pattern matches DiceVals
    member((Pattern, WildcardIndex), Patterns),
    matches_pattern(DiceVals, Pattern).


% *********************************************************************
% Predicate Name: matches_pattern
% Description: Checks if a list of dice values matches a given pattern.
% Parameters:
%   - Dice: List of dice values.
%   - Pattern: Pattern to match against.
% Algorithm:
%   - Base case: If both lists are empty, they match.
%   - If the pattern element is a variable (_), match any value.
%   - Otherwise, ensure exact match.
% Reference: None
% *********************************************************************
matches_pattern([], []).
matches_pattern([D | RestDice], [P | RestPattern]) :-
    (   var(P) -> true  % If pattern element is a variable (_), match any value
    ;   D =:= P         % Otherwise, ensure exact match
    ),
    matches_pattern(RestDice, RestPattern).




