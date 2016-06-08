package Cater::Caterer;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;
use Data::Dumper;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.3" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();


=head1 NAME

Cater::Caterer


=head1 DESCRIPTION AND SYNOPSIS

Module provides a library of caterer-related functionality for use throughout the whole site.


=head1 METHODS


=head2 get_all_cuisine_types()

Returns an arrayref of all known cuisine types in the database.

=over 4

=item Input: None

=item Output: An arrayref containing [ C<name>, C<sort_by> ]

=back

    my $cuisines = Cater::Caterer->get_all_cuisine_types();

=cut

sub get_all_cuisine_types
{
    my ( $self ) = @_;

    my @cuisines = $SCHEMA->resultset('CuisineType')->search(
        undef,
        {
            order_by => { -asc => 'sort_by' },
        },
    );

    return \@cuisines;
}


=head2 get_random_caterers()

Returns an array of Clients, either matched to a zip, or chosen at random if a zip is unavailable or undetectable.

=over 4

=item Input: A hash containing [ C<zipcodes>, C<max_caterers> ], where C<zipcodes> is an arrayref of zipcodes (default undef), and C<max_caterers> is the max caterers returned (default 3).

=item Output: An array containing Client objects.

=back

    my @caterers = Cater::Caterer->get_random_caterers( zip => $zip, max_caterers => $max_caterers );

=cut

sub get_random_caterers
{
    my ( $self, %params ) = @_;

    my $zipcodes     = delete $params{'zipcodes'}     // undef;
    my $max_caterers = delete $params{'max_caterers'} // 3;

    my %where = ();
    if ( defined $zipcodes )
    {
        $where{zip}{'-in'} = $zipcodes;
    }

    my @caterers = $SCHEMA->resultset('Client')->search(
        \%where,
        {
            order_by => \"RAND()",
            rows     => $max_caterers,
        },
    );

    return @caterers;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
