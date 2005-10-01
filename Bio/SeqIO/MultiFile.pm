# $Id$
#
# BioPerl module for Bio::SeqIO::MultiFile
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::MultiFile - Treating a set of files as a single input stream

=head1 SYNOPSIS

   $seqin = Bio::SeqIO::MultiFile( '-format' => 'Fasta',
                                   '-files'  => ['file1','file2'] );
   while((my $seq = $seqin->next_seq)) {
       # do something with $seq
   }

=head1 DESCRIPTION

Bio::SeqIO::MultiFile provides a simple way of bundling a whole
set of identically formatted sequence input files as a single stream.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bioperl.org                 - General discussion
  http://www.bioperl.org/MailList.shtml - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.
Bug reports can be submitted via the web:

  http://bugzilla.bioperl.org/

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqIO::MultiFile;
use strict;
use vars qw(@ISA);
use Bio::SeqIO;

@ISA = qw(Bio::SeqIO);


# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
  my($self,@args) = @_;

  $self->SUPER::_initialize(@args);

  my ($file_array,$format) = $self->_rearrange([qw(
					 FILES
					 FORMAT
					)],
				     @args,
				     );
  if( !defined $file_array || ! ref $file_array ) {
      $self->throw("Must have an array files for MultiFile");
  }

  if( !defined $format ) {
      $self->throw("Must have a format for MultiFile");
  }

  $self->{'_file_array'} = [];

  $self->_set_file(@$file_array);
  $self->_format($format);
  if( $self->_load_file() == 0 ) {
     $self->throw("Unable even to initialise the first file");
  }
}

=head2 next_seq

 Title   : next_seq
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub next_seq{
   my ($self,@args) = @_;

   my $seq = $self->_current_seqio->next_seq();
   if( !defined $seq ) {
       if( $self->_load_file() == 0) {
	   return undef;
       } else {
	   return $self->next_seq();
       }
   } else {
       return $seq;
   }
   
}

=head2 next_primary_seq

 Title   : next_primary_seq
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub next_primary_seq{
   my ($self,@args) = @_;

   my $seq = $self->_current_seqio->next_primary_seq();
   if( !defined $seq ) {
       if( $self->_load_file() == 0) {
	   return undef;
       } else {
	   return $self->next_primary_seq();
       }
   } else {
       return $seq;
   }

}

=head2 _load_file

 Title   : _load_file
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub _load_file{
   my ($self,@args) = @_;

   my $file = shift(@{$self->{'_file_array'}});
   if( !defined $file ) {
       return 0;
   }
   my $seqio = Bio::SeqIO->new( '-format' => $self->_format(), -file => $file);
   # should throw an exception - but if not...
   if( !defined $seqio) {
       $self->throw("no seqio built for $file!");
   }

   $self->_current_seqio($seqio);
   return 1;
}

=head2 _set_file

 Title   : _set_file
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub _set_file{
   my ($self,@files) = @_;

   push(@{$self->{'_file_array'}},@files);
   
}

=head2 _current_seqio

 Title   : _current_seqio
 Usage   : $obj->_current_seqio($newval)
 Function: 
 Example : 
 Returns : value of _current_seqio
 Args    : newvalue (optional)


=cut

sub _current_seqio{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_current_seqio'} = $value;
    }
    return $obj->{'_current_seqio'};

}

=head2 _format

 Title   : _format
 Usage   : $obj->_format($newval)
 Function: 
 Example : 
 Returns : value of _format
 Args    : newvalue (optional)


=cut

sub _format{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_format'} = $value;
    }
    return $obj->{'_format'};

}

1;
