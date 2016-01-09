package Cater;
use Dancer2;

use strict;
use warnings;

use Dancer2::Session::Cookie;

use Const::Fast;

use version; our $VERSION = qv( 'v0.1.2' );

use Cater::Login;


=head1 NAME

Cater


=head1 SYNOPSIS AND USAGE

Primary web application library, providing all routes and data calls.


=head1 ROUTES


=head2 'GET /'

Root route. Presents user with main landing page.

=cut

get '/' => sub
{
    template 'index';
};


=head2 'GET /login'

User login route. Presents user with a login page.

=cut

get '/login' => sub
{
    template 'login',
                    {
                        data => {
                                    username      => query_parameters->get('username'),
                                    user_type     => query_parameters->get('user_type'),
                                    error_message => query_parameters->get('error_message'),
                                },
                    };
};


=head2 'POST /login'

User login submission route. Processes the login information, and forwards the user back either to the login page, or to their home page.

=cut

post '/login' => sub
{
    my $login_result = Cater::Login->process_login_credentials(
                                                               username  => body_parameters->get('username'),
                                                               password  => body_parameters->get('password'),
                                                               user_type => body_parameters->get('user_type'),
                                                              );

    if ( $login_result->{'success'} )
    {
        forward '/';
    }
    else
    {
        warn $login_result->{'log_message'};
        forward '/login',
                        {
                            username      => body_parameters->get('username'),
                            user_type     => body_parameters->get('user_type'),
                            error_message => $login_result->{'error_message'},
                        },
                        { method => 'GET' }
    }
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
