package Cater::DBSchema;

use base 'DBIx::Class::Schema';

use strict;
use warnings;

use Const::Fast;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema


=head1 DESCRIPTION AND USAGE

Database schema for the Cater app, using DBIx::Class.

=cut

const my $DB_NAME => 'dbi:mysql:catering';
const my $DB_USER => 'caterit';
const my $DB_PASS => 'CoMeCaTeR4Me';

__PACKAGE__->load_namespaces();

=head1 METHODS


=head2 get_schema_connection()

Returns a DBIx::Class::Schema object for the Catering DB.

=over 4

=item Input: None

=item Output: DBIx::Class::Schema object.

=back

    my $schema = Cater::DBSchema->get_schema_connection();

=cut

sub get_schema_connection
{
    my ( $self ) = @_;

    return __PACKAGE__->connect(
                                $DB_NAME,
                                $DB_USER,
                                $DB_PASS,
                                {
                                    PrintError => 0,
                                    RaiseError => 1,
                                    ChopBlanks => 1,
                                    ShowErrorStatement => 1,
                                    AutoCommit => 1,
                                },
                            );
}

1;
