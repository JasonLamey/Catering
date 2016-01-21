package Cater::User;

use Dancer2 appname => 'Cater';
use base 'Cater::DBI';

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::User


=head1 DESCRIPTION AND USAGE

Database object representing Users within the web app.

=cut

__PACKAGE__->table( 'users' );
__PACKAGE__->columns( Primary => 'id' );
__PACKAGE__->columns( All => qw/id username full_name password email created_on updated_on/ );
__PACKAGE__->has_a(
                    created_on => 'Time::Piece',
                    inflate    => sub { Time::Piece->strptime( shift, "%Y-%m-%d" ) },
                    deflate    => 'ymd',
);
__PACKAGE__->has_a(
                    updated_on => 'Time::Piece',
                    inflate    => sub { Time::Piece->strptime( shift, "%Y-%m-%d" ) },
                    deflate    => 'ymd',
);
# Cater::User->has_many( somethings => 'Object::Package' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
