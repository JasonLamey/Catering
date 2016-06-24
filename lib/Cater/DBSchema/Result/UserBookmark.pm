package Cater::DBSchema::Result::UserBookmark;

use Dancer2 appname => 'Cater';
use base 'DBIx::Class::Core';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBSchema::Result::UserBookmark


=head1 DESCRIPTION AND USAGE

Database object representing User Bookmark records within the web app.

=cut

#+------------+---------------------+------+-----+-------------------+----------------+
#| Field      | Type                | Null | Key | Default           | Extra          |
#+------------+---------------------+------+-----+-------------------+----------------+
#| id         | bigint(20) unsigned | NO   | PRI | NULL              | auto_increment |
#| user_id    | bigint(20) unsigned | NO   |     | NULL              |                |
#| client_id  | bigint(20) unsigned | NO   |     | NULL              |                |
#| created_on | datetime            | NO   |     | CURRENT_TIMESTAMP |                |
#+------------+---------------------+------+-----+-------------------+----------------+

__PACKAGE__->table( 'user_bookmarks' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'bookmark',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            user_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            client_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            created_on =>
                                {
                                    data_type         => 'DateTime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

# Cater::User->has_many( somethings => 'Object::Package' );

__PACKAGE__->belongs_to( 'user' => 'Cater::DBSchema::Result::User', 'user_id' );
__PACKAGE__->belongs_to( 'client' => 'Cater::DBSchema::Result::Client', 'client_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
