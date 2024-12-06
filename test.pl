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

main:-
Scorecard = [
       ["Ones", 1, 1, 1],
       ["Twos", 0, 0, 0],
       ["Threes", 9, 2, 2],
       ["Fours", 16, 1, 2],
       ["Fives", 15, 2, 4],
       ["Sixes", 12, 1, 4],
       ["Three of a Kind", 15, 1, 3],
       ["Four of a Kind", 7, 2, 3],
       ["Full House", 0, 0, 0],
       ["Four Straight", 0, 0, 0],
       ["Five Straight", 0, 0, 0],
       ["Yahtzee", 50, 1, 5]
   ],
   RoundNo = 6,
   save_to_file(Scorecard, RoundNo).