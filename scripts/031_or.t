# -*- perl -*-

# t/031_or.t - Do an OR search

my $SILLY = sub 
{
	my $chk = shift;
	$chk =~ /(.*)/;
	return (1, $1, "Passed");
};

my %SEARCH1 = (
	field1  =>  [ '20',   $SILLY ], 
	field2  =>  [ 'Av',   $SILLY ], 
);
my %SEARCH2 = (
	field2  =>  [ 'Ce',   $SILLY ], 
	field3  =>  [ '.biz', $SILLY ], 
);


#use Test::More tests => 2;
use CGI::Search;

my @db_fields = 
	(
		[ 'field1',  $SILLY, 1 ], 
		[ 'field2',  $SILLY, 1 ], 
		[ 'field3',  $SILLY, 1 ], 
		[ 'field4',  $SILLY, 1 ], 
	);

my $object = CGI::Search->new (
	db_file        => '../test_data/test.db', 
	db_fields      => \@db_fields, 
	search_fields  => \%SEARCH1, 
	template       => '../test_data/test.tmpl', 
);
my @results1 = $object->result(1);

my @results2 = $object->result(1, \%SEARCH2);

{
	use Data::Dumper;
	print "Results 1\n----\n";
	print Data::Dumper->Dump(\@results1);
	print "\nResults 2\n----\n";
	print Data::Dumper->Dump(\@results2);
}

