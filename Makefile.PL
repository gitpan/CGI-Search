use ExtUtils::MakeMaker qw(WriteMakefile prompt);

my $CONFIG = 'lib/CGI/Search/Config.pm';

unless(-e $CONFIG) {
	# Get system-specific configuration information
	print<<END;
A cache directory is used to cache the HTML::Template files for later use.  
Using a cache dir can help improve performance.  For convieance, CGI::Search 
can use a default cache dir.  This can be overridden by passing the 'file_cache_dir' 
option to CGI::Search->new() in your programs.

The default cache directory must be readable by all programs that use the default 
cache dir in CGI::Search.
END
	my $default_cache_dir = 
		prompt('Please enter the default cache directory for your system >');
	

	open(CONFIG, '>', $CONFIG) or die "Can't open $CONFIG: $!\n";
	print CONFIG <<END;

# This package is not to be used by external programs.  It is meant only for configuring 
# CGI::Search.
#

package CGI::Search::Config;
use strict;

BEGIN {
	use Exporter ();
	use vars qw (\$VERSION \@ISA \@EXPORT \@EXPORT_OK \%EXPORT_TAGS);
	\$VERSION     = 0.1;
	\@ISA         = qw (Exporter);
	\@EXPORT      = qw ( \$DEFAULT_CACHE_DIR );
	\@EXPORT_OK   = qw ();
	\%EXPORT_TAGS = ();
}

my \$DEFAULT_CACHE_DIR = '$default_cache_dir';

1;

END
	close(CONFIG);
}


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'CGI::Search',
    VERSION_FROM => 'lib/CGI/Search.pm', # finds $VERSION
    AUTHOR       => 'Timm Murray (tmurray@agronomy.org)',
    ABSTRACT     => 'CGI::Search - Simple way of using a CGI to search flat-text databases', 

    PREREQ_PM    => 	{
	    			HTML::Template   => 0, 
				Email::Valid     => 0, 
    			}, 
);
