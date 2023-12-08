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

    (* Input race durations *)
    times: array of cardinal;
    (* Input race records *)
    dists: array of cardinal;

    i: cardinal;

    (* Solution *)
    prod_n_wins: cardinal;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

function num_wins(time: cardinal; dist: cardinal) : cardinal;
var
    hold_ms_speed: cardinal;
begin
    num_wins := 0;
    for hold_ms_speed := 0 to time do
    begin
        if hold_ms_speed * (time - hold_ms_speed) > dist then
            num_wins := num_wins + 1;
    end;
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    setlength(times, 0);
    readln(f, line);
    for token in splitstring(line, ' ') do
    begin
        if (length(token) = 0) or (not is_digit(token[1])) then
            continue;
        setlength(times, length(times) + 1);
        times[length(times) - 1] := strtoint(token);
    end;

    setlength(dists, 0);
    readln(f, line);
    for token in splitstring(line, ' ') do
    begin
        if (length(token) = 0) or (not is_digit(token[1])) then
            continue;
        setlength(dists, length(dists) + 1);
        dists[length(dists) - 1] := strtoint(token);
    end;

    prod_n_wins := 1;
    for i := 0 to length(times) - 1 do
    begin
        prod_n_wins := prod_n_wins * num_wins(times[i], dists[i]);
    end;

    writeln('Product of numbers of winning solutions: ', prod_n_wins);

    close(f);
end.
