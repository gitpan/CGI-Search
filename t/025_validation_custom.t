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
	);
}


use Test::More tests => scalar(@test);
use CGI::Search qw(:test);

foreach my $i (0 .. $#test) {
	# Need to check if some things are equal to undef.  'warnings' 
	# just causes needless error messages.
	# 
	no warnings;
	my $search = CGI::Search->new( db_file => '/', template => '/', 
		test_validator => \&validator, file_cache_dir => '/tmp', );
	ok(( $search->test_custom_validator( 
			$test[$i][0]) )[1] eq $test[$i][1], 
		"test$test[$i][1]");
}

sub validator {
	my $data = shift;
	$data =~ /\A(.*)\z/;
	return (1, $1, "Passed");
}

