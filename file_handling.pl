consult('scorecard.pl').



% load_scorecard(-Scorecard)
% Loads a scorecard from a file provided by the user.
load_scorecard(Scorecard, RoundNum) :-
    read_file_name(FileName),
    read_file(FileName, RawData),
    preprocess_data(RawData, Data),
    %format("Data: ~w~n", [Data]),
    (   Data = [RoundNo|[Values]] % Parse round number and values
    ->  %format("Round Number: ~w~n", [RoundNo]),
        %format("Values: ~w~n", [Values]),
        initialize_scorecard(InitialScorecard),
        update_scorecard_values(InitialScorecard, Values, Scorecard),
        %format("Updated Scorecard: ~w~n", [Scorecard]),
        RoundNum is [RoundNo]
        %Scorecard = [RoundNo|UpdatedScorecard] % Combine round and updated scorecard
    ;   write("Error: Failed to parse data from the file."), nl,
        fail
    ).



% read_file_name(-FileName)
% Reads the file name from the user.
read_file_name(FileName) :-
    write("Enter the name of the file: "),
    read_line_to_string(user_input, FileName).

% read_file(+FileName, -Data)
% Reads and parses data from the specified file.
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

% preprocess_data(+RawData, -ProcessedData)
% Converts 'human' and 'computer' to 1 and 2 in the raw data.
preprocess_data([RoundNo, RawValues], [RoundNo, ProcessedValues]) :-
    maplist(preprocess_entry, RawValues, ProcessedValues).

% preprocess_entry(+RawEntry, -ProcessedEntry)
% Processes each individual entry.
preprocess_entry([A, human, C], [A, 1, C]) :- !.
preprocess_entry([A, computer, C], [A, 2, C]) :- !.
preprocess_entry(Entry, Entry). % Leave other entries unchanged.



% update_scorecard_values(+Scorecard, +Values, -UpdatedScorecard)
% Updates the scorecard with the provided values.
update_scorecard_values(Scorecard, Values, UpdatedScorecard) :-
    %format("Scorecard Initialized: ~w~n", [Scorecard]),
    %format("Scorecard to Process: ~w~n", [Values]),
    update_scorecard_values_helper(Scorecard, Values, UpdatedScorecard)
    %format("Updated Scorea=card: ~w~n", [UpdatedScorecard]).
    .

% Base case: empty scorecard.
update_scorecard_values_helper([], _, []).

% Recursive case: process each row of the scorecard.
update_scorecard_values_helper([Row|RestScorecard], Values, [UpdatedRow|UpdatedRest]) :-
    Row = [Category|_RestOfRow], % Extract the category and current row data.
    (   % Check if the current value is `[0]`.
        nth0(_Index, Values, CurrentValue, RemainingValues),
        (   CurrentValue = [0]  % If it's `[0]`, skip updating the row.
        ->  %format("Skipping category for Score: 0~n"),
            UpdatedRow = Row % Keep the row unchanged.
        ;   % Otherwise, process the value normally.
            CurrentValue = [Score, PlayerID, Round],
            %format("Score: ~w, PlayerID: ~w, Round: ~w~n", [Score, PlayerID, Round]),
            UpdatedRow = [Category, Score, PlayerID, Round]
        )
    ;   % If no value matches, leave the row unchanged.
        UpdatedRow = Row,
        RemainingValues = Values
    ),
    % Process the rest of the scorecard.
    update_scorecard_values_helper(RestScorecard, RemainingValues, UpdatedRest).


% display_loaded_scorecard(+Scorecard)
% Displays the scorecard in a readable format.
display_loaded_scorecard(Scorecard) :-
    write("Scorecard:"), nl,
    write("-----------------------------"), nl,
    write("Category | Score | Player | Round"), nl,
    write("-----------------------------"), nl,
    display_scorecard_rows(Scorecard).

% display_scorecard_rows(+Rows)
% Helper to display each row in the scorecard.
display_scorecard_rows([]).
display_scorecard_rows([[Category, Score, Player, Round]|Rest]) :-
    format("~w | ~w | ~w | ~w~n", [Category, Score, Player, Round]),
    display_scorecard_rows(Rest).



% ----- save_to_file-----

% ask_to_save_game(+Scorecard, +RoundNo)
% Asks the user if they wish to save the game and takes appropriate action.
ask_to_save_game(Scorecard, RoundNo) :-
    nl,write("Do you wish to save the game? (Y/N): "),
    read_line_to_string(user_input, Input),
    validate_save_input(Input, Scorecard, RoundNo).

% validate_save_input(+Input, +Scorecard, +RoundNo)
% Validates the user's input and acts accordingly.
validate_save_input("Y", Scorecard, RoundNo) :-
    save_to_file(Scorecard, RoundNo),
    write("Game saved successfully. Exiting the program."), nl,nl,
    halt. % Exit the program.
validate_save_input("N", _, _) :-
    write("Game not saved."), nl, nl. % Exit the program.
validate_save_input(_, Scorecard, RoundNo) :-
    write("Invalid input. Please enter Y or N."), nl,nl,
    ask_to_save_game(Scorecard, RoundNo).



% save_to_file(+Scorecard, +RoundNo)
% Saves the Scorecard and RoundNo to a user-specified file in the required format.
save_to_file(Scorecard, RoundNo) :-
    write("Enter the name of the file (with .txt extension): "),
    read_line_to_string(user_input, FileName), % Get the file name from the user
    convert_scorecard(Scorecard, ProcessedValues), % Process the scorecard into the required format
    Data = [RoundNo, ProcessedValues], % Combine RoundNo and ProcessedValues
    open(FileName, write, Stream), % Open the file for writing
    write(Stream, Data), % Write the data to the file
    write(Stream, '.'), % Add a period at the end
    close(Stream), % Close the file
    format("Scorecard saved to ~w successfully.~n", [FileName]).

% convert_scorecard(+Scorecard, -ProcessedValues)
% Converts the Scorecard into the required format for writing to a file.
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


