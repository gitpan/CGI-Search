# -*- perl -*-

# t/021_validation_integer.t - check validation of numbers


# First entry is the data to test.  Second entry is the expected result.
BEGIN {
	@test = (
		[ 1,       1     ], 
		[ 234,     234   ], 
		[ 5678,    5678  ], 
		[ 3.1416,  undef ], 
		[ 31.416,  undef ], 
		[ '74foo', undef ], 
		[ 'bar63', undef ], 
		[ 'baz',   undef ], 
	);
}

use Test::More tests => scalar(@test);
use CGI::Search qw(INTEGER);

foreach my $i (0 .. $#test) {
	# Need to check if some things are equal to undef.  'warnings' 
	# just causes needless error messages.
	# 
	no warnings;
	ok((INTEGER($test[$i][0]))[1] eq $test[$i][1], "test$test[$i][1]");
}


