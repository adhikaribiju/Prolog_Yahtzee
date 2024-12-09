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




% Main computer turn entry point
computer_turn_test(Scorecard, RoundNum, NewScorecard) :-
    PlayerID is 2,
    format("Computer Turn:"), nl,
    format("Round: ~d~n", [RoundNum]),
    display_scorecard(Scorecard),
    roll_dice(DiceValues),
    (   play_computer_turn_test(DiceValues, [], Scorecard, RoundNum, 0, NewScorecard)
    ->  format("Working as intended.~n")
    ;   format("Error: Failed to compute a valid turn.~n"),
        format("ani New Scorecard____: ~w~n", [NewScorecard])
    ).

% Recursive logic for the computer turn
play_computer_turn_test(DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewScorecard) :-
    format("Current Dice: ~w~n", [DiceValues]),
    NewRerollCount is RerollCount + 1,
    format("Reroll Count: ~w~n", [NewRerollCount]),
    display_available_combinations(DiceValues, Scorecard),
    availableCombinations(DiceValues, AvailableCategories),
    (   NewRerollCount =< 2
    ->  % Make a decision
        make_computer_decision_test(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, DecidedDiceValues, DecidedScorecard, DecidedKeptIndices),
        (   CategoryScored = 0
        ->  % No category scored, recurse with possibly updated dice
            play_computer_turn_test(DecidedDiceValues, DecidedKeptIndices, Scorecard, RoundNum, NewRerollCount, NewScorecard)
        ;   % Category scored, finalize
            NewScorecard = DecidedScorecard
        )
    ;   % No rerolls left, pick highest scoring category
        scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
        get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
        format("No rerolls left. Standing automatically.~n"),
        (   CategoriesAvailableToScore \= []
        ->  find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
            update_scorecard(Scorecard, HighestCategory, DiceValues, RoundNum, 2, FinalScorecard),
            format("Scored Highest Available Category: ~w~n", [HighestCategory]),
            display_msg(HighestCategory),
            NewScorecard = FinalScorecard
        ;   format("No available categories to score. Skipping turn.~n"),
            NewScorecard = Scorecard
        )
    ).


% Decide what to do with the current dice based on available categories and full sections
make_computer_decision_test(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, NewScorecard, NewKeptIndices) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    format("Categories Available to Score: ~w~n", [CategoriesAvailableToScore]),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    format("Scores of Categories Available to Score: ~w~n", [ScoresOfCategoriesAvailableToScore]), nl,

    % (   CategoriesAvailableToScore = []
    % ->  % No available categories, try rerolling or return with no score
    %     CategoryScored = 0,
    %     NewScorecard = Scorecard,
    %     NewDiceValues = DiceValues,
    %     NewKeptIndices = KeptIndices

    % ;   % We have some categories to score
        (   is_lower_section_full(Scorecard)
        ->  format("Lower section is full. Checking the upper section...~n"),
            (   is_upper_section_full(Scorecard)
            ->  format("Both sections full, no scoring possible.~n"),
                CategoryScored = 0,
                NewScorecard = Scorecard,
                NewDiceValues = DiceValues,
                NewKeptIndices = KeptIndices
            ;   format("Trying to fill the upper section...~n"),
                try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, NewScorecard, NewKeptIndices)
            )
        ;   % Lower section not full
            format("Trying to fill the lower section...~n"),
            try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, NewScorecard, NewKeptIndices)
        )
   % )
    
    .


% Attempt to score in the lower section
try_lower_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, NewScorecard, NewKeptIndices) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    %format("try_lower_section: Categories Available to Score: ~w~n", [CategoriesAvailableToScore]),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    %format("try_lower_section: Scores of Categories: ~w~n", [ScoresOfCategoriesAvailableToScore]),

        % Check if Yahtzee is available
        ( \+ is_category_filled(Scorecard, 12) ->
            (hasYahtzee(DiceValues) -> % If Yahtzee is Available to score, score it.
                update_scorecard(Scorecard, 12, DiceValues, RoundNum, 2, NewScorecard),
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
                    display_keeps(FourOfAKindIndices),
                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                    format("New Dice: ~w~n", [NewDiceValues]),
                    NewKeptIndices = FourOfAKindIndices
                ;   
                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee

                        (\+ is_category_filled(Scorecard, 9) -> 
                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                CategoryScored = 9,
                                display_msg(CategoryScored),
                                NewDiceValues = DiceValues,
                                NewKeptIndices = KeptIndices
                            ; 


                                % reroll the odd dice to get Yahtzee
                                format("Trying to get Yahtzee...~n"),
                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                display_keeps(ThreeOfAKindIndices),
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
                                update_scorecard(Scorecard, 11, DiceValues, RoundNum, 2, NewScorecard), 
                                CategoryScored = 11,
                                display_msg(CategoryScored),
                                NewDiceValues = DiceValues,
                                NewKeptIndices = KeptIndices
                            ;
                                format("Four Straight Check Gardai Chu3"), nl,
                                 % check for four straight
                                % try to get five straight
                                (isFourSequential(DiceValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                                    format("Trying to get Five Straight...~n"),
                                    custom_remove([1,2,3,4,5], FourStraightIndices, IndicesToReroll),
                                    display_keeps(FourStraightIndices),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = FourStraightIndices
                                ;
                                    % try to get five straight
                                    (isThreeSequential(DiceValues, ThreeStraightIndices), kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("Trying to get Five Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                        display_keeps(ThreeStraightIndices),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = ThreeStraightIndices
                                    ;
                                        format("Check Fail Vayo"), nl,
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtze"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices), % if dice is kept, display the kept indices
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
                                    update_scorecard(Scorecard, 10, DiceValues, RoundNum, 2, NewScorecard),
                                    CategoryScored = 10,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                ;
                                        % try to get five straight
                                        (isThreeSequential(DiceValues, ThreeStraightIndices), kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                                        format("Trying to get Four Straight...~n"),
                                        custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = ThreeStraightIndices
                                        ;
                                        % maybe there is 2 of a kind, but never mind, let's reroll everything
                                        format("Rerolling everything possible to get Yahtze"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                        )
                                )
                            ;
                                % At this point, no swquence/of a kind is available, so let's reroll everything
                                format("Rerolling everything possible to get Yahtze"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                display_keeps(KeptIndices), % if dice is kept, display the kept indices
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
                    update_scorecard(Scorecard, 11, DiceValues, RoundNum, 2, NewScorecard), 
                    CategoryScored = 11,
                    display_msg(CategoryScored),
                    NewDiceValues = DiceValues,
                    NewKeptIndices = KeptIndices
                ;
                    format("Four Straight Check Gardai Chu1"), nl,
                        % check for four straight
                    % try to get five straight
                    (isFourSequential(DiceValues, FourStraightIndices), kept_indices_checker(KeptIndices, FourStraightIndices) ->
                        format("Trying to get Five Straight...~n"),
                        custom_remove([1,2,3,4,5], FourStraightIndices, IndicesToReroll),
                        display_keeps(FourStraightIndices),
                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                        format("New Dice: ~w~n", [NewDiceValues]),
                        NewKeptIndices = FourStraightIndices
                    ;
                        % try to get five straight
                        (isThreeSequential(DiceValues, ThreeStraightIndices), kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
                            format("Trying to get Five Straight...~n"),
                            custom_remove([1,2,3,4,5], ThreeStraightIndices, IndicesToReroll),
                            display_keeps(ThreeStraightIndices),
                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                            format("New Dice: ~w~n", [NewDiceValues]),
                            NewKeptIndices = ThreeStraightIndices
                        ;

                            % check for 4 of a kind, full house, 3 of a kind and 2 of a kind
                        
                            
                            % check if 4 of a kind is filled
                            ( \+ is_category_filled(Scorecard, 8) -> 
                                ( hasFourOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                    update_scorecard(Scorecard, 8, DiceValues, RoundNum, 2, NewScorecard), 
                                    CategoryScored = 8,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                
                                ;   
                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                        format("MUJI LADO KHA"),
                                        (\+ is_category_filled(Scorecard, 9) -> 
                                            ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                                CategoryScored = 9,
                                                display_msg(CategoryScored),
                                                NewDiceValues = DiceValues,
                                                NewKeptIndices = KeptIndices
                                            ; 
                                                % reroll the odd dice to get Yahtzee
                                                format("Trying to get Four of a Kind...~n"),
                                                custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                                display_keeps(ThreeOfAKindIndices),
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = ThreeOfAKindIndices
                                                
                                            )
                                        )



                                    ;
                                        % check for 2 of a kind, if yes, maybe full house?
                                        giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                        ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                            (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                format("Trying to get Full House...~n"),
                                                custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                display_keeps(FullHouseIndices),
                                                reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = ThreeOfAKindIndices 
                                            ;
                                                format("Trying to get Four of a Kind...~n"),
                                                custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                display_keeps(TwoOfAKindIndices),
                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                format("New Dice: ~w~n", [NewDiceValues]),
                                                NewKeptIndices = TwoOfAKindIndices
                                                
                                                  
                                            )
                                        ;   
                                            % reroll all dice
                                            format("Rerolling everything possible to get Four of a Kind???"), nl,
                                            custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                            display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            NewKeptIndices = KeptIndices
                                        )

                                    
                                    )
                                )
                            ;
                               % No Four of a kind, check for three of a kind/full house

                                            (\+ is_category_filled(Scorecard, 9) -> 

                                        
                                            ( hasFullHouse(DiceValues)) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee
                                                update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                                CategoryScored = 9,
                                                display_msg(CategoryScored),
                                                NewDiceValues = DiceValues,
                                                NewKeptIndices = KeptIndices
                                            ; 
                                                ( \+ is_category_filled(Scorecard, 7) -> 
                                                    ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                        update_scorecard(Scorecard, 7, DiceValues, RoundNum, 2, NewScorecard), 
                                                        CategoryScored = 7,
                                                        display_msg(CategoryScored),
                                                        NewDiceValues = DiceValues,
                                                        NewKeptIndices = KeptIndices
                                                    ;   
                                                        % check for 2 of a kind, if yes, maybe full house?
                                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                            ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                                (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                                    format("Trying to get Full House...~n"),
                                                                    custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                                    display_keeps(FullHouseIndices),
                                                                    reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                                    NewKeptIndices = ThreeOfAKindIndices 
                                                                ;
                                                                    format("Trying to get Three of a Kind...~n"),
                                                                    custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                                    display_keeps(TwoOfAKindIndices),
                                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                                    NewKeptIndices = TwoOfAKindIndices                   
                                                                )
                                                            ;   
                                                                % reroll all dice
                                                                format("Rerolling everything possible to get Four of a Kind111"), nl,
                                                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                                display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                                                reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                                NewKeptIndices = KeptIndices
                                                            )
                                                    )
                                                ;
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Four of a Kind..."), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                    display_keeps(KeptIndices), % if dice is kept, display the kept indices
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
                        update_scorecard(Scorecard, 10, DiceValues, RoundNum, 2, NewScorecard),
                        CategoryScored = 10,
                        display_msg(CategoryScored),
                        NewDiceValues = DiceValues,
                        NewKeptIndices = KeptIndices
                    ;
                            % try to get five straight
                            (isThreeSequential(DiceValues, ThreeStraightIndices), kept_indices_checker(KeptIndices, ThreeStraightIndices) ->
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
                                        update_scorecard(Scorecard, 8, DiceValues, RoundNum, 2, NewScorecard), 
                                        CategoryScored = 8,
                                        display_msg(CategoryScored),
                                        NewDiceValues = DiceValues,
                                        NewKeptIndices = KeptIndices
                                    ;   
                                        giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                        ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee


                                            (\+ is_category_filled(Scorecard, 9) -> 
                                                ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                                    CategoryScored = 9,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                ; 

                                                    % reroll the odd dice to get Yahtzee
                                                    format("Trying to get Four of a Kind...~n"),
                                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                                    display_keeps(ThreeOfAKindIndices),
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = ThreeOfAKindIndices
                                                    
                                                )
                                            )


                                        ;
                                            % check for 2 of a kind, if yes, maybe full house?
                                            giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                            ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                    format("Trying to get Full House...~n"),
                                                    custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                    display_keeps(FullHouseIndices),
                                                    reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = ThreeOfAKindIndices 
                                                ;
                                                    format("Trying to get Four of a Kind...~n"),
                                                    custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                    display_keeps(TwoOfAKindIndices),
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    format("New Dice: ~w~n", [NewDiceValues]),
                                                    NewKeptIndices = TwoOfAKindIndices
                                                    
                                                    
                                                )
                                            ;   
                                                % reroll all dice
                                                format("Rerolling everything possible to get Four of a Kind---"), nl,
                                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                display_keeps(KeptIndices), % if dice is kept, display the kept indices
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
                                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                                    CategoryScored = 9,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                ; 
                                                    update_scorecard(Scorecard, 7, DiceValues, RoundNum, 2, NewScorecard), 
                                                    CategoryScored = 7,
                                                    display_msg(CategoryScored),
                                                    NewDiceValues = DiceValues,
                                                    NewKeptIndices = KeptIndices
                                                    
                                            )
                                            

                                        ;   
                                            % check for 2 of a kind, if yes, maybe full house?
                                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                                ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                                        format("Trying to get Full House...~n"),
                                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                                        display_keeps(FullHouseIndices),
                                                        reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = ThreeOfAKindIndices 
                                                    ;
                                                        format("Trying to get Three of a Kind??...~n"),
                                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                                        display_keeps(TwoOfAKindIndices),
                                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                        format("New Dice: ~w~n", [NewDiceValues]),
                                                        NewKeptIndices = TwoOfAKindIndices                   
                                                    )
                                                ;   
                                                    % reroll all dice
                                                    format("Rerolling everything possible to get Four of a Kind==="), nl,
                                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                                    display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                                    NewKeptIndices = KeptIndices
                                                )
                                        )
                                    ;
                                        % reroll all dice
                                        format("Rerolling everything possible to get Four of a Kind444"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices), % if dice is kept, display the kept indices
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
                            update_scorecard(Scorecard, 8, DiceValues, RoundNum, 2, NewScorecard), 
                            CategoryScored = 8,
                            display_msg(CategoryScored),
                            NewDiceValues = DiceValues,
                            NewKeptIndices = KeptIndices
                        ;   
                            giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                            ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) -> % If there is a three of a kind, reroll the odd dice to get Yahtzee

                                (\+ is_category_filled(Scorecard, 9) -> 
                                    ( hasFullHouse(DiceValues)) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                        update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                        CategoryScored = 9,
                                        display_msg(CategoryScored),
                                        NewDiceValues = DiceValues,
                                        NewKeptIndices = KeptIndices
                                    ; 

                                    % reroll the odd dice to get Yahtzee
                                    format("Trying to get Four of a Kind...~n"),
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                    display_keeps(ThreeOfAKindIndices),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = ThreeOfAKindIndices
                                    
                                )   

                            ;
                                % check for 2 of a kind, if yes, maybe full house?
                                giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                    (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                        format("Trying to get Full House...~n"),
                                        custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                        display_keeps(FullHouseIndices),
                                        reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = ThreeOfAKindIndices 
                                    ;
                                        format("Trying to get Four of a Kind...~n"),
                                        custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                        display_keeps(TwoOfAKindIndices),
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        format("New Dice: ~w~n", [NewDiceValues]),
                                        NewKeptIndices = TwoOfAKindIndices
                                        
                                            
                                    )
                                ;   
                                    % reroll all dice
                                    format("Rerolling everything possible to get Four of a Kind2323"), nl,
                                    custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                    display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    NewKeptIndices = KeptIndices
                                )

                            
                            )
                        )
                    ;
                        % No Four of a kind, check for three of a kind/full house
                        format("yoo??"),
                        ( \+ is_category_filled(Scorecard, 7) -> 
                            ( hasThreeOfAKind(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                            format("yeta??"),
                               (\+ is_category_filled(Scorecard, 9) -> 
                                        ( hasFullHouse(DiceValues) -> % If there is a four of a kind, reroll the odd dice to get Yahtzee
                                            update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                            CategoryScored = 9,
                                            display_msg(CategoryScored),
                                            NewDiceValues = DiceValues,
                                            NewKeptIndices = KeptIndices
                                        ; 

                                            update_scorecard(Scorecard, 8, DiceValues, RoundNum, 2, NewScorecard), 
                                            CategoryScored = 8,
                                            display_msg(CategoryScored),
                                            NewDiceValues = DiceValues,
                                            NewKeptIndices = KeptIndices
                                        )
                                ;
                                    update_scorecard(Scorecard, 8, DiceValues, RoundNum, 2, NewScorecard), 
                                    CategoryScored = 8,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                )




                            ;   
                                % check for 2 of a kind, if yes, maybe full house?
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("Trying to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_keeps(FullHouseIndices),
                                            reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = ThreeOfAKindIndices 
                                        ;
                                            format("Trying to get Three of a Kind))...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                            display_keeps(TwoOfAKindIndices),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = TwoOfAKindIndices                   
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible to get Four?? of a Kind"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                    )
                            )
                        ;

                            (\+ is_category_filled(Scorecard, 9) -> 
                                ( hasFullHouse(DiceValues) -> % If there is a Full House
                                    update_scorecard(Scorecard, 9, DiceValues, RoundNum, 2, NewScorecard), 
                                    CategoryScored = 9,
                                    display_msg(CategoryScored),
                                    NewDiceValues = DiceValues,
                                    NewKeptIndices = KeptIndices
                                ; 
                                    

                                    giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices),
                                    ( hasThreeOfAKind(DiceValues), kept_indices_checker(KeptIndices, ThreeOfAKindIndices) ->
                                    format("Trying to get Full House...~n"),
                                    custom_remove([1,2,3,4,5], ThreeOfAKindIndices, IndicesToReroll),
                                    display_keeps(ThreeOfAKindIndices),
                                    reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                    format("New Dice: ~w~n", [NewDiceValues]),
                                    NewKeptIndices = ThreeOfAKindIndices        

                                    
                                    ;
                                    % Try to get a Full House?
                                    giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices),
                                    ( (length(TwoOfAkindIndices, 2)), kept_indices_checker(KeptIndices, TwoOfAKindIndices) -> 
                                        (checkUniqueAmongPairs(DiceValues, [OddIndex]) ->
                                            format("Trying to get Full House...~n"),
                                            custom_remove([1,2,3,4,5], OddIndex, FullHouseIndices),
                                            display_keeps(FullHouseIndices),
                                            reroll_dice(DiceValues, OddIndex, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = ThreeOfAKindIndices 
                                        ;

                                            format("Trying to get Full House++...~n"),
                                            custom_remove([1,2,3,4,5], TwoOfAKindIndices, IndicesToReroll),
                                            display_keeps(TwoOfAKindIndices),
                                            reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                            format("New Dice: ~w~n", [NewDiceValues]),
                                            NewKeptIndices = TwoOfAKindIndices                   
                                        )
                                    ;   
                                        % reroll all dice
                                        format("Rerolling everything possible to get Four?? of a Kind"), nl,
                                        custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                        display_keeps(KeptIndices), % if dice is kept, display the kept indices
                                        reroll_dice(DiceValues, IndicesToReroll, NewDiceValues),
                                        NewKeptIndices = KeptIndices
                                    )                                    
                                    )

                                )
                            ;
                                % reroll all dice
                                format("Rerolling everything possible to get Full House"), nl,
                                custom_remove([1,2,3,4,5], KeptIndices, IndicesToReroll),
                                display_keeps(KeptIndices), % if dice is kept, display the kept indices
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

display_keeps(KeptIndices) :-
    (KeptIndices \= [] -> format("Computer decided to keep positions: ~w~n", [KeptIndices]) ; nl).



% Attempt to score in the upper section
try_upper_section(CategoryScored, DiceValues, KeptIndices, Scorecard, RoundNum, RerollCount, NewDiceValues, NewScorecard, NewKeptIndices) :-
    scoreableCombinations(DiceValues, Scorecard, CategoriesAvailableToScore),
    format("try_upper_section: Categories Available: ~w~n", [CategoriesAvailableToScore]),
    get_scores_for_categories(CategoriesAvailableToScore, DiceValues, ScoresOfCategoriesAvailableToScore),
    format("try_upper_section: Scores: ~w~n", [ScoresOfCategoriesAvailableToScore]),
    (   CategoriesAvailableToScore = []
    ->  % No available categories here either
        CategoryScored = 0,
        NewScorecard = Scorecard,
        NewDiceValues = DiceValues,
        NewKeptIndices = KeptIndices
    ;   % Pick the best upper category (for simplicity, just do the same logic)
        find_highest_category(CategoriesAvailableToScore, ScoresOfCategoriesAvailableToScore, HighestCategory),
        update_scorecard(Scorecard, HighestCategory, DiceValues, RoundNum, 2, UpdatedScorecard),
        format("Scored category ~w in upper section.~n", [HighestCategory]),
        CategoryScored = HighestCategory,
        NewScorecard = UpdatedScorecard,
        NewDiceValues = DiceValues,
        NewKeptIndices = KeptIndices
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
        ["Fives", 5, 2, 1],
        ["Sixes", 0, 0, 0],
        ["Three of a Kind", 25, 2, 2],
        ["Four of a Kind", 30, 1, 2],
        ["Full House", 0, 0, 0],
        ["Four Straight", 30, 0, 0],
        ["Five Straight", 20, 0, 0],
        ["Yahtzee", 50, 0, 0]
    ],
    RoundNum is 1,
    format("Scorecard: ~w~n", [Scorecard]),
    format("Round: ~w~n", [RoundNum]),
    computer_turn_test(Scorecard, RoundNum, NewScorecard),
    computer_turn_test(NewScorecard, RoundNum, NewScorecard2),
    computer_turn_test(NewScorecard2, RoundNum, NewScorecard3),
    computer_turn_test(NewScorecard3, RoundNum, NewScorecard4),
    computer_turn_test(NewScorecard4, RoundNum, NewScorecard5)
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

    


hya :-
    compile('dice.pl'),
    compile('scorecard.pl'),
    DiceValues = [1,1,1,2,4],

   % check hasYahtzee, hasFullHouse, hasFourOfAKind, hasThreeOfAKind, hasTwoOfAKind
    (hasYahtzee(DiceValues) -> format("Yahtzee is available.~n"); format("Yahtzee is not available.~n")),
    (hasFullHouse(DiceValues) -> format("Full House is available.~n"); format("Full House is not available.~n")),
    (hasFourOfAKind(DiceValues) -> format("Four of a Kind is available.~n"); format("Four of a Kind is not available.~n")),
    (hasThreeOfAKind(DiceValues) -> format("Three of a Kind is available.~n"); format("Three of a Kind is not available.~n")),

    % check getThreeOfaKindIndices, getTwoOfaKindIndices
    (giveThreeOfaKindIndices(DiceValues, ThreeOfAKindIndices) -> format("Three of a Kind indices: ~w~n", [ThreeOfAKindIndices]); format("Three of a Kind indices not available.~n")),
    (giveTwoOfaKindIndices(DiceValues, TwoOfAKindIndices) -> format("Two of a Kind indices: ~w~n", [TwoOfAKindIndices]); format("Two of a Kind indices not available.~n")).

    % Initialization directive
:- initialization(try).

