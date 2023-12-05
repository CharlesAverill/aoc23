program Cubes;
(* 
    Given a list of games in which cubes are randomly from a bag in sets, 
    determine the least number of cubes of each color that must be in the bag
    for each game to be possible.
*)

uses 
    (* For max *)
    math,
    (* For sscanf *)
    sysutils,
    (* For splitstring *)
    strutils;

type 
    color = (red, green, blue);

type
cube_set = record
    r, g, b : cardinal;
end;

type
game = record
    id: cardinal;
    sets: array of cube_set;
end;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;

    (* Current line of input file *)
    line: string;
    (* Current game of input file *)
    g: game;

    (* Current cube set *)
    cs: cube_set;

    (* Expected numbers of cubes *)
    minred : cardinal = 12;
    mingreen: cardinal = 13;
    minblue: cardinal = 14;

    (* Output - power (product of mins) of possible games *)
    sum_power : cardinal;

function count_chars(str: string; target: Char): Integer;
var
    i: Integer;
begin
    count_chars := 0;
    for i := 1 to Length(str) do
    begin
        if str[i] = target then
            inc(count_chars);
    end;
end;

function string_of_cube_set(c: cube_set) : string;
begin
    string_of_cube_set := concat(inttostr(c.r), ' red - ', inttostr(c.g), ' green - ', inttostr(c.b), ' blue')
end;

function parse_game(game_str: string) : game;
var
    i, count: cardinal;
    sets, cube_set, count_cube : string;
    cube: ansistring;
begin
    sscanf(game_str, 'Game %d:', [@parse_game.id]);
    sets := copy(game_str, pos(':', game_str) + 2);

    setlength(parse_game.sets, count_chars(game_str, ';') + 1);

    i := 0;
    for cube_set in splitstring(sets, ';') do
    begin
        parse_game.sets[i].r := 0;
        parse_game.sets[i].g := 0;
        parse_game.sets[i].b := 0;

        for count_cube in splitstring(trim(cube_set), ',') do
        begin
            sscanf(trim(count_cube), '%d %s', [@count, @cube]);

            if comparetext(cube, 'red') = 0 then 
                parse_game.sets[i].r := count
            else if comparetext(cube, 'green') = 0 then 
                parse_game.sets[i].g := count
            else if comparetext(cube, 'blue') = 0 then 
                parse_game.sets[i].b := count;
        
        end;

        inc(i);
    end;
end;

procedure print_game(g: game);
var 
    set_idx : cardinal;
begin
    writeln('Game ', g.id);
    writeln('----------');
    for set_idx := 0 to length(g.sets) - 1 do
    begin
        writeln('  Set ', set_idx + 1, ': ', string_of_cube_set(g.sets[set_idx]))
    end;
end;

begin
    sum_power := 0;

	(* Get filename from stdin *)
	write('Input filename: ');
	readln(fn);

	(* Open file *)
	assign(f, fn);
	reset(f);

    while not eof(f) do
    begin
        readln(f, line);
        g := parse_game(line);

        minred := 0;
        mingreen := 0;
        minblue := 0;
        for cs in g.sets do
        begin
            minred := max(minred, cs.r);
            mingreen := max(mingreen, cs.g);
            minblue := max(minblue, cs.b);
        end;

        sum_power := sum_power + (minred * mingreen * minblue);
    end;

    writeln('Sum of powers: ', sum_power);

    close(f);
end.
