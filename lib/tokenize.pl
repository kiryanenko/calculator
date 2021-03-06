=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	my @res;
	
	my @chanks = split
		m{
			(
				(?<!e) [-+] 	# +|- w/o 'e' before
				|
				[*()/^] 		# or operations
			)
			|
			\s+ 				# or spaces
		}x, $expr;
	@res = grep { length $_; } @chanks;	# Удаляю пустые строки

	my $nBrackets = 0;		# Для проверки валидности скобок
	my $prev = '';
	for (@res) {
		given($_) {
			when (['+', '-']) { $_ = "U$_" if $prev =~ m{^U?[\(\+\*-/^]?$}; }
			when ('(') { $nBrackets++; }
			when (')') { $nBrackets--; }
			when (m{^[\*/^]$} && $prev =~ /\d|\)/) { }
			when (/^\d*\.?\d*(?<=\d|\.)(e?[\+-]?\d+)?$/ && $prev =~ /^\D*$/) { $_ = 0+$_ }
			default { die "Bad: '$_'" }
		}
		die "Bad: '$_'" if $nBrackets < 0;
		$prev = $_;
	}
	die "Bad: Не хватает аргумента после" if $prev =~ m{^U?[*/^+-]$};
	die "Bad: Не хватает закрывающих скобок" if $nBrackets;

	return \@res;
}

1;
