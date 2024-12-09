:-compile('scorecard.pl').
:-compile('human.pl').
:-compile('computer.pl').
:-compile('dice.pl').
:-compile('file_handling.pl').

% Entry point of the program
start :-
    display_options,
    read_input_display(Choice), nl,
    handle_choice(Choice).

% Display the menu options to the user
display_options :-
    nl,
    write("Welcome to Yahtzee!"), nl, nl,
    write("Please select one of the following"), nl, nl,
    write("1. Start Game"), nl,
    write("2. Load Game"), nl,
    write("3. Exit"), nl, nl.

% Read user input as a string
read_input_display(Input) :-
    write("Enter your choice: "),
    read_line_to_string(user_input, Input).

read_input(Input) :-
    read_line_to_string(user_input, Input).

% Handle the user's choice
handle_choice("1") :-
    start_game.
handle_choice("2") :-
    load_scorecard(Scorecard,RoundNum),
    nl,
    calculate_final_scores(Scorecard, HumanScore, ComputerScore),
    write("Your Score: "), write(HumanScore), nl,
    write("Computer's Score: "), write(ComputerScore), nl, nl,
    %format("Round Number: ~w~n", [RoundNum]),
    %display_scorecard(Scorecard), nl,
    nl,
    NewRoundNo is RoundNum - 1,
    player_with_lowest_score(Scorecard, NewPlayerID),
    play_consecutive_rounds(Scorecard,NewRoundNo,NewPlayerID).
handle_choice("3") :-
    write("Exiting program..."), nl, nl.
handle_choice(_) :-
    write("Invalid choice, please try again."), nl,
    start.

% Begin the game
start_game :-
    nl,
    write("Rolling the dice to determine who starts the round.... "), nl,
    write("Enter 'M' for manual or 'R' for random: "), nl,
    read_input(Method), nl,
    handle_method(Method).

% Handle input method (manual or random)
handle_method("M") :-
    manual_input.
handle_method("R") :-
    random_input.
handle_method(_) :-
    write("Invalid input, please try again."), nl,
    start_game.

% Manual input for both players
manual_input :-
    write("Enter a number for your dice (1-6): "), nl,
    read_input(P1String),
    parse_number(P1String, P1),
    validate_number(P1),
    write("Enter a number for Computer's dice (1-6): "), nl,
    read_input(P2String),
    parse_number(P2String, P2),
    validate_number(P2),
    determine_toss_winner(P1, P2).

% Parse input string to a number
parse_number(Input, Number) :-
    number_string(Number, Input).

% Random input for both players
random_input :-
    random_between(1, 6, P1),
    random_between(1, 6, P2),
    write("You rolled: "), write(P1), nl,
    write("Computer rolled: "), write(P2), nl,
    determine_toss_winner(P1, P2).

% Validate the number is between 1 and 6
validate_number(N) :-
    (N >= 1, N =< 6 ->
        true
    ;
        write("Invalid number, please enter a number between 1 and 6."), nl,
        manual_input
    ).

% Determine the winner or if it's a draw
determine_toss_winner(P1, P2) :-
    nl,
    (P1 > P2 ->
        write("You won!"), nl, nl,
        start_round(1)
    ;
    P1 < P2 ->
        write("Computer won!"), nl, nl,
        start_round(2)
    ;
        write("It's a draw!"), nl, nl,
        start_game
    ).


% Start a new round
start_round(PlayerID) :-
    initialize_scorecard(Scorecard),
    RoundNum is 1,
    (PlayerID =:= 1 ->
        human_turn(Scorecard, RoundNum, NewScorecard),
        computer_turn(NewScorecard, RoundNum, RoundEndScorecard)
    ;
    PlayerID =:= 2 ->
        computer_turn(Scorecard,RoundNum, NewScorecard),
        human_turn(NewScorecard, RoundNum, RoundEndScorecard)
    ),
    player_with_lowest_score(RoundEndScorecard, NewPlayerID),
    ask_to_save_game(RoundEndScorecard, RoundNum),
    play_consecutive_rounds(RoundEndScorecard,RoundNum,NewPlayerID).


% Play consecutive rounds
play_consecutive_rounds(Scorecard, RoundNum, PlayerID) :-
    NewRoundNo is RoundNum + 1,
    %write("Starting Consecutive round"), nl,
    (PlayerID =:= 2 ->
        computer_turn(Scorecard, NewRoundNo, TempScorecard),
            (handle_end_game(TempScorecard, NewRoundNo) -> 
                true, NewScorecard = TempScorecard
            ;
                human_turn(TempScorecard, NewRoundNo, NewScorecard))
    ;
        human_turn(Scorecard, NewRoundNo, TempScorecard),
            (handle_end_game(TempScorecard, NewRoundNo) -> 
                true, NewScorecard = TempScorecard
            ;
                computer_turn(TempScorecard, NewRoundNo, NewScorecard))
    ),
    % This block runs only if handle_end_game does not succeed
    (is_scorecard_full(NewScorecard) ->
        write("Game over!"), nl,
        display_final_scores(NewScorecard)
    ;
        ask_to_save_game(NewScorecard, NewRoundNo),
        player_with_lowest_score(NewScorecard, NewPlayerID),
        play_consecutive_rounds(NewScorecard, NewRoundNo, NewPlayerID)
    ).


% check if the scorecard is full
handle_end_game(Scorecard, _RoundNo) :-
    (is_scorecard_full(Scorecard) ->
        %write("Game over!"), nl,
        %display_final_scores(Scorecard),
        true
    ;
        false
    ).

display_final_scores(Scorecard) :-
    display_scorecard(Scorecard), nl, nl,
    calculate_final_scores(Scorecard, HumanScore, ComputerScore),
    write("Your Score: "), write(HumanScore), nl,
    write("Computer's Score: "), write(ComputerScore), nl, nl,
    determine_winner(HumanScore, ComputerScore).

% Calculate the final scores
calculate_final_scores(Scorecard, HumanScore, ComputerScore) :-
    calculate_total_score(Scorecard, 1, HumanScore),
    calculate_total_score(Scorecard, 2, ComputerScore).

% Determine the winner
determine_winner(HumanScore, ComputerScore) :-
    write("-------------------------"), nl,
    (HumanScore > ComputerScore ->
        write("You won!"), nl
    ;
    HumanScore < ComputerScore ->
        write("Computer won!"), nl
    ;
        write("It's a draw!"), nl
    ),
    write("-------------------------"), nl, nl,
    write("Exiting program..."), nl, nl.

% Initialization directive
:- initialization(start).
