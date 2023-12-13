program Oasis;
(*
    Given sequences of values over time, extrapolate each sequence by 1 and return
    the sum of the extrapolated values. Extrapolation is performed by calculating
    the rates of change in each pair of a sequence, then
        - if the rates of change are all 0, add a 0 to the sequence, and add
          an extrapolated value to the sequence above by doing
            upper_seq += last(upper_seq) + last(current_seq)
          Continue doing this until all sequences have been extrapolated, the 
          extrapolated value in the root sequence is part of the output sum.
        - if the rates of change are not all 0, compute the rates of change of
          the old rates of change, and repeat the process
*)

uses
    strutils,
    sysutils;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;
    (* Input file line *)
    line: string;
    nstr: string;

    (* 
        Array of all sequences, where derivatives[0] is the root sequence, and 
        derivatives[i] is d^i derivatives[i - 1] / dx^i
    *)
    derivatives: array of array of cardinal;
    current: array of cardinal;
    i: cardinal;

    (* Output *)
    sum: cardinal;

type
    cardinal_array = array of cardinal;

(* Determine if all values in an array are 0 *)
function all_zero(seq: array of cardinal) : boolean;
var
    current: cardinal;
begin
    all_zero := true;
    for current in seq do
        all_zero := all_zero and (current = 0)
end;

function calc_derivatives(seq: array of cardinal) : cardinal_array;
var
    i: cardinal;
begin
    setlength(calc_derivatives, length(seq) - 1);
    for i := 0 to length(calc_derivatives) - 1 do
        calc_derivatives[i] := seq[i + 1] - seq[i];
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    sum := 0;

    while not eof(f) do
    begin
        readln(f, line);

        setlength(derivatives, 1);
        setlength(derivatives[0], 0);
        for nstr in splitstring(line, ' ') do
        begin
            setlength(derivatives[0], length(derivatives[0]) + 1);
            derivatives[0][high(derivatives[0])] := strtoint(nstr);
        end;

        (* Compute derivatives *)
        current := derivatives[0];
        while not all_zero(current) do
        begin
            setlength(derivatives, length(derivatives) + 1);
            derivatives[high(derivatives)] := calc_derivatives(derivatives[high(derivatives) - 1]);
            current := derivatives[high(derivatives)];
        end;
        setlength(current, length(current) + 1);
        current[high(current)] := 0;
        derivatives[high(derivatives)] := current;

        (* Extrapolate *)
        for i := high(derivatives) - 1 downto 0 do
        begin
            setlength(derivatives[i], length(derivatives[i]) + 1);
            derivatives[i][high(derivatives[i])] := derivatives[i][high(derivatives[i]) - 1] + derivatives[i + 1][high(derivatives[i + 1])];
        end;

        sum := sum + derivatives[0][high(derivatives[0])];
    end;

    writeln('Sum: ', sum);

    close(f);
end.
