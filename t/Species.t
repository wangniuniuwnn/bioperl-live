# -*-Perl-*- Test Harness script for Bioperl
# $Id$

use strict;

BEGIN {
	use lib 't/lib';
    use BioperlTest;
    
    test_begin(-tests => 20);
	
	use_ok('Bio::Species');
	use_ok('Bio::DB::Taxonomy');
}

ok my $sps = Bio::Species->new();
$sps->classification(qw( sapiens Homo Hominidae
			 Catarrhini Primates Eutheria Mammalia Vertebrata
			 Chordata Metazoa Eukaryota));

is $sps->binomial, 'Homo sapiens';

ok $sps->sub_species('sapiensis');
is $sps->binomial, 'Homo sapiens';
is $sps->binomial('FULL'), 'Homo sapiens sapiensis';
is $sps->sub_species, 'sapiensis';

$sps->classification(qw( sapiens Homo Hominidae
			 Catarrhini Primates Eutheria Mammalia Vertebrata
			 Chordata Metazoa Eukaryota));
is $sps->binomial, 'Homo sapiens';


# test cmd line initializtion
ok my $species = Bio::Species->new( -classification => 
				[ qw( sapiens Homo Hominidae
				      Catarrhini Primates Eutheria 
				      Mammalia Vertebrata
				      Chordata Metazoa Eukaryota) ] );
is $species->binomial, 'Homo sapiens';
is $species->species, 'sapiens';
is $species->genus, 'Homo';


# A Bio::Species isa Bio::Taxon, so test some things from there briefly
is $species->scientific_name, 'sapiens';
is $species->rank, 'species';

# We can make a species object from just an id an db handle
SKIP: {
    test_skip(-tests => 5, -requires_networking => 1);
	
    $species = Bio::Species->new(-id => 51351);
    my $taxdb = Bio::DB::Taxonomy->new(-source => 'entrez');
    eval {$species->db_handle($taxdb);};
    skip "Unable to connect to entrez database; no network or server busy?", 5 if $@;
    is $species->binomial, 'Brassica rapa subsp.';
    is $species->binomial('FULL'), 'Brassica rapa subsp. pekinensis';
    is $species->genus, 'Brassica';
    is $species->species, 'rapa subsp.';
    is $species->sub_species, 'pekinensis';
}
