package Cater::ZipCode;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use LWP::UserAgent;
use Data::Dumper;
use Const::Fast;
use JSON qw//; # use the qw// to prevent namespace collisions with Dancer2
use FindBin;
use CHI;

use version; our $VERSION = qv( "v0.1.0" );

const my $CACHED_FILE_DIR  => "$FindBin::Bin/../cached_files/";
const my $CACHE_EXPIRES_IN => '3 days';

=head1 NAME

Cater::ZipCode


=head1 DESCRIPTION AND SYNOPSIS

Module provides a number of helper methods for deriving zip-code based data.


=head1 METHODS


=head2 get_zipcodes_by_radius()

Creates an API call to ZipCodeAPI.com to retrieve JSON data. Sends a request that looks similar to:
    https://www.zipcodeapi.com/rest/<api_key>/radius.<format>/<zip_code>/<distance>/<units>
and retrieves JSON data of zipcodes within a certain radius.

=over 4

=item Input: A hashref containing [ C<zipcode>, C<distance>, C<units>, C<zips_only> ]. C<units> are either 'mile' or 'km', and defaults to C<mile>. C<zipcode> is mandatory. C<distance> defaults to 50 units. C<zips_only> defaults to FALSE.

=item Output: An arrayref containing the deserialized JSON data.

=back

    my $zipcodes = Cater::ZipCode->get_zipcodes_by_radius(
                                                            zipcode   => $zipcode,
                                                            distance  => $distance,
                                                            units     => $units,
                                                            zips_only => 0,
                                                         );

=cut

sub get_zipcodes_by_radius
{
    my ( $self, %params ) = @_;

    my $zipcode   = delete $params{'zipcode'}   // undef;
    my $distance  = delete $params{'distance'}  // 50;
    my $units     = delete $params{'units'}     // 'mile';
    my $zips_only = delete $params{'zips_only'} // 0;

    if ( not defined $zipcode )
    {
        warning( "Missing zipcode when attempting to contact ZipCodeAPI." );
        return [];
    }

    my $cache = CHI->new(
                            driver     => 'BerkeleyDB',
                            root_dir   => $CACHED_FILE_DIR,
                            memoize_cache_objects => 1,
                        );

    my $cache_key = join( '_', $zipcode, $distance, $units );

    my $zipcode_array = $cache->get( $cache_key );

    if ( ! defined $zipcode_array )
    {
        debug( 'GETTING FROM ZIPCODEAPI: COULD NOT FIND KEY >' . $cache_key . '< IN CACHE.' );
        my $api_key = config->{ZipCodeAPI};
        my $url = "https://www.zipcodeapi.com/rest/$api_key/radius.json/$zipcode/$distance/$units";

        my $ua = LWP::UserAgent->new;
        $ua->timeout( 10 );

        my $response = $ua->get( $url );

        if ( $response->is_success )
        {
            $zipcode_array = JSON::decode_json $response->decoded_content;
        }
        else
        {
            warning( "Could not pull data from ZipCodeAPI: " . $response->status_line );
            return [];
        }

        $cache->set( $cache_key, $zipcode_array, $CACHE_EXPIRES_IN );
    }

    my @zips;
    if ( $zips_only == 1 )
    {
        @zips = map { $_->{'zip_code'} } @{ $zipcode_array->{'zip_codes'} };
    }
    else
    {
        @zips = @{ $zipcode_array->{'zip_codes'} };
    }

    return \@zips;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
