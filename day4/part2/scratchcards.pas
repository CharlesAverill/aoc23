program Scratchcards;
(*
    Given a list of scratchcards, which contain two lists of winning and given
    numbers, return the total number of scratchcards you have, including those
    you started with. Scratchcards are won via the following rules:
    - If card N has M winning numbers, you receive copies of cards [N + 1 : N + M]
        (i.e. if card 10 has 5 winning numbers, you get [11, 12, 13, 14, 15])
    - Copies of scratchcards are also scored. So if you win a copy of card X,
      all cards it wins are also scored.
        (i.e. if you have card 1 and card 2, and card 1 wins a copy of card 2,
        you score both instances of card 2)
*)

uses 
    (* For max *)
    math,
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

    (* Number of copies of each card *)
    copies: array of cardinal;
    (* Number of copies of current card *)
    curr_copies: cardinal;

    (* Loop indices *)
    i, j: cardinal;

    (* Number of copies won per scratchcard *)
    score: cardinal;
    (* Count of all scratchcards *)
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
    w, g: cardinal;
begin
    score_card := 0;

    for g := 0 to length(card.given) - 1 do
    begin
        for w := 0 to length(card.winning) - 1 do
        begin
            if card.given[g] = card.winning[w] then
            begin
                score_card := score_card + 1;
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
    setlength(copies, 0);

    while not eof(f) do
    begin
        readln(f, line);

        card := parse_card(line);
        score := score_card(card);

        setlength(copies, math.max(cardinal(length(copies)), card.id + score));
        // Add the current original card to the stack
        copies[card.id - 1] := copies[card.id - 1] + 1;
        
        // Iterate through the number of cards that the current card won
        // Increment their count by copies[card.id - 1]
        for i := 1 to score do
        begin
            copies[card.id + i - 1] := copies[card.id + i - 1] + copies[card.id - 1];
        end;
    end;

    for i := 0 to length(copies) - 1 do
    begin
        sum := sum + copies[i];
    end;

    writeln('Number of scratchcards: ', sum);
end.
