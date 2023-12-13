# Advent of Code 2023

This is my first time participating in [Advent of Code](https://adventofcode.com/).
I will be participating using the [Pascal](https://en.wikipedia.org/wiki/Pascal_(programming_language)) Programming Language, which I have not used before. 
All solutions are compiled using [fpc](https://www.freepascal.org/) version 3.2.2

Here's a [sample of Pascal code](helloworld.pas):

```pascal
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
	i : integer;
begin
	fact_it := 1;
	for i := 1 to n do
	begin
		fact_it := fact_it * i;
	end;
end;

begin
	writeln('Hello World!');
	writeln('fact(5): ', fact(5));
	writeln('fact_it(5): ', fact_it(5));
end.

```
