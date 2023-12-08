program SeedPlanting;
(*
    Given a list of seeds and mappings of various growing conditions,
    return the lowest value corresponding to seed location among all seeds. The
    sequence of maps does the conversion 'seed -> cond1 -> cond2 -> ... -> location'
*)

uses 
    (* For min *)
    math,
    (* For sscanf, strtoint *)
    sysutils,
    (* For splitstring *)
    strutils;

type 
map = record
    from_start, to_start, range: cardinal;
end;

type 
    cardinal_array = array of cardinal;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;

    (* Current input line *)
    line: string;

    (* Main loop counter *)
    i, j: cardinal;

    (* Temporary string array *)
    s: string;

    (* Seed array *)
    seeds: array of cardinal;
    seed: cardinal;
    (* Minimum location after transformation *)
    min_loc: cardinal;

    (* Current maps *)
    maps: array of map;
    m: map;

function apply_maps(seeds: array of cardinal; maps: array of map) : cardinal_array;
var
    i: cardinal;
    m: map;
    found: boolean;
begin
    setlength(apply_maps, length(seeds));

    for i := 0 to length(seeds) - 1 do
    begin
        found := false;
        for m in maps do
        begin
            if (m.from_start <= seeds[i]) and 
                (seeds[i] <= m.from_start + m.range - 1) then
            begin
                found := true;
                apply_maps[i] := (m.to_start - m.from_start) + seeds[i];
                break;
            end;
        end;

        if not found then
            apply_maps[i] := seeds[i];
    end;
end;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    setlength(seeds, 0);
    setlength(maps, 0);

    i := 0;
    while not eof(f) do
    begin
        readln(f, line);

        if (length(line) = 0) or ((i <> 0) and (not is_digit(line[1]))) then
        begin
            if length(maps) <> 0 then 
            begin
                // for j := 0 to length(seeds) - 1 do
                // begin
                //     writeln(seeds[j], ' -> ', apply_maps(seeds, maps)[j]);
                // end;
                // writeln('------------');

                seeds := apply_maps(seeds, maps);
                setlength(maps, 0);
            end;
            continue;
        end;

        if i = 0 then
        begin
            for s in splitstring(copy(line, 8), ' ') do
            begin
                setlength(seeds, length(seeds) + 1);
                seeds[length(seeds) - 1] := strtoint(s);
            end;

            i := i + 1;
            continue;
        end;

        (* Reading map *)
        sscanf(line, '%d %d %d', [@m.to_start, @m.from_start, @m.range]);
        setlength(maps, length(maps) + 1);
        maps[length(maps) - 1] := m;
        // seeds := apply_map(seeds, m);
    end;
    
    if length(maps) <> 0 then 
    begin
        // for j := 0 to length(seeds) - 1 do
        // begin
        //     writeln(seeds[j], ' -> ', apply_maps(seeds, maps)[j]);
        // end;
        // writeln('------------');

        seeds := apply_maps(seeds, maps);
        setlength(maps, 0);
    end;

    min_loc := seeds[0];
    for seed in seeds do
    begin
        min_loc := min(seed, min_loc);
    end;

    writeln('Minimum location: ', min_loc);
end.
