#!/usr/bin/perl
use strict;
use warnings;
BEGIN { push @INC, '../lib' }
use CGI::Search qw(:validators);
use Data::Dumper;

#NONE('blah');
my $TMPL_FILE    = '../test_data/test.tmpl';
my $DB_FILE      = '../test_data/test.db';
my $DB_SEPERATOR = '\|';  # Be sure to escape any special regex chars

# Database fields description
my @DB_FIELDS    = (
	[ 'num1',   \&INTEGER, 1 ], 
	[ 'text1',  \&WORD,    1 ], 
	[ 'email',  \&EMAIL,   1 ], 
	[ 'num2',   \&BLOB,    1 ], 
);

# Paging options (not currently supported).  All are automatically verfied as a $NUMBER
my $RESULTS_PER_PAGE = 25;
my $MAX_RESULTS      = 0;  # Infinate
my $PAGE_NUMBER      = 0;

# Search options
my %SEARCH           = (
	num1   => [ 2,   \&INTEGER ], 
);

print "\nConstructing . . . ";

my $search = CGI::Search->new(
	template          => $TMPL_FILE, 
	cache             => 0, 
	file_cache        => 0, 
	db_file           => $DB_FILE, 
	db_seperator      => $DB_SEPERATOR, 
	db_fields         => \@DB_FIELDS, 
	results_per_page  => $RESULTS_PER_PAGE, 
	max_results       => $MAX_RESULTS, 
	page_number       => $PAGE_NUMBER, 
	search_fields     => \%SEARCH, 
);

print "Done\nResults . . . \n";

my $results = $search->result(1) or die("Error: " . $search->errstr);

print "\nDone\n";
print "Data:\n\n";

#print Data::Dumper->Dumper(\@results);
$results->output(print_to => *STDOUT);

