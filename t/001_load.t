# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'CGI::Search' ); }


my $SILLY = sub 
{
	my $chk = shift;
	$chk =~ /(.*)/;
	return (1, $1, "Passed");
};

my @db_fields = 
	(
		[ 'field1',  $SILLY, 1 ], 
		[ 'field2',  $SILLY, 1 ], 
		[ 'field3',  $SILLY, 1 ], 
	);
my %search_fields = 
	(
		field1  => [ 'foo', $SILLY ], 
	);

my $object = CGI::Search->new (
	db_file        => '../test_data/test.db', 
	db_fields      => \@db_fields, 
	search_fields  => \%search_fields, 
	template       => '../test_data/test.tmpl', 
	file_cache_dir => '/tmp', 
);
isa_ok ($object, 'CGI::Search');


