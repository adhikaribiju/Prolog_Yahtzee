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
    ["Aces", 0, 0, 0],
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

% main predicate to initialize and display the scorecard
scorecard :-
    initialize_scorecard(Scorecard),
    display_scorecard(Scorecard).
