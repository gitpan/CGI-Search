# -*- perl -*-

# t/024_validation_email.t - check validation of an email


BEGIN {
	# First entry is the data to test.  Second entry is the expected result.
	@test = (
		[ 'abc@example.com',         'abc@example.com'        ], 
		[ 'def_@example.com',        'def_@example.com'       ], 
		[ 'abc.def@gh.example.com',  'abc.def@gh.example.com' ], 
		[ '123@example.com',         '123@example.com'        ], 
		[ 'abc@ example.com',        'abc@ example.com'       ], 
		[ 'abc def@example.com',     undef                    ], 
		[ 'abcexample.com',          undef                    ], 
		[ '@example.com',            undef                    ], 
		[ 'abc@def@example.com',     undef                    ], 
		[ 'abc.@example.com',        undef                    ], 

		# This one is not valid by RFC-822, but should be (RFC-2822 fixes it?)
		[ 'abc@example',             undef                    ], 
	);
}


use Test::More tests => scalar(@test);
use CGI::Search qw(EMAIL);

foreach my $i (0 .. $#test) {
	# Need to check if some things are equal to undef.  'warnings' 
	# just causes needless error messages.
	# 
	no warnings;
	ok((EMAIL($test[$i][0]))[1] eq $test[$i][1], "test$test[$i][1]");
}


