#!/usr/bin/perl
# Test the paging function of CGI::Search
#

#  on_current_page($entry_num);
#  
# Decide if the given entry number is before, on, or after the current page.  
# Return values are:
#
# -1   Before current page
# 0    On current page
# 1    After current page
# 
sub on_current_page 
{
	my $entry_num        = shift || 0;
	my $results_per_page = shift || 0;
	my $start            = shift || 0;
	my $stop             = shift || 0;

	# if $results_per_page is 0, then show all results
	return 0  if $results_per_page == 0;

	print "[-$start-$stop-$entry_num-]";
	return -1 if $entry_num < $start;
	return 0  if( ($entry_num >= $start) && ($entry_num <= $stop) );
	return 1;
}


my @data;
$data [$_] = $_ foreach (0 .. 10000);


my $results_per_page = 20;
my $page_number      = 0;

for(my $i = 0; $i <= $#data; $i++) {
	my $start = $results_per_page * $page_number;
	my $stop  = $results_per_page ? ($start + $results_per_page - 1) : 0;
	my $on_cur = on_current_page($i, $results_per_page, $start, $stop);

	if($on_cur == 0) {
		print "$i: $data[$i]\n";
	}
	elsif($on_cur == 1) {
		print "-- Hit [enter] to view next page -- \n";
		<>;
		$page_number++;
		$i--;
	}
}

