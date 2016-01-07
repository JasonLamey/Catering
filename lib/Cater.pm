package Cater;
use Dancer2;

use strict;
use warnings;

use Dancer2::Session::Cookie;

use Const::Fast;

use version; our $VERSION = qv( 'v0.1.2' );


=head1 NAME

Cater


=head1 SYNOPSIS AND USAGE

Primary web application library, providing all routes and data calls.


=head1 ROUTES


=head2 '/'

Root route. Presents user with main landing page.

=cut

get '/' => sub
{
    template 'index';
};


=head2 '/login'

User login route.

=cut

get '/login' => sub
{
};


=head2 '/register'

User registration route.

=cut

get '/register' => sub
{
};


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut;

1;
