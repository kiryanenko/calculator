=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;

	my @stack;
	for(@$rpn) {
		given ($_) {
			when (/\d/) { push @stack, $_; }
			when ('U+') { push @stack, pop @stack; }
			when ('U-') { push @stack, -pop @stack; }
			when ('+') { my $prev = pop @stack; push @stack, (pop @stack) + $prev; }
			when ('-') { my $prev = pop @stack; push @stack, (pop @stack) - $prev; }
			when ('*') { my $prev = pop @stack; push @stack, (pop @stack) * $prev; }
			when ('/') { my $prev = pop @stack; push @stack, (pop @stack) / $prev; }
			when ('^') { my $prev = pop @stack; push @stack, (pop @stack) ** $prev; }
		}
	}

	return shift @stack;
}

1;
