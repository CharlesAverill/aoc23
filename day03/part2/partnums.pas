program PartNums;
(* 
    Given a 2D map of part numbers and symbols, return the sum of all gear ratios,
    which are products of exactly two numbers that are adjacent in any direction
    to a '*'
*)

uses 
    (* for strtoint *)
    sysutils;

type
point = record
    x, y : cardinal;
    is_gear: boolean;
end;

type
num = record
    value: cardinal;
    start: point;
    length: cardinal;
end;

type 
nums_syms = record
    numbers: array of num;
    symbols: array of point;
end;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;

    (* Current line *)
    line: string;
    (* Parsed numbers and symbols from line *)
    line_ns: nums_syms;

    (* Array of all numbers in input file *)
    numbers: array of num;
    (* Array of all symbols *)
    symbols: array of point;

    (* Loop indices *)
    i, j : cardinal;

    (* Foreach values *)
    n: num;
    s: point;

    (* Number of gears in range *)
    ngears: cardinal;
    (* Temporary gear ratio *)
    gear_ratio: cardinal;

    (* Sum of all gear ratios *)
    sum: cardinal;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

(* Returns all numbers and symbols found in a line *)
function scan_line(line: string; line_y: cardinal) : nums_syms;
var
    i: cardinal;
    p: point;

    scanning_int: boolean;
    int_str: string;
    int_start: cardinal;
    n: num;
begin
    (* Initialize arrays *)
    setlength(scan_line.numbers, 0);
    setlength(scan_line.symbols, 0);

    scanning_int := false;
    int_str := '';
    int_start := 0;

    for i := 1 to length(line) do
    begin
        if (not scanning_int) and (length(int_str) > 0) then
        begin
            n.value := strtoint(int_str);
            n.start.x := int_start;
            n.start.y := line_y;
            n.length := length(int_str);
            scan_line.numbers[length(scan_line.numbers) - 1] := n;

            int_str := '';
        end;

        if is_digit(line[i]) then
        begin
            int_str := concat(int_str, line[i]);
            if not scanning_int then
            begin
                setlength(scan_line.numbers, length(scan_line.numbers) + 1);
                scanning_int := true;
                int_start := i;
            end;
        end else if line[i] = '.' then
            scanning_int := false
        else 
        begin
            setlength(scan_line.symbols, length(scan_line.symbols) + 1);

            p.x := i;
            p.y := line_y;
            p.is_gear := line[i] = '*';
            scan_line.symbols[length(scan_line.symbols) - 1] := p;

            scanning_int := false;
        end;
    end;

    if length(int_str) > 0 then
    begin
        n.value := strtoint(int_str);
        n.start.x := int_start;
        n.start.y := line_y;
        n.length := length(int_str);
        scan_line.numbers[length(scan_line.numbers) - 1] := n;

        int_str := '';
    end;
end;

procedure print_num(n: num);
begin
    writeln('------------');
    writeln(n.value);
    writeln('(', n.start.x, ', ', n.start.y, ') - (', n.start.x + n.length - 1, ', ', n.start.y, ')');
end;

begin
    (* Get filename from stdin *)
    write('Input filename: ');
    readln(fn);

    (* Open file *)
    assign(f, fn);
    reset(f);

    (* Initialize arrays *)
    setlength(numbers, 0);
    setlength(symbols, 0);

    (* Iterate through all lines in file *)
    j := 0;
    while not eof(f) do
    begin
        j := j + 1;

        readln(f, line);

        line_ns := scan_line(line, j);

        (* Copy parsed numbers and symbols into main arrays *)
        setlength(numbers, length(numbers) + length(line_ns.numbers));
        setlength(symbols, length(symbols) + length(line_ns.symbols));

        if length(line_ns.numbers) > 0 then
        begin
            for i := 0 to length(line_ns.numbers) - 1 do
            begin
                numbers[length(numbers) - length(line_ns.numbers) + i] := line_ns.numbers[i];
            end;
        end;

        if length(line_ns.symbols) > 0 then
        begin;
            for i := 0 to length(line_ns.symbols) - 1 do
            begin
                symbols[length(symbols) - length(line_ns.symbols) + i] := line_ns.symbols[i];
            end;
        end;
    end;

    sum := 0;

    (* For each gear, check if exactly two numbers are in range *)
    for s in symbols do
    begin
        if not s.is_gear then
            continue;

        ngears := 0;
        gear_ratio := 1;
        for n in numbers do 
        begin
            (* Determine if n is in range *)
            if ((s.y - 1 <= n.start.y) and (n.start.y <= s.y + 1)) and 
                (((s.x - 1 <= n.start.x) and (n.start.x <= s.x + 1)) or
                 ((s.x - 1 <= n.start.x + n.length - 1) and (n.start.x + n.length - 1 <= s.x + 1)) or
                 ((n.start.x <= s.x) and (s.x <= n.start.x + n.length))
                ) then
            begin
                ngears := ngears + 1;
                gear_ratio := gear_ratio * n.value;
            end;
        end;

        (* Toss out non-gears *)
        if not (ngears = 2) then
        begin
            continue;
        end;

        sum := sum + gear_ratio;
    end;

    writeln('Sum of gear ratios: ', sum);

    close(f);
end.
