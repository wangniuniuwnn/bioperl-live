# -*-Perl-*-
## Bioperl Test Harness Script for Modules
##

use Test;
use strict;
use vars qw($tests);
BEGIN { 
    eval { local * STDERR; require Bio::Ext::Align };
    if ( $@ ) {
	plan test => 1;
	skip(1, 1, 1,'Bio::Ext::Align not loaded');
	print STDERR "\tBio::Ext::Align not loaded\n";
	exit(0);
    }
    plan tests => 3;
}
use Bio::SearchDist;
ok(1);

my $dist = new Bio::SearchDist;

ok ref($dist), 'Bio::SearchDist';
my @scores =  qw( 100 200 120 121 78 165 215 6 18);
foreach my $score ( @scores ) {
    $dist->add_score($score);
}
    
ok $dis->fit_evd(), 1;

foreach $score ( @scores ) {
    my $evalue = $dist->evalue($score);
#    print SDTERR "Score $score had an evalue of $evalue\n";
}
