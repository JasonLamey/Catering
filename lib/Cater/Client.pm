package Cater::Client;

use base 'Cater::DBI';

use strict;
use warnings;


=head1 NAME

Cater::Client

=head1 DESCRIPTION AND USAGE

Database representation of a client object within the web app.

=cut



Cater::Client->table( 'clients' );
Cater::Client->columns(
                            All => qw/
                                        id username password poc_name company email
                                        phone street1 street2 city state zip country
                                        website created_on updated_on
                                     /
                      );
Cater::Client->has_a(
                        created_on => 'Time::Piece',
                        inflate    => sub { Time::Piece->strptime( shift, "%Y-%m-%d" ) },
                        deflate    => 'ymd',
);
Cater::Client->has_a(
                        updated_on => 'Time::Piece',
                        inflate    => sub { Time::Piece->strptime( shift, "%Y-%m-%d" ) },
                        deflate    => 'ymd',
);



=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
