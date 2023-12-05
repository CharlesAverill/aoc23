program Trebuchet;
(*
  Sum the first and last digits of each line of an input text file, and return
  the sum of sums.
*)

var
	(* Input filename *)
	fn: String;
	(* Input file *)
	f: text;

	(* Current line of input file *)
    line: String;
	(* Index into line *)
	i: integer;

	(* Sum of sums of each line *)
	(* 'cardinal' refers to a standard 4-byte unsigned integer type *)
	sum: cardinal;

function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

function digit_to_integer(c: char) : integer;
begin
	digit_to_integer := ord(c) - 48
end;

begin
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

		(* Iterate forward through all characters in line *)
		for i := 1 to length(line) do
		begin
			if is_digit(line[i]) then
			begin
				(* First digit of two-digit decimal number, so mul by 10 *)
				sum := sum + (10 * digit_to_integer(line[i]));
				break
			end;
		end;

        (* Iterate backwards through all characters in line *)
        for i := length(line) downto 1 do
        begin
            if is_digit(line[i]) then
            begin
				(* Second digit of two-digit decimal number *)
                sum := sum + digit_to_integer(line[i]);
                break
            end;
        end;
	end;

	writeln(sum);

	close(f);
end.
