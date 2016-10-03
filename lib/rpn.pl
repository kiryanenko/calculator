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

	my @stack = ();		# стэк операций
	my $prev = '';		# предыдущая операция
	for (@$source) {
		if (/\d/) { push @rpn, $_; }
		elsif ($_ eq ')') {
			if ($prev eq '(') { 
				$prev = pop @stack; 
			} else { 
				push @rpn, $prev;  
				$prev = pop @stack;
				redo;
			}
		}
		elsif (!$priority{$prev} || $_ eq '(' || 
			$priority{$prev} < $priority{$_} || $priority{$_} == 3) { 
			push @stack, $prev;
			$prev = $_; 
		}
		elsif ($priority{$prev} == $priority{$_}) { 
			push @rpn, $prev;  
			$prev = $_;
		}
		elsif ($priority{$prev} > $priority{$_}) {
			push @rpn, $prev;  
			$prev = pop @stack;
			redo;
		}
	}
	if ($prev) {
		shift @stack;
		@rpn = (@rpn, $prev, reverse  @stack);
	}

	return \@rpn;
}

1;
