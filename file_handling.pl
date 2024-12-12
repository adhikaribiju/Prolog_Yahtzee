consult('scorecard.pl').



% *********************************************************************
% Predicate Name: load_scorecard
% Purpose: Loads a scorecard from a file.
% Parameters:
%   - Scorecard: The scorecard to load.
%   - RoundNum: The round number.
% Algorithm:
% Read the name of the file from the user.
% Read the data from the file.
% Preprocess the data.
% Initialize the scorecard.
% Update the scorecard with the values.
% Reference: None
% *********************************************************************
load_scorecard(Scorecard, RoundNum) :-
    read_file_name(FileName),
    read_file(FileName, RawData),
    preprocess_data(RawData, Data),
    %format("Data: ~w~n", [Data]),
    (   Data = [RoundNo|[Values]] % Parse round number and values
    ->  initialize_scorecard(InitialScorecard),
        update_scorecard_values(InitialScorecard, Values, Scorecard),
        RoundNum is [RoundNo]
    ;   write("Error: Failed to parse data from the file."), nl,
        fail
    ).



% *********************************************************************
% Predicate Name: read_file_name
% Purpose: Reads the name of the file from the user.
% Parameters:
%   - FileName: The name of the file to read from.
% Algorithm:
% Ask the user to enter the name of the file.
% Reference: None
% *********************************************************************
read_file_name(FileName) :-
    write("Enter the name of the file: "),
    read_line_to_string(user_input, FileName).



% *********************************************************************
% Predicate Name: read_file
% Purpose: Reads data from a file.
% Parameters:
%   - FileName: The name of the file to read from.
%   - Data: The Prolog term read from the file.
% Algorithm:
% Open the file for reading.
% Read the Prolog term from the file.
% Close the file.
% Handle errors if the file does not exist or if there is an error reading the file.
% Reference: None
% *********************************************************************
read_file(FileName, Data) :-
    exists_file(FileName), % Check if file exists
    catch(
        (   open(FileName, read, Stream),
            read(Stream, Data), % Read the Prolog term from the file
            close(Stream)
        ),
        _Error,
        (   write("Error reading file."), nl, fail)
    ).
read_file(_, _) :-
    write("Error: File does not exist."), nl, fail.



% *********************************************************************
% Predicate Name: preprocess_data
% Purpose: Preprocesses the data loaded from the file.
% Parameters:
%   - RawData: The raw data loaded from the file.
%   - Data: The preprocessed data.
% Algorithm:
% Preprocess the data loaded from the file.
% Reference: None
% *********************************************************************
preprocess_data([RoundNo, RawValues], [RoundNo, ProcessedValues]) :-
    maplist(preprocess_entry, RawValues, ProcessedValues).


% *********************************************************************
% Predicate Name: preprocess_entry
% Purpose: Preprocesses an entry in the scorecard.
% Parameters:
%   - Entry: The entry to preprocess.
%   - ProcessedEntry: The preprocessed entry.
% Algorithm:
% Convert 'human' to 1 and 'computer' to 2.
% Leave other entries unchanged.
% Reference: None
% *********************************************************************
preprocess_entry([A, human, C], [A, 1, C]).
preprocess_entry([A, computer, C], [A, 2, C]).
preprocess_entry(Entry, Entry). % Leave other entries unchanged.


% *********************************************************************
% Predicate Name: update_scorecard_values   
% Purpose: Updates the scorecard with the provided values.
% Parameters:
%   - Scorecard: The scorecard to update.
%   - Values: The values to update the scorecard with.
%   - UpdatedScorecard: The updated scorecard.
% Algorithm:
% Update the scorecard with the provided values.
% Reference: None
% *********************************************************************
update_scorecard_values(Scorecard, Values, UpdatedScorecard) :-
    update_scorecard_values_helper(Scorecard, Values, UpdatedScorecard).




% *********************************************************************
% Predicate Name: update_scorecard_values_helper
% Purpose: Updates the scorecard with the provided values.
% Parameters:
%   - Scorecard: The scorecard to update.
%   - Values: The values to update the scorecard with.
%   - UpdatedScorecard: The updated scorecard.
% Algorithm:
% Update the scorecard with the provided values.
%      - If the current value is `[0]`, skip updating the row.
%      - Otherwise, update the row with the provided value.
% Reference: None
% *********************************************************************
update_scorecard_values_helper([], _, []). % Base case: no more rows to process.
update_scorecard_values_helper([Row|RestScorecard], Values, [UpdatedRow|UpdatedRest]) :-
    Row = [Category|_RestOfRow], 
    (  nth0(_Index, Values, CurrentValue, RemainingValues),
        (   CurrentValue = [0]  % If it's `[0]`, skip updating the row.
        ->  UpdatedRow = Row % Keep the row unchanged.
        ;  
            CurrentValue = [Score, PlayerID, Round],
            UpdatedRow = [Category, Score, PlayerID, Round]
        )
    ;   % If no value matches, leave the row unchanged.
        UpdatedRow = Row,
        RemainingValues = Values
    ),
    % Process the rest of the scorecard.
    update_scorecard_values_helper(RestScorecard, RemainingValues, UpdatedRest).


% *********************************************************************
% Predicate Name: display_loaded_scorecard
% Purpose: Displays the loaded scorecard.
% Parameters:
%   - Scorecard: The scorecard to display.
% Algorithm:
% Display the scorecard.
% Reference: None
% *********************************************************************
display_loaded_scorecard(Scorecard) :-
    write("Scorecard:"), nl,
    write("-----------------------------"), nl,
    write("Category | Score | Player | Round"), nl,
    write("-----------------------------"), nl,
    display_scorecard_rows(Scorecard).


% *********************************************************************
% Predicate Name: display_scorecard_rows
% Purpose: Displays the rows of the scorecard.
% Parameters:
%   - Scorecard: The scorecard to display.
% Algorithm:
% Display each row of the scorecard.
% Reference: None
% *********************************************************************
display_scorecard_rows([]).
display_scorecard_rows([[Category, Score, Player, Round]|Rest]) :-
    format("~w | ~w | ~w | ~w~n", [Category, Score, Player, Round]),
    display_scorecard_rows(Rest).



% *********************************************************************
% Predicate Name: ask_to_save_game
% Purpose: Asks the user if they want to save the game.
% Parameters:
%   - Scorecard: The scorecard to save.
%   - RoundNo: The current round number.
% Algorithm:
% Ask the user if they want to save the game.
%      - If the input is Y, save the game and exit the program.
%      - If the input is N, do not save the game.
%      - Otherwise, display an invalid input message and retry.
% Reference: None
% *********************************************************************
ask_to_save_game(Scorecard, RoundNo) :-
    nl,write("Do you wish to save the game? (Y/N): "),
    read_line_to_string(user_input, Input),
    validate_save_input(Input, Scorecard, RoundNo).



% *********************************************************************
% Predicate Name: validate_save_input
% Purpose: Validates the user's input for saving the game.
% Parameters:
%   - Input: The user's input.
%   - Scorecard: The scorecard to save.
%   - RoundNo: The current round number.
% Algorithm:
% If the input is Y, save the game and exit the program.
% If the input is N, do not save the game.
% Otherwise, display an invalid input message and retry.
% Reference: None
% *********************************************************************
validate_save_input("Y", Scorecard, RoundNo) :-
    save_to_file(Scorecard, RoundNo),
    write("Game saved successfully. Exiting the program."), nl,nl,
    halt. % Exit the program.
validate_save_input("N", _, _) :-
    write("Game not saved."), nl, nl. % Exit the program.
validate_save_input(_, Scorecard, RoundNo) :-
    write("Invalid input. Please enter Y or N."), nl,nl,
    ask_to_save_game(Scorecard, RoundNo).



% *********************************************************************
% Predicate Name: save_to_file
% Purpose: Saves the scorecard to a file.
% Parameters:
%   - Scorecard: The scorecard to save.
%   - RoundNo: The current round number.
% Algorithm:
% Get the file name from the user.
% Convert the scorecard to the required format.
% Write the data to the file.
% Reference: None
% *********************************************************************
save_to_file(Scorecard, RoundNo) :-
    NewRoundNo is RoundNo + 1, % Increment the round number
    write("Enter the name of the file: "),
    read_line_to_string(user_input, FileName), % Get the file name from the user
    convert_scorecard(Scorecard, ProcessedValues), % Process the scorecard into the required format
    Data = [NewRoundNo, ProcessedValues], % Combine RoundNo and ProcessedValues
    open(FileName, write, Stream), % Open the file for writing
    write(Stream, Data), % Write the data to the file
    write(Stream, '.'), % Add a period at the end
    close(Stream), % Close the file
    format("Scorecard saved to ~w successfully.~n", [FileName]).



% *********************************************************************
% Predicate Name: convert_scorecard
% Purpose: Converts the scorecard to the required format for saving.
% Parameters:
%   - Scorecard: The scorecard to convert.
%   - ProcessedScorecard: The converted scorecard.
%   - Rest: The remaining scorecard to process.
% Algorithm:
% Convert each row of the scorecard to the required format.
%      - If the score is 0, write [0].
%      - If the player is 'human', map to 1.
%      - If the player is 'computer', map to 2.
% Reference: None
% *********************************************************************
convert_scorecard([], []).
convert_scorecard([[_, 0, _, _]|Rest], [[0]|ProcessedRest]) :-
    % If Score is 0, write [0].
    convert_scorecard(Rest, ProcessedRest).
convert_scorecard([[_, Score, 1, Round]|Rest], [[Score, human, Round]|ProcessedRest]) :-
    % If PlayerID is 1, map to 'human'.
    convert_scorecard(Rest, ProcessedRest).
convert_scorecard([[_, Score, 2, Round]|Rest], [[Score, computer, Round]|ProcessedRest]) :-
    % If PlayerID is 2, map to 'computer'.
    convert_scorecard(Rest, ProcessedRest).


