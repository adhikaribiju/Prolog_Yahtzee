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


computer_turn(Scorecard, RoundNum, NewScorecard) :-
    PlayerID is 2,
    format("Computer Turn:"), nl,
    format("Round: ~d~n", [RoundNum]),
    display_scorecard(Scorecard),
    roll_dice(DiceValues),
    play_computer_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard)
    .


% Manage the turn flow with rerolls and scoring
play_computer_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    display_available_combinations(DiceValues, Scorecard), nl,
    availableCombinations(DiceValues, AvailableCategories), nl,
    (   RerollCount < 2
    ->  ask_roll_or_stand(Decision),
        handle_computer_decision(Decision, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard)
    ;   format("No rerolls left. Standing automatically.~n"),
        PlayerID is 2,
        ask_category_to_score(Scorecard, DiceValues, RoundNum, PlayerID, NewScorecard)
    ).

% Handle player's decision to roll or stand
handle_computer_decision("roll", DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard) :-
    ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices),
    reroll_dice(DiceValues, RerollIndices, UpdatedDice),
    display_dice(UpdatedDice),
    format("Kept Indices: ~w~n", [KeptIndices]),
    format("Reroll Indices: ~w~n", [RerollIndices]),
    length(DiceValues, NumDice),
    numlist(1, NumDice, AllIndices),
    subtract(AllIndices, RerollIndices, NewKeptIndices),
    NextRerollCount is RerollCount + 1,
    play_turn(UpdatedDice, NewKeptIndices, Scorecard, RoundNum, NextRerollCount, NewScorecard).
handle_computer_decision("stand", DiceValues, _, Scorecard, RoundNum, _, AvailableCategories, NewScorecard) :-
    (   AvailableCategories \= []
    ->  PlayerID is 2,
        ask_category_to_score(Scorecard, DiceValues, RoundNum, PlayerID, NewScorecard)
    ;   format("No available categories to score. Skipping turn.~n"),
        NewScorecard = Scorecard
    ).

% Roll initial dice values
roll_dice(DiceValues) :-
    get_yes_no_input(Response),
    ( Response = "Y" -> 
        get_manual_dice(5, DiceValues)
    ; 
        generate_random_dice(5, DiceValues)
    ),
    display_dice(DiceValues).

% Reroll the dice
reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    length(DiceValues, NumDice),
    numlist(1, NumDice, AllIndices),
    subtract(AllIndices, RerollIndices, KeptIndices),
    ask_reroll_method(Method),
    (   Method = "R" -> randomly_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues)
    ;   Method = "M" -> manually_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues)
    ).

% Random reroll
randomly_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    length(RerollIndices, NumReroll),
    roll_specific_dice(NumReroll, NewValues),
    replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).

% Manual reroll
manually_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    maplist(read_die_value, RerollIndices, NewValues),
    replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).

% Generate random dice values
generate_random_dice(0, []) :- !.
generate_random_dice(N, [Value | Rest]) :-
    random_between(1, 6, Value),
    N1 is N - 1,
    generate_random_dice(N1, Rest).

% Replace values at specific indices
replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues) :-
    replace_indices_helper(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).

replace_indices_helper(DiceValues, [], [], DiceValues).
replace_indices_helper(DiceValues, [Index|RerollRest], [Value|ValueRest], UpdatedDiceValues) :-
    nth1(Index, DiceValues, _, TempDiceValues),
    nth1(Index, TempUpdatedDiceValues, Value, TempDiceValues),
    replace_indices_helper(TempUpdatedDiceValues, RerollRest, ValueRest, UpdatedDiceValues).

% Ask the user if they want to reroll manually or randomly
ask_reroll_method(Method) :-
    format("Do you want to reroll manually (M) or randomly (R)? "),
    read_line_to_string(user_input, Input),
    (   member(Input, ["M", "R"]) -> Method = Input
    ;   format("Invalid input. Try again.~n"),
        ask_reroll_method(Method)
    ).

% Read a new value for a die
read_die_value(Index, Value) :-
    format("Enter new value for die at position ~d (1-6): ", [Index]),
    read_line_to_string(user_input, Input),
    atom_number(Input, Value),
    (   between(1, 6, Value) -> true
    ;   format("Invalid value. Try again.~n"),
        read_die_value(Index, Value)
    ).

% Ask if the player wants to roll again or stand
ask_roll_or_stand(Decision) :-
    format("Do you want to roll again or stand? (R/S): "),
    read_line_to_string(user_input, Input),
    (   Input = "R" -> Decision = "roll"
    ;   Input = "S" -> Decision = "stand"
    ;   format("Invalid input. Try again.~n"),
        ask_roll_or_stand(Decision)
    ).


roll_specific_dice(0, []) :- !.
roll_specific_dice(N, [Value | Rest]) :-
    random_between(1, 6, Value),
    N1 is N - 1,
    roll_specific_dice(N1, Rest).


    % Ask which dice values to reroll, ensuring kept dice are not rerolled
    ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices) :-
        format("Current dice: ~w~n", [DiceValues]),
        write("Enter the values of the dice you want to reroll, separated by commas (e.g., 5,4): "),
        read_line_to_string(user_input, Input),
        split_string(Input, ",", " ", StringValues),
        maplist(atom_number, StringValues, DicesToReroll),
        format("Reroll values: ~w~n", [DicesToReroll]),
        
        OriginalKeptIndices = KeptIndices,
        OriginalDiceValues = DiceValues,
        (   find_dices_to_reroll_indices(DiceValues, DicesToReroll, KeptIndices, [], RerollIndices)
        ->  true
        ;   format("Invalid reroll selection. Try again.~n"),
            ask_reroll_dice_indices(OriginalDiceValues, OriginalKeptIndices, RerollIndices)
        )
        .

    % Function to calculate indices of dice to reroll, ensuring kept dice are not rerolled
    find_dices_to_reroll_indices(DiceValues, DicesToReroll, KeptIndices, CurrentRerollIndices, DicesToRerollInd) :-
        find_dices_to_reroll_indices_helper(DiceValues, DicesToReroll, KeptIndices, CurrentRerollIndices, DicesToRerollInd).

    % Helper function with accumulator, ensuring kept dice are not rerolled
    find_dices_to_reroll_indices_helper(_, [], _, Acc, Acc). % Base case: No more values to match
    find_dices_to_reroll_indices_helper(DiceValues, [Reroll|Rest], KeptIndices, Acc, DicesToRerollInd) :-
        % tempKeptIndices = KeptIndices,
        % tempDicesToRerollInd = DicesToRerollInd,
        (   nth1(Index, DiceValues, Reroll), \+ member(Index, Acc), \+ member(Index, KeptIndices)
        ->  find_dices_to_reroll_indices_helper(DiceValues, Rest, KeptIndices, [Index|Acc], DicesToRerollInd)
        ;   (   nth1(Index, DiceValues, Reroll), member(Index, KeptIndices)
            ->  format("Dice already kept, and can't be rerolled.~n"),
                format("Kept Indices: ~w~n", [KeptIndices]),
                format("Dices to Reroll: ~w~n", [DicesToReroll]),
                false
            ;   true
            ),
            find_dices_to_reroll_indices_helper(DiceValues, Rest, KeptIndices, Acc, DicesToRerollInd)
        ). % Recursively process the rest




%%______________________________MAIN CODE STATS HERE____________________________________________________________%%






% Find the highest scoreable availble category in the given dice and scorecard.
computer_turn_test(Scorecard, RoundNum, NewScorecard) :-
    PlayerID is 2,
    format("Computer Turn:"), nl,
    format("Round: ~d~n", [RoundNum]),
    display_scorecard(Scorecard),
    roll_dice(DiceValues),
    (   play_computer_turn_test(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard)
    ->  format("New Scorecard____: ~w~n", [NewScorecard])
    ;   format("Error: Failed to compute a valid turn.~n"),
        format("ani New Scorecard____: ~w~n", [NewScorecard])
    )
    
    .

play_computer_turn_test(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    NewRerollCount is RerollCount + 1,
    format("Reroll Count: ~w~n", [NewRerollCount]),
    display_available_combinations(DiceValues, Scorecard), nl,
    availableCombinations(DiceValues, AvailableCategories), nl,
    (   RerollCount < 2
    ->  %ask_roll_or_stand(Decision),
        make_computer_decision_test(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, UpdatedScorecard, NewKeptIndices),
        format("Scored Category: ~w~n", [CategoryScored]),
        format("Scorecard: ~w~n", [NewScorecard]),
        NewScorecard = UpdatedScorecard,
         ( CategoryScored = 0
            ->  play_computer_turn_test(NewDiceValues, NewKeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard)
         ;   true  % Exit recursion when a category is scored
        )
    ;   format("No rerolls left. Standing automatically.~n"),
        % Mero Notes:::
        % You will need to change this, score the highest available category, 
        %(if nothing is available, write(Nothing available to score, skipping turn.))
        format("I neeed to implement the way to score the highest!~n"),
        PlayerID is 2,
        (CategoriesAvailableToScore \= [] ->
        find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestPosibleCategory),
        format("Highest Possible Category: ~w~n", [HighestPosibleCategory]),
        update_scorecard(Scorecard, HighestPosibleCategory, DiceValues, RoundNum, 2, NewScorecard),
        CategoryScored is HighestPosibleCategory,
        display_msg(CategoryScored)
        ;   format("No available categories to score. Skipping turn.~n"),
            NewScorecard = Scorecard
        )
    ).


make_computer_decision_test(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount,NewDiceValues, UpdatedScorecard, NewKeptIndices) :-
    
    % check if low section is full
    % if it is full, call try_score_upper_section

    CategoryScored is 0, % default value
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    format("Categories Available to Score: ~w~n", [CategoriesAvailableToScore]),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore), nl,
    format("Scores of Categories Available to Score: ~w~n", [ScoresOfCategoriesAvailableToScore]), nl,


(   is_lower_section_full(Scorecard)
    ->  format("Lower section is full. Checking the upper section...~n"),
        (   is_upper_section_full(Scorecard)
        ->  format("Both sections are full. Skipping turn.~n"),
            % If the scorecard is full, no scoring possible
            NewScorecard = Scorecard,
            NewDiceValues = DiceValues,
            NewKeptIndices = KeptIndices
        ;   format("Trying to fill the upper section...~n"),
            % Attempt to fill the upper section
            try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDice, NewScorecard, NewKeptIndices)
        )
    ;   % Lower section not full, try filling it
        format("Trying to fill the lower section...~n"),
        try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDice, NewScorecard, NewKeptIndices),
        UpdatedScorecard = NewScorecard,
        format("la yo? Scorecard: ~w~n", [UpdatedScorecard])
    ),

    format("Ma eta chu" ),nl



    % find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestPosibleCategory),
    % format("Highest Possible Category: ~w~n", [HighestPosibleCategory]),
    % update_scorecard(Scorecard, HighestPosibleCategory, DiceValues, RoundNum, 2, NewScorecard),
    % CategoryScored is HighestPosibleCategory,
    % display_msg(CategoryScored)

    .


% Base case: When there's only one category and one score, the result is the category.
find_highest_category([Category], [Score], Category).

% Recursive case: Compare the first score with the maximum score in the rest of the list.
find_highest_category([Category1 | Categories], [Score1 | Scores], ResultCategory) :-
    find_highest_category(Categories, Scores, TempCategory),
    nth0(Index, Categories, TempCategory),
    nth0(Index, Scores, TempScore),
    (Score1 >= TempScore ->
        ResultCategory = Category1;
        ResultCategory = TempCategory).


display_msg(CategoryScored) :-
    format("Computer decided to score on Category No: : ~w~n", [CategoryScored]).


try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount,NewDiceValues, NewScorecard, NewKeptIndices) :-


    .


try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount,NewDiceValues, NewScorecard, NewKeptIndices) :-
    format("MujiI am here"), nl,
    ( \+ is_category_filled(Scorecard, 12) ->
        format("I am here"), nl,
        (hasYahtzee(DiceValues) ->
            % Yahtzee is Available to score, score it.
            update_scorecard(Scorecard, 12, DiceValues, RoundNum, 2, NewScorecard),
            format("+++New Scorecard: ~w~n", [NewScorecard]),
            CategoryScored is 12,
            NewDiceValues = DiceValues,
            NewKeptIndices = KeptIndices,
            %exit
            true
        ; % else
            giveFourOfaKindIndices(DiceValues, indicesToKeep),
        % try to get Yahtzee 
            ( hasFourOfAKind(DiceValues), kept_indices_checker(KeptIndices, indicesToKeep) ->
                % reroll the odd dice to get Yahtzee
                custom_remove([1,2,3,4,5], indicesToKeep, indicesToReroll),
                reroll_dice(DiceValues, indicesToReroll, NewDiceValues),
                format("New Dice: ~w~n", [NewDiceValues]),
                NewKeptIndices = indicesToKeep

            )
        )   
    ;   format("No available categories to score. Skipping turn.~n"),
        NewScorecard = Scorecard
    ).
  







try_is_seqeuntial(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount,NewDiceValues, NewScorecard, NewKeptIndices) :-



    .







try :-
    compile('scorecard.pl'),
    compile('dice.pl'),
    Scorecard = [
        ["Ones", 1, 1, 1],
        ["Twos", 0, 0, 0],
        ["Threes", 0, 0, 0],
        ["Fours", 0, 0, 0],
        ["Fives", 5, 2, 1],
        ["Sixes", 0, 0, 0],
        ["Three of a Kind", 25, 2, 2],
        ["Four of a Kind", 30, 1, 2],
        ["Full House", 0, 0, 0],
        ["Four Straight", 20, 1, 3],
        ["Five Straight", 30, 2, 3],
        ["Yahtzee", 0, 0, 0]
    ],
    RoundNum is 1,
    format("Scorecard: ~w~n", [Scorecard]),
    format("Round: ~w~n", [RoundNum]),
    computer_turn_test(Scorecard, RoundNum, NewScorecard),
    format("New Scorecard____: ~w~n", [NewScorecard])
    .




% Define the main predicate
main :-
    % Define the scorecard
    Scorecard = [
        ["Ones", 1, 1, 1],
        ["Twos", 0, 0, 0],
        ["Threes", 0, 0, 0],
        ["Fours", 0, 0, 0],
        ["Fives", 5, 2, 1],
        ["Sixes", 0, 0, 0],
        ["Three of a Kind", 25, 2, 2],
        ["Four of a Kind", 30, 1, 2],
        ["Full House", 0, 0, 0],
        ["Four Straight", 20, 1, 3],
        ["Five Straight", 30, 2, 3],
        ["Yahtzee", 0, 0, 0]
    ],

    % Test the is_category_filled function
    CategoryNum = 1,
    (is_category_filled(Scorecard, CategoryNum) ->
        format("Category ~w is filled.~n", [CategoryNum]);
        format("Category ~w is not filled.~n", [CategoryNum])),

    CategoryNum2 = 2,
    (is_category_filled(Scorecard, CategoryNum2) ->
        format("Category ~w is filled.~n", [CategoryNum2]);
        format("Category ~w is not filled.~n", [CategoryNum2])),

    CategoryNum3 = 12,
    (is_category_filled(Scorecard, CategoryNum3) ->
        format("Category ~w is filled.~n", [CategoryNum3]);
        format("Category ~w is not filled.~n", [CategoryNum3])).

    

% Initialization directive
%:- initialization(try).
