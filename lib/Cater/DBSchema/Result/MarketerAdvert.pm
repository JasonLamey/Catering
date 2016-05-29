package Cater::DBSchema::Result::MarketerAdvert;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::MarketerAdvert


=head1 DESCRIPTION AND USAGE

Database object representing Marketer Advertisements within the web app.

=cut

__PACKAGE__->table( 'marketer_ads' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'advert',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            marketer_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            headline =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            body =>
                                {
                                    data_type         => 'text',
                                    is_nullable       => 0,
                                },
                            phone =>
                                {
                                    data_type         => 'varchar',
                                    size              => 50,
                                    is_nullable       => 1,
                                    default_value     => undef,
                                },
                            email =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 1,
                                    default_value     => undef,
                                },
                            website =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 1,
                                    default_value     => undef,
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
__PACKAGE__->belongs_to( 'marketer' => 'Cater::DBSchema::Result::Marketer', 'marketer_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
