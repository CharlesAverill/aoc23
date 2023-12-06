program Scratchcards;
(*
    Given a list of scratchcards, which contain two lists of winning and given
    numbers, return the number of points that all of the scratchcards are worth.
    A card's worth is determined by how many of the given numbers match the winning
    numbers: the first match is worth one point, and each match after doubles
    the worth of the card.
*)

uses 
    (* For sscanf *)
    sysutils,
    (* For splitstring *)
    strutils;

type 
scratchcard = record
    id: cardinal;
    winning, given: array of cardinal;
end;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;

    (* Current line of input *)
    line: string;

    (* Current scratchcard *)
    card: scratchcard;

    (* Sum of all scratchcard values *)
    sum: cardinal;

function parse_card(line: string) : scratchcard;
var
    winning_str, given_str: array of ansistring;
    winning_start, given_start: cardinal;
    i, empties: cardinal;
begin
    sscanf(line, 'Card %d:', [@parse_card.id]);

    winning_start := pos(':', line) + 1;
    given_start := pos('|', line) + 1;
    
    winning_str := splitstring(trim(copy(line, winning_start, given_start - winning_start - 1)), ' ');
    given_str := splitstring(trim(copy(line, given_start)), ' ');

    setlength(parse_card.winning, length(winning_str));
    setlength(parse_card.given, length(given_str));

    empties := 0;
    for i := 0 to length(winning_str) - 1 do
    begin
        if (winning_str[i] = ' ') or (winning_str[i] = '') then
        begin
            setlength(parse_card.winning, length(parse_card.winning) - 1);
            empties := empties + 1;
            continue;
        end;

        parse_card.winning[i - empties] := strtoint(winning_str[i]);
    end;

    empties := 0;
    for i := 0 to length(given_str) - 1 do
    begin
        if (given_str[i] = ' ') or (given_str[i] = '') then
        begin
            setlength(parse_card.given, length(parse_card.given) - 1);
            empties := empties + 1;
            continue;
        end;

        parse_card.given[i - empties] := strtoint(given_str[i]);
    end;
end;

function score_card(card: scratchcard) : cardinal;
var
    w, g, multiplier: cardinal;
begin
    score_card := 0;

    for g := 0 to length(card.given) - 1 do
    begin
        for w := 0 to length(card.winning) - 1 do
        begin
            if card.given[g] = card.winning[w] then
            begin
                if score_card = 0 then
                    score_card := 1
                else
                    score_card := score_card * 2;
                break;
            end;
        end;
    end;
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    sum := 0;

    while not eof(f) do
    begin
        readln(f, line);

        card := parse_card(line);

        sum := sum + score_card(card);
    end;

    writeln('Sum of points: ', sum);
end.
