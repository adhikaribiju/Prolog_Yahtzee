% human_turn
% Handles the human player's turn
% Display the scorecard and round number
% 5 Dice needs to be rolled
% ask the player to roll manually or randomly - ask_user_roll
% if the player chooses to roll manually, ask the player 5 dice values man_roll
% if the player chooses to roll randomly, generate 5 random dice values rand_roll
% display the dice values display_dice
% Main turn handler
% Main turn handler
% Human player's turn
% Main turn handler for the human player
human_turn(Scorecard, RoundNum, NewScorecard) :-
    format("Your Turn (Round ~d):~n", [RoundNum]),
    display_scorecard(Scorecard),
    roll_dice(DiceValues),
    play_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard).

% Manage the turn flow with rerolls and scoring
play_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    display_available_combinations(DiceValues, Scorecard),
    availableCombinations(DiceValues, AvailableCategories),
    (   RerollCount < 2
    ->  ask_roll_or_stand(Decision),
        handle_decision(Decision, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard)
    ;   format("No rerolls left. Standing automatically.~n"),
        ask_category_to_score(Scorecard, DiceValues, RoundNum, 1, NewScorecard)
    ).

% Handle player's decision to roll or stand
handle_decision("roll", DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard) :-
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
handle_decision("stand", DiceValues, _, Scorecard, RoundNum, _, AvailableCategories, NewScorecard) :-
    (   AvailableCategories \= []
    ->  ask_category_to_score(Scorecard, DiceValues, RoundNum, 1, NewScorecard)
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


% Human Help Functions