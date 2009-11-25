#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2009 -- leonerd@leonerd.org.uk

package Term::Terminfo;

use strict;
use warnings;

our $VERSION = '0.04';

use Carp;

use base qw( DynaLoader );

__PACKAGE__->DynaLoader::bootstrap( $VERSION );

=head1 NAME

C<Term::Terminfo> - access the F<terminfo> database

=head1 SYNOPSIS

 use Term::Terminfo;

 my $ti = Term::Terminfo->new;

 printf "This terminal %s do overstrike\n",
    $ti->getflag('os') ? "can" : "cannot";

 printf "Tabs on this terminal are initially every %d columns\n",
    $ti->getnum('it');

=head1 DESCRIPTION

Objects in this class provide access to F<terminfo> database entires.

=cut

=head1 CONSTRUCTOR

=cut

=head2 $ti = Term::Terminfo->new( $termtype )

Constructs a new C<Term::Terminfo> object representing the given termtype. If
C<$termtype> is not defined, C<$ENV{TERM}> will be used instead. If that
variable is empty, C<vt100> will be used.

=cut

sub new
{
   my $class = shift;
   my ( $termtype ) = @_;

   # If we've really no idea, call it a VT100
   $termtype ||= $ENV{TERM} || "vt100";

   return bless {
      term => $termtype,
   }, $class;
}

=head1 METHODS

=cut

=head2 $bool = $ti->getflag( $capname )

Returns the value of the named boolean capability.

=cut

sub getflag
{
   my $self = shift;
   my ( $capname ) = @_;

   $self->_init unless $self->{flags};
   return $self->{flags}{$capname};
}

=head2 $num = $ti->getnum( $capname )

Returns the value of the named numeric capability.

=cut

sub getnum
{
   my $self = shift;
   my ( $capname ) = @_;

   $self->_init unless $self->{nums};
   return $self->{nums}{$capname};
}

=head2 $str = $ti->getstr( $capname )

Returns the value of the named string capability.

=cut

sub getstr
{
   my $self = shift;
   my ( $capname ) = @_;

   $self->_init unless $self->{strs};
   return $self->{strs}{$capname};
}

# Keep perl happy; keep Britain tidy
1;

__END__

=head1 TODO

This distribution provides a small accessor interface onto F<terminfo>. It was
originally created simply so I can get at the C<bce> capability flag of the
current terminal, because F<screen> unlike every other terminal ever, doesn't
do this. Grrr.

It probably also wants more accessors for things like C<tparm> and C<tputs>.
I may at some point consider them.

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>
