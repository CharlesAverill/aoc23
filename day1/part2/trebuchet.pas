program Trebuchet;
(*
  Sum the first and last digits of each line of an input text file, and return
  the sum of sums.
*)

uses
	(* For min *)
	math,
	(* For rpos *)
	strutils,
	(* For string comparisons *)
	sysutils;

var
	(* Input filename *)
	fn: string;
	(* Input file *)
	f: text;

	(* Current line of input file *)
    line: string;
	(* Index into line *)
	i: integer;
	(* Integer value word digit *)
	wd_int: integer;
	(* Array of word digits *)
	word_digits: array of string = (
		'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
	);
	(* Index for word_digits loop *)
	wd: integer;
	(* Tracker for earliest word digit *)
	wd_earliest: integer;

	(* Sum of each line *)
	(* 'cardinal' refers to a standard 4-byte unsigned integer type *)
	to_add: cardinal;
	(* Sum of sums of each line *)
	sum: cardinal;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

(* Convert a character in '0'..'9' to its corresponding integer value *)
function digit_to_integer(c: char) : integer;
begin
	digit_to_integer := ord(c) - 48
end;

begin
	(*
	  Plan:
	  	1. Iterate through all lines in file
		2. For each line, look for the earliest "word digit" (one, two, etc),
		   and then look for the earliest digit (1, 2, etc). Take the earlier of
		   the two as the first digit
		3. Repeat, but picking the latest of the matches as the second digit
	*)

	sum := 0;

	(* Get filename from stdin *)
	write('Input filename: ');
	readln(fn);

	(* Open file *)
	assign(f, fn);
	reset(f);

	(* Iterate through all lines in file *)
	while not eof(f) do
	begin
		readln(f, line);

		to_add := 0;

		(* Look forward for digit words *)
		wd_int := -1;
		wd_earliest := -1;
		for wd := 0 to length(word_digits) - 1 do
		begin
			if (pos(word_digits[wd], line) > 0) and 
				((wd_earliest = -1) or (pos(word_digits[wd], line) < wd_earliest)) then
			begin
				wd_int := wd;
				wd_earliest := pos(word_digits[wd], line);
			end;
		end;
		to_add := 10 * wd_int;

		(* 
		  If we don't find a digit word, then we scan the entire line for a 
		  digit. If we do find one, only search up to its index to try and find
		  an earlier occurance of a digit.
		*)
		if wd_earliest < 0 then
			wd_earliest := length(line);

		(* Iterate forward through all characters in line *)
		for i := 1 to wd_earliest do
		begin
			if is_digit(line[i]) then
			begin
				(* First digit of two-digit decimal number, so mul by 10 *)
				to_add := 10 * digit_to_integer(line[i]);
				break
			end
		end;

		(* Add to sum and clear to_add for reuse *)
		sum := sum + to_add;
		to_add := 0;

		(* Look backward for digit words *)
		wd_int := -1;
		wd_earliest := -1;
		for wd := 0 to length(word_digits) - 1 do
		begin
			if (rpos(word_digits[wd], line) > 0) and 
				((wd_earliest = -1) or (rpos(word_digits[wd], line) > wd_earliest)) then
			begin
				wd_int := wd;
				wd_earliest := rpos(word_digits[wd], line);
			end;
		end;
		to_add := wd_int;

		if wd_earliest < 0 then
			wd_earliest := 1;

        (* Iterate backwards through all characters in line *)
        for i := length(line) downto wd_earliest do
        begin
            if is_digit(line[i]) then
            begin
				(* Second digit of two-digit decimal number *)
                to_add := digit_to_integer(line[i]);
                break
            end;
        end;

		sum := sum + to_add;
	end;

	writeln(sum);

	close(f);
end.
