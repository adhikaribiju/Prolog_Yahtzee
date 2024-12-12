
% Predicate Name: human_turn/3
% Description:  Manages a human player's turn in a dice game.
% Parameters:
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   NewScorecard: The updated scorecard after the human player's turn.
% Algorithm:
%   1. Display the current game state (round number and scorecard).
%   2. Generate a set of random dice rolls for the player.
%   3. Allow the player to interact with the game:
%       a.  Display the dice rolls.
%       b.  Provide options for rerolling dice.
%       c.  Allow the player to choose a scoring category based on the dice values and scorecard.
%   4. Update the scorecard based on the player's choices.
% Reference: None
% *********************************************************************
human_turn(Scorecard, RoundNum, NewScorecard) :-
    nl,
    format("Your Turn~n"), nl,
    format("Round: ~d~n", [RoundNum]), nl,
    display_scorecard(Scorecard), nl,
    roll_dice(DiceValues),
    play_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard).


% Predicate Name: play_turn/6
% Description:  Handles a player's turn in a dice game, allowing for rerolls and scoring.
% Parameters:
%     DiceValues: A list of the current dice values.
%     KeptIndices: A list of indices of dice to keep (not reroll).
%     Scorecard: The current scorecard.
%     RoundNum: The current round number.
%     RerollCount: The number of times the dice have been rerolled this turn.
%     NewScorecard: The updated scorecard after the player's turn.
% Algorithm:
%   1. Display the current dice values.
%   2. If available, display a list of possible scoring combinations and potential categories to aim for.
%   3. Display the available scoring categories based on the current dice values.
%   4. Offer help to the human player (prompt_human_help/4).
%   5. If the reroll count is less than 2:
%       a. Ask the player whether they want to reroll or stand (ask_roll_or_stand/1).
%       b. Handle the player's decision (handle_decision/8) to either reroll some dice or score a category.
%   6. If the reroll count is 2 (no rerolls left):
%       a. Inform the player that they are standing automatically.
%       b. Ask the player to choose a category to score (ask_category_to_score/5).
% Reference: None
% *********************************************************************
play_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    (display_available_combinations(DiceValues, Scorecard)-> true; nl),
    (display_potential_categories(DiceValues, Scorecard, RerollCount, _)->true;nl),
    availableCombinations(DiceValues, AvailableCategories), nl,
    (prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount) -> nl; nl),
    (   RerollCount < 2
    ->  ask_roll_or_stand(Decision),
        handle_decision(Decision, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard)
    ;   format("No rerolls left. Standing automatically.~n"),
        ask_category_to_score(Scorecard, DiceValues, RoundNum, 1, NewScorecard)
    ).


% Predicate Name: handle_decision/8
% Description: Processes the player's decision to either reroll dice or stand in a dice game.
% Parameters:
%   Decision: The player's decision ("roll" or "stand").
%   DiceValues: A list of the current dice values.
%   KeptIndices: A list of indices of dice to keep (not reroll).
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   RerollCount: The number of times the dice have been rerolled this turn.
%   AvailableCategories: A list of available scoring categories.
%   NewScorecard: The updated scorecard after handling the decision.
% Algorithm:
%   1. If the decision is "roll":
%       a. Ask the player which dice to reroll (ask_reroll_dice_indices/3).
%       b. Reroll the selected dice and display the updated dice values.
%       c. Update the list of kept dice indices.
%       d. Increment the reroll count.
%       e. Recursively call play_turn/6 with the updated dice, kept indices, and reroll count.
%   2. If the decision is "stand":
%       a. If there are available categories to score:
%           i.  Ask the player to choose a category to score (ask_category_to_score/5).
%       b. If there are no available categories to score:
%           i.  Inform the player that no categories are available and skip the turn (leave the scorecard unchanged).
% Reference: None
% *********************************************************************
handle_decision("roll", DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, _AvailableCategories, NewScorecard) :-
    ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices),
    reroll_dice(DiceValues, RerollIndices, UpdatedDice),
    display_dice(UpdatedDice),
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



% *********************************************************************
% Predicate Name: reroll_dice
% Description: Rerolls the dice based on the user's selection.
% Parameters:
%   - DiceValues: Current dice values.
%   - RerollIndices: Indices of dice to reroll.
%   - UpdatedDiceValues: Updated dice values after reroll.
% Algorithm:
%   - Ask the user if they want to reroll manually or randomly.
%   - Reroll the dice based on the user's selection.
% Reference: None
% *********************************************************************
reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    ask_reroll_method(Method),
    (   Method = "R" -> randomly_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues)
    ;   Method = "M" -> manually_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues)
    ).



% *********************************************************************
% Predicate Name: randomly_reroll_dice
% Description: Rerolls the dice randomly.
% Parameters:
%   - DiceValues: Current dice values.
%   - RerollIndices: Indices of dice to reroll.
%   - UpdatedDiceValues: Updated dice values after reroll.
% Algorithm:
%   - Roll the dice randomly.
% Reference: None
% *********************************************************************
randomly_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    length(RerollIndices, NumReroll),
    roll_specific_dice(NumReroll, NewValues),
    replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).


% *********************************************************************
% Predicate Name: manually_reroll_dice
% Description: Rerolls the dice manually.
% Parameters:
%   - DiceValues: Current dice values.
%   - RerollIndices: Indices of dice to reroll.
%   - UpdatedDiceValues: Updated dice values after reroll.
% Algorithm:
%   - Ask the user for new values for the dice.
%   - Replace the dice values at the specified indices.
% Reference: None
% *********************************************************************
manually_reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    maplist(read_die_value, RerollIndices, NewValues),
    replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).


% *********************************************************************
% Predicate Name: replace_indices
% Description: Replaces the values at the specified indices.
% Parameters:
%   - DiceValues: Current dice values.
%   - RerollIndices: Indices of dice to reroll.
%   - NewValues: New values for the dice.
%   - UpdatedDiceValues: Updated dice values after reroll.
% Algorithm:
%   - Replace the values at the specified indices.
% Reference: None
% *********************************************************************
replace_indices(DiceValues, RerollIndices, NewValues, UpdatedDiceValues) :-
    replace_indices_helper(DiceValues, RerollIndices, NewValues, UpdatedDiceValues).


% *********************************************************************
% Predicate Name: replace_indices_helper
% Description: Helper predicate to replace the values at the specified indices.
% Parameters:
%   - DiceValues: Current dice values.
%   - RerollIndices: Indices of dice to reroll.
%   - NewValues: New values for the dice.
%   - UpdatedDiceValues: Updated dice values after reroll.
% Algorithm:
%   - for each index in the reroll indices, replace the value at that index.
% Reference: None
% *********************************************************************
replace_indices_helper(DiceValues, [], [], DiceValues).
replace_indices_helper(DiceValues, [Index|RerollRest], [Value|ValueRest], UpdatedDiceValues) :-
    nth1(Index, DiceValues, _, TempDiceValues),
    nth1(Index, TempUpdatedDiceValues, Value, TempDiceValues),
    replace_indices_helper(TempUpdatedDiceValues, RerollRest, ValueRest, UpdatedDiceValues).


% *********************************************************************
% Predicate Name: ask_reroll_method
% Description: Asks the user if they want to reroll manually or randomly.
% Parameters:
%   - Method: User's selection for reroll method.
% Algorithm:
%   - Ask the user if they want to reroll manually or randomly.
% Reference: None
% *********************************************************************
ask_reroll_method(Method) :-
    format("Do you want to reroll manually (M) or randomly (R)? "),
    read_line_to_string(user_input, Input),
    (   member(Input, ["M", "R"]) -> Method = Input
    ;   format("Invalid input. You may try again.~n"),
        ask_reroll_method(Method)
    ).


% *********************************************************************
% Predicate Name: read_die_value
% Description: Reads a new value for the dice from the user.
% Parameters:
%   - Index: Index of the die to reroll.
%   - Value: New value for the die.
% Algorithm:
%   - Ask the user for a new value for the die.
% Reference: None
% *********************************************************************
read_die_value(Index, Value) :-
    format("Enter new value for the dice (1-6): "),
    read_line_to_string(user_input, Input),
    (   atom_number(Input, Value), between(1, 6, Value) -> true
    ;   format("Invalid value. You may try again.~n"),
        read_die_value(Index, Value)
    ).


% *********************************************************************
% Predicate Name: ask_roll_or_stand
% Description: Asks the user if they want to roll again or stand.
% Parameters:
%   - Decision: User's decision to roll or stand.
% Algorithm:
%   - Ask the user if they want to roll again or stand.
% Reference: None
% *********************************************************************
ask_roll_or_stand(Decision) :-
    format("Do you want to roll again or stand? (R/S): "),
    read_line_to_string(user_input, Input),
    (   Input = "R" -> Decision = "roll"
    ;   Input = "S" -> Decision = "stand"
    ;   format("Invalid input. You may try again.~n"),
        ask_roll_or_stand(Decision)
    ).


% *********************************************************************
% Predicate Name: roll_specific_dice
% Description: Rolls a specific number of dice.
% Parameters:
%   - N: Number of dice to roll.
%   - Values: Values of the dice after rolling.
% Algorithm:
%   - Roll a specific number of dice.
% Reference: None
% *********************************************************************
roll_specific_dice(0, []) :- 
    true.  % Base case: no more dice to roll
roll_specific_dice(N, [Value | Rest]) :-
    random_between(1, 6, Value),
    N1 is N - 1,
    roll_specific_dice(N1, Rest).



% *********************************************************************
% Predicate Name: ask_reroll_dice_indices
% Description: Asks the user which dice to reroll.
% Parameters:
%   - DiceValues: Current dice values.  
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - RerollIndices: Indices of dice to reroll.
% Algorithm:
%   - Ask the user for the indices of the dice to reroll.
%   - Validate the input and reroll the dice.
% Reference: None
% *********************************************************************
ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices) :-
    format("Current dice: ~w~n", [DiceValues]),
    write("Enter the values of the dice you want to reroll, separated by commas (e.g., 5,4): "),
    read_line_to_string(user_input, Input),
    split_string(Input, ",", " ", StringValues),
    maplist(atom_number, StringValues, DicesToReroll),
    (   subset(DicesToReroll, DiceValues) ->  
        format("Rerolling dices: ~w~n", [DicesToReroll]),

        OriginalKeptIndices = KeptIndices,
        OriginalDiceValues = DiceValues,
        (   find_dices_to_reroll_indices(DiceValues, DicesToReroll, KeptIndices, [], RerollIndices)
        ->  true
        ;   format("Invalid reroll selection. You may try again.~n"),
            ask_reroll_dice_indices(OriginalDiceValues, OriginalKeptIndices, RerollIndices)
        )
    ;   
        format("Invalid dice selection. Please enter a valid dice number.~n"),
        ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices)
    ).


% *********************************************************************
% Predicate Name: find_dices_to_reroll_indices
% Description: Finds the indices of the dice to reroll.
% Parameters:
%   - DiceValues: Current dice values.
%   - DicesToReroll: Values of the dice to reroll.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - CurrentRerollIndices: Indices of dice to reroll.
%   - DicesToRerollInd: Indices of dice to reroll.
% Algorithm:
%   - Find the indices of the dice to reroll.
% Reference: None
% *********************************************************************
find_dices_to_reroll_indices(DiceValues, DicesToReroll, KeptIndices, CurrentRerollIndices, DicesToRerollInd) :-
    find_dices_to_reroll_indices_helper(DiceValues, DicesToReroll, KeptIndices, CurrentRerollIndices, DicesToRerollInd).



% *********************************************************************
% Predicate Name: find_dices_to_reroll_indices_helper
% Description: Helper predicate to find the indices of the dice to reroll.
% Parameters:
%   - DiceValues: Current dice values.
%   - DicesToReroll: Values of the dice to reroll.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - Acc: Accumulator for the indices of dice to reroll.
%   - DicesToRerollInd: Indices of dice to reroll.
% Algorithm:
%   - Find the indices of the dice to reroll.
% Reference: None
% *********************************************************************
find_dices_to_reroll_indices_helper(_, [], _, Acc, Acc). % Base case: No more values to match
find_dices_to_reroll_indices_helper(DiceValues, [Reroll|Rest], KeptIndices, Acc, DicesToRerollInd) :-
    (   nth1(Index, DiceValues, Reroll), \+ member(Index, Acc), \+ member(Index, KeptIndices)
    ->  find_dices_to_reroll_indices_helper(DiceValues, Rest, KeptIndices, [Index|Acc], DicesToRerollInd)
    ;   (   nth1(Index, DiceValues, Reroll), member(Index, KeptIndices)
        ->  format("Dice already kept, and can't be rerolled.~n"), false;   true),
        find_dices_to_reroll_indices_helper(DiceValues, Rest, KeptIndices, Acc, DicesToRerollInd)
    ). % Recursively process the rest


% ******************************************************************************************************************************************
%%________________________________________________________Human Help Functions____________________________________________________________%%
% ******************************************************************************************************************************************


% *********************************************************************
% Predicate Name: prompt_human_help
% Description: Prompts the user if they want help.
% Parameters:
%   - DiceValues: Current dice values.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - Scorecard: Current scorecard.
%   - RerollCount: Number of rerolls taken.
% Algorithm:
%   - Ask the user if they want help.
%   - If the user wants help, provide suggestions.
% Reference: None
% *********************************************************************
prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount) :-
    format("Do you wish to use help (Y/N)? "),
    read_line_to_string(user_input, Response),
    (   Response = "Y" -> (human_help(DiceValues, KeptIndices, Scorecard, RerollCount)->true;nl)
    ;   Response = "N" -> true
    ;   format("Invalid response. Please enter Y or N.~n"),
        prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount)
    ).



% *********************************************************************
% Predicate Name: human_help
% Description: Provides suggestions to the user.
% Parameters:
%   - DiceValues: Current dice values.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - Scorecard: Current scorecard.
%   - RerollCount: Number of rerolls taken.
% Algorithm:
%  -  If rerolls are available, make a decision.
%  -  If no rerolls are available, suggest the highest scoring category.
% Reference: None
% *********************************************************************
human_help(DiceValues, KeptIndices, Scorecard, RerollCount) :-
    (   RerollCount < 2
    ->  % Make a decision
        make_human_decision(DiceValues, KeptIndices, Scorecard)
    ;   % No rerolls left, pick highest scoring category
        scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
        get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
        format("You don't have any more rerolls left.~n"),
        (   CategoriesAvailableToScore \= []
        ->  find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
            find_category_name(HighestCategory, CategoryName),
            format("You may score the highest available category: ~w~n", [CategoryName])
        ;   format("No available categories to score. Your turn will be skipped.~n")
        )
    ).


% *********************************************************************
% Predicate Name: make_human_decision
% Description: Makes a decision for the human player.
% Parameters:
%   - DiceValues: Current dice values.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - Scorecard: Current scorecard.
% Algorithm:
%   - check if the lower section is full.
%   - if the lower section is full, check the upper section.
%   - if the upper section is full, no scoring is possible.
%   - if the upper section is not full, check the upper section.
% Reference: None
% *********************************************************************
make_human_decision(DiceValues, KeptIndices, Scorecard) :-
    (   is_lower_section_full(Scorecard)
    ->  (   is_upper_section_full(Scorecard)
        ->  nl
        ;   check_upper_section(DiceValues, KeptIndices, Scorecard)
        )
    ;  check_lower_section(DiceValues, KeptIndices, Scorecard)
    ).


% Predicate Name: check_lower_section/3
% Description: Checks for potential scoring opportunities and provides suggestions in the lower section of the scorecard.
% Parameters:
%   DiceValues: A list of the current dice values.
%   KeptIndices: A list of indices of dice to keep (not reroll).
%   Scorecard: The current scorecard.
% Algorithm:
%   This algorithm prioritizes Yahtzee, then large straights, then other lower section combinations, providing suggestions to the user on how to proceed.
%   1. Check if Yahtzee (category 12) is available on the scorecard:
%       a. If Yahtzee is available:
%           i.  If the current dice form a Yahtzee, notify the user that they can score it.
%           ii. If not, suggest ways to try to get a Yahtzee:
%               * Prioritize keeping four-of-a-kind, then three-of-a-kind, then two-of-a-kind, suggesting rerolling other dice.
%               * If no matching dice, suggest rerolling everything.
%       b. If Yahtzee is not available:
%           i.  Check if a five straight (category 11) is available:
%               * If the current dice form a five straight, notify the user that they can score it.
%               * If not, suggest ways to try to get a five straight:
%                   + Prioritize keeping four sequential dice, then three sequential dice, then a wildcard die with three sequential dice.
%                   + If no sequence, check for and prioritize keeping four-of-a-kind, then full house, then three-of-a-kind, then two-of-a-kind.
%                   + If none of the above, suggest rerolling everything.
%           ii. If a five straight is not available, check if a four straight (category 10) is available:
%               * If the current dice form a four straight, notify the user that they can score it.
%               * If not, suggest ways to try to get a four straight:
%                   + Prioritize keeping three sequential dice.
%                   + If no sequence, check for and prioritize keeping four-of-a-kind, then full house, then three-of-a-kind, then two-of-a-kind.
%                   + If none of the above, suggest rerolling everything.
%           iii. If neither five straight nor four straight is available, proceed with checking for other combinations in a similar manner, prioritizing four-of-a-kind, then full house, then three-of-a-kind.
% Reference: None
% *********************************************************************
check_lower_section(DiceValues, KeptIndices, Scorecard) :-
        % Check if Yahtzee is available
        ( \+ is_category_filled(Scorecard, 12) ->
            (hasYahtzee(DiceValues) -> % If Yahtzee is Available to score, score it.
                format("Yahtzee is available to score. You may score it!~n")

            ; % else Yahtzee is available on scorecard, so let's try to get it
                giveFourOfaKindIndices(DiceValues, FourOfAKindIndices),
                ( hasFourOfAKind(DiceValues), kept_indices_checker(KeptIndices, FourOfAKindIndices) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                    % reroll the odd dice to get Yahtzee
                    format("You may try to get Yahtzee...~n"),
                    display_roll_msg(FourOfAKindIndices, DiceValues)
                ;   
                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee

                        (\+ is_category_filled(Scorecard, 9) -> 
                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                (format("Full House is available to score. You may score it!~n"))
                            ; 
                                % reroll the odd dice to get Yahtzee
                                format("You may try to get Yahtzee...~n"),
                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                
                            )
                        ;
                                % reroll the odd dice to get Yahtzee
                                format("You may try to get Yahtzee...~n"),
                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                        )
                    ;  
                        % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
                        ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                            (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                                format("Five Straight is available to score. You may score it!~n")
                            ;
                                % try to get five straight
                                (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                                    format("You may try to get Five Straight...~n"),
                                    display_roll_msg(FourStraightIndices, DiceValues)
                                ;
                                    % try to get five straight
                                    (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        (find_wildcard_index(DiceValues, WildcardIndex), kept_indices_checker(KeptIndices, [WildcardIndex]) ->
                                            format("Trying to get Five Straight...~n"),
                                            custom_remove([1,2,3,4,5], [WildcardIndex], IndicesToKeep2),
                                            format("You may try to get Five Straight...~n"),
                                            display_roll_msg(ThreeStraightIndices, IndicesToKeep2)
                                        ;
                                           format("You may try to get Five Straight...~n"),
                                            display_roll_msg(ThreeStraightIndices, DiceValues)
                                        )
                                        
                                    ;
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            format("You may try to get Yahtzee...~n"),
                                            display_roll_msg(TwoOfAKindIndices, DiceValues)         
                                        ;   
                                            format("Rerolling everything possible to get Yahtze"), nl,
                                            display_roll_msg(KeptIndices, DiceValues)
                                        )
                                    )
                                )
                            )
                        ;
                            % Since Five Striaght is filled, let's try to get Four Straight
                            % check for four straight
                            ( \+ is_category_filled(Scorecard, 10) -> 
                                (hasFourStraight(DiceValues) ->
                                    format("Four Straight is available to score. You may score it!~n")
                                ;
                                        % try to get five straight
                                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                            format("You may try to get Four Straight...~n"),
                                            display_roll_msg(ThreeStraightIndices, DiceValues)
                                        ;
                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                            ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                format("You may try to get Yahtzee...~n"),
                                                display_roll_msg(TwoOfAKindIndices, DiceValues)         
                                            ;   
                                                format("Rerolling everything possible to get Yahtze"), nl,
                                                display_roll_msg(KeptIndices, DiceValues)
                                            )
                                        )
                                )
                            ;

                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    format("You may try to get Yahtzee...~n"),
                                    display_roll_msg(TwoOfAKindIndices, DiceValues)         
                                ;   
                                    format("Rerolling everything possible to get Yahtze"), nl,
                                    display_roll_msg(KeptIndices, DiceValues)
                                )
                            )
                        )
                    
                    )
                        
                )
            )   
        
        ;
           % At this point, Yahtzee is not availble on the scorecard.
            % Let's try sequence then of a kind)
            % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
            ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                    format("Five Straight is available to score. You may score it!~n")
                ;
                    % check for four straight
                    % try to get five straight
                    (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                        format("You may try to get Five Straight...~n"),
                        display_roll_msg(FourStraightIndices, DiceValues)
                    ;
                        % try to get five straight
                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                            (find_wildcard_index(DiceValues, WildcardIndex), kept_indices_checker(KeptIndices, [WildcardIndex]) ->
                                format("Trying to get Five Straight...~n"),
                                custom_remove([1,2,3,4,5], [WildcardIndex], IndicesToKeep2),
                                format("You may try to get Five Straight...~n"),
                                display_roll_msg(ThreeStraightIndices, IndicesToKeep2)
                            ;
                                format("You may try to get Five Straight...~n"),
                                display_roll_msg(ThreeStraightIndices, DiceValues)
                            )
                        ;
                            % check for 4 of a kind, full house, 3 of a kind and 2 of a kind
                            % check if 4 of a kind is filled
                            ( \+ is_category_filled(Scorecard, 8) -> 
                                ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                    format("Four of a Kind is available to score. You may score it!~n")
                                
                                ;   
                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                        (\+ is_category_filled(Scorecard, 9) -> 
                                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                format("Full House is available to score. You may score it!~n")
                                            ; 
                                                % reroll the odd dice to get Yahtzee
                                                format("You may try to get Four of a Kind...~n"),
                                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                                
                                            )
                                        ;
                                            % reroll the odd dice to get Yahtzee
                                                format("You may try to get Four of a Kind...~n"),
                                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                        )

                                    ;
                                        % check for 2 of a kind, if yes, maybe full house?
                                        giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                        ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("You may try to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_roll_msg(FullHouseIndices, DiceValues)
                                            ;
                                                format("You may try to get Four of a Kind...~n"),
                                                display_roll_msg(TwoOfAKindIndices, DiceValues)
                                            )
                                        ;   
                                            % reroll all dice
                                            format("Rerolling everything possible to get Four of a Kind"), nl,
                                            
                                            display_roll_msg(KeptIndices, DiceValues)
                                        )
                                    )
                                )
                            ;
                               % No Four of a kind, check for three of a kind/full house
                                (\+ is_category_filled(Scorecard, 9) -> 
                                ( hasFullHouse(DiceValues)) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                    format("Full House is available to score. You may score it!~n")
                                ; 
                                    ( \+ is_category_filled(Scorecard, 7) -> 
                                        ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                            format("Three of a Kind is available to score. You may score it!~n")
                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("You may try to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_roll_msg(FullHouseIndices, DiceValues)
                                                    ;
                                                        format("You may try to get Three of a Kind...~n"),
                                                        display_roll_msg(TwoOfAKindIndices, DiceValues)                   
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind"), nl,
                                                    
                                                    display_roll_msg(KeptIndices, DiceValues)
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind..."), nl,
                                        
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                                )

                            )

                        )
                    )
                )
            ;
                % Since Five Striaght is filled, let's try to get Four Straight
                % check for four straight
                ( \+ is_category_filled(Scorecard, 10) -> 
                    (hasFourStraight(DiceValues) ->
                        format("Four Straight is available to score. You may score it!~n")
                    ;
                            % try to get five straight
                            (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                format("You may try to get Four Straight...~n"),
                                display_roll_msg(ThreeStraightIndices, DiceValues)
                            ;
                                % check for 4 of a kind, full house, 3 of a kind and 2 of a kind
                                % check if 4 of a kind is filled
                                ( \+ is_category_filled(Scorecard, 8) -> 
                                    ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                        format("Four of a Kind is available to score. You may score it!~n")
                                    ;   
                                        giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                        ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                   format("Full House is available to score. You may score it!~n")
                                                ; 
                                                    % reroll the odd dice to get Yahtzee
                                                    format("You may try to get Four of a Kind...~n"),
                                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                                )
                                            ;
                                                    % reroll the odd dice to get Yahtzee
                                                    format("You may try to get Four of a Kind...~n"),
                                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                            )
                                        ;
                                            % check for 2 of a kind, if yes, maybe full house?
                                            giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                            ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                    format("You may try to get Full House...~n"),
                                                    custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                    display_roll_msg(FullHouseIndices, DiceValues)
                                                ;
                                                    format("You may try to get Four of a Kind...~n"),
                                                    display_roll_msg(TwoOfAKindIndices, DiceValues)
                                                )
                                            ;   
                                                % reroll all dice
                                                format("Rerolling everything possible to get Four of a Kind"), nl,
                                                display_roll_msg(KeptIndices, DiceValues)
                                            )

                                        
                                        )
                                    )
                                ;
                                % No Four of a kind, check for three of a kind/full house
                                    ( \+ is_category_filled(Scorecard, 7) -> 
                                        ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee

                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                    format("Full House is available to score. You may score it!~n")
                                                ; 
                                                    format("Three of a Kind is available to score. You may score it!~n")
                                                )
                                            ;
                                                format("Three of a Kind is available to score. You may score it!~n")
                                            )
                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("You may try to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_roll_msg(FullHouseIndices, DiceValues)
                                                    ;
                                                        format("You may try to get Three of a Kind...~n"),
                                                        display_roll_msg(TwoOfAKindIndices, DiceValues)                   
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind"), nl,
                                                    
                                                    display_roll_msg(KeptIndices, DiceValues)
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind"), nl,
                                        
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                                )

                            )
                    )
                ;
                    % At this point, Yahtzee, Five Straight and Four Straight are filled, so let's try to get Full House/Three of a Kind/Four of a Kind
                    % check for 4 of a kind, full house, 3 of a kind and 2 of a kind  
                    % check if 4 of a kind is filled
                    ( \+ is_category_filled(Scorecard, 8) -> 
                        ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                            format("Four of a Kind is available to score. You may score it!~n")
                        ;   
                            giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                            ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                (\+ is_category_filled(Scorecard, 9) -> 
                                    ( hasFullHouse(DiceValues)) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                        format("Full House is available to score. You may score it!~n")
                                    ; 
                                    % reroll the odd dice to get Yahtzee
                                    format("You may try to get Four of a Kind...~n"),
                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                )   
                            ;
                                % check for 2 of a kind, if yes, maybe full house?
                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                        format("You may try to get Full House...~n"),
                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                        display_roll_msg(FullHouseIndices, DiceValues)
                                    ;
                                        format("You may try to get Four of a Kind...~n"),
                                        display_roll_msg(TwoOfAKindIndices, DiceValues) 
                                    )
                                ;   
                                    % reroll all dice
                                    format("Rerolling everything possible to get Four of a Kind"), nl,
                                    display_roll_msg(KeptIndices, DiceValues)
                                )

                            
                            )
                        )
                    ;
                        % No Four of a kind, check for three of a kind/full house
                        ( \+ is_category_filled(Scorecard, 7) -> 
                            ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                               (\+ is_category_filled(Scorecard, 9) -> 
                                        ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                            format("Full House is available to score. You may score it!~n")
                                        ; 
                                            format("Three of a Kind is available to score. You may score it!~n")
                                        )
                                ;
                                    format("Three of a Kind is available to score. You may score it!~n")
                                )
                            ;   
                                % check for 2 of a kind, if yes, maybe full house?
                                    giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                    ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("You may try to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_roll_msg(FullHouseIndices, DiceValues) 
                                        ;
                                            format("You may try to get Three of a Kind))...~n"),
                                            display_roll_msg(TwoOfAKindIndices, DiceValues)                    
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind"), nl,
                                        
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                            )
                        ;
                            (\+ is_category_filled(Scorecard, 9) -> 
                                ( hasFullHouse(DiceValues) -> % If there is a Full House
                                    format("Full House is available to score. You may score it!~n")
                                ; 
                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) ->
                                        format("You may try to get Full House...~n"),
                                        display_roll_msg(ThreeOfAKindIndices, DiceValues)       
                                    ;
                                        % Try to get a Full House?
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("You may try to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_roll_msg(FullHouseIndices, DiceValues) 
                                            ;
                                                format("You may try to get Full House...~n"),
                                                display_roll_msg(TwoOfAKindIndices, DiceValues)                    
                                            )
                                        ;   
                                            % reroll all dice
                                            format("Rerolling everything possible"), nl,
                                            display_roll_msg(KeptIndices, DiceValues)
                                        )                                    
                                    )

                                )
                            ;
                                % reroll all dice
                                format("Rerolling everything possible to get Full House"), nl,
                                display_roll_msg(KeptIndices, DiceValues)
                            )
                        )

                    )

                )
            )
        ).



% *********************************************************************
% Predicate Name: display_roll_msg/2
% Description: Displays a message suggesting which dice to keep or reroll.
% Parameters:
%   KeptIndices: Indices of dice kept from previous rolls.
%   DiceValues: Current dice values.
% Algorithm:
%   1. Determine the dice values corresponding to the KeptIndices.
%   2. If there are kept dice (KeptIndices is not empty):
%       a. Display a message suggesting to keep those dice and reroll the others.
%   3. If there are no kept dice (KeptIndices is empty):
%       a. Display a message suggesting to reroll all the dice.
% Reference: None
% *********************************************************************
display_roll_msg(KeptIndices, DiceValues) :-
    find_dice_values(DiceValues, KeptIndices, KeptDiceValues),
    (KeptIndices \= [] -> format("You may keep these dices: ~w~n", [KeptDiceValues]) ; format("You may reroll all dices"),nl).




% *********************************************************************
% Predicate Name: check_upper_section
% Description: Checks the upper section for scoring opportunities.
% Parameters:
%   - DiceValues: Current dice values.
%   - KeptIndices: Indices of dice kept from previous rolls.
%   - Scorecard: Current scorecard.
% Algorithm:
%   - Check if any categories are available to score.
%   - If no categories are available, display a message.
%   - If categories are available, pick the best category to score.
% Reference: None
% *********************************************************************
check_upper_section(DiceValues, KeptIndices, Scorecard) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    (   CategoriesAvailableToScore = []
    ->  % No available categories here either
        
        display_roll_msg(KeptIndices, DiceValues)
    ;   % Pick the best upper category to score
        find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
        get_score(HighestCategory, DiceValues, HighestScore),
        (HighestScore > 7 ->
            find_category_name(HighestCategory, HighestCategoryName),
            format("You may score  category: ~w since it scores more than 7~n", [HighestCategoryName])
        ;
            format("None of the categories score more than 7.~n"),
            
            display_roll_msg(KeptIndices, DiceValues)
        )
    ).
