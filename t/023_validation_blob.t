# -*- perl -*-

# t/023_validation_blob.t - check validation of a blob


BEGIN {
	# First entry is the data to test.  Second entry is the expected result.
	@test = (
		[ 'foo',       'foo'   ], 
		[ 'bar1',      'bar1'  ], 
		[ '1baz',      '1baz'  ], 
		[ '_foo',      '_foo'  ], 
		[ ' bar',      ' bar'  ], 
		[ 'f oo',      'f oo'  ], 
		[ "baz\n",     "baz\n" ], 
		[ 'foo.',      'foo.'  ], 
		[ 'bar,',      'bar,'  ], 
		# Uses some ASCII control characeters to get a failed test
		[ "foo\0x07",  undef   ], 
		[ "bar\0x0E",  undef   ], 
		[ "baz\0x11",  undef   ], 
	);
}


use Test::More tests => scalar(@test);
use CGI::Search qw(BLOB);

foreach my $i (0 .. $#test) {
	# Need to check if some things are equal to undef.  'warnings' 
	# just causes needless error messages.
	# 
	no warnings;
	ok((BLOB($test[$i][0]))[1] eq $test[$i][1], "test$test[$i][1]");
}


