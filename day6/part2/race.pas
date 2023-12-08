program race;
(*
    Consider a boat with a button. While the button is being held, the boat's
    speed charges (if you hold the button for 3ms and release, it moves at
    3m/s). Now, given race durations and distance records, determine how long
    you must hold a boat's button for it to win the race. Multiple answers are
    possible, so return the product of the sums of all possible winning button
    configurations for each race
*)

uses 
    (* for strtoint *)
    sysutils,
    (* For splitstring *)
    strutils;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;
    (* Input file line, token *)
    line, token: string;

    (* Input race duration *)
    time: qword;
    (* Input race record *)
    dist: qword;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

function num_wins(time: qword; dist: qword) : qword;
var
    hold_ms_speed: qword;
begin
    num_wins := 0;
    for hold_ms_speed := 0 to time do
    begin
        if hold_ms_speed * (time - hold_ms_speed) > dist then
        begin
            num_wins := num_wins + 1;
        end;
    end;
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    (* Read in race time *)
    readln(f, line);
    line := stringreplace(line, ' ', '', [rfReplaceAll]);
    for token in splitstring(line, ':') do
    begin
        if (length(token) = 0) or (not is_digit(token[1])) then
            continue;
        time := strtoqword(token);
    end;

    (* Read in race record *)
    readln(f, line);
    line := stringreplace(line, ' ', '', [rfReplaceAll]);
    for token in splitstring(line, ':') do
    begin
        if (length(token) = 0) or (not is_digit(token[1])) then
            continue;
        dist := strtoqword(token);
    end;

    writeln('Product of numbers of winning solutions: ', num_wins(time, dist));

    close(f);
end.
