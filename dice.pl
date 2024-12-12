

% *********************************************************************
% Predicate Name: get_random_dice_roll
% Purpose: Generates a random dice roll between 1 and 6.
% Parameters:
%   - Value: An integer representing the generated dice roll.
% Algorithm:
% Generate a random number between 1 and 6.
% Reference: None
% *********************************************************************
get_random_dice_roll(Value) :-
    random_between(1, 6, Value).


% *********************************************************************
% Predicate Name: roll_dice
% Purpose: Rolls the dice for the player.
% Parameters:
%   - DiceValues: A list containing the dice values.
% Algorithm:
% Ask the user if they want to manually enter the dice values.
%      - If the user wants to manually enter the dice values, get the values from the user.
%      - Otherwise, generate 5 random dice values.
% Display the dice values to the user.
% Reference: None
% *********************************************************************
roll_dice(DiceValues) :-
    get_yes_no_input(Response),
    ( Response = "Y" -> 
        get_manual_dice(5, DiceValues)  % Get manual dice input
    ; 
        generate_random_dice(5, DiceValues)  % Generate 5 random dice rolls
    ),
    display_dice(DiceValues).


% *********************************************************************
% Predicate Name: get_yes_no_input
% Purpose: Gets a yes/no input from the user.
% Parameters:
%   - Response: A string containing the user's response.
% Algorithm:
% Ask the user to enter Y or N.
%      - If the input is Y or N, return the response.
%      - Otherwise, display an invalid input message and retry.
% Reference: None
% *********************************************************************
get_yes_no_input(Response) :-
    format("Do you want to manually enter the dice? (Y/N): "), nl,
    read_line_to_string(user_input, Input),
    ( Input = "Y" -> 
        Response = "Y"
    ; Input = "N" -> 
        Response = "N"
    ; 
        format("Invalid Input! Please enter Y or N.~n"),
        get_yes_no_input(Response)  % Retry on invalid input
    ).


% *********************************************************************
% Predicate Name: get_manual_dice
% Purpose: Gets a list of dice values from the user.
% Parameters:
%   - N: the number of dice values to get.
%   - DiceValues: A list containing the dice values.
% Algorithm:
% Ask the user to enter the dice values one by one.
%      - If the input is valid, add the value to the list.
%      - Otherwise, display an invalid input message and retry.
% Reference: None
% *********************************************************************
get_manual_dice(0, []) :- 
    true.  % Base case: no more dice to gather
get_manual_dice(N, [Value | Rest]) :-
    format("Enter the dice value (1-6): "), nl,
    read_line_to_string(user_input, Input),
    
    ( atom_number(Input, Value), between(1, 6, Value) -> 
        N1 is N - 1,
        get_manual_dice(N1, Rest)
    ; 
        format("Invalid Input. Please enter a number between 1 and 6.~n"),
        get_manual_dice(N, [Value | Rest])  % Retry on invalid input
    ).


% *********************************************************************
% Predicate Name: generate_random_dice
% Purpose: Generates a list of random dice values.
% Parameters:
%   - N: the number of dice values to generate.
%   - DiceValues: A list containing the generated dice values.
% Algorithm:
% Generate N random dice values between 1 and 6.
% Reference: None
% *********************************************************************
generate_random_dice(0, []) :- 
    true.  % Base case: no more dice to generate
generate_random_dice(N, [Value | Rest]) :-
    get_random_dice_roll(Value),
    N1 is N - 1,
    generate_random_dice(N1, Rest).


% *********************************************************************
% Predicate Name: is_valid_list
% Purpose: Checks if a list of dice values is valid.
% Parameters:
%   - DiceList: A list containing the dice values.
% Algorithm:
% Check if the list has exactly 5 elements and each element is a valid dice value.
% Reference: None
% *********************************************************************
is_valid_list(DiceList) :-
    length(DiceList, 5),  % Check if the list has exactly 5 elements
    maplist(valid_dice_value, DiceList).


% *********************************************************************
% Predicate Name: valid_dice_value
% Purpose: Checks if a dice value is valid.
% Parameters:
%   - Value: An integer representing the dice value.
% Algorithm:
% Check if the value is an integer between 1 and 6.
% Reference: None
% *********************************************************************
valid_dice_value(Value) :-
    integer(Value),
    between(1, 6, Value).

    
% *********************************************************************
% Predicate Name: get_manual_dice_list
% Purpose: Gets a valid list of dice values from the user.
% Parameters:
%   - DiceList: A list containing the dice values.
% Algorithm:
% Ask the user to enter the dice values in the form of a list.
%      - If the input is valid, return the list.
%      - Otherwise, display an invalid input message and retry.
% Reference: None
% *********************************************************************
get_manual_dice_list(DiceList) :-
    format("Enter the Dice Values in the form of a list (e.g., [1, 2, 3, 4, 5]): "), nl,
    read(DiceList),
    ( is_valid_list(DiceList) -> 
        true
    ; 
        display_invalid_msg,
        get_manual_dice_list(DiceList)  % Retry on invalid input
    ).


% *********************************************************************
% Predicate Name: display_invalid_msg
% Purpose: Displays an invalid input message to the user.
% Parameters: None
% Algorithm:
% - Display an invalid input message to the user.
% Reference: None
% *********************************************************************
display_invalid_msg :-
    format("Invalid input! Please enter exactly 5 values between 1 and 6.~n").


% *********************************************************************
% Predicate Name: display_dice
% Purpose: Displays the dice values to the user.
% Parameters:
%   - DiceValues: A list containing the dice values.
% Return Value: None (outputs the dice values directly to the console).
% Algorithm:
% Display the dice values to the user.
% Reference: None
% *********************************************************************
display_dice(DiceValues) :-
    format("Dice: ~w~n", [DiceValues]).
