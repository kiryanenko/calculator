=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

	my %priority = (
		''   => 0,
		'('  => 0,
		')'  => 0,
		'+'  => 1,
		'-'  => 1,
		'*'  => 2,
		'/'  => 2,
		'U+' => 3,
		'U-' => 3,
		'^'  => 4
	);

	my @stack = ('');		# стек операций
	for (@$source) {
		if (/\d/) { push @rpn, $_; }
		elsif ($_ eq ')') {
			if ($stack[0] eq '(') { 
				shift @stack; 
			} else { 
				push @rpn, shift @stack;
				redo;
			}
		}
		elsif (!$priority{$stack[0]} || $_ eq '(' || 
			$priority{$stack[0]} < $priority{$_} || $priority{$_} == 3) { 
			unshift @stack, $_; 
		}
		elsif ($priority{$stack[0]} == $priority{$_}) { 
			push @rpn, $stack[0];  
			$stack[0] = $_;
		}
		elsif ($priority{$stack[0]} > $priority{$_}) {
			push @rpn, shift @stack;
			redo;
		}
	}
	pop @stack;
	push @rpn, @stack;

	return \@rpn;
}

1;
