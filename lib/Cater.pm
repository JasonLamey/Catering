package Cater;
use Dancer2;

use strict;
use warnings;

use Dancer2::Session::Cookie;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Deferred;

use Const::Fast;

use version; our $VERSION = qv( 'v0.1.2' );

use Cater::Login;
use Cater::Email;


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
                                    username      => ( param 'username'      // '' ),
                                    user_type     => ( param 'user_type'     // '' ),
                                },
                        msgs => {
                                    error_message => ( param 'error_message' // '' ),
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
        info 'Successful Login: >' . body_parameters->get('username') . '< from IP: >' .
             request->remote_address . ' - ' . request->remote_host . '<';
        session user => body_parameters->get('username');
        redirect '/';
    }
    else
    {
        warning $login_result->{'log_message'};
        forward '/login',
                        {
                            username      => body_parameters->get('username'),
                            user_type     => body_parameters->get('user_type'),
                            error_message => $login_result->{'error_message'},
                        },
                        { method => 'GET' };
    }
};


=head2 'GET /register'

User registration route. Provides the appropriate registration form for signup.

=cut

get '/register' => sub
{
    template 'register',
                    {
                        data => {
                                    username  => ( param 'username'  // '' ),
                                    full_name => ( param 'full_name' // '' ),
                                    email     => ( param 'email'     // '' ),
                                    user_type => ( param 'user_type' // '' ),
                                },
                        msgs => {
                                    error_message => ( param 'error_message' // '' ),
                                },
                    };
};


=head2 'POST /register'

User registration processing route.

=cut

post '/register' => sub
{
    my $registration_result = Cater::Login->process_registration_data(
                                                                       username         => body_parameters->get('username'),
                                                                       full_name        => body_parameters->get('full_name'),
                                                                       email            => body_parameters->get('email'),
                                                                       password         => body_parameters->get('password'),
                                                                       password_confirm => body_parameters->get('password_confirm'),
                                                                       user_type        => body_parameters->get('user_type'),
                                                                     );

    if ( $registration_result->{'success'} )
    {
        # Send registration confirmation e-mail.
        my $sent_email = Cater::Email->send_registration_confirmation(
                                                                        username  => body_parameters->get('username'),
                                                                        full_name => body_parameters->get('full_name'),
                                                                        email     => body_parameters->get('email'),
                                                                        ccode     => $registration_result->{'ccode'},
                                                                     );
        if ( ! $sent_email->{'success'} )
        {
            deferred error_message => $sent_email->{'error_message'} if defined $sent_email->{'error_message'};
            error $sent_email->{'log_message'};
        }

        forward '/post_register', {
                                    username  => body_parameters->get('username'),
                                    full_name => body_parameters->get('full_name'),
                                    email     => body_parameters->get('email'),
                                    user_type => body_parameters->get('user_type'),
                                  };
    }
    else
    {
        error $registration_result->{'log_message'};
        deferred error_message => $registration_result->{'error_message'} if defined $registration_result->{'error_message'};
        forward '/register',
                        {
                            username  => body_parameters->get('username'),
                            full_name => body_parameters->get('full_name'),
                            email     => body_parameters->get('email'),
                            user_type => body_parameters->get('user_type'),
                        },
                        { method => 'GET' };
    }
};


=head2 'GET or POST /post_register'

User post-registration instructions route.

=cut

any [ 'get', 'post' ] => '/post_register' => sub
{
    template 'post_register.tt', {
                                    data => {
                                                username  => ( param 'username'  // '' ),
                                                full_name => ( param 'full_name' // '' ),
                                                email     => ( param 'email'     // '' ),
                                                user_type => ( param 'user_type' // '' ),
                                            },
                                 };
};


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut;

1;
