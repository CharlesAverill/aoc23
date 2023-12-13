program Wasteland;
(*
    Given a graph of degree two as well as a list of left/right instructions,
    traverse the graph in parallel from all nodes ending in 'A' until all current
    nodes end in 'Z' and return the number of steps required to make the journey. 
    If you run out of instructions, repeat the instructions you have.

    For large numbers of steps, it is infeasible to actually traverse the graph
    in parallel (for a ~2^10 node graph with 5 starting nodes, the number of steps
    is in the trillions). Thankfully, due to some neat quirks of the input data, 
    taking the Least Common Multiple of each of the individual paths' lengths 
    provides the right answer.
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
    current_nodes: array of node;
    current, c: node;

    (* Output *)
    steps: cardinal;
    step_counts: array of cardinal;

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

function gcd(a, b : qword) : qword;
var
    t: qword;
begin
    while b <> 0 do
    begin
        t := b;
        b := a mod b;
        a := t;
    end;
    gcd := a;
end;

function lcm(counts: array of cardinal) : qword;
var
    i: cardinal;
begin
    lcm := 1;
    for i in counts do
        lcm := lcm * i div gcd(lcm, i);
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

        if namestr[high(namestr)] = 'A' then
        begin
            setlength(current_nodes, length(current_nodes) + 1);
            current_nodes[high(current_nodes)] := name_to_ptr[high(name_to_ptr)].value;
        end;
    end;

    setlength(step_counts, 0);
    for c in current_nodes do
    begin
        ictr := 1;
        steps := 0;
        current := c;

        (* Do the same operation as part 1, but look for endswith(Z) to terminate loop *)
        while not (current.name[3] = 'Z') do
        begin
            if instructions[ictr] = 'L' then
                current := find(name_to_ptr, current.left)
            else
                current := find(name_to_ptr, current.right);
            ictr := max(1, (ictr + 1) mod (length(instructions) + 1));
            steps := steps + 1;
        end;

        (* Push result onto list of results *)
        setlength(step_counts, length(step_counts) + 1);
        step_counts[high(step_counts)] := steps;
        writeln(steps);
    end;

    writeln('Steps: ', lcm(step_counts));

    close(f);
end.
