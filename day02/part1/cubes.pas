program Cubes;
(* 
    Given a list of games in which cubes are randomly from a bag in sets, 
    determine which sets of games make it possible for the bag to contain
        - 12 red cubes
        - 13 green cubes
        - 14 blue cubes
    And return the sum of the IDs of those games.
*)

uses 
    (* For sscanf *)
    sysutils,
    (* For splitstring *)
    strutils;

type 
    color = (red, green, blue);

(* The numbers of each color of cube per cube set *)
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
    (* Whether current cube set is impossible *)
    cs_imp: boolean;

    (* Expected numbers of cubes *)
    nred : cardinal = 12;
    ngreen: cardinal = 13;
    nblue: cardinal = 14;

    (* Output - sum of possible games *)
    sum_possible : cardinal;

(* Count the number of occurrences of 'target' in 'str' *)
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

(* Get the string representation of a cube set *)
function string_of_cube_set(c: cube_set) : string;
begin
    string_of_cube_set := concat(inttostr(c.r), ' red - ', inttostr(c.g), ' green - ', inttostr(c.b), ' blue')
end;

(* Parse a game string into a 'game' record *)
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

(* Print a string representation of a 'game' *)
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
    sum_possible := 0;

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

        cs_imp := false;
        for cs in g.sets do
        begin
            if (cs.r > nred) or (cs.g > ngreen) or (cs.b > nblue) then
            begin
                cs_imp := true;
                break
            end
        end;

        if cs_imp then
            continue;

        sum_possible := sum_possible + g.id;
    end;

    writeln('Possible: ', sum_possible);

    close(f);
end.
