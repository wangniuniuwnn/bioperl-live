# $Id$
#
# BioPerl module for Bio::DB::EntrezGene
#
# Cared for by Brian Osborne osborne1 at optonline.net
#
# Copyright Brian Osborne
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::DB::EntrezGene - Database object interface to Entrez Gene

=head1 SYNOPSIS

    use Bio::DB::EntrezGene;

    $db = Bio::DB::EntrezGene->new;

    $seq = $db->get_Seq_by_id(2); # Gene id

    # or ...

    my $seqio = $db->get_Stream_by_id([2, 4693, 3064]);
    while( my $seq = $seqio->next_seq ) {
	    print "seq is is ", $seq->display_id, "\n";
    }

=head1 DESCRIPTION

Allows the dynamic retrieval of Sequence objects from the 
Entrez Gene database at NCBI, via an Entrez query using Gene ids.

WARNING: Please do NOT spam the Entrez web server with multiple requests.
NCBI offers Batch Entrez for this purpose.

=head1 NOTES

The Entrez eutils API does not allow queries by name and taxon id as
of this writing, therefore there are get_Seq_by_id and get_Stream_by_id
methods which expect Gene ids. There are no get_Seq_by_acc or 
get_Stream_by_acc methods.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the
evolution of this and other Bioperl modules. Send
your comments and suggestions preferably to one
of the Bioperl mailing lists. Your participation
is much appreciated.

  bioperl-l@bioperl.org             - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  http://bugzilla.bioperl.org/

=head1 AUTHOR - Brian Osborne

Email osborne1@optonline.net

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::DB::EntrezGene;
use strict;
use vars qw(@ISA $DEFAULTFORMAT $DEFAULTMODE %PARAMSTRING );
use Bio::DB::NCBIHelper;

@ISA = qw(Bio::DB::NCBIHelper);
BEGIN { 
    $DEFAULTMODE   = 'single';
    $DEFAULTFORMAT = 'asn.1';	    
    %PARAMSTRING = ('batch'  => {'db'     => 'gene',
											 'usehistory' => 'y',
											 'tool'   => 'bioperl',
											 'retmode' => 'asn.1'},
						   'gi'     => {'db'     => 'gene',
											 'usehistory' => 'y',
											 'tool'   => 'bioperl',
											 'retmode' => 'asn.1'},
						  'version' => {'db'     => 'gene',
											 'usehistory' => 'y',
											 'tool'   => 'bioperl',
											 'retmode' => 'asn.1'},
						  'single'  => {'db'     => 'gene',
											 'usehistory' => 'y',
											 'tool'   => 'bioperl',
											 'retmode' => 'asn.1'} );
}

# the new way to make modules a little more lightweight
sub new {
  my($class, @args) = @_;
  my $self = $class->SUPER::new(@args);
  # Seems that Bio::SeqIO::entrezgene requires this:
  $self->{_retrieval_type} = "tempfile"; 
  $self->request_format($self->default_format);
  return $self;
}

=head2 get_params

 Title   : get_params
 Usage   : my %params = $self->get_params($mode)
 Function: Returns key,value pairs to be passed to NCBI database
           for either 'batch' or 'single' sequence retrieval method
 Returns : A key,value pair hash
 Args    : 'single' or 'batch' mode for retrieval

=cut

sub get_params {
    my ($self, $mode) = @_;
    return defined $PARAMSTRING{$mode} ? %{$PARAMSTRING{$mode}} : 
		%{$PARAMSTRING{$DEFAULTMODE}};
}

=head2 default_format

 Title   : default_format
 Usage   : my $format = $self->default_format
 Function: Returns default sequence format for this module
 Returns : string
 Args    : none

=cut

sub default_format {
	return $DEFAULTFORMAT;
}

# from Bio::DB::WebDBSeqI from Bio::DB::RandomAccessI

=head1 Routines from Bio::DB::WebDBSeqI and Bio::DB::RandomAccessI

=head2 get_Seq_by_id

 Title   : get_Seq_by_id
 Usage   : $seq = $db->get_Seq_by_id(2)
 Function: Gets a Bio::Seq object by its name
 Returns : A Bio::Seq object
 Args    : Gene id
 Throws  : "id does not exist" exception

=head1 Routines implemented by Bio::DB::NCBIHelper

=head2 get_request

 Title   : get_request
 Usage   : my $url = $self->get_request
 Function: HTTP::Request
 Returns : 
 Args    : %qualifiers = a hash of qualifiers (ids, format, etc)

=head2 get_Stream_by_id

  Title   : get_Stream_by_id
  Usage   : $stream = $db->get_Stream_by_id( [$gid1, $gid2] );
  Function: Gets a series of Seq objects using Gene ids
  Returns : A Bio::SeqIO stream object
  Args    : $ref : a reference to an array of Gene ids

=head2 request_format

 Title   : request_format
 Usage   : my $format = $self->request_format;
           $self->request_format($format);
 Function: Get/Set sequence format retrieval
 Returns : String representing format
 Args    : $format = sequence format

=cut

# override to force format
sub request_format {
    my ($self) = @_;
    return $self->SUPER::request_format($self->default_format());
}

1;

__END__
