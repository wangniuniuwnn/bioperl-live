# -*-Perl-*- Test Harness script for Bioperl
# $Id$

use strict;

BEGIN {
    use lib 't/lib';
    use BioperlTest;
    
    test_begin(-tests => 35);
	
	use_ok('Bio::SeqIO');
	use_ok('Bio::Seq::SequenceTrace');
}

my $verbose = test_debug();

ok my $in_scf = Bio::SeqIO->new(-file => test_input_file('chad100.scf'),
								-format => 'scf',
								-verbose => $verbose);

my $swq = $in_scf->next_seq();

isa_ok($swq,"Bio::Seq::SequenceTrace");

cmp_ok (length($swq->seq()), '>', 10);
my $qualities = join(' ',@{$swq->qual()});

cmp_ok (length($qualities), '>', 10);
my $id = $swq->id();
is ($swq->id(), "ML4942R");

my $a_channel = $swq->trace("a");
cmp_ok (scalar(@$a_channel), '>', 10);
my $c_channel = $swq->trace("c");
cmp_ok (scalar(@$c_channel), '>', 10);
my $g_channel = $swq->trace("g");
cmp_ok (scalar(@$g_channel), '>', 10);
my $t_channel = $swq->trace("t");
cmp_ok (scalar(@$t_channel), '>', 10);

my $ref = $swq->peak_indices();
my @indices = @$ref;
is (scalar(@indices), 761);

warn("Now checking version3...\n") if $verbose;
my $in_scf_v3 = Bio::SeqIO->new(-file => test_input_file('version3.scf'),
										  -format => 'scf',
										  -verbose => $verbose);

my $v3 = $in_scf_v3->next_seq();
isa_ok($v3, 'Bio::Seq::SequenceTrace');
my $ind = $v3->peak_indices();
my @ff = @$ind;

@indices = @{$v3->peak_indices()};
is (scalar(@indices), 1106);

my %header = %{$in_scf_v3->get_header()};
is $header{bases}, 1106;
is $header{samples},  14107;

# is the Bio::Seq::SequenceTrace AnnotatableI?
my $ac = $v3->annotation();

isa_ok($ac,"Bio::Annotation::Collection");

my @name_comments = grep {$_->tagname() eq 'NAME'} 
  $ac->get_Annotations('comment');

is $name_comments[0]->as_text(), 'Comment: IIABP1D4373';

# also get comments this way...
$ac = $in_scf_v3->get_comments();

isa_ok($ac,"Bio::Annotation::Collection");

@name_comments = grep {$_->tagname() eq 'NAME'} 
  $ac->get_Annotations('comment');

is $name_comments[0]->as_text(), 'Comment: IIABP1D4373';

my @conv_comments = grep {$_->tagname() eq 'CONV'} 
  $ac->get_Annotations('comment');

is $conv_comments[0]->as_text(), 'Comment: phred version=0.990722.h';

# is the SequenceTrace object annotated?
my $st_ac = $swq->annotation();

isa_ok ($st_ac, "Bio::Annotation::Collection");

my @ann =   $st_ac->get_Annotations();

is $ann[0]->tagname, 'SIGN';
is $ann[2]->text, 'SRC3700';
is $ann[5]->tagname, 'LANE';
is $ann[5]->text, 89;
is $ann[6]->text, 'phred version=0.980904.e';
is $ann[8]->text, 'ABI 373A or 377';

my $outfile = test_output_file();
my $out_scf = Bio::SeqIO->new(-file => ">$outfile",
										-format => 'scf',
										-verbose => $verbose);

# Bug 2196 - commentless scf

my $in = Bio::SeqIO->new(-file => test_input_file('13-pilE-F.scf'),
							  -format => 'scf',
							  -verbose => $verbose);

my $seq = $in->next_seq;

ok ($seq);

isa_ok($seq, 'Bio::Seq::SequenceTrace');

$ac = $seq->annotation;

isa_ok($ac, 'Bio::Annotation::Collection');

@name_comments = grep {$_->tagname() eq 'NAME'} 
  $ac->get_Annotations('comment');

is $name_comments[0], undef;

@conv_comments = grep {$_->tagname() eq 'CONV'} 
  $ac->get_Annotations('comment');

is $conv_comments[0], undef;

# the new way

warn("Now testing the _writing_ of scfs\n") if $verbose;

$out_scf->write_seq(-target	=>	$v3,
						  -MACH		=>	'CSM sequence-o-matic 5000',
						  -TPSW		=>	'trace processing software',
						  -BCSW		=>	'basecalling software',
						  -DATF		=>	'AM_Version=2.00',
						  -DATN		=>	'a22c.alf',
						  -CONV		=>	'Bioperl-scf.pm');

ok( -s $outfile && ! -z "$outfile" );

# TODO? tests below don't do much

$out_scf = Bio::SeqIO->new(-verbose => 1,
							-file => ">$outfile",
							-format => 'scf');

$swq = Bio::Seq::Quality->new(-seq =>'ATCGATCGAA',
										-qual =>"10 20 30 40 50 20 10 30 40 50",
										-alphabet =>'dna');

my $trace = Bio::Seq::SequenceTrace->new(-swq => $swq);

$out_scf->write_seq(	-target	=>	$trace,
							-MACH		=>	'CSM sequence-o-matic 5000',
							-TPSW		=>	'trace processing software',
							-BCSW		=>	'basecalling software',
							-DATF		=>	'AM_Version=2.00',
							-DATN		=>	'a22c.alf',
							-CONV		=>	'Bioperl-scf.pm' );

warn("Trying to write an scf with a subset of a real scf...\n") if $verbose;
$out_scf = Bio::SeqIO->new(-verbose => 1,
									-file => ">$outfile",
									-format => 'scf');

$in_scf_v3 = Bio::SeqIO->new(-file => test_input_file('version3.scf'),
									  -format => 'scf',
									  -verbose => $verbose);
$v3 = $in_scf_v3->next_seq();

my $sub_v3 = $v3->sub_trace_object(5,50);

#warn("The subtrace object is this:\n") if $DEBUG;

$out_scf->write_seq(-target => $sub_v3 );

my $in_scf_v2 = Bio::SeqIO->new(-file => test_input_file('version2.scf'),
										  -format => 'scf',
										  -verbose => $verbose);
$v3 = $in_scf_v2->next_seq();
ok($v3);

$out_scf = Bio::SeqIO->new(-file   => ">$outfile",
                           -format => "scf");
$out_scf->write_seq( -target  => $v3,
                     -version => 2 );

# now some version 2 things...
