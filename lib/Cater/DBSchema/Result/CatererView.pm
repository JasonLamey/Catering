package Cater::DBSchema::Result::CatererView;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::CatererView


=head1 DESCRIPTION AND USAGE

Database object representing Caterer Views within the web app.

=cut

#+-----------+---------------------+------+-----+---------+----------------+
#| Field     | Type                | Null | Key | Default | Extra          |
#+-----------+---------------------+------+-----+---------+----------------+
#| id        | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
#| client_id | bigint(20) unsigned | NO   | MUL | NULL    |                |
#| date      | date                | NO   |     | NULL    |                |
#| count     | int(10) unsigned    | NO   |     | 0       |                |
#+-----------+---------------------+------+-----+---------+----------------+

__PACKAGE__->table( 'caterer_views' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'caterer_view',
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
                            date =>
                                {
                                    data_type         => 'Date',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->date,
                                },
                            count =>
                                {
                                    data_type         => 'integer',
                                    is_nullable       => 0,
                                    default_value     => 0,
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
