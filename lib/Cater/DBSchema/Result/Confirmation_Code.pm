package Cater::DBSchema::Result::Confirmation_Code;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::Confirmation_Code


=head1 DESCRIPTION AND USAGE

Database object representing Confirmation Code records within the web app.

=cut

__PACKAGE__->table( 'confirmation_codes' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'ccode',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            confirmation_code =>
                                {
                                    data_type         => 'varchar',
                                    size              => 40,
                                    is_nullable       => 0,
                                },
                            account_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            account_type =>
                                {
                                    data_type         => 'varchar',
                                    size              => 10,
                                    is_nullable       => 0,
                                },
                            confirmed =>
                                {
                                    data_type         => 'integer',
                                    size              => 1,
                                    is_nullable       => 0,
                                    default_value     => 0,
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
