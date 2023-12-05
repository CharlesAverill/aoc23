program HelloWorld;

function fact(n: integer): integer;
begin
	if (n <= 0) then
		fact := 1
	else
		fact := n * fact(n - 1)
end;

function fact_it(n: integer): integer;
var
	prod, i : integer;
begin
	prod := 1;
	for i := 1 to n do
	begin
		prod := prod * i;
	end;
	fact_it := prod;
end;

begin
	writeln('Hello World!');
	writeln('fact(5): ', fact(5));
	writeln('fact_it(5): ', fact_it(5));
end.
