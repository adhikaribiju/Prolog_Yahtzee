

% Predicate Name: computer_turn/3
% Description: Simulates the computer's turn in a dice game, updating the scorecard.
% Parameters:
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   NewScorecard: The updated scorecard after the computer's turn.
% Algorithm:
%   1. Display the current game state (round number and scorecard).
%   2. Generate a set of random dice rolls.
%   3. Analyze the dice rolls and the current scorecard to determine the best scoring option.
%   4. Update the scorecard with the chosen scoring option.
%   5. If no valid scoring option is found, leave the scorecard unchanged. 
% Reference: None
% *********************************************************************
computer_turn(Scorecard, RoundNum, NewScorecard) :-
    nl,
    PlayerID is 2,
    format("Computer Turn:"), nl,
    format("Round: ~d~n", [RoundNum]), nl,
    display_scorecard(Scorecard), nl,
    roll_dice(DiceValues),
    (   play_computer_turn(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard, PlayerID)->  nl;  NewScorecard = Scorecard).


% Predicate Name: play_computer_turn/7
% Description:  Determines and executes the computer's move in a dice game.
% Parameters:
%   DiceValues: A list of the current dice values.
%   KeptIndices: A list of indices of dice to keep (not reroll).
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   RerollCount: The number of times the dice have been rerolled this turn.
%   NewScorecard: The updated scorecard after the computer's move.
%   PlayerID:  The ID of the player (in this case, the computer).
% Algorithm:
%   1. Display the current dice values and roll count.
%   2. If available, display a list of possible scoring combinations and potential categories to aim for.
%   3. If the reroll count is less than or equal to 2:
%       a. Use a decision-making process (make_computer_decision/9) to choose a scoring category and potentially reroll some dice.
%       b. If a category is scored (CategoryScored is not 0), update the scorecard with the chosen category.
%       c. If no category is scored, recursively call play_computer_turn/7 with the updated dice and incremented reroll count.
%   4. If the reroll count is greater than 2 (no rerolls left):
%       a. Identify all scoreable combinations based on the current dice and scorecard.
%       b. Calculate the potential score for each available category.
%       c. If there are any scoreable categories:
%           i.  Select the category with the highest potential score.
%           ii. Update the scorecard with the selected category.
%       d. If there are no scoreable categories, leave the scorecard unchanged.
% Reference: None
% *********************************************************************
play_computer_turn(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard,PlayerID) :-
    format("Current Dice: ~w~n", [DiceValues]),
    NewRerollCount is RerollCount + 1,
    nl, format("Roll Count: ~w~n", [NewRerollCount]),nl,
    (display_available_combinations(DiceValues, Scorecard)-> true; nl),
    (display_potential_categories(DiceValues, Scorecard, RerollCount, _)->true; nl),
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


% Predicate Name: make_computer_decision/9
% Description:  Decides the computer's move in a dice game, potentially scoring a category or rerolling dice.
% Parameters:
%   CategoryScored: An output variable indicating the category scored (0 if none).
%   DiceValues: A list of the current dice values.
%   KeptIndices: A list of indices of dice to keep (not reroll).
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   NewDiceValues:  The updated dice values after potential rerolls.
%   NewScorecard: The updated scorecard after the decision (if a category is scored).
%   NewKeptIndices: The updated list of kept dice indices.
%   PlayerID: The ID of the player (in this case, the computer).
% Algorithm:
%   1. Check if the lower section of the scorecard is full.
%      a. If the lower section is full, check if the upper section is also full.
%          i. If both sections are full, no category can be scored, so set CategoryScored to 0 and leave the scorecard and dice unchanged.
%         ii. If only the lower section is full, try scoring in the upper section (try_upper_section/9).
%      b. If the lower section is not full, try scoring in the lower section (try_lower_section/9).
% Reference: None
% *********************************************************************
make_computer_decision(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID) :-
    (   is_lower_section_full(Scorecard)
    ->  (   is_upper_section_full(Scorecard)
        ->  CategoryScored = 0,
            NewScorecard = Scorecard,
            NewDiceValues = DiceValues,
            NewKeptIndices = KeptIndices
        ;   try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID)
        )
    ;   try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, NewDiceValues, NewScorecard, NewKeptIndices,PlayerID)
    ).



% Predicate Name: try_lower_section/9
% Description: Attempts to find a scoring opportunity in the lower section of the scorecard.
% Parameters:
%   CategoryScored: An output variable indicating the category scored (0 if none).
%   DiceValues: A list of the current dice values.
%   KeptIndices: A list of indices of dice to keep (not reroll).
%   Scorecard: The current scorecard.
%   RoundNum: The current round number.
%   NewDiceValues:  The updated dice values after potential rerolls.
%   NewScorecard: The updated scorecard after the decision (if a category is scored).
%   NewKeptIndices: The updated list of kept dice indices.
%   PlayerID: The ID of the player (in this case, the computer).
% Algorithm: 
%  This algorithm prioritizes scoring and achieving Yahtzee, then large straights, then other lower section combinations. 
%  It attempts to reroll dice strategically to improve the chances of getting these combinations.
%   1. Check if Yahtzee (category 12) is available on the scorecard:
%       a. If Yahtzee is available:
%           i.  If the current dice form a Yahtzee, score it.
%           ii. If not, try to get a Yahtzee:
%               * Prioritize keeping four-of-a-kind, then three-of-a-kind, then two-of-a-kind, rerolling other dice.
%               * If no matching dice, reroll everything.
%       b. If Yahtzee is not available:
%           i.  Check if a five straight (category 11) is available:
%               * If the current dice form a five straight, score it.
%               * If not, try to get a five straight:
%                   + Prioritize keeping four sequential dice, then three sequential dice, then a wildcard die with three sequential dice.
%                   + If no sequence, check for and prioritize keeping four-of-a-kind, then full house, then three-of-a-kind, then two-of-a-kind.
%                   + If none of the above, reroll everything.
%           ii. If a five straight is not available, check if a four straight (category 10) is available:
%               * If the current dice form a four straight, score it.
%               * If not, try to get a four straight:
%                   + Prioritize keeping three sequential dice.
%                   + If no sequence, check for and prioritize keeping four-of-a-kind, then full house, then three-of-a-kind, then two-of-a-kind.
%                   + If none of the above, reroll everything.
%           iii. If neither five straight nor four straight is available, proceed with checking for other combinations in a similar manner, prioritizing four-of-a-kind, then full house, then three-of-a-kind.
%  Throughout the process, if a combination is found that can be scored, the scorecard is updated, and the CategoryScored variable is set accordingly.
% Reference: None
% *********************************************************************
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
                        ;
                                % reroll the odd dice to get Yahtzee
                                format("Trying to get Yahtzee...~n"),
                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                display_keeps(ThreeOfAKindIndices, DiceValues),
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                format("New Dice: ~w~n", [NewDiceValues]),
                                NewKeptIndices = ThreeOfAKindIndices

                        )



                    ;  
                        %format("Straight Check Gardai Chu2"), nl,
                        % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
                        ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                            (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                                update_scorecard(Scorecard, 11, DiceValues, RoundNum, PlayerID, NewScorecard), 
                                CategoryScored = 11,
                                display_msg(CategoryScored),
                                NewDiceValues = DiceValues,
                                NewKeptIndices = KeptIndices
                            ;
                                %format("Four Straight Check Gardai Chu3"), nl,
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
                                        (find_wildcard_index(DiceValues, WildcardIndex), kept_indices_checker(KeptIndices, [WildcardIndex]) ->
                                            format("Trying to get Five Straight...~n"),
                                            custom_remove([1,2,3,4,5], [WildcardIndex], IndicesToKeep2),
                                            display_keeps(IndicesToKeep2, DiceValues),
                                            reroll_dice(DiceValues, [WildcardIndex], NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = []
                                        ;
                                            format("Trying to get Five Straight...~n"),
                                            custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                            display_keeps(ThreeStraightIndices, DiceValues),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = ThreeStraightIndices
                                        )
                                        
                                    ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            format("Trying to get Yahtzee...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                            display_keeps(TwoOfAKindIndices, DiceValues),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = TwoOfAKindIndices
                                        ;   
                                            format("Rerolling everything possible to get Yahtzee"), nl,
                                            custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                            display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            NewKeptIndices = KeptIndices
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
                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                            ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                format("Trying to get Yahtzee...~n"),
                                                custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                display_keeps(TwoOfAKindIndices, DiceValues),
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = TwoOfAKindIndices
                                            ;   
                                                format("Rerolling everything possible to get Yahtzee"), nl,
                                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                display_keeps(KeptIndices, DiceValues), % if dice is kept, display the kept indices
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                NewKeptIndices = KeptIndices
                                            )
                                        )
                                )
                            ;
                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                ( member(Length, [2]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    format("Trying to get Yahtzee...~n"),
                                    custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                    display_keeps(TwoOfAKindIndices, DiceValues),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = TwoOfAKindIndices
                                ;   
                                    format("Rerolling everything possible to get Yahtzee"), nl,
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
           % At this point, Yahtzee is not availble on the scorecard.
            % Let's try sequence then of a kind)
            % At this point, the dice doesn't have 4 of a kind or 3 of a kind, so let's see if there is sequence
            ( \+ is_category_filled(Scorecard, 11) -> % Check if Five Straight is filled
                (hasFiveStraight(DiceValues) -> % If Five Straight is Available to score, score it.
                    update_scorecard(Scorecard, 11, DiceValues, RoundNum, PlayerID, NewScorecard), 
                    CategoryScored = 11,
                    display_msg(CategoryScored),
                    NewDiceValues = DiceValues,
                    NewKeptIndices = KeptIndices
                ;
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
                            (find_wildcard_index(DiceValues, WildcardIndex), kept_indices_checker(KeptIndices, [WildcardIndex]) ->
                                format("Trying to get Five Straight...~n"),
                                custom_remove([1,2,3,4,5], [WildcardIndex], IndicesToKeep2),
                                display_keeps(IndicesToKeep2, DiceValues),
                                reroll_dice(DiceValues, [WildcardIndex], NewDiceValues),
                                format("New Dice: ~w~n", [NewDiceValues]),
                                NewKeptIndices = []
                            ;
                                format("Trying to get Five Straight...~n"),
                                custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                display_keeps(ThreeStraightIndices, DiceValues),
                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                format("New Dice: ~w~n", [NewDiceValues]),
                                NewKeptIndices = ThreeStraightIndices
                            )
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
                                        giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                        ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                                            giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                            ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                                        format("Rerolling everything possible to get Three of a Kind"), nl,
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
                                giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                                    giveTwoOfaKindOrFourIndices(DiceValues, TwoOfAKindIndices),
                                    ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
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
                            %format("yetai ho hajue?"), nl,
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
                                        ( member(Length, [2, 4]), length(TwoOfAKindIndices, Length), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("Trying to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_keeps(FullHouseIndices, DiceValues),
                                                reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = FullHouseIndices 
                                            ;
                                                format("Trying to get Full House...~n"),
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
        ).





% Predicate Name: find_highest_category/3
% Description: Finds the category with the highest score from a list of categories and their corresponding scores.
% Parameters:
%   Categories: A list of categories.
%   Scores: A list of scores corresponding to the categories.
%   ResultCategory: The category with the highest score.
% Algorithm:
%   1. Base Case: If there's only one category, return that category as the result.
%   2. Recursive Case:
%       a. Recursively find the highest-scoring category from the rest of the list (excluding the first category and score).
%       b. Compare the score of the first category (Score1) with the score of the highest-scoring category found in the recursive step (TempScore).
%       c. If Score1 is greater than TempScore, return the first category (Category1) as the result.
%       d. Otherwise, return the highest-scoring category found in the recursive step (TempCategory) as the result.
% Reference: None
% *********************************************************************
find_highest_category([Category], [_], Category). % Base case: When there's only one category and one score, the result is the category.
find_highest_category([Category1 | Categories], [Score1 | Scores], ResultCategory) :-
    find_highest_category(Categories, Scores, TempCategory),
    nth0(Index, Categories, TempCategory),
    nth0(Index, Scores, TempScore),
    (Score1 > TempScore ->
        ResultCategory = Category1;
        ResultCategory = TempCategory).


% *********************************************************************
% Predicate Name: display_msg
% Purpose: To display the category that the computer scored in
% Parameters:
    % CategoryScored: The category that the computer scored in
% Algorithm:
    % 1. Find the name of the category that the computer scored in
    % 2. Display the category that the computer scored in
% Reference: None
% *********************************************************************
display_msg(CategoryScored) :-
    find_category_name(CategoryScored, CategoryName),
    format("Computer decided to score on Category: ~w~n", [CategoryName]).

% *********************************************************************
% Predicate Name: display_keeps
% Purpose: To display the indices of the dice that the computer kept
% Parameters:
    % KeptIndices: The indices of the dice that the computer kept
    % DiceValues: The values of the dice
% Algorithm:
    % 1. Find the values of the dice that the computer kept
    % 2. If the computer kept any dice, display the values of the dice
    % 3. If the computer did not keep any dice, display that the computer decided to reroll all dice
% Reference: None
% *********************************************************************
display_keeps(KeptIndices, DiceValues) :-
    find_dice_values(DiceValues, KeptIndices, KeptDiceValues),
    (KeptIndices \= [] -> format("Computer decided to keep these dices: ~w~n", [KeptDiceValues]), nl ; format("Computer decided to reroll all dices"), nl, nl).



% *********************************************************************
% Predicate Name: try_upper_section
% Purpose: To try to score in the upper section of the scorecard
% Parameters:
    % CategoryScored: The category that the computer scored in
    % DiceValues: The values of the dice
    % KeptIndices: The indices of the dice that the computer kept
    % Scorecard: The scorecard of the computer
    % RoundNum: The current round number
    % NewDiceValues: The new values of the dice after rerolling
    % NewScorecard: The new scorecard of the computer
    % NewKeptIndices: The new indices of the dice that the computer kept
    % PlayerID: The ID of the player
% Algorithm:
    % 1. Get the categories that are available to score
    % 2. Get the scores of the categories available to score
    % 3. If there are no available categories to score, reroll the dice
    % 4. If there are available categories to score, pick the best category and score it
    % 5. If the score is greater than 7, update the scorecard and return the category scored
    % 6. If the score is less than 7, reroll the dice
% Reference: None
% *********************************************************************
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
