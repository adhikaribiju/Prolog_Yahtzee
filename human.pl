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


% human_turn
% Handles the human player's turn
% Display the scorecard and round number
% 5 Dice needs to be rolled
% ask the player to roll manually or randomly - ask_user_roll
% if the player chooses to roll manually, ask the player 5 dice values man_roll
% if the player chooses to roll randomly, generate 5 random dice values rand_roll
% display the dice values display_dice
human_turn(Scorecard, RoundNum, NewScorecard) :-
    PlayerID is 1,
    format("Your Turn:"), nl,
    format("Round: ~d~n", [RoundNum]),
    display_scorecard(Scorecard),
    roll_dice(DiceValues),
    display_available_combinations(DiceValues, Scorecard),
    availableCombinations(DiceValues, AvailableIndices),  % Get available categories.
    (   AvailableIndices \= []  % Check if there are scoreable categories.
    ->  ask_category_to_score(Scorecard, DiceValues, RoundNum, 1 , NewScorecard)
    ;   write("Nothing to score, skipping turn."), nl
    )
    .

% display_options

