use ExtUtils::MakeMaker qw(WriteMakefile);


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
				Compress::Zlib   => 0, 
				IO::Zlib         => 0, 
    			}, 
);
