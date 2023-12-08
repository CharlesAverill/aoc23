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
range = record
    left, right: qword;
end;

type 
    range_array = array of range;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;

    (* Current input line *)
    line: string;

    (* Main loop counter *)
    i, j, k: cardinal;

    (* Temporary string array *)
    s: string;

    (* Seed array *)
    seeds: array of range;
    seedranges: array of cardinal;
    seed: range;
    nseeds: cardinal;

    (* Seed range information *)
    rangestart, rangelength: cardinal;
    (* Minimum location after transformation *)
    min_loc: cardinal;

    (* Current maps *)
    maps: array of map;
    m: map;

function string_of_range(r: range) : string;
begin
    string_of_range := concat('(', inttostr(r.left), ', ', inttostr(r.right), ')');
end;

function apply_maps(seeds: range_array; maps: array of map) : range_array;
var
    r: range;
    m: map;
    new_seeds, A: range_array;
    (* Index to output *)
    seed, Aseed: cardinal;
    (* new range {before, mid, after}*)
    nr_b, nr_m, nr_a: range;
begin
    apply_maps := seeds;
    setlength(A, 0);
    Aseed := 0;

    for m in maps do
    begin
        seed := 0;
        setlength(new_seeds, 0);

        for r in apply_maps do
        begin
            (* 
                We want to split the map ranges into 3 ranges that fall
                before, in the middle of, and after the current range r.
                Any overlapping ranges are added to our new list of ranges
            *)
            nr_b.left := r.left;
            nr_b.right := min(r.right, m.from_start);
            nr_m.left := max(r.left, m.from_start);
            nr_m.right := min(m.from_start + m.range, r.right);
            nr_a.left := max(m.from_start + m.range, r.left);
            nr_a.right := r.right;

            if nr_b.right > nr_b.left then
            begin
                if seed >= length(new_seeds) then
                    setlength(new_seeds, seed + 1);
                new_seeds[seed] := nr_b;
                seed := seed + 1;
            end;

            if nr_m.right > nr_m.left then
            begin
                if Aseed >= length(A) then
                    setlength(A, Aseed + 1);
                A[Aseed].left := nr_m.left - m.from_start + m.to_start;
                A[Aseed].right := nr_m.right - m.from_start + m.to_start;
                Aseed := Aseed + 1;
            end;

            if nr_a.right > nr_a.left then
            begin
                if seed >= length(new_seeds) then
                    setlength(new_seeds, seed + 1);
                new_seeds[seed] := nr_a;
                seed := seed + 1;
            end;
        end;

        apply_maps := new_seeds;
    end;

    apply_maps := concat(A, apply_maps);
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
    setlength(seedranges, 0);
    setlength(maps, 0);

    i := 0;
    while not eof(f) do
    begin
        readln(f, line);

        if (length(line) = 0) or ((i <> 0) and (not is_digit(line[1]))) then
        begin
            if length(maps) <> 0 then 
            begin
                seeds := apply_maps(seeds, maps);
                setlength(maps, 0);
            end;
            continue;
        end;

        if i = 0 then
        begin
            for s in splitstring(copy(line, 8), ' ') do
            begin
                setlength(seedranges, length(seedranges) + 1);
                seedranges[length(seedranges) - 1] := strtoint(s);
            end;

            for j := 0 to (length(seedranges) div 2) - 1 do
            begin
                setlength(seeds, length(seeds) + 1);
                seeds[j].left := seedranges[2 * j];
                seeds[j].right := seedranges[2 * j] + seedranges[2 * j + 1];
            end;

            i := i + 1;
            continue;
        end;

        (* Reading map *)
        sscanf(line, '%d %d %d', [@m.to_start, @m.from_start, @m.range]);
        setlength(maps, length(maps) + 1);
        maps[length(maps) - 1] := m;
    end;
    
    if length(maps) <> 0 then 
    begin
        seeds := apply_maps(seeds, maps);
    end;

    min_loc := seeds[0].left;
    for seed in seeds do
    begin
        min_loc := min(seed.left, min_loc);
    end;

    writeln('Minimum location: ', min_loc);
end.
