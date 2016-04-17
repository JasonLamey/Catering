package Cater::DBSchema::Result::CatererLocation;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::CatererLocation


=head1 DESCRIPTION AND USAGE

Database object representing Caterer Locations within the web app.

=cut


__PACKAGE__->table( 'caterer_locations' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'caterer_location',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            client_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            name =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            phone =>
                                {
                                    data_type         => 'varchar',
                                    size              => 30,
                                    is_nullable       => 0,
                                },
                            street1 =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            street2 =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 1,
                                    default_value     => undef,
                                },
                            city =>
                                {
                                    data_type         => 'varchar',
                                    size              => 100,
                                    is_nullable       => 0,
                                },
                            state =>
                                {
                                    data_type         => 'varchar',
                                    size              => 50,
                                    is_nullable       => 0,
                                },
                            postal =>
                                {
                                    data_type         => 'varchar',
                                    size              => 15,
                                    is_nullable       => 0,
                                },
                            country =>
                                {
                                    data_type         => 'char',
                                    size              => 2,
                                    is_nullable       => 1,
                                },
                            email =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 1,
                                },
                            website =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 1,
                                },
                            created_on =>
                                {
                                    data_type         => 'DateTime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                            updated_on =>
                                {
                                    data_type         => 'Timestamp',
                                    is_nullable       => 1,
                                    default_value     => undef,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->belongs_to( 'client' => 'Cater::DBSchema::Result::Client', 'client_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
