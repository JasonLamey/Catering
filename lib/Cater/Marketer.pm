package Cater::Marketer;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;
use Data::Dumper;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.0" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();


=head1 NAME

Cater::Marketer


=head1 DESCRIPTION AND SYNOPSIS

Module provides a library of marketer-related functionality for use throughout the whole site.


=head1 METHODS


=head2 get_random_marketer_ads()

Returns an array of up to n number of marketer advertisements from the database.

=over 4

=item Input: A hash containing [ C<zip>, C<max_ads> ], where both values are optional. C<zip> defaults to undef. C<max_ads> defaults to 3.

=item Output: An array containing the advertisement objects requested.

=back

    my $ads = Cater::Marketer->get_random_marketer_ads( zip => $zip, max_ads => $max_num );

=cut

sub get_random_marketer_ads
{
    my ( $self, %params ) = @_;
    my $zip     = delete $params{'zip'}     // undef;
    my $max_ads = delete $params{'max_ads'} // 3;

    #TODO: Build code to handle zip code-based searching.

    my @ads = $SCHEMA->resultset('MarketerAdvert')->search(
        undef,
        {
            order_by => \"RAND()",
            rows     => $max_ads,
        },
    );

    return @ads;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
