program Wasteland;
(*
    Given a graph of degree two as well as a list of left/right instructions,
    traverse the graph from node AAA to ZZZ and return the number of steps 
    required to make the journey. If you run out of instructions, repeat the
    instructions you have.
*)

uses 
    math,
    strutils,
    sysutils;

type
node = record
    name, left, right: string;
end;

type
str_node = record
    key: string;
    value: node;
end;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;
    (* Input file line *)
    line: string;

    (* String of left/right instructions *)
    instructions: ansistring;
    (* Which instruction we're currently at *)
    ictr: cardinal;

    (* Mapping from node names to pointers for constructing graph *)
    name_to_ptr: array of str_node;
    (* Scanned node info *)
    namestr, lstr, rstr: ansistring;

    (* Current node in traversal *)
    current: node;

    (* Output *)
    steps: cardinal;

function find(dict: array of str_node; key: string) : node;
var
    current: str_node;
begin
    for current in dict do
        if current.key = key then
        begin
            find := current.value;
            break;
        end;
end;

function string_of_node(n: node) : string;
begin
    string_of_node := concat(n.name, ': (', n.left, ' - ', n.right, ')');
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    (* Read in instructions *)
    readln(f, instructions);
    readln(f, line);

    setlength(name_to_ptr, 0);
    while not eof(f) do
    begin
        readln(f, line);

        (* Scan in node information *)
        setlength(name_to_ptr, length(name_to_ptr) + 1);
        sscanf(splitstring(line, ',')[0], '%s = (%s', [@namestr, @lstr]);
        rstr := copy(splitstring(line, ',')[1], 2, 3);

        setlength(name_to_ptr, length(name_to_ptr) + 1);
        name_to_ptr[high(name_to_ptr)].key := ansitoutf8(namestr);
        name_to_ptr[high(name_to_ptr)].value.name := ansitoutf8(namestr);
        name_to_ptr[high(name_to_ptr)].value.left := ansitoutf8(lstr);
        name_to_ptr[high(name_to_ptr)].value.right := ansitoutf8(rstr);
    end;

    current := find(name_to_ptr, 'AAA');
    ictr := 1;
    steps := 0;
    (* Traverse graph *)
    while current.name <> 'ZZZ' do
    begin
        if instructions[ictr] = 'L' then
            current := find(name_to_ptr, current.left)
        else
            current := find(name_to_ptr, current.right);
        (* Keeps ictr in range [1, length(instructions)] *)
        ictr := max(1, (ictr + 1) mod (length(instructions) + 1));
        steps := steps + 1;
    end;

    writeln('Steps: ', steps);

    close(f);
end.
