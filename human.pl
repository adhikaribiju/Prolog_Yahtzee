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
    nl,
    format("Your Turn~n"), nl,
    format("Round: ~d~n", [RoundNum]), nl,
    display_scorecard(Scorecard), nl,
    roll_dice(DiceValues),
    play_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard).

% Manage the turn flow with rerolls and scoring
play_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    display_available_combinations(DiceValues, Scorecard), nl,
    display_potential_categories(DiceValues, Scorecard, RerollCount, PotentialCategoryList),
    availableCombinations(DiceValues, AvailableCategories), nl,
    (prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount) -> nl; nl),
    (   RerollCount < 2
    ->  ask_roll_or_stand(Decision),
        handle_decision(Decision, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, AvailableCategories, NewScorecard)
    ;   format("No rerolls left. Standing automatically.~n"),
        ask_category_to_score(Scorecard, DiceValues, RoundNum, 1, NewScorecard)
    ).

% Handle player's decision to roll or stand
handle_decision("roll", DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, _AvailableCategories, NewScorecard) :-
    ask_reroll_dice_indices(DiceValues, KeptIndices, RerollIndices),
    reroll_dice(DiceValues, RerollIndices, UpdatedDice),
    display_dice(UpdatedDice),
    %format("Kept Indices: ~w~n", [KeptIndices]),
    %format("Reroll Indices: ~w~n", [RerollIndices]),
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
% roll_dice(DiceValues) :-
%     get_yes_no_input(Response),
%     ( Response = "Y" -> 
%         get_manual_dice(5, DiceValues)
%     ; 
%         generate_random_dice(5, DiceValues)
%     ),
%     display_dice(DiceValues).

% Reroll the dice
reroll_dice(DiceValues, RerollIndices, UpdatedDiceValues) :-
    %length(DiceValues, NumDice), -- commented out to avoid error
    %numlist(1, NumDice, AllIndices), -- commented out to avoid error
    %subtract(AllIndices, RerollIndices, KeptIndices), -- commented out to avoid error
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
% generate_random_dice(0, []) :- !.
% generate_random_dice(N, [Value | Rest]) :-
%     random_between(1, 6, Value),
%     N1 is N - 1,
%     generate_random_dice(N1, Rest).

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
    ;   format("Invalid input. You may try again.~n"),
        ask_reroll_method(Method)
    ).

% Read a new value for a die
read_die_value(Index, Value) :-
    format("Enter new value for the dice (1-6): "),
    read_line_to_string(user_input, Input),
    atom_number(Input, Value),
    (   between(1, 6, Value) -> true
    ;   format("Invalid value. You may try again.~n"),
        read_die_value(Index, Value)
    ).

% Ask if the player wants to roll again or stand
ask_roll_or_stand(Decision) :-
    format("Do you want to roll again or stand? (R/S): "),
    read_line_to_string(user_input, Input),
    (   Input = "R" -> Decision = "roll"
    ;   Input = "S" -> Decision = "stand"
    ;   format("Invalid input. You may try again.~n"),
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
        format("Rerolling dices: ~w~n", [DicesToReroll]),
        
        OriginalKeptIndices = KeptIndices,
        OriginalDiceValues = DiceValues,
        (   find_dices_to_reroll_indices(DiceValues, DicesToReroll, KeptIndices, [], RerollIndices)
        ->  true
        ;   format("Invalid reroll selection. You may try again.~n"),
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
                %format("Dices to Reroll: ~w~n", [DicesToReroll]),
                false
            ;   true
            ),
            find_dices_to_reroll_indices_helper(DiceValues, Rest, KeptIndices, Acc, DicesToRerollInd)
        ). % Recursively process the rest



%%______________________________Human Help Functions____________________________________________________________%%


prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount) :-
    format("Do you wish to use help (Y/N)? "),
    read_line_to_string(user_input, Response),
    (   Response = "Y" -> human_help(DiceValues, KeptIndices, Scorecard, RerollCount)
    ;   Response = "N" -> true
    ;   format("Invalid response. Please enter Y or N.~n"),
        prompt_human_help(DiceValues, KeptIndices, Scorecard, RerollCount)
    ).


% Recursive logic for the computer turn
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


% Decide what to do with the current dice based on available categories and full sections
make_human_decision(DiceValues, KeptIndices, Scorecard) :-
    (   is_lower_section_full(Scorecard)
    ->  format("Lower section is full. Checking the upper section...~n"),
        (   is_upper_section_full(Scorecard)
        ->  format("Both sections full, no scoring possible.~n")
        ;   format("You may try to fill the upper section...~n"),
            check_upper_section(DiceValues, KeptIndices, Scorecard)
        )
    ;   % Lower section not full
        format("You may try to fill the lower section...~n"),
        check_lower_section(DiceValues, KeptIndices, Scorecard)
    )
    .


% Attempt to score in the lower section
check_lower_section(DiceValues, KeptIndices, Scorecard) :-
        % Check if Yahtzee is available
        ( \+ is_category_filled(Scorecard, 12) ->
            (hasYahtzee(DiceValues) -> % If Yahtzee is Available to score, score it.
                format("Yahtzee is available to score. You may score it!~n")
            ; % else Yahtzee is available on scorecard, so let's You may try to get it
                giveFourOfaKindIndices(DiceValues, FourOfAKindIndices),
                ( hasFourOfAKind(DiceValues), kept_indices_checker(KeptIndices, FourOfAKindIndices) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                    % reroll the odd dice to get Yahtzee
                    format("You may try to get Yahtzee...~n"),
                    custom_remove([1,2,3,4,5], FourOfAKindIndices, _IndicesToReroll),
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
                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, _IndicesToReroll),
                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                            )
                        )
                    ;  
                        format("Straight Check Gardai Chu2"), nl,
                        % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
                        ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                            (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                                format("Five Straight is available to score. You may score it!~n")
                            ;
                                format("Four Straight Check Gardai Chu3"), nl,
                                 % check for four straight
                                % You may try to get five straight
                                (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                                    format("You may try to get Five Straight...~n"),
                                    custom_remove([1,2,3,4,5], FourStraightIndices, _IndicesToReroll),
                                    display_roll_msg(FourStraightIndices, DiceValues)
                                ;
                                    % You may try to get five straight
                                    (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("You may try to get Five Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, _IndicesToReroll),
                                        display_roll_msg(ThreeStraightIndices, DiceValues)
                                    ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtze"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                                )
                            )
                        ;
                            % Since Five Striaght is filled, let's You may try to get Four Straight
                            % check for four straight
                            ( \+ is_category_filled(Scorecard, 10) -> 
                                (hasFourStraight(DiceValues) ->
                                    format("Four Straight is available to score. You may score it!~n")
                                ;
                                        % You may try to get five straight
                                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("You may try to get Four Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, _IndicesToReroll),
                                        display_roll_msg(ThreeStraightIndices, DiceValues)
                                        ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtzee"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                        display_roll_msg(KeptIndices, DiceValues)
                                        )
                                )
                            ;
                                % At this point, no swquence/of a kind is available, so let's reroll everything
                                format("Rerolling everything possible to get Yahtze"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                display_roll_msg(KeptIndices, DiceValues)
                            )
                        )
                    
                    )
                        
                )
            )   
        
        ;
           % At this point, Yahtzee is not availble on the scorecard.
            % Let's You may try sequence then of a kind)
            format("Straight Check Gardai Chu4"), nl,
            % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
            ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                    format("Five Straight is available to score. You may score it!~n")
                ;
                    format("Four Straight Check Gardai Chu1"), nl,
                        % check for four straight
                    % You may try to get five straight
                    (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                        format("You may try to get Five Straight...~n"),
                        custom_remove([1,2,3,4,5], FourStraightIndices, _IndicesToReroll),
                        display_roll_msg(FourStraightIndices, DiceValues)
                    ;
                        % You may try to get five straight
                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                            format("You may try to get Five Straight...~n"),
                            custom_remove([1,2,3,4,5], ThreeStraightIndices, _IndicesToReroll),
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
                                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, _IndicesToReroll),
                                                display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                            )
                                        )



                                    ;
                                        % check for 2 of a kind, if yes, maybe full house?
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("You may try to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_roll_msg(FullHouseIndices, DiceValues),
                                                reroll_dice(DiceValues, OddIndex, _NewDiceValues)
                                            ;
                                                format("You may try to get Four of a Kind...~n"),
                                                custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                                display_roll_msg(TwoOfAKindIndices, DiceValues)
                                            )
                                        ;   
                                            % reroll all dice
                                            format("Rerolling everything possible to get Four of a Kind"), nl,
                                            custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
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
                                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("You may try to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_roll_msg(FullHouseIndices, DiceValues),
                                                        reroll_dice(DiceValues, OddIndex, _NewDiceValues)
                                                    ;
                                                        format("You may try to get Three of a Kind...~n"),
                                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                                        display_roll_msg(TwoOfAKindIndices, DiceValues)             
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind"), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                                    display_roll_msg(KeptIndices, DiceValues)
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind..."), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                                )

                            )

                        )
                    )
                )
            ;
                % Since Five Striaght is filled, let's You may try to get Four Straight
                % check for four straight
                ( \+ is_category_filled(Scorecard, 10) -> 
                    (hasFourStraight(DiceValues) ->
                        % Yahtzee is Available to score, score it.
                        format("Four Straight is available to score. You may score it!~n")
                    ;
                            % You may try to get five straight
                            (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                format("You may try to get Four Straight...~n"),
                                custom_remove([1,2,3,4,5], ThreeStraightIndices, _IndicesToReroll),
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
                                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, _IndicesToReroll),
                                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                                )
                                            )


                                        ;
                                            % check for 2 of a kind, if yes, maybe full house?
                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                            ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                    format("You may try to get Full House...~n"),
                                                    custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                    display_roll_msg(FullHouseIndices, DiceValues),
                                                    reroll_dice(DiceValues, OddIndex, _NewDiceValues)
                                                ;
                                                    format("You may try to get Four of a Kind...~n"),
                                                    custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                                    display_roll_msg(TwoOfAKindIndices, DiceValues)
                                                )
                                            ;   
                                                % reroll all dice
                                                format("Rerolling everything possible to get Four of a Kind"), nl,
                                                custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                                display_roll_msg(KeptIndices, DiceValues)
                                            )

                                        
                                        )
                                    )
                                ;
                                % No Four of a kind, check for three of a kind/full house

                                    ( \+ is_category_filled(Scorecard, 7) -> 
                                        ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee

                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues)) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                    format("Full House is available to score. You may score it!~n")
                                                ; 
                                                    format("Three of a Kind is available to score. You may score it!~n")
                                                    
                                            )
                                            

                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("You may try to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_roll_msg(FullHouseIndices, DiceValues)
                                                    ;
                                                        format("You may try to get Three of a Kind??...~n"),
                                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                                        display_roll_msg(TwoOfAKindIndices, DiceValues)              
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind==="), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                                    display_roll_msg(KeptIndices, DiceValues)
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind444"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )
                                )

                            )
                    )
                ;
                    % At this point, Yahtzee, Five Straight and Four Straight are filled, so let's You may try to get Full House/Three of a Kind/Four of a Kind
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
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, _IndicesToReroll),
                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                )   

                            ;
                                % check for 2 of a kind, if yes, maybe full house?
                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                        format("You may try to get Full House...~n"),
                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                        display_roll_msg(FullHouseIndices, DiceValues)
                                    ;
                                        format("You may try to get Four of a Kind...~n"),
                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                        display_roll_msg(TwoOfAKindIndices, DiceValues)
                                    )
                                ;   
                                    % reroll all dice
                                    format("Rerolling everything possible to get Four of a Kind2323"), nl,
                                    custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
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
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("You may try to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_roll_msg(FullHouseIndices, DiceValues)
                                        ;
                                            format("You may try to get Three of a Kind))...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                            display_roll_msg(TwoOfAKindIndices, DiceValues)              
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
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
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, _IndicesToReroll),
                                    display_roll_msg(ThreeOfAKindIndices, DiceValues)
                                    ;
                                    % You may try to get a Full House?
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("You may try to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_roll_msg(FullHouseIndices, DiceValues)
                                        ;
                                            format("You may try to get Full House++...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, _IndicesToReroll),
                                            display_roll_msg(TwoOfAKindIndices, DiceValues)              
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                        display_roll_msg(KeptIndices, DiceValues)
                                    )                                    
                                    )

                                )
                            ;
                                % reroll all dice
                                format("Rerolling everything possible to get Full House"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
                                display_roll_msg(KeptIndices, DiceValues)
                            )
                        )

                    )

                )
            )
        )
    .



% Base case: When there's only one category and one score, the result is the category.
% find_highest_category([Category], [_], Category).

% % Recursive case: Compare the first score with the maximum score in the rest of the list.
% find_highest_category([Category1 | Categories], [Score1 | Scores], ResultCategory) :-
%     find_highest_category(Categories, Scores, TempCategory),
%     nth0(Index, Categories, TempCategory),
%     nth0(Index, Scores, TempScore),
%     (Score1 >= TempScore ->
%         ResultCategory = Category1;
%         ResultCategory = TempCategory).


display_roll_msg(KeptIndices, DiceValues) :-
    find_dice_values(DiceValues, KeptIndices, KeptDiceValues),
    (KeptIndices \= [] -> format("You may keep these dices: ~w~n", [KeptDiceValues]) ; format("You may reroll all dices"),nl).



% Attempt to score in the upper section
check_upper_section(DiceValues, KeptIndices, Scorecard) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    (   CategoriesAvailableToScore = []
    ->  % No available categories here either
        custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
        display_roll_msg(KeptIndices, DiceValues)
    ;   % Pick the best upper category to score
        find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
        get_score(HighestCategory, DiceValues, HighestScore),
        (HighestScore > 7 ->
            find_category_name(HighestCategory, HighestCategoryName),
            format("You may score  category: ~w since it scores more than 7~n", [HighestCategoryName])
        ;
            format("None of the categories score more than 7.~n"),
            custom_remove([1,2,3,4,5], KeptIndices, _IndicesToReroll),
            display_roll_msg(KeptIndices, DiceValues)
        )
    ).
