package Cater;
use Dancer ':syntax';

use strict;
use warnings;

use Cater::DBI;
use Cater::User;
use Cater::Marketer;

use Const::Fast;

use version; our $VERSION = qv( 'v0.1.0' );


=head1 NAME

Cater

=head1 SYNOPSIS AND USAGE

Primary web application library, providing all routes and data calls.

=head1 ROUTES

=cut


=head2 '/'

Root route.

=cut

get '/' => sub {
    template 'index';
};



=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut;

true;
