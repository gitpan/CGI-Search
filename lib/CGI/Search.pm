
package CGI::Search;
use strict;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 0.1;
	@ISA         = qw (Exporter);
	@EXPORT      = qw ();
	@EXPORT_OK   = qw (INTEGER WORD BLOB EMAIL NONE test_custom_validator);
	%EXPORT_TAGS = (
		validators => [ qw(INTEGER WORD BLOB EMAIL NONE) ], 

		# Only for testing, don't use in a real program
		test       => [ qw(test_custom_validator) ], 
	);
}

use CGI::Search::Config;  # System-specific configuration info



=head1 NAME

CGI::Search - Simple way of using a CGI to search flat-text database files.

=head1 SYNOPSIS

  use CGI::Search qw(:validators);
  use CGI qw(:standard);
  
  my $TMPL_FILE    = '/path/to/template';
  my $DB_FILE      = '/path/to/flat_file';
  my $DB_SEPERATOR = '\|';  # Be sure to escape any special regex chars and put in single-quotes
  
  # This is not a good validator.  Don't do this.
  my $CUSTOM_VALIDATOR = sub 
  {
  	if($_[0] =~ /\A(.*)\z/) {
		return (1, $1, "Passed");
	}
	else {
		return (0, undef, "$_[0] is not valid");
	}
  };
  # Database fields description
  my @DB_FIELDS    = (
  	[ 'num1',   \&INTEGER,          1  ], 
	[ 'text1',  \&WORD,             0  ], 
	[ 'email',  \&EMAIL,            1  ], 
	[ 'num2',   \&INTEGER,          0  ], 
	[ 'field1', $CUSTOM_VALIDATOR,  0  ], 
  );

  # Paging options (not currently supported).  All are automatically verfied as an INTEGER
  my $RESULTS_PER_PAGE = param('RESULTS_PER_PAGE') || 0;
  my $MAX_RESULTS      = 0;  # Infinate
  my $PAGE_NUMBER      = param('PAGE') || 0;
  
  # Search options
  my %SEARCH           = (
  	num1   => [ param("num1"),  \&INTEGER ], 
	email  => [ param("email"), \&EMAIL   ], 
  );

  
  my $search = CGI::Search->new(
  	script_name       => $ENV{SCRIPT_NAME}, 
  	template          => $TMPL_FILE, 
	db_file           => $DB_FILE, 
	db_seperator      => $DB_SEPERATOR, 
	db_fields         => \@DB_FIELDS, 
	results_per_page  => $RESULTS_PER_PAGE, 
	max_results       => $MAX_RESULTS, 
	page_number       => $PAGE_NUMBER, 
	search_fields     => \%SEARCH, 
  );

  # List context   -- return array-of-hashes
  my @data = $search->result(1) or die "Error: " . $search->errstr();
  # Scalar context -- return HTML::Template object
  my $tmpl = $search->result(1) or die "Error: " . $search->errstr();

  my %new_search = (
  	num1  => [ param("num1"),      \&INTEGER ], 
	email => [ param("old_email"), \&EMAIL   ], 
  );
  
  # Run a search with different parameters
  my $new_tmpl = $search->result(1, \%new_search);


=head1 DESCRIPTION

Many CGIs simply search flat-text databases and return the results to the browser.  This 
object implements a generic interface for searching such databases and returning an 
HTML::Template object ready to be presented to the browser.  Returning the data as a 
hash-of-arrays is also possible, although this will probably be less used in practice.

Input from the user and the database is easily verified, thus making it simple to write 
secure and more robust code.

An Object Oreinted Purist will note that two orthogonal concepts (searching and user 
input validation) are being put together.  In this case, I have rejected the purist 
approach because binding these two together will make it so easy to do validation 
that there is no excuse for not doing it.  If the purists want to use a different 
module (and probably write twice as much code doing it), that is fine with me.


=head1 VALIDATORS

Validators are used to check input from the database and the user.  The data will be 
untainted after the pattern is matched.

Currently defined validators are:

  INTEGER   Base-10 (or smaller base) Integer
  WORD      Any alphanumeric text (whitespace and punctuation not allowed)
  BLOB      Any alphanumeric text (whitespace and punctuation allowed)
  EMAIL     An e-mail address (only checks for a valid format)
  NONE      Do no validation (will NOT be untainted)

All of these are exported via :validators.

Custom patterns are possible by passing a referance to a subroutine that will match and 
untaint the data.  See the synopsis, where $CUSTOM_VALIDATOR contains a referance to a 
subroutine that will act as a (stupid) custom validator.

Be sure that your custom validator untaints the data, or weird things may or may not happen.

Custom validators need to return a three-element array.  If the data was valid, then 
it returns a true value in the first element, the untained data in the second element 
and any string in the third element ("Passed" is typical, but don't rely on that).  If the 
data failed to validate, then the first element is a false value, the second is undef, and 
the third element is an error message.

Note for INTEGER: This will not work for floating point numbers.  Some systems have a 
buggy number-to-string converter, so an integer might become a float when the number is 
matched by a regex.  Many of these problems are worked around in perl 5.8.0.

INTEGER will also fail to match a number in scientific notation (like "12.46e2")


=head1 TEMPLATES

All templates need to have certain variables and conditionals in order to handle error 
conditions.  Here's an example of a good template:

  <html>
  <head>
      <title>Search results</title>
  </head>
  <body bgcolor="#FFFFFF">

      <TMPL_UNLESS NAME="error">
          <h1>Search results</h1>

	  <TMPL_UNLESS NAME="results">
	      <!-- Shows up if there were no results in the search -->
	      <p>No results were found for your search</p>
	  </TMPL_UNLESS>
	  
	  <TMPL_LOOP NAME="results">
	      <TMPL_UNLESS NAME="error">

	          <!-- Show the fields from the database you wish to display -->
	          <p><TMPL_VAR NAME="field1"></p>
	          <p><TMPL_VAR NAME="field2"></p>
	          <p><TMPL_VAR NAME="field3"></p>
	          <p>&nbsp;</p>
	          <p>&nbsp;</p>
		  
	      <TMPL_ELSE>
	          <!-- Errors within the search results -->
	          <p>Error in database: <TMPL_VAR NAME="error"></p>
	      </TMPL_UNLESS>
	      
	  </TMPL_LOOP>

	  <!-- For pagination -->
	  <form action="<TMPL_VAR NAME="script_name">" method="GET">
	  <TMPL_LOOP NAME="search_fields">
		  <input type="hidden" name="<TMPL_VAR NAME="name">" 
			  value="<TMPL_VAR NAME="value">">
	  </TMPL_LOOP>

	  <input type="hidden" name="cur_page" value="<TMPL_VAR NAME="cur_page">">
	  <p>Show <input type="text" name="results_per_page" 
		  value="<TMPL_VAR NAME="results_per_page">" size="3"> results per page</p>

	  <p><TMPL_IF NAME="prev">
		  <input type="submit" name="prev" value="Previous"> &nbsp;</TMPL_IF>
	  <TMPL_IF NAME="next">
		  <input type="submit" name="next" value="Next"></TMPL_IF>
	  </p>
	  </form>

      <TMPL_ELSE>
          <!-- Errors for the overall search -->
          <h1><TMPL_VAR NAME="error"></h1>

	  <p><TMPL_VAR NAME="errstr"></p>  <!-- "errstr" contains a specific error message -->
      </TMPL_UNLESS>

  </body>
  </html>


Note where errors are handled within the template.  There can be an error in the overall 
search or within a single search item, such as when a field in the database didn't validate 
correctly.

You can define other template variables outside the loop and fill them in yourself after 
the search is completed.

Within the results loop, variables are filled in according to the fields named in the 
"db_fields" option passed to new().  HTML::Template is called with "die_on_bad_params => 0", 
so any fields that pass the search result but aren't in the template won't kill the entire 
process.



=head1 DATABASE FIELDS



=head1 SEARCH FIELDS



=head1 PAGINATION

Paging data tends to force certain structures on the templates. I'm not happy with it, 
but I don't see a way out of it without disallowing paging completely.  I encrouage 
anyone who can to come up with a more flexible and elegant solution.  Until then, 
we're stuck with the current implementation.

In your template, you need to place a new form that will call the next page.  This form 
will take TMPL_LOOP params named "search_fields containing input fields.  These are filled 
with the data you passed as the search terms.

	  <form action="<TMPL_VAR NAME="script_name">" method="POST">
	  <TMPL_LOOP NAME="search_fields">
		  <input type="hidden" name="<TMPL_VAR NAME="name">" 
			  value="<TMPL_VAR NAME="value">">
	  </TMPL_LOOP>

If you want to let users change the search options, you could put the options 
into a text field instead, if you so choose.

Next, we define what the current page number is, how many results we want to 
see per page, and a next and previous button.  Which button is pressed will determine 
if we go forward or back.

  <input type="hidden" name="cur_page" value="<TMPL_VAR NAME="cur_page">">
  <p>Show <input type="text" name="results_per_page" 
  	value="<TMPL_VAR NAME="results_per_page">" size="3"> results per page</p>

  <p><TMPL_IF NAME="prev">
	  <input type="submit" name="prev" value="Previous"> &nbsp;</TMPL_IF>
  <TMPL_IF NAME="next">
	  <input type="submit" name="next" value="Next"></TMPL_IF>
  </p>
  </form>

In this case, the current page number is put into a hidden field, and the results per 
page is coming from a text box which defaults to the current value of results_per_page 
you passed to CGI::Search->new().

To determine the current page, your script should do something like this:

  my $PAGE_NUMBER = param('cur_page') || 0;
  $PAGE_NUMBER++ if param('next');
  $PAGE_NUMBER-- if param('prev');

Notice that the 'cur_page' param is actually the value of the last page the user 
was on.  If the user hit the 'next' button, we need to increment that value.  If 
the user hit the 'previous' button, we decrement the value.

=head1 USAGE

=head2 new

  new(%options)

Constructor.  Takes the following options in the hash:

  # Database description options
  db_file           Path to database flat-file you want to search
  db_lock           Get a shared lock on the database file (default 1)
  db_seperator      The field seperator the flat file uses.  Defaults to '|' (no quotes). 
                    Be sure any special regex chars are escaped.
  db_fields         Referance to an array of arrays describing the fields in the flat-file.  
                    See DATABASE FIELDS.

  # Search options
  search_fields     Referance to a hash of arrays describing the fields you need to search on.  
                    See SEARCH FIELDS.

  # Paging options (not currently implemented)
  results_per_page  How many results to show on each page of output.  Default is 0 (infinte).
  max_results       Maximum number of results to search for.  Default is 0 (infinite).
  page_number       The current page number of output.  Default is 0 (first page).
  
  # These options are passed to HTML::Template.  See the documentation of that module 
  # for more details.
  # 
  template           Path to the template file 
  cache              Cache results (only helps under a persistent environment, like mod_perl) 
  file_cache         File caching (helps in any situation) 
  file_cache_dir     Place to store file caches (leave blank to use a default directory) 
  loop_context_vars  Use context vars in loops (default 0) 
  global_vars        Allow global variables inside a loop (default 0) 
  strict             Strict matching of template tags (default 1)


=head2 result

  result [ $or_search, \%search_fields ]

Searches the database and returns the result.  In scalar context, it returns an 
HTML::Template object that has been filled out with the data searched for.  In 
array context, it returns the actual data in an array of hashes (which can be 
used as a param in a HTML::Template object). 

$or_search is used to decide if all fields need to match (AND search) or if 
only one of the fields needs to match (OR search).  If set to a true value, it 
does an OR search.  Otherwise, it does AND.

Optionally, you can pass a referance to a hash containing new search fields that 
override the terms passed to new().

=head2 get_prev_page

  get_prev_page

Returns the page number of the previous page or undef if we're on the first page.

=head2 get_next_page

  get_next_page

Returns the page number of the next page.  Note that CGI::Search doesn't know if there 
will be any results on the "next" page, so this will happily return a value for page 
249 if a user clicks that much, even if the results stoped at page 7.

=head2 errstr 

  errstr 

Returns the last error in a string. 



=head1 SUPPORT

Please send bug reports (preferably with a patch attached) to tmurray@agronomy.org.

=head1 BUGS

Yes.

=head1 TODO

Add pagination support.

Reimplement INTEGER() using Regexp::Common::number (other validators, too?).

Using an SQL-like syntax to do searching instead of a hash of options (???)


=head1 AUTHOR

	Timm Murray
	CPAN ID: TMURRAY
	tmurray@agronomy.org
	http://www.agronomy.org

=head1 COPYRIGHT

Copyright 2003, American Society of Agronomy. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of either:

a) the GNU General Public License as published by the Free Software
   Foundation; either version 2, or (at your option) any later
   version, or

b) the "Artistic License" which comes with Perl.


=head1 SEE ALSO

perl(1).  HTML::Template. CGI.

=cut




#
# Private methods
#

# Take in a database entry, terms to search on, a database description, and the line number 
# of the flat file being searched.
#
# $passed_search->(
#     \@input,      # A database entry, with one field in each array
#     \%search,     # Hash-of-arrays--contains fields to search on (db_fields)
#     \@db_fields,  # Array-of-arrays--contains the name of each field in the first element 
#                   #     and a referance to a validation subroutine in the second element
#     $or_search,   # Set to 1 to do an OR search instead of an AND search
# );
#
# Returns 1 if the line passed the search, 0 if it didn't, or -1 if there was an 
# error (check $self->{errstr}).
#
my $passed_search = sub 
{
	my $self       = shift;
	my $input      = shift;
	my $in_terms   = shift;
	my $db_fields  = shift;
	my $or_search  = shift;

	my %search    = $in_terms ? %{ $in_terms } : %{ $self->{search_fields} };
	my @input     = @{ $input };
	my @db_fields = @{ $db_fields };

	my $match     = 0;

	# Validation stuff should probably be moved into a seperate sub
	foreach my $i (0 .. $#input) {
		my $result;
		# Check if this field is required.  If it is required, but is null, 
		# create an error. Otherwise, skip validation if it's null. 
		# 
		if($db_fields[$i][2]) {
			if(! $input[$i]) {
				warn "1\n";
				$self->{errstr} = "Validation error: is null";
				return -1;
			}
			else {
				my $validator = $db_fields[$i][1];
				my $str;
				my $is_good;
				($is_good, $result, $str) = &$validator($input[$i]);
				unless($is_good) {
					warn "2: $result ($input[$i])\n";
					$self->{errstr} = "Validation error: $str";
					return -1;
				}
			}
		}
		# Not a required field, but if it's not null, search it
		elsif($input[$i]) {
			my $validator = $db_fields[$i][1];
			my $str;
			my $is_good;
			($is_good, $result, $str) = &$validator($input[$i]);
			unless($is_good) {
				warn "3 $result ($input[$i])\n";
				$self->{errstr} = "Validation error: $str";
				return -1;
			}
		}

		# The actual searching
		my $search_for = @{ $search{$db_fields[$i][0]} }[0];
		next unless $search_for;
		$match = ($result =~ /$search_for/i) ? 1 : 0;

		if($or_search) {   last if     $match   }
		else           {   last unless $match   }
	}

	return $match;
};

#  $on_current_page->($entry_num);
#  
# Decide if the given entry number is before, on, or after the current page.  
# Return values are:
#
# -1   Before current page
# 0    On current page
# 1    After current page
# 
my $on_current_page = sub 
{
	my $self      = shift;
	my $entry_num = shift || 0;

	my $results_per_page = $self->{results_per_page};
	my $start            = $self->{start};
	my $stop             = $self->{stop};

	# if $results_per_page is 0, then show all results
	return 0  if $results_per_page == 0;

	return -1 if $entry_num < $start;
	return 0  if( ($entry_num >= $start) && ($entry_num <= $stop) );
	return 1;
};

# Searches the database and returns an array containing the results of the search.
# 
# This is where the fun is
# 
my $search = sub 
{
	my $self              = shift;
	my $or_search         = shift;
	my $in_terms          = shift;
	my $file              = $self->{db_file};
	my $lock              = $self->{db_lock};
	my $seperator         = $self->{db_seperator};
	my @fields            = @{ $self->{db_fields} };

	my %search_fields = $in_terms ? %{ $in_terms } : %{ $self->{search_fields} };
	my @results;

	open(IN, '<', $file) or (($self->{errstr} = $!) && return);
	if($lock) {
		use Fcntl qw(:DEFAULT :flock);
		flock(IN, LOCK_SH) or (($self->{errstr} = $!) && return);
	}

	my $entry_num = 0;
	while(my $line = <IN>) {
		chomp $line;
		my @input = split /$seperator/, $line, scalar(@fields);

		my $passed = $self->$passed_search(\@input, 
			\%search_fields, $self->{db_fields}, $or_search);
		
		if($passed > 0) {
			# Paging stuff
			my $on_page = $self->$on_current_page($entry_num++);
			last if $on_page > 0;
			next if $on_page < 0;

			my %data;
			foreach my $i (0 .. $#input) {
				$data{$fields[$i][0]} = $input[$i];
			}

			push @results, \%data;
		}
		elsif($passed < 0) {
			push @results, { error => 'Error in database' };
			warn "Error in database (" . $self->{db_file} . "), line $.:" . 
				$self->{errstr} . "\n";
		}
	}
	
	close(IN);

	return @results;
};

# Searches the data and returns an HTML::Template object filled in with the 
# data.
#
my $result_template = sub 
{
	my $self = shift;
	my $or_search = shift;
	my $in_terms = shift;

	my %terms = %{ $in_terms };

	use HTML::Template;
	my $tmpl = HTML::Template->new(
		filename           => $self->{template}, 
		die_on_bad_params  => 0,   # Database might contain fields the template doesn't 
		cache              => $self->{cache}, 
		file_cache         => $self->{file_cache}, 
		file_cache_dir     => $self->{file_cache_dir}, 
		loop_context_vars  => $self->{loop_context_vars}, 
		global_vars        => $self->{global_vars}, 
		strict             => $self->{strict}, 
	);

	my @results = $self->$search($or_search, \%terms);
	if(@results) {
		$tmpl->param('results' => \@results);
	

		my @search_fields;
		foreach my $i (keys %terms) {
			my %field = (
				name  => $i, 
				value => $terms{$i}[0], 
			);
			push @search_fields, \%field;
		}

		$tmpl->param(search_fields    => \@search_fields);
		$tmpl->param(results_per_page => $self->{results_per_page});
		$tmpl->param(cur_page         => $self->{page_number});
		$tmpl->param(script_name      => $self->{script_name});
		$tmpl->param('prev'      => $self->{'prev'});
		$tmpl->param('next'      => $self->{'next'});

	}
	else {
		$tmpl->param('error' => $self->{errstr});
	}
	
	return $tmpl;
};



# 
# Default validation subroutines
#

# Several regexen in the validation routines use qr// to precompile their regex.  
# Even though we're not doing any variable interpolation, trivial benchmarks show 
# this to be almost 30% faster than either inline or use /o (which isn't generally 
# recommended anyway).  (Benchmarks were run on Cygwin w/perl 5.6.1.  People on 
# other platforms report no speed gains.)
# 
# These validation subs could potentially be run many, many times, so speed 
# is important.  INTEGER, WORD, and BLOB will probably be used the most. 
# 
my $integer = qr/\A(\d+)\z/;
my $word    = qr/\A(\w+)\z/;
my $blob    = qr/\A([\w\s[:punct:]]+)\z/;

sub INTEGER 
{ 
	my $chk = $_[0];
	if($chk =~ /$integer/) {
		return (1, $1, "Passed");
	}
	else {
		return (0, undef, "'$chk' is not a valid integer");
	}
}

sub WORD 
{ 
	my $chk = $_[0];
	if($chk =~ /$word/) {
		return (1, $1, "Passed");
	}
	else {
		return (0, undef, "'$chk' is not a valid word");
	}
}

sub BLOB 
{ 
	my $chk = $_[0];
	if($chk =~ /$blob/) {
		return (1, $1, "Passed");
	}
	else {
		return (0, undef, "'$chk' is not a valid blob");
	}
}

sub EMAIL 
{ 
	my $chk = $_[0];
	
	use Email::Valid;
	if(Email::Valid->address($chk)) {
		# We already know its format is valid, so untaint it.
		# 
		# Can't use qr// or /o, since a variable is being interpolated.
		# 
		# Using /($chk)/ is faster than /(.*)/ (by about 20%).  
		# Using anchors (like in /\A($chk)\z/) is slower, though 
		# /\A(.*)\z/ is slightly faster than plain /(.*)/ (by about 4%).  
		# Putting /o on the .* regexen did not give a noticable improvement.
		#
		$chk =~ /($chk)/;
		return (1, $1, "Passed");
	}
	else {
		return (0, undef, "'$chk' is not a valid e-mail address");
	}
}

sub NONE { return (1, $_[0], "Passed") };

sub test_custom_validator 
{
	my $self             = shift;
	my $custom_validator = $self->{test_validator};
	my $data             = shift;

	return $custom_validator->($data);
}



# 
# Public methods
#


sub new
{
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self;
	{ my %hash; $self = bless(\%hash, $class); }

	# Get params passed to new()
	my %input;
	for(my $i = 0; $i < $#_; $i += 2) {
		defined($_[($i + 1)]) or die "CGI::Search called with an odd number of arguments - should be of the form name => value";
		$input{$_[$i]} = $_[($i + 1)];
	}
	
	$self->{db_file}          = $input{db_file}           || 
		die "Need a database file to search"; 
	$self->{db_lock}          = defined($input{db_lock})      ? $input{db_lock}      : 1; 
	$self->{db_seperator}     = defined($input{db_seperator}) ? $input{db_seperator} : '\|'; 
	$self->{db_fields}        = $input{db_fields}         || undef; 
	$self->{search_fields}    = $input{search_fields}     || undef; 

	$self->{results_per_page} = $input{results_per_page}  || 0;
	$self->{max_results}      = $input{max_results}       || 0;
	$self->{page_number}      = $input{page_number}       || 0;

	# HTML::Template options
	$self->{template}           = $input{template}           || 
		die "Need a template file"; 
	$self->{cache}              = $input{cache}              || 0; 
	$self->{file_cache}         = defined($input{file_cache}) ? $input{file_cache} : 1; 
	$self->{file_cache_dir}     = $input{file_cache_dir}; 
	$self->{loop_context_vars}  = $input{loop_context_vars}  || 0; 
	$self->{global_vars}        = $input{global_vars}        || 0; 
	$self->{strict}             = defined($input{strict})     ? $input{strict}     : 1; 

	# For testing -- don't use in a real program
	$self->{test_validator}     = $input{test_validator};

	if($self->{file_cache}) {
		defined($self->{file_cache_dir}) or 
			die "Using a file cache, but no file_cache_dir option specified\n";
	}
	else { $self->{file_cache_dir} = '/' }
	
	die("Failed to validate page_number") 
		unless (INTEGER($self->{page_number}))[0];
	die("Failed to validate results_per_page") 
		unless (INTEGER($self->{results_per_page}))[0];
	die("Failed to validate max_results") 
		unless (INTEGER($self->{max_results}))[0];

	my $start = $self->{results_per_page} * $self->{page_number};
	my $stop  = $self->{results_per_page} ? ($start + $self->{results_per_page} - 1) : 0;

	$self->{start} = $start;
	$self->{stop}  = $stop;

	if($self->{results_per_page}) {
		my $prev = $self->{page_number} - 1;
		my $next = $self->{page_number} + 1;

		$self->{'prev'} = 1 if($prev >= 0);
		$self->{'next'} = 1 if($next);
	}

	$self->{errstr} = '';

	return $self;
}

sub result 
{
	my $self      = shift;
	my $or_search = shift;
	my $in_terms  = shift;
	my %terms  = $in_terms ? %{ $in_terms } : %{ $self->{search_fields} };

	# Validate the search terms
	#
	foreach my $i (keys %terms) {
		my ($param, $validator) = @{ $terms{$i} };
		unless( ($validator->($param))[0] ) {
			$self->{errstr} = "Param $param is invalid";
			return wantarray ? () : undef;
		}
	}

	return (wantarray ? 
		$self->$search($or_search, \%terms) : 
		$self->$result_template($or_search, \%terms));
}

sub get_prev_page 
{
	return $_[0]->{prev};
}

sub get_next_page 
{
	return $_[0]->{'next'};
}

sub errstr 
{
	my $self = shift;
	return $self->{errstr};
}



1;

__END__


