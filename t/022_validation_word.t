# -*- perl -*-

# t/022_validation_word.t - check validation of a word


BEGIN {
	# First entry is the data to test.  Second entry is the expected result.
	@test = (
		[ 'foo',   'foo'  ], 
		[ 'bar1',  'bar1' ], 
		[ '1baz',  '1baz' ], 
		[ '_foo',  '_foo' ], 
		[ ' bar',  undef  ], 
		[ 'f oo',  undef  ], 
		[ "baz\n", undef  ], 
		[ 'foo;',  undef  ], 
		[ '/bar',  undef  ], 
		[ 'b*z',   undef  ], 
		[ 'foo.',  undef  ], 
		[ 'bar,',  undef  ], 
	);
}


use Test::More tests => scalar(@test);
use CGI::Search qw(WORD);

foreach my $i (0 .. $#test) {
	# Need to check if some things are equal to undef.  'warnings' 
	# just causes needless error messages.
	# 
	no warnings;
	ok((WORD($test[$i][0]))[1] eq $test[$i][1], "test$test[$i][1]");
}


