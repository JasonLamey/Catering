package Cater::DBSchema::Result::Client;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::Client


=head1 DESCRIPTION AND USAGE

Database object representing Client (specialized Users) within the web app.

=cut

__PACKAGE__->table( 'clients' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'client',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            username =>
                                {
                                    data_type         => 'varchar',
                                    size              => 40,
                                    is_nullable       => 0,
                                },
                            password =>
                                {
                                    data_type         => 'char',
                                    size              => 73,
                                    is_nullable       => 0,
                                },
                            poc_name =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            company =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            email =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            phone =>
                                {
                                    data_type         => 'varchar',
                                    size              => 25,
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
                                    is_nullable       => 0,
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
                            zip =>
                                {
                                    data_type         => 'varchar',
                                    size              => 15,
                                    is_nullable       => 0,
                                },
                            country =>
                                {
                                    data_type         => 'char',
                                    size              => 2,
                                    is_nullable       => 0,
                                },
                            website =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
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

# Cater::User->has_many( somethings => 'Object::Package' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
