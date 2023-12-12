program Camel;
(*
    Given hands of cards, apply standard hand type scoring and lexicographic
    scoring to sort the hand. Then, determine the winnings by multiplying each
    hand's bid by their 'rank' (position in the sorted list). We now have to 
    consider J cards as Jokers, which take the value of whichever card would've
    made the hand the strongest possible via the same scoring rules, except in
    breaking ties, when J is now the weakest card.
*)

uses
    math,
    sysutils,
    strutils;

type
hand = record
    cards: array of cardinal;
    bid: cardinal;
end;

var
    (* Input filename *)
    fn: string;
    (* Input file *)
    f: text;
    (* Input file line *)
    line, card: string;

    (* Input hands *)
    hands: array of hand;
    i: cardinal;
    card_val: cardinal;

    winnings: qword;

type 
    hands_array = array of hand;

(* Determine if a character is '0'..'9' *)
function is_digit(c: char) : boolean;
begin
	is_digit := (48 <= ord(c)) and (ord(c) <= 57)
end;

(* Return the number of pairs in a hand *)
function n_pairs(h: hand) : cardinal;
var
    i, j: cardinal;
    found: cardinal; 
begin
    n_pairs := 0;
    found := 0;

    for i := 0 to length(h.cards) - 1 do
    begin
        if h.cards[i] = found then
            continue;
        
        for j := i + 1 to length(h.cards) - 1 do
        begin
            if h.cards[i] = h.cards[j] then
            begin
                n_pairs := n_pairs + 1;
                found := h.cards[i];
                break;
            end;
        end;
    end;
end;

(* Return the largest number of like cards in a hand *)
function n_of_a_kind(h: hand) : cardinal;
var
    c: cardinal;
    counts: array[2..14] of cardinal;
begin
    for c := 2 to 14 do
        counts[c] := 0;

    for c in h.cards do 
    begin
        counts[c] := counts[c] + 1;
    end;

    n_of_a_kind := 0;
    for c := 2 to 14 do
    begin
        n_of_a_kind := max(n_of_a_kind, counts[c]);
    end;
end;

(* Determine if hand is a full house *)
function full_house(h: hand) : boolean;
var
    c: cardinal;
    counts: array[2..14] of cardinal;
    found2, found3: boolean;
begin
    for c := 2 to 14 do
        counts[c] := 0;

    for c in h.cards do 
    begin
        counts[c] := counts[c] + 1;
    end;

    found2 := false;
    found3 := false;
    for c := 2 to 14 do
    begin
        if counts[c] = 2 then
            found2 := true
        else if counts[c] = 3 then
            found3 := true;
    end;

    full_house := found2 and found3;
end;

(* 
    Classify a hand into the following classes:
    - 6: 5 of a kind
    - 5: 4 of a kind
    - 4: Full house
    - 3: 3 of a kind
    - 2: Two pair
    - 1: One pair
    - 0: High card
*)
function classify_hand(h: hand) : cardinal;
var
    n: cardinal;
begin
    (* Handle high card, one/two pair case *)
    classify_hand := n_pairs(h);

    (* Handle n of a kind cases *)
    n := n_of_a_kind(h);
    if n = 3 then
        classify_hand := max(classify_hand, 3)
    else if n > 3 then
        classify_hand := max(classify_hand, n + 1);

    (* Handle full house *)
    if full_house(h) then
        classify_hand := max(classify_hand, 4);
end;

(* Compare two hands. Return 1 if A > B, 0 if A = B, -1 if A < B *)
function compare_hands(A: hand; B: hand) : integer;
var
    i: cardinal;
begin
    if classify_hand(A) < classify_hand(B) then
        compare_hands := -1
    else if classify_hand(A) > classify_hand(B) then
        compare_hands := 1
    else
    begin
        for i := 0 to length(A.cards) do
        begin
            if A.cards[i] = B.cards[i] then
                continue
            else if A.cards[i] < B.cards[i] then
                compare_hands := -1
            else 
                compare_hands := 1;
            break;
        end;
    end;
end;

function bubble_sort(hands: hands_array) : hands_array;
var
    i, j: cardinal;
    swap: hand;
begin
    bubble_sort := hands;
    for i := 0 to length(bubble_sort) - 2 do
    begin
        for j := 0 to length(bubble_sort) - i - 2 do
        begin
            if compare_hands(bubble_sort[j], bubble_sort[j + 1]) > 0 then
            begin
                swap := bubble_sort[j];
                bubble_sort[j] := bubble_sort[j + 1];
                bubble_sort[j + 1] := swap;
            end;
        end;
    end;
end;

function string_of_hand(h: hand) : string;
var
    c: cardinal;
    v: string;
begin
    string_of_hand := '';
    for c in h.cards do
    begin
        if c < 10 then
            v := inttostr(c)
        else if c = 10 then
            v := 'T'
        else if c = 11 then
            v := 'J'
        else if c = 12 then
            v := 'Q'
        else if c = 13 then
            v := 'K'
        else if c = 14 then
            v := 'A';
        
        string_of_hand := concat(string_of_hand, v);
    end;

    string_of_hand := concat(string_of_hand, ' ', inttostr(h.bid));
end;

begin
    write('Input filename: ');
    readln(fn);

    assign(f, fn);
    reset(f);

    setlength(hands, 0);

    while not eof(f) do
    begin
        readln(f, line);

        i := length(hands);
        setlength(hands, length(hands) + 1);

        (* Parse hand bid *)
        hands[i].bid := strtoint(splitstring(line, ' ')[1]);

        (* Parse hand cards *)
        setlength(hands[i].cards, 0);
        for card in splitstring(line, ' ')[0] do
        begin
            setlength(hands[i].cards, length(hands[i].cards) + 1);
            if is_digit(card[1]) then
                card_val := strtoint(card)
            else if card = 'T' then
                card_val := 10
            else if card = 'J' then
                card_val := 1
            else if card = 'Q' then
                card_val := 12
            else if card = 'K' then
                card_val := 13
            else if card = 'A' then
                card_val := 14;
            hands[i].cards[length(hands[i].cards) - 1] := card_val;
        end;
    end;

    (* Sort hands based on their value *)
    hands := bubble_sort(hands);

    winnings := 0;
    for i := 0 to length(hands) - 1 do
    begin
        writeln(string_of_hand(hands[i]), ' ', classify_hand(hands[i]));
        winnings := winnings + ((i + 1) * hands[i].bid);
    end;

    writeln('Winnings: ', winnings);

    close(f);
end.
