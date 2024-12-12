:-compile('scorecard.pl').
:-compile('human.pl').
:-compile('computer.pl').
:-compile('dice.pl').
:-compile('file_handling.pl').


% *********************************************************************
% Predicate Name: start
% Purpose: to start the game.
% Algorithm:
%   1. Display the menu options to the user.
%   2. Read the user's choice.
%   3. Handle the user's choice.
% Reference: None
% *********************************************************************
start :-
    display_options,
    read_input_display(Choice), nl,
    handle_choice(Choice).


% *********************************************************************
% Predicate Name: display_options
% Purpose: to display the menu options to the user.
% Algorithm:
%   1. Display a welcome message.
%   2. Display the menu options.
% Reference: None
% *********************************************************************
display_options :-
    nl,
    write("Welcome to Yahtzee!"), nl, nl,
    write("Please select one of the following"), nl, nl,
    write("1. Start Game"), nl,
    write("2. Load Game"), nl,
    write("3. Exit"), nl, nl.



% *********************************************************************
% Predicate Name: read_input_display
% Purpose: to read the user's choice as a string and display a message.
% Parameters:
%   - Input: the user's choice.
% Algorithm:
%   1. Display a message asking the user to enter their choice.
%   2. Read the user's choice as a string.
% Reference: None
% *********************************************************************
read_input_display(Input) :-
    write("Enter your choice: "),
    read_line_to_string(user_input, Input).


% *********************************************************************
% Predicate Name: read_input
% Purpose: to read the user's choice as a string.
% Parameters:
%   - Input: the user's choice.
% Algorithm:
%   1. Read the user's choice as a string.
% Reference: None
% *********************************************************************
read_input(Input) :-
    read_line_to_string(user_input, Input).


% *********************************************************************
% Predicate Name: handle_choice
% Purpose: to handle the user's choice.
% Parameters:
%   - Choice: the user's choice.
% Algorithm:
%   1. If the choice is "1", start the game.
%   2. If the choice is "2", load the game.
%   3. If the choice is "3", exit the program.
%   4. Otherwise, display an error message and ask the user to enter a valid choice.
% Reference: None
% *********************************************************************
handle_choice("1") :-
    start_game.
handle_choice("2") :-
    load_scorecard(Scorecard,RoundNum),
    nl,
    calculate_final_scores(Scorecard, HumanScore, ComputerScore),
    write("Your Score: "), write(HumanScore), nl,
    write("Computer's Score: "), write(ComputerScore), nl, nl,
    nl,
    NewRoundNo is RoundNum - 1,
    player_with_lowest_score(Scorecard, NewPlayerID),
    play_consecutive_rounds(Scorecard,NewRoundNo,NewPlayerID).
handle_choice("3") :-
    write("Exiting program..."), nl, nl.
handle_choice(_) :-
    write("Invalid choice, please try again."), nl,
    start.



% *********************************************************************
% Predicate Name: start_game
% Purpose: to start the game.
% Algorithm:
%   1. Display a message to the user.
%   2. Ask the user to enter a method of input.
%   3. Handle the method of input.
% Reference: None
% *********************************************************************
start_game :-
    nl,
    write("Rolling the dice to determine who starts the round.... "), nl,
    write("Enter 'M' for manual or 'R' for random: "), nl,
    read_input(Method), nl,
    handle_method(Method).


% *********************************************************************
% Predicate Name: handle_method
% Purpose: to handle the method of input.
% Parameters:
%   - Method: the method of input.
% Algorithm:
%   1. If the method is "M", get input from the user.
%   2. If the method is "R", generate random numbers for both players.
%   3. Otherwise, display an error message and ask the user to enter a valid method.
% Reference: None
% *********************************************************************
handle_method("M") :-
    manual_input.
handle_method("R") :-
    random_input.
handle_method(_) :-
    write("Invalid input, please try again."), nl,
    start_game.


% *********************************************************************
% Predicate Name: manual_input
% Purpose: to get input from the user.
% Algorithm:
%   1. Ask the user to enter a number for their dice.
%   2. Parse the input to a number.
%   3. Validate the number.
%   4. Ask the user to enter a number for the computer's dice.
%   5. Parse the input to a number.
%   6. Validate the number.
%   7. Determine the winner of the toss.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: parse_number
% Purpose: to parse a string to a number.
% Parameters:
%   - Input: the string to be parsed.
%   - Number: the number parsed from the string.
% Algorithm:
%   1. Use number_string to parse the input string to a number.
% Reference: None
% *********************************************************************
parse_number(Input, Number) :-
    number_string(Number, Input).



% *********************************************************************
% Predicate Name: random_input
% Purpose: to generate random numbers for both players.
% Algorithm:
%   1. Generate random numbers between 1 and 6 for both players.
%   2. Display the numbers rolled by both players.
%   3. Determine the winner of the toss.
% Reference: None
% *********************************************************************
random_input :-
    random_between(1, 6, P1),
    random_between(1, 6, P2),
    write("You rolled: "), write(P1), nl,
    write("Computer rolled: "), write(P2), nl,
    determine_toss_winner(P1, P2).

% *********************************************************************
% Predicate Name: validate_number
% Purpose: to validate the number entered by the user.
% Parameters:
%   - N: the number entered by the user.
% Algorithm:
%   1. If N is between 1 and 6, the number is valid.
%   2. Otherwise, display an error message and ask the user to enter a valid number.
% Reference: None
% *********************************************************************
validate_number(N) :-
    (N >= 1, N =< 6 ->
        true
    ;
        write("Invalid number, please enter a number between 1 and 6."), nl,
        manual_input
    ).


% *********************************************************************
% Predicate Name: determine_toss_winner
% Purpose: to determine the winner of the toss.
% Parameters:
%   - P1: the number rolled by the human player.
%   - P2: the number rolled by the computer player.
% Algorithm:
%   1. If P1 is greater than P2, the human player wins the toss.
%   2. If P2 is greater than P1, the computer player wins the toss.
%   3. If P1 is equal to P2, it is a draw.
%   4. Start the round with the player who won the toss.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: start_round
% Purpose: To start a round of the game.
% Parameters:
%   - PlayerID: the ID of the player whose turn it is.
% Algorithm:
%   1. Initialize the scorecard.
%   2. Set the round number to 1.
%   3. If the player is the human, play the human's turn first and then computer's turn.
%   4. If the player is the computer, play the computer's turn first, and then human's turn.
%   5. Determine the player with the lowest score.
%   6. Ask the user if they want to save the game.
%   7. Play consecutive rounds with the new scorecard, round number, and player ID.
% Reference: None
% *********************************************************************
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



% *********************************************************************
% Predicate Name: play_consecutive_rounds
% Purpose: To play consecutive rounds of the game.
% Parameters:
%   - Scorecard: a list of lists representing the scorecard. Each inner list contains the category number and the score for that category.
%   - RoundNum: the current round number.
%   - PlayerID: the ID of the player whose turn it is.
% Algorithm:
%   1. Increment the round number.
%   2. If the player is the computer, play the computer's turn.
%   3. If the player is the human, play the human's turn.
%   4. Check if the game has ended.
%   5. If the game has ended, display the final scores.
%   6. Otherwise, ask the user if they want to save the game.
%   7. Determine the player with the lowest score.
%   8. Play consecutive rounds with the new scorecard, round number, and player ID.
% Reference: None
% *********************************************************************
play_consecutive_rounds(Scorecard, RoundNum, PlayerID) :-
    NewRoundNo is RoundNum + 1,
    (PlayerID =:= 2 ->
        computer_turn(Scorecard, NewRoundNo, TempScorecard),
            (handle_end_game(TempScorecard, NewRoundNo) -> 
                NewScorecard = TempScorecard
            ;
                human_turn(TempScorecard, NewRoundNo, NewScorecard))
    ;
        human_turn(Scorecard, NewRoundNo, TempScorecard),
            (handle_end_game(TempScorecard, NewRoundNo) -> 
                NewScorecard = TempScorecard
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


% *********************************************************************
% Predicate Name: handle_end_game
% Purpose: This predicate checks if the game has ended.
% Parameters:
%   - scorecard: a list of lists representing the scorecard. Each inner list contains the category number and the score for that category.
%   - round: the current round number.
% Return Value: fails if the game has ended, true otherwise.
% Algorithm:
%   1. Check if the scorecard is full.
%   2. If the scorecard is full, the predicate succeeds.
%   3. Otherwise, the predicate fails.
% Reference: none
% *********************************************************************
handle_end_game(Scorecard, _RoundNo) :-
    (is_scorecard_full(Scorecard) -> true ; false).


% *********************************************************************
% Predicate Name: display_final_scores
% Purpose: Displays the scorecard, calculates final scores, and determines the winner.
% Parameters:
%   - Scorecard: A list storing the scorees, caterogies, and rounds for both players.
% Algorithm:
%   1. Display the scorecard.
%   2. Calculate the final scores for both players.
%   3. Display the final scores.
%   4. Determine the winner.
% Reference: None
% *********************************************************************

display_final_scores(Scorecard) :-
    display_scorecard(Scorecard), nl, nl,
    calculate_final_scores(Scorecard, HumanScore, ComputerScore),
    write("Your Score: "), write(HumanScore), nl,
    write("Computer's Score: "), write(ComputerScore), nl, nl,
    determine_winner(HumanScore, ComputerScore).


% *********************************************************************
% Predicate Name: calculate_final_scores
% Purpose: Computes the total scores for the human and computer players based on the scorecard.
% Parameters:
%   - Scorecard: a list of lists representing the scorecard. Each inner list contains the category number and the score for that category.
%   - HumanScore: to set the total score of the human player.
%   - ComputerScore: to set the total score of the computer player.
% *********************************************************************
calculate_final_scores(Scorecard, HumanScore, ComputerScore) :-
    calculate_total_score(Scorecard, 1, HumanScore),
    calculate_total_score(Scorecard, 2, ComputerScore).



% *********************************************************************
% Predicate Name: determine_winner
% Purpose: Determines the winner between a human and a computer based on their scores.
% Parameters:
%   - HumanScore: the score of the human player.
%   - ComputerScore: the score of the computer player.
% Algorithm:
% Compare HumanScore and ComputerScore:
%      - If HumanScore is greater, print "You won!".
%      - If ComputerScore is greater, print "Computer won!".
%      - Otherwise, print "It's a draw!".
% Reference: None
% *********************************************************************
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
