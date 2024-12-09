% Generate a random dice roll between 1 and 6
get_random_dice_roll(Value) :-
    random_between(1, 6, Value).

% Roll dice function
roll_dice(DiceValues) :-
    get_yes_no_input(Response),
    ( Response = "Y" -> 
        get_manual_dice(5, DiceValues)  % Get manual dice input
    ; 
        generate_random_dice(5, DiceValues)  % Generate 5 random dice rolls
    ),
    display_dice(DiceValues).

% Ask the user for a valid Y/N input
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

% Recursively gather N dice values between 1 and 6
get_manual_dice(0, []) :- !.  % Base case: no more dice to gather
get_manual_dice(N, [Value | Rest]) :-
    format("Enter the dice value (1-6): "), nl,
    read_line_to_string(user_input, Input),
    atom_number(Input, Value),
    ( between(1, 6, Value) -> 
        N1 is N - 1,
        get_manual_dice(N1, Rest)
    ; 
        format("Invalid Input. Please enter a number between 1 and 6.~n"),
        get_manual_dice(N, [Value | Rest])  % Retry on invalid input
    ).

% Generate N random dice values between 1 and 6
generate_random_dice(0, []) :- !.  % Base case: no more dice to generate
generate_random_dice(N, [Value | Rest]) :-
    get_random_dice_roll(Value),
    N1 is N - 1,
    generate_random_dice(N1, Rest).

% Check if a list of dice values is valid
is_valid_list(DiceList) :-
    length(DiceList, 5),  % Check if the list has exactly 5 elements
    maplist(valid_dice_value, DiceList).

% Check if a single dice value is valid
valid_dice_value(Value) :-
    integer(Value),
    between(1, 6, Value).

% Get a valid list of dice values from the user
get_manual_dice_list(DiceList) :-
    format("Enter the Dice Values in the form of a list (e.g., [1, 2, 3, 4, 5]): "), nl,
    read(DiceList),
    ( is_valid_list(DiceList) -> 
        true
    ; 
        display_invalid_msg,
        get_manual_dice_list(DiceList)  % Retry on invalid input
    ).

% Display an invalid input message
display_invalid_msg :-
    format("Invalid input! Please enter exactly 5 values between 1 and 6.~n").


% display_dice(DiceValues)
display_dice(DiceValues) :-
    format("Dice: ~w~n", [DiceValues]).
