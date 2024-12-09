
%%______________________________MAIN CODE STATS HERE____________________________________________________________%%


% Main computer turn entry point
computer_turn(Scorecard, RoundNum, NewScorecard) :-
    nl,
    PlayerID is 2,
    format("Computer Turn:"), nl,
    format("Round: ~d~n", [RoundNum]), nl,
    display_scorecard(Scorecard), nl,
    roll_dice(DiceValues),
    (   play_computer_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard, PlayerID)
    ->  format("Working as intended.~n")
    ;   format("Error: Failed to compute a valid turn.~n"),
        format("ani New Scorecard____: ~w~n", [NewScorecard])
    ).

% Recursive logic for the computer turn
play_computer_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard,PlayerID) :-
    format("Current Dice: ~w~n", [DiceValues]),
    NewRerollCount is RerollCount + 1,
    nl, format("Roll Count: ~w~n", [NewRerollCount]),nl,
    display_available_combinations(DiceValues, Scorecard), nl,
    display_potential_categories(DiceValues, Scorecard, RerollCount, PotentialCategoryList),
    (   NewRerollCount =< 2
    ->  % Make a decision
        make_computer_decision(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, DecidedDiceValues, DecidedScorecard, DecidedKeptIndices,PlayerID),
        (   CategoryScored = 0
        ->  % No category scored, recurse with possibly updated dice
            play_computer_turn(DecidedDiceValues, DecidedKeptIndices, Scorecard, RoundNum, NewRerollCount, NewScorecard,PlayerID)
        ;   % Category scored, finalize
            NewScorecard = DecidedScorecard
        )
    ;   % No rerolls left, pick highest scoring category
        scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
        get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
        format("No rerolls left. Standing automatically.~n"),
        (   CategoriesAvailableToScore \= []
        ->  find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
            update_scorecard(Scorecard, HighestCategory, DiceValues, RoundNum, PlayerID, FinalScorecard),
            find_category_name(HighestCategory, CategoryName),
            format("Scored Highest Available Category: ~w~n", [CategoryName]),
            display_msg(HighestCategory),
            NewScorecard = FinalScorecard
        ;   format("No available categories to score. Skipping turn.~n"),
            NewScorecard = Scorecard
        )
    ).


% Decide what to do with the current dice based on available categories and full sections
make_computer_decision(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    %format("Categories Available to Score: ~w~n", [CategoriesAvailableToScore]),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore), nl,
    %format("Scores of Categories Available to Score: ~w~n", [ScoresOfCategoriesAvailableToScore]), nl,

    (   is_lower_section_full(Scorecard)
    ->  format("Lower section is full. Checking the upper section...~n"),
        (   is_upper_section_full(Scorecard)
        ->  format("Both sections full, no scoring possible.~n"),
            CategoryScored = 0,
            NewScorecard = Scorecard,
            NewDiceValues = DiceValues,
            NewKeptIndices = KeptIndices
        ;   format("Trying to fill the upper section...~n"),
            try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID)
        )
    ;   % Lower section not full
        format("Trying to fill the lower section...~n"),
        try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID)
    )

    
    .


% Attempt to score in the lower section
try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID) :-
        % Check if Yahtzee is available
        ( \+ is_category_filled(Scorecard, 12) ->
            (hasYahtzee(DiceValues) -> % If Yahtzee is Available to score, score it.
                update_scorecard(Scorecard, 12, DiceValues, RoundNum, PlayerID, NewScorecard),
                CategoryScored = 12,
                display_msg(CategoryScored),
                NewDiceValues = DiceValues,
                NewKeptIndices = KeptIndices

            ; % else Yahtzee is available on scorecard, so let's try to get it
                giveFourOfaKindIndices(DiceValues, FourOfAKindIndices),
                ( hasFourOfAKind(DiceValues), kept_indices_checker(KeptIndices, FourOfAKindIndices) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                    % reroll the odd dice to get Yahtzee
                    format("Trying to get Yahtzee...~n"),
                    custom_remove([1,2,3,4,5], FourOfAKindIndices, IndicesToReroll),
                    display_keeps(FourOfAKindIndices, DiceValues),
                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                    format("New Dice: ~w~n", [NewDiceValues]),
                    NewKeptIndices = FourOfAKindIndices
                ;   
                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee

                        (\+ is_category_filled(Scorecard, 9) -> 
                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                CategoryScored = 9,
                                display_msg(CategoryScored),
                                NewDiceValues = DiceValues,
                                NewKeptIndices = KeptIndices
                            ; 


                                % reroll the odd dice to get Yahtzee
                                format("Trying to get Yahtzee...~n"),
                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                display_keeps(ThreeOfAKindIndices, DiceValues),
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                format("New Dice: ~w~n", [NewDiceValues]),
                                NewKeptIndices = ThreeOfAKindIndices
                                
                            )
                        )



                    ;  
                        format("Straight Check Gardai Chu2"), nl,
                        % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
                        ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                            (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                                update_scorecard(Scorecard, 11, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                CategoryScored = 11,
                                display_msg(CategoryScored),
                                NewDiceValues = DiceValues,
                                NewKeptIndices = KeptIndices
                            ;
                                format("Four Straight Check Gardai Chu3"), nl,
                                 % check for four straight
                                % try to get five straight
                                (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                                    format("Trying to get Five Straight...~n"),
                                    custom_remove([1,2,3,4,5], FourStraightIndices, IndicesToReroll),
                                    display_keeps(FourStraightIndices, DiceValues),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = FourStraightIndices
                                ;
                                    % try to get five straight
                                    (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("Trying to get Five Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                        display_keeps(ThreeStraightIndices, DiceValues),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = ThreeStraightIndices
                                    ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtze"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                    )
                                )
                            )
                        ;
                            % Since Five Striaght is filled, let's try to get Four Straight
                            % check for four straight
                            ( \+ is_category_filled(Scorecard, 10) -> 
                                (hasFourStraight(DiceValues) ->
                                    % Yahtzee is Available to score, score it.
                                    update_scorecard(Scorecard, 10, DiceValues, RoundNum, PlayerID, NewScorecard),
                                    CategoryScored = 10,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                ;
                                        % try to get five straight
                                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("Trying to get Four Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = ThreeStraightIndices
                                        ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtzee"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                        )
                                )
                            ;
                                % At this point, no swquence/of a kind is available, so let's reroll everything
                                format("Rerolling everything possible to get Yahtze"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                NewKeptIndices = KeptIndices
                            )
                        )
                    
                    )
                        
                )
            )   
        
        ;
           % At this point, Yahtzee is not availble on the scorecard.
            % Let's try sequence then of a kind)
            format("Straight Check Gardai Chu4"), nl,
            % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
            ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                    update_scorecard(Scorecard, 11, DiceValues, RoundNum, PlayerID, NewScorecard), 
                    CategoryScored = 11,
                    display_msg(CategoryScored),
                    NewDiceValues = DiceValues,
                    NewKeptIndices = KeptIndices
                ;
                    format("Four Straight Check Gardai Chu1"), nl,
                        % check for four straight
                    % try to get five straight
                    (isFourSequential(DiceValues, FourStraightValues), find_all_indices(DiceValues, FourStraightValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                        format("Trying to get Five Straight...~n"),
                        custom_remove([1,2,3,4,5], FourStraightIndices, IndicesToReroll),
                        display_keeps(FourStraightIndices, DiceValues),
                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                        format("New Dice: ~w~n", [NewDiceValues]),
                        NewKeptIndices = FourStraightIndices
                    ;
                        % try to get five straight
                        (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                            format("Trying to get Five Straight...~n"),
                            custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                            display_keeps(ThreeStraightIndices, DiceValues),
                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                            format("New Dice: ~w~n", [NewDiceValues]),
                            NewKeptIndices = ThreeStraightIndices
                        ;

                            % check for 4 of a kind, full house, 3 of a kind and 2 of a kind
                        
                            
                            % check if 4 of a kind is filled
                            ( \+ is_category_filled(Scorecard, 8) -> 
                                ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                    update_scorecard(Scorecard, 8, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                    CategoryScored = 8,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                
                                ;   
                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                        (\+ is_category_filled(Scorecard, 9) -> 
                                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                                CategoryScored = 9,
                                                display_msg(CategoryScored),
                                                NewDiceValues = DiceValues,
                                                NewKeptIndices = KeptIndices
                                            ; 
                                                % reroll the odd dice to get Yahtzee
                                                format("Trying to get Four of a Kind...~n"),
                                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                                display_keeps(ThreeOfAKindIndices, DiceValues),
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = ThreeOfAKindIndices
                                                
                                            )
                                        )



                                    ;
                                        % check for 2 of a kind, if yes, maybe full house?
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("Trying to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_keeps(FullHouseIndices, DiceValues),
                                                reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = TwoOfAKindIndices 
                                            ;
                                                format("Trying to get Four of a Kind...~n"),
                                                custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                display_keeps(TwoOfAKindIndices, DiceValues),
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = TwoOfAKindIndices
                                                
                                                  
                                            )
                                        ;   
                                            % reroll all dice
                                            format("Rerolling everything possible to get Four of a Kind"), nl,
                                            custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                            display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            NewKeptIndices = KeptIndices
                                        )

                                    
                                    )
                                )
                            ;
                               % No Four of a kind, check for three of a kind/full house

                                (\+ is_category_filled(Scorecard, 9) -> 

                            
                                ( hasFullHouse(DiceValues)) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                    CategoryScored = 9,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                ; 
                                    ( \+ is_category_filled(Scorecard, 7) -> 
                                        ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                            update_scorecard(Scorecard, 7, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                            CategoryScored = 7,
                                            display_msg(CategoryScored),
                                            NewDiceValues = DiceValues,
                                            NewKeptIndices = KeptIndices
                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("Trying to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_keeps(FullHouseIndices, DiceValues),
                                                        reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = FullHouseIndices 
                                                    ;
                                                        format("Trying to get Three of a Kind...~n"),
                                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                        display_keeps(TwoOfAKindIndices, DiceValues),
                                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = TwoOfAKindIndices                   
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind"), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                    display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    NewKeptIndices = KeptIndices
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind..."), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
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
                        % Yahtzee is Available to score, score it.
                        update_scorecard(Scorecard, 10, DiceValues, RoundNum, PlayerID, NewScorecard),
                        CategoryScored = 10,
                        display_msg(CategoryScored),
                        NewDiceValues = DiceValues,
                        NewKeptIndices = KeptIndices
                    ;
                            % try to get five straight
                            (isThreeSequential(DiceValues, ThreeStraightValues), find_all_indices(DiceValues, ThreeStraightValues, ThreeStraightIndices),kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                format("Trying to get Four Straight...~n"),
                                custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                format("New Dice: ~w~n", [NewDiceValues]),
                                NewKeptIndices = ThreeStraightIndices
                            ;
                                % check for 4 of a kind, full house, 3 of a kind and 2 of a kind
                        
                                % check if 4 of a kind is filled
                                ( \+ is_category_filled(Scorecard, 8) -> 
                                    ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                        update_scorecard(Scorecard, 8, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                        CategoryScored = 8,
                                        display_msg(CategoryScored),
                                        NewDiceValues = DiceValues,
                                        NewKeptIndices = KeptIndices
                                    ;   
                                        giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                        ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee


                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                                    CategoryScored = 9,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                ; 

                                                    % reroll the odd dice to get Yahtzee
                                                    format("Trying to get Four of a Kind...~n"),
                                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                                    display_keeps(ThreeOfAKindIndices, DiceValues),
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = ThreeOfAKindIndices
                                                    
                                                )
                                            )


                                        ;
                                            % check for 2 of a kind, if yes, maybe full house?
                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                            ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                    format("Trying to get Full House...~n"),
                                                    custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                    display_keeps(FullHouseIndices, DiceValues),
                                                    reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = FullHouseIndices 
                                                ;
                                                    format("Trying to get Four of a Kind...~n"),
                                                    custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                    display_keeps(TwoOfAKindIndices, DiceValues),
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = TwoOfAKindIndices
                                                    
                                                    
                                                )
                                            ;   
                                                % reroll all dice
                                                format("Rerolling everything possible to get Four of a Kind"), nl,
                                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                NewKeptIndices = KeptIndices
                                            )

                                        
                                        )
                                    )
                                ;
                                % No Four of a kind, check for three of a kind/full house

                                    ( \+ is_category_filled(Scorecard, 7) -> 
                                        ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee

                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues)) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                                    CategoryScored = 9,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                ; 
                                                    update_scorecard(Scorecard, 7, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                                    CategoryScored = 7,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                    
                                            )
                                            

                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("Trying to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_keeps(FullHouseIndices, DiceValues),
                                                        reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = FullHouseIndices 
                                                    ;
                                                        format("Trying to get Three of a Kind??...~n"),
                                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                        display_keeps(TwoOfAKindIndices, DiceValues),
                                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = TwoOfAKindIndices                   
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Three of a Kind==="), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                    display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    NewKeptIndices = KeptIndices
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind444"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
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
                            update_scorecard(Scorecard, 8, DiceValues, RoundNum, PlayerID, NewScorecard), 
                            CategoryScored = 8,
                            display_msg(CategoryScored),
                            NewDiceValues = DiceValues,
                            NewKeptIndices = KeptIndices
                        ;   
                            giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                            ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee

                                (\+ is_category_filled(Scorecard, 9) -> 
                                    ( hasFullHouse(DiceValues)) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                        update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                        CategoryScored = 9,
                                        display_msg(CategoryScored),
                                        NewDiceValues = DiceValues,
                                        NewKeptIndices = KeptIndices
                                    ; 

                                    % reroll the odd dice to get Yahtzee
                                    format("Trying to get Four of a Kind...~n"),
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                    display_keeps(ThreeOfAKindIndices, DiceValues),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = ThreeOfAKindIndices
                                    
                                )   

                            ;
                                % check for 2 of a kind, if yes, maybe full house?
                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                        format("Trying to get Full House...~n"),
                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                        display_keeps(FullHouseIndices, DiceValues),
                                        reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = FullHouseIndices 
                                    ;
                                        format("Trying to get Four of a Kind...~n"),
                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                        display_keeps(TwoOfAKindIndices, DiceValues),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = TwoOfAKindIndices
                                        
                                            
                                    )
                                ;   
                                    % reroll all dice
                                    format("Rerolling everything possible to get Four of a Kind2323"), nl,
                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                    display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    NewKeptIndices = KeptIndices
                                )

                            
                            )
                        )
                    ;
                        % No Four of a kind, check for three of a kind/full house
                        ( \+ is_category_filled(Scorecard, 7) -> 
                            ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                               (\+ is_category_filled(Scorecard, 9) -> 
                                        ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                            update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                            CategoryScored = 9,
                                            display_msg(CategoryScored),
                                            NewDiceValues = DiceValues,
                                            NewKeptIndices = KeptIndices
                                        ; 
                                            update_scorecard(Scorecard, 7, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                            CategoryScored = 7,
                                            display_msg(CategoryScored),
                                            NewDiceValues = DiceValues,
                                            NewKeptIndices = KeptIndices
                                        )
                                ;
                                    update_scorecard(Scorecard, 7, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                    CategoryScored = 7,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                )




                            ;   
                                % check for 2 of a kind, if yes, maybe full house?
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("Trying to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_keeps(FullHouseIndices, DiceValues),
                                            reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = FullHouseIndices 
                                        ;
                                            format("Trying to get Three of a Kind))...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                            display_keeps(TwoOfAKindIndices, DiceValues),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = TwoOfAKindIndices                   
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible to get Three of a Kind"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                    )
                            )
                        ;

                            (\+ is_category_filled(Scorecard, 9) -> 
                                ( hasFullHouse(DiceValues) -> % If there is a Full House
                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                    CategoryScored = 9,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                ; 
                                    

                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) ->
                                    format("Trying to get Full House...~n"),
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                    display_keeps(ThreeOfAKindIndices, DiceValues),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = ThreeOfAKindIndices        

                                    
                                    ;
                                    % Try to get a Full House?
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAKindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("Trying to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_keeps(FullHouseIndices, DiceValues),
                                            reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = FullHouseIndices 
                                        ;

                                            format("Trying to get Full House++...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                            display_keeps(TwoOfAKindIndices, DiceValues),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = TwoOfAKindIndices                   
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                    )                                    
                                    )

                                )
                            ;
                                % reroll all dice
                                format("Rerolling everything possible to get Full House"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                NewKeptIndices = KeptIndices
                            )
                        )

                    )

                )
            )
        )
    .



% Base case: When there's only one category and one score, the result is the category.
find_highest_category([Category], [_], Category).

% Recursive case: Compare the first score with the maximum score in the rest of the list.
find_highest_category([Category1 | Categories], [Score1 | Scores], ResultCategory) :-
    find_highest_category(Categories, Scores, TempCategory),
    nth0(Index, Categories, TempCategory),
    nth0(Index, Scores, TempScore),
    (Score1 >= TempScore ->
        ResultCategory = Category1;
        ResultCategory = TempCategory).


display_msg(CategoryScored) :-
    find_category_name(CategoryScored, CategoryName),
    format("Computer decided to score on Category: ~w~n", [CategoryName]).

display_keeps(KeptIndices, DiceValues) :-
    find_dice_values(DiceValues, KeptIndices, KeptDiceValues),
    (KeptIndices \= [] -> format("Computer decided to keep these dices: ~w~n", [KeptDiceValues]), nl ; format("Computer decided to reroll all dices"), nl, nl).



% Attempt to score in the upper section
try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    (   CategoriesAvailableToScore = []
    ->  % No available categories here either
        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
        display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
        NewKeptIndices = KeptIndices
    ;   % Pick the best upper category (for simplicity, just do the same logic)
        
        find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
        get_score(HighestCategory, DiceValues, HighestScore),
        (HighestScore > 7 ->
            update_scorecard(Scorecard, HighestCategory, DiceValues, RoundNum, PlayerID, UpdatedScorecard),
            CategoryScored = HighestCategory,
            NewScorecard = UpdatedScorecard
        ;
            custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
            display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
            NewKeptIndices = KeptIndices
        )
    ).


try :-
    compile('scorecard.pl'),
    compile('dice.pl'),
    compile('human.pl'),
    Scorecard = [
        ["Ones", 1, 1, 1],
        ["Twos", 0, 0, 0],
        ["Threes", 0, 0, 0],
        ["Fours", 0, 0, 0],
        ["Fives", 5, 0, 1],
        ["Sixes", 0, 0, 0],
        ["Three of a Kind", 0, 0, 0],
        ["Four of a Kind", 0, 1, 2],
        ["Full House", 0, 1, 2],
        ["Four Straight", 0, 1, 3],
        ["Five Straight", 0, 1, 4],
        ["Yahtzee", 0, 1, 3]
    ],
    RoundNum is 1,
    format("Scorecard: ~w~n", [Scorecard]),
    format("Round: ~w~n", [RoundNum]),
    computer_turn(Scorecard, RoundNum, NewScorecard),
    computer_turn(NewScorecard, RoundNum, NewScorecard2),
    computer_turn(NewScorecard2, RoundNum, NewScorecard3),
    computer_turn(NewScorecard3, RoundNum, NewScorecard4),
    computer_turn(NewScorecard4, RoundNum, _)
    .


% hya :-
%     consult('scorecard.pl'),  % Load the file
%     isFourSequential([5, 4, 3, 2, 1], FourStraightIndices),
%     isThreeSequential([1, 2, 3, 4, 5], ThreeStraightIndices),
%     find_all_indices([5, 3, 3, 2, 1], [3,3,5], Indices),  % Ensure this is implemented
%     % Example placeholder for TwoOfaKindIndices (needs implementation)
%     TwoOfaKindIndices = [],  % Define it or calculate it properly
%     format("Four Straight Indices: ~w~n", [Indices]),
%     format("Three Straight Indices: ~w~n", [ThreeStraightIndices]),
%     format("Two of a Kind Indices: ~w~n", [TwoOfaKindIndices]).

%:- initialization(try).