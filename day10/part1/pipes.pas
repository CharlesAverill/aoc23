program Pipes;
(*
    Given a maze of pipes, find the single cycle in the maze and determine the
    farthest point in the cycle from the cycle start point S.
*)

uses
    sysutils,
    math;

type
    tile = (
        NS, EW, NE, NW, SW, SE, GR, ST
    );

    pair = record
        x, y : integer;
    end;

    pair_array = array of pair;
    paptr = ^pair_array;

    cardinal_array = array of cardinal;
    captr = ^cardinal_array;

    maze_type = array of array of tile;

var
    fn: string;
    f: text;
    line: string;

    maze: maze_type;
    i, width: cardinal;

    start_pos: pair;
    emptyp: array of pair;
    emptyc: array of cardinal;

function tile_of_char(c: char) : tile;
begin
    case c of
        '|': tile_of_char := NS;
        '-': tile_of_char := EW;
        'L': tile_of_char := NE;
        'J': tile_of_char := NW;
        '7': tile_of_char := SW;
        'F': tile_of_char := SE;
        '.': tile_of_char := GR;
        'S': tile_of_char := ST;
    end;
end;

(* Check if a point is in bounds *)
function in_bounds(maze: maze_type; pos: pair) : boolean;
begin
    in_bounds :=    (pos.x >= 0) and (pos.x <= high(maze[0])) and 
                    (pos.y >= 0) and (pos.y <= high(maze));
end;

function tile_in_array(t: tile; a: array of tile) : boolean;
var
    x: tile;
begin
    tile_in_array := false;
    for x in a do
        tile_in_array := tile_in_array or (x = t)
end;

function add_pairs(a, b: pair) : pair;
begin
    add_pairs.x := a.x + b.x;
    add_pairs.y := a.y + b.y;
end;

(* Get all possible moves at a position *)
function possible_moves(maze: maze_type; pos: pair) : pair_array;
const
    all_moves: array of pair = (
        (x: 0; y:-1),
        (x: 0; y: 1),
        (x:-1; y: 0),
        (x: 1; y: 0)
    );
    source_connections: array of array of tile = (
        (ST, NS, NE, NW),
        (ST, NS, SE, SW),
        (ST, EW, NW, SW),
        (ST, EW, NE, SE)
    );
    direction_connections: array of array of tile = (
        (ST, NS, SE, SW),
        (ST, NS, NE, NW),
        (ST, EW, NE, SE),
        (ST, EW, NW, SW)
    );
var
    move: pair;
    i: cardinal;
begin
    setlength(possible_moves, 0);

    for i := 0 to high(all_moves) do
    begin
        move := add_pairs(pos, all_moves[i]);
        // writeln(maze[pos.y][pos.x], ' ', maze[move.y][move.x], ' ', tile_in_array(maze[pos.y][pos.x], source_connections[i]), ' ', tile_in_array(maze[move.y][move.x], direction_connections[i]));
        if in_bounds(maze, move) and
            tile_in_array(maze[pos.y][pos.x], source_connections[i]) and 
            tile_in_array(maze[move.y][move.x], direction_connections[i]) then
        begin
            setlength(possible_moves, length(possible_moves) + 1);
            possible_moves[high(possible_moves)] := move;
        end;
    end;
end;

(*
    Find the index of a pair in an array
*)
function find_pair(p: pair; a: array of pair) : integer;
var
    i: integer;
begin
    find_pair := -1;
    for i := 0 to high(a) do
    begin
        if (a[i].x = p.x) and (a[i].y = p.y) then
        begin
            find_pair := i;
            break;
        end;
    end;
end;

function string_of_pair(p: pair) : string;
begin
    string_of_pair := concat('(', inttostr(p.x), ', ', inttostr(p.y), ')')
end;

procedure print_pair_array(p: array of pair);
var
    x: pair;
begin
    write('[');
    for x in p do
        write(string_of_pair(x), '; ');
    writeln(']');
end;

(*
    Main program logic. Do a depth-first search over the maze, noting the minimum
    distance from S to each visited node. Then, return the max of those min distances.
*)
function dfs(maze: maze_type; pos: pair; depth: cardinal; visited: paptr; visited_distances: captr) : cardinal;
var
    move: pair;
    idx: integer;
    c: cardinal;
begin
    setlength(visited^, length(visited^) + 1);
    visited^[high(visited^)] := pos;
    setlength(visited_distances^, length(visited_distances^) + 1);
    visited_distances^[high(visited_distances^)] := depth;

    dfs := depth;

    for move in possible_moves(maze, pos) do
    begin
        idx := find_pair(move, visited^);
        if (idx >= 0) and (visited_distances^[idx] <= depth) then
            continue;

        if (idx >= 0) then
            visited_distances^[idx] := depth + 1;

        dfs(maze, move, depth + 1, visited, visited_distances);
    end;

    dfs := visited_distances^[0];
    for c in visited_distances^ do
        dfs := max(dfs, c);
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    setlength(maze, 0);
    width := 0;

    while not eof(f) do
    begin
        readln(f, line);

        setlength(maze, length(maze) + 1);
        if width = 0 then
            width := length(line);

        setlength(maze[high(maze)], width);
        for i := 0 to width do
        begin
            maze[high(maze)][i] := tile_of_char(line[i + 1]);
            if maze[high(maze)][i] = ST then
            begin
                start_pos.x := i;
                start_pos.y := high(maze);
            end;
        end;
    end;

    setlength(emptyp, 0);
    setlength(emptyc, 0);
    writeln('Max distance from S: ', dfs(maze, start_pos, 0, @emptyp, @emptyc));

    close(f);
end.
