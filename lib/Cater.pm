package Cater;
use Dancer2;

use strict;
use warnings;

use Dancer2::Session::Cookie;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Deferred;
use Dancer2::Plugin::Passphrase;

use Locale::Country;
use Const::Fast;
use FormValidator::Simple;
use Data::Dumper;
use DateTime;
use Template;
use FindBin;
use Try::Tiny;
use GeoIP2::Database::Reader;

my $template = Template->new(
                                {
                                    PLUGIN_BASE => 'Cater::Template::Plugin',
                                }
                            );

use version; our $VERSION = qv( 'v0.1.4' );

use Cater::DBSchema;
use Cater::Login;
use Cater::Email;
use Cater::Admin;

const my $SCHEMA           => Cater::DBSchema->get_schema_connection();
const my $COUNTRY_CODE_SET => 'LOCALE_CODE_ALPHA_2';

=head1 NAME

Cater


=head1 SYNOPSIS AND USAGE

Primary web application library, providing all routes and data calls.


=head1 ROUTES

=cut

hook before => sub
{
    # Fetch GeoLocation details
    my $reader = GeoIP2::Database::Reader->new(
        file    => "$FindBin::Bin/../lib/GeoIP2/GeoLite2-City.mmdb",
        locales => [ 'en' ]
    );

    try
    {
        my $record = $reader->city( ip => request->remote_address );
        #my $record = $reader->city( ip => '173.71.202.84' );  # DEBUG: This is a static debugging IP address. DO NOT use in production.

        debug "Pulled GeoLocation data for >" . request->remote_address . "<";
        my $country_rec  = $record->country();
        my $city_rec     = $record->city();
        my $postal_rec   = $record->postal();
        my $location_rec = $record->location();

        var guest_country => $country_rec->name();
        var guest_ccode   => $country_rec->iso_code();
        var guest_city    => $city_rec->name();
        var guest_postal  => $postal_rec->code();
        var guest_lat     => $location_rec->latitude();
        var guest_long    => $location_rec->longitude();
    }
    catch
    {
        warning "Could not find GeoLocation data for >" . request->remote_address . '<';
    };
};


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
                        breadcrumbs => [
                                    { current => 1, name => 'Login/Register' },
                                ],
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
        deferred success => 'Successfully logged in.  Welcome back, <b>' . session( "user" ) . '</b>!';
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


=head2 'GET /logout'

User logout route. Destroys the user's session, effectively logging them out of their account.

=cut

get '/logout' => sub
{
    my $user = session( "user" );
    app->destroy_session;
    deferred success => 'You have been successfully logged out. Come back soon!';
    info 'Successful Logout of >' . $user . '<';
    redirect '/';
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
        # Save confirmation code in the DB.
        my $ccode_saved = Cater::Login->save_confirmation_code(
                                                                username  => body_parameters->get('username'),
                                                                user_type => body_parameters->get('user_type'),
                                                                ccode     => $registration_result->{'ccode'},
                                                              );
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
    template 'post_registration.tt', {
                                        data => {
                                                    username  => ( param 'username'  // '' ),
                                                    full_name => ( param 'full_name' // '' ),
                                                    email     => ( param 'email'     // '' ),
                                                    user_type => ( param 'user_type' // '' ),
                                                },
                                     };
};


=head2 'GET or post /account_confirmation'

User account confirmation page.

=cut

any [ 'get', 'post' ] => '/account_confirmation/:ccode?' => sub
{
    my $ccode = param 'ccode' // '';

    my $ccode_confirmed = Cater::Login->confirm_ccode( ccode => $ccode );

    if ( ! $ccode_confirmed->{'success'} )
    {
        warning $ccode_confirmed->{'log_message'};
    }

    deferred error_message => $ccode_confirmed->{'error_message'} if $ccode_confirmed->{'error_message'};

    template 'account_confirmation.tt', {
                                            data => {
                                                        ccode   => $ccode,
                                                        success => $ccode_confirmed->{'success'},
                                                        user    => $ccode_confirmed->{'user'},
                                                    },
                                        };
};


=head2 Admin-based routes

=cut

prefix '/admin' => sub
{
    hook before => sub
    {
        if (
            ! session( 'admin_user' )
            &&
            request->dispatch_path =~ m{^/admin}
            &&
            request->dispatch_path !~ m{^/admin/login}
            &&
            request->is_get()
        )
        {
            forward '/admin/login', { requested_path => request->dispatch_path };
        }

        # Fetch the admin user and admin/op status if we're serving an admin page and the admin is logged in.
        if ( request->dispatch_path =~ m{^/admin} && session( 'admin_user' ) )
        {
            my $admin_user = Cater::Admin->get_admin_user( username => session( 'admin_user' ) );
            var admin_user => $admin_user;
            var is_admin   => ( defined $admin_user && $admin_user->admin_type eq 'Admin' ) ? 1 : 0;
            session->expires( 600 ); # Admin session auto-expires after 10 minutes of inactivity.
        }
    };


=head2 get '/'

Root admin route

=cut

    get '/?' => sub
    {
        my $stats = Cater::Admin->get_index_stats();

        template 'admin/index', {
                                    data        => {
                                                        stats => $stats,
                                                   },
                                    breadcrumbs => [
                                                        { link => '/admin/', name => 'ADMIN' },
                                                        { current  => 1, name => 'Main' },
                                                   ],
                                },
                                { layout => 'admin' };
    };


=head2 get '/admin/login'

Provides the admin-specific login screen to the user.

=cut

    get '/login' => sub
    {
        template 'admin/login',
                        {
                            data => {
                                        username       => ( param 'username'       // '' ),
                                        requested_path => ( param 'requested_path' // '/admin/' ),
                                    },
                            msgs => {
                                        error_message  => ( param 'error_message' // '' ),
                                    },
                            breadcrumbs => [
                                        { link => '/admin/', name => 'ADMIN' },
                                        { current  => 1, name => 'Login' },
                                    ],
                        },
                        { layout => 'admin' };
    };

=head2 post /admin/login

Processes the login attempt.

=cut

    post '/login' => sub
    {
        my $login_result = Cater::Admin->process_login_credentials(
                                                                   username  => body_parameters->get('username'),
                                                                   password  => body_parameters->get('password'),
                                                                  );

        if ( $login_result->{'success'} )
        {
            info 'Successful Admin Login: >' . body_parameters->get('username') . '< from IP: >' .
                 request->remote_address . ' - ' . request->remote_host . '<';
            session admin_user => body_parameters->get('username');
            deferred success => 'Successfully logged in.  Welcome back, <b>' . session( "admin_user" ) . '</b>!';
            redirect ( body_parameters->get('requested_path') // '/admin/' );
        }
        else
        {
            warning $login_result->{'log_message'};
            deferred error_message => $login_result->{'error_message'};
            forward '/admin/login',
                            {
                                username      => body_parameters->get('username'),
                                error_message => $login_result->{'error_message'},
                            },
                            { method => 'GET' };
        }
    };


=head2 'GET /admin/logout'

Admin logout route. Destroys the user's session, effectively logging them out of their account.

=cut

    get '/logout' => sub
    {
        my $user = session( "admin_user" );
        app->destroy_session;
        deferred success => 'You have been successfully logged out. Come back soon!';
        info 'Successful Admin Logout of >' . $user . '<';
        redirect '/';
    };


=head2 'GET /admin/manage/caterers'

Route to the Caterer Management page.

=cut

    get '/manage/caterers' => sub
    {
        my $caterers = Cater::Admin->get_all_caterers();
        template 'admin/manage/caterers', {
                                            data => {
                                                        caterers => $caterers,
                                                    },
                                            breadcrumbs => [
                                                        { link => '/admin/', name => 'ADMIN' },
                                                        { current  => 1, name => 'Manage Caterers' },
                                                    ],
                                          },
                                        { layout => 'admin' };
    };


=head2 'GET /admin/manage/caterers/<id>/view'

Route viewing a Client's account information.

=cut

    get '/manage/caterers/:id/view' => sub
    {
        my $caterer = Cater::Admin->get_caterer_by_id( client_id => route_parameters->{'id'} );

        template 'admin/manage/caterer_view',   {
                                                    data => {
                                                                caterer => $caterer,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/caterers', name => 'Manage Caterers' },
                                                                { current  => 1, name => 'View Caterer Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'GET /admin/manage/caterers/<id>/edit'

Route for editing caterer account information.

=cut

    get '/manage/caterers/:id/edit' => sub
    {
        my $caterer   = Cater::Admin->get_caterer_by_id( client_id => route_parameters->{'id'} );
        my @countries = Locale::Country::all_country_names();

        template 'admin/manage/caterer_edit',   {
                                                    data => {
                                                                caterer   => $caterer,
                                                                countries => \@countries,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/caterers', name => 'Manage Caterers' },
                                                                { link  => '/admin/manage/caterers/' . route_parameters->{'id'} . '/view', name => 'View Caterer' },
                                                                { current  => 1, name => 'Edit Caterer Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'POST /admin/manage/caterers/<id>/save'

Route for saving caterer account information.

=cut

    post '/manage/caterers/:id/save' => sub
    {
        my $caterer = Cater::Admin->get_caterer_by_id( client_id => route_parameters->{'id'} );

        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    company  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    email    => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    phone    => [ [ 'LENGTH', 0, 30 ] ],
                                                                    street1  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    city     => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    state    => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    country  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    zip      => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    poc_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my @countries = Locale::Country::all_country_names();
            my $new_caterer = {
                                    id         => route_parameters->{'id'},
                                    company    => body_parameters->{'company'},
                                    email      => body_parameters->{'email'},
                                    phone      => body_parameters->{'phone'},
                                    street1    => body_parameters->{'street1'},
                                    street2    => body_parameters->{'street2'},
                                    city       => body_parameters->{'city'},
                                    state      => body_parameters->{'state'},
                                    country    => body_parameters->{'country'},
                                    zip        => body_parameters->{'zip'},
                                    poc_name   => body_parameters->{'poc_name'},
                                    username   => body_parameters->{'username'},
                                    confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                    created_on => body_parameters->{'created_on'},
                                    updated_on => body_parameters->{'updated_on'},
                              };

            template 'admin/manage/caterer_edit',   {
                                                        data => {
                                                                    caterer   => $new_caterer,
                                                                    countries => \@countries,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/caterers', name => 'Manage Caterers' },
                                                                    { link  => '/admin/manage/caterers/' . route_parameters->{'id'} . '/view', name => 'View Caterer' },
                                                                    { current  => 1, name => 'Edit Caterer Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        $SCHEMA->txn_do( sub
                            {
                                $caterer->update(
                                        {
                                            company    => body_parameters->{'company'},
                                            email      => body_parameters->{'email'},
                                            phone      => body_parameters->{'phone'},
                                            street1    => body_parameters->{'street1'},
                                            street2    => body_parameters->{'street2'},
                                            city       => body_parameters->{'city'},
                                            state      => body_parameters->{'state'},
                                            country    => body_parameters->{'country'},
                                            zip        => body_parameters->{'zip'},
                                            poc_name   => body_parameters->{'poc_name'},
                                            username   => body_parameters->{'username'},
                                            confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                            updated_on => DateTime->now(),
                                        }
                                )
                            }
        );

        deferred success => "Successfully updated <strong>" . body_parameters->{'company'} . "</strong>.";
        redirect '/admin/manage/caterers/' . route_parameters->{'id'} . '/view';
    };


=head2 'GET /admin/manage/caterers/add'

Route to adding a new Caterer/Client account.

=cut

    get '/manage/caterers/add' => sub
    {
        my @countries = Locale::Country::all_country_names();

        template 'admin/manage/caterer_add', {
                                                    data => {
                                                                countries => \@countries,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/caterers', name => 'Manage Caterers' },
                                                                { current  => 1, name => 'Add Caterer Record' },
                                                            ],
                                             },
                                             { layout => 'admin' };
    };


=head2 'POST /admin/manage/caterers/create'

Route for saving new caterer account information.

=cut

    post '/manage/caterers/create' => sub
    {
        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    company  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    email    => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    phone    => [ [ 'LENGTH', 0, 30 ] ],
                                                                    street1  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    city     => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    state    => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    country  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    zip      => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    poc_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        my $new_caterer = {
                                company    => body_parameters->{'company'},
                                email      => body_parameters->{'email'},
                                phone      => body_parameters->{'phone'},
                                street1    => body_parameters->{'street1'},
                                street2    => body_parameters->{'street2'},
                                city       => body_parameters->{'city'},
                                state      => body_parameters->{'state'},
                                country    => body_parameters->{'country'},
                                zip        => body_parameters->{'zip'},
                                poc_name   => body_parameters->{'poc_name'},
                                username   => body_parameters->{'username'},
                                confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                created_on => DateTime->now(),
                          };

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my @countries = Locale::Country::all_country_names();

            template 'admin/manage/caterer_add',   {
                                                        data => {
                                                                    caterer   => $new_caterer,
                                                                    countries => \@countries,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/caterers', name => 'Manage Caterers' },
                                                                    { current  => 1, name => 'Add Caterer Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        my $added_caterer = $SCHEMA->resultset( 'Client' )->new(
                                                                    {
                                                                        company    => body_parameters->{'company'},
                                                                        email      => body_parameters->{'email'},
                                                                        phone      => body_parameters->{'phone'},
                                                                        street1    => body_parameters->{'street1'},
                                                                        street2    => body_parameters->{'street2'},
                                                                        city       => body_parameters->{'city'},
                                                                        state      => body_parameters->{'state'},
                                                                        country    => body_parameters->{'country'},
                                                                        zip        => body_parameters->{'zip'},
                                                                        poc_name   => body_parameters->{'poc_name'},
                                                                        username   => body_parameters->{'username'},
                                                                        password   => passphrase( body_parameters->{'password'} )->generate->rfc2307(),
                                                                        confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                                                        created_on => DateTime->now(),
                                                                    }
                                                                );

        $SCHEMA->txn_do( sub
                            {
                                $added_caterer->insert
                            }
        );

        deferred success => "Successfully added <strong>" . body_parameters->{'company'} . "</strong>.";
        redirect '/admin/manage/caterers/' . $added_caterer->id . '/view';
    };


=head2 'GET /admin/manage/caterers/<id>/delete'

Route to delete a specific caterer/client account

=cut

    get '/manage/caterers/:id/delete' => sub
    {
        unless ( vars->{'is_admin'} )
        {
            redirect '/admin/manage/caterers/' . route_parameters->{'id'} . '/view';
        }

        my $caterer = Cater::Admin->get_caterer_by_id( client_id => route_parameters->{'id'} );
        my $caterer_name = $caterer->company;

        $SCHEMA->txn_do( sub
                            {
                                $caterer->delete
                            }
        );

        deferred success => "Successfully deleted <strong>$caterer_name</strong>.";
        redirect '/admin/manage/caterers';
    };


=head2 'GET /admin/manage/marketers'

Route to the Marketer Management page.

=cut

    get '/manage/marketers' => sub
    {
        my $marketers = Cater::Admin->get_all_marketers();
        template 'admin/manage/marketers', {
                                            data => {
                                                        marketers => $marketers,
                                                    },
                                            breadcrumbs => [
                                                        { link => '/admin/', name => 'ADMIN' },
                                                        { current  => 1, name => 'Manage Marketers' },
                                                    ],
                                          },
                                        { layout => 'admin' };
    };


=head2 'GET /admin/manage/marketers/<id>/view'

Route viewing a Client's account information.

=cut

    get '/manage/marketers/:id/view' => sub
    {
        my $marketer = Cater::Admin->get_marketer_by_id( marketer_id => route_parameters->{'id'} );

        template 'admin/manage/marketer_view',   {
                                                    data => {
                                                                marketer => $marketer,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/marketers', name => 'Manage Marketers' },
                                                                { current  => 1, name => 'View Marketer Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'GET /admin/manage/marketers/<id>/edit'

Route for editing marketer account information.

=cut

    get '/manage/marketers/:id/edit' => sub
    {
        my $marketer   = Cater::Admin->get_marketer_by_id( marketer_id => route_parameters->{'id'} );
        my @countries = Locale::Country::all_country_names();

        template 'admin/manage/marketer_edit',   {
                                                    data => {
                                                                marketer   => $marketer,
                                                                countries => \@countries,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/marketers', name => 'Manage Marketers' },
                                                                { link  => '/admin/manage/marketers/' . route_parameters->{'id'} . '/view', name => 'View Marketer' },
                                                                { current  => 1, name => 'Edit Marketer Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'POST /admin/manage/marketers/<id>/save'

Route for saving marketer account information.

=cut

    post '/manage/marketers/:id/save' => sub
    {
        my $marketer = Cater::Admin->get_marketer_by_id( marketer_id => route_parameters->{'id'} );

        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    company  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    email    => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    phone    => [ [ 'LENGTH', 0, 30 ] ],
                                                                    street1  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    city     => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    state    => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    country  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    zip      => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    poc_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my @countries = Locale::Country::all_country_names();
            my $new_marketer = {
                                    id         => route_parameters->{'id'},
                                    company    => body_parameters->{'company'},
                                    email      => body_parameters->{'email'},
                                    phone      => body_parameters->{'phone'},
                                    street1    => body_parameters->{'street1'},
                                    street2    => body_parameters->{'street2'},
                                    city       => body_parameters->{'city'},
                                    state      => body_parameters->{'state'},
                                    country    => body_parameters->{'country'},
                                    zip        => body_parameters->{'zip'},
                                    poc_name   => body_parameters->{'poc_name'},
                                    username   => body_parameters->{'username'},
                                    confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                    created_on => body_parameters->{'created_on'},
                                    updated_on => body_parameters->{'updated_on'},
                              };

            template 'admin/manage/marketer_edit',   {
                                                        data => {
                                                                    marketer   => $new_marketer,
                                                                    countries => \@countries,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/marketers', name => 'Manage Marketers' },
                                                                    { link  => '/admin/manage/marketers/' . route_parameters->{'id'} . '/view', name => 'View Marketer' },
                                                                    { current  => 1, name => 'Edit Marketer Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        $SCHEMA->txn_do( sub
                            {
                                $marketer->update(
                                        {
                                            company    => body_parameters->{'company'},
                                            email      => body_parameters->{'email'},
                                            phone      => body_parameters->{'phone'},
                                            street1    => body_parameters->{'street1'},
                                            street2    => body_parameters->{'street2'},
                                            city       => body_parameters->{'city'},
                                            state      => body_parameters->{'state'},
                                            country    => body_parameters->{'country'},
                                            zip        => body_parameters->{'zip'},
                                            poc_name   => body_parameters->{'poc_name'},
                                            username   => body_parameters->{'username'},
                                            confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                            updated_on => DateTime->now(),
                                        }
                                )
                            }
        );

        deferred success => "Successfully updated <strong>" . body_parameters->{'company'} . "</strong>.";
        redirect '/admin/manage/marketers/' . route_parameters->{'id'} . '/view';
    };


=head2 'GET /admin/manage/marketers/add'

Route to adding a new Caterer/Client account.

=cut

    get '/manage/marketers/add' => sub
    {
        my @countries = Locale::Country::all_country_names();

        template 'admin/manage/marketer_add', {
                                                    data => {
                                                                countries => \@countries,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/marketers', name => 'Manage Marketers' },
                                                                { current  => 1, name => 'Add Marketer Record' },
                                                            ],
                                             },
                                             { layout => 'admin' };
    };


=head2 'POST /admin/manage/marketers/create'

Route for saving new marketer account information.

=cut

    post '/manage/marketers/create' => sub
    {
        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    company  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    email    => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    phone    => [ [ 'LENGTH', 0, 30 ] ],
                                                                    street1  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    city     => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    state    => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    country  => [ 'NOT_BLANK', [ 'LENGTH', 4, 255 ] ],
                                                                    zip      => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    poc_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        my $new_marketer = {
                                company    => body_parameters->{'company'},
                                email      => body_parameters->{'email'},
                                phone      => body_parameters->{'phone'},
                                street1    => body_parameters->{'street1'},
                                street2    => body_parameters->{'street2'},
                                city       => body_parameters->{'city'},
                                state      => body_parameters->{'state'},
                                country    => body_parameters->{'country'},
                                zip        => body_parameters->{'zip'},
                                poc_name   => body_parameters->{'poc_name'},
                                username   => body_parameters->{'username'},
                                confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                created_on => DateTime->now(),
                          };

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my @countries = Locale::Country::all_country_names();

            template 'admin/manage/marketer_add',   {
                                                        data => {
                                                                    marketer   => $new_marketer,
                                                                    countries => \@countries,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/marketers', name => 'Manage Marketers' },
                                                                    { current  => 1, name => 'Add Marketer Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        my $added_marketer = $SCHEMA->resultset( 'Marketer' )->new(
                                                                    {
                                                                        company    => body_parameters->{'company'},
                                                                        email      => body_parameters->{'email'},
                                                                        phone      => body_parameters->{'phone'},
                                                                        street1    => body_parameters->{'street1'},
                                                                        street2    => body_parameters->{'street2'},
                                                                        city       => body_parameters->{'city'},
                                                                        state      => body_parameters->{'state'},
                                                                        country    => body_parameters->{'country'},
                                                                        zip        => body_parameters->{'zip'},
                                                                        poc_name   => body_parameters->{'poc_name'},
                                                                        username   => body_parameters->{'username'},
                                                                        password   => passphrase( body_parameters->{'password'} )->generate->rfc2307(),
                                                                        confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                                                        created_on => DateTime->now(),
                                                                    }
                                                                );

        $SCHEMA->txn_do( sub
                            {
                                $added_marketer->insert
                            }
        );

        deferred success => "Successfully added <strong>" . body_parameters->{'company'} . "</strong>.";
        redirect '/admin/manage/marketers/' . $added_marketer->id . '/view';
    };


=head2 'GET /admin/manage/marketers/<id>/delete'

Route to delete a specific marketer/client account

=cut

    get '/manage/marketers/:id/delete' => sub
    {
        unless ( vars->{'is_admin'} )
        {
            redirect '/admin/manage/marketers/' . route_parameters->{'id'} . '/view';
        }

        my $marketer = Cater::Admin->get_marketer_by_id( marketer_id => route_parameters->{'id'} );
        my $marketer_name = $marketer->company;

        $SCHEMA->txn_do( sub
                            {
                                $marketer->delete
                            }
        );

        deferred success => "Successfully deleted <strong>$marketer_name</strong>.";
        redirect '/admin/manage/marketers';
    };


=head2 'GET /admin/manage/users'

Route to the User Management page.

=cut

    get '/manage/users' => sub
    {
        my $users = Cater::Admin->get_all_users();
        template 'admin/manage/users', {
                                            data => {
                                                        users => $users,
                                                    },
                                            breadcrumbs => [
                                                        { link => '/admin/', name => 'ADMIN' },
                                                        { current  => 1, name => 'Manage Users' },
                                                    ],
                                          },
                                        { layout => 'admin' };
    };


=head2 'GET /admin/manage/users/<id>/view'

Route viewing a Client's account information.

=cut

    get '/manage/users/:id/view' => sub
    {
        my $user = Cater::Admin->get_user_by_id( user_id => route_parameters->{'id'} );

        template 'admin/manage/user_view',   {
                                                    data => {
                                                                user => $user,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/users', name => 'Manage Users' },
                                                                { current  => 1, name => 'View User Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'GET /admin/manage/users/<id>/edit'

Route for editing user account information.

=cut

    get '/manage/users/:id/edit' => sub
    {
        my $user   = Cater::Admin->get_user_by_id( user_id => route_parameters->{'id'} );

        template 'admin/manage/user_edit',   {
                                                    data => {
                                                                user   => $user,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/users', name => 'Manage Users' },
                                                                { link  => '/admin/manage/users/' . route_parameters->{'id'} . '/view', name => 'View User' },
                                                                { current  => 1, name => 'Edit User Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'POST /admin/manage/users/<id>/save'

Route for saving user account information.

=cut

    post '/manage/users/:id/save' => sub
    {
        my $user = Cater::Admin->get_user_by_id( user_id => route_parameters->{'id'} );

        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    email     => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    full_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username  => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my $new_user = {
                                    id         => route_parameters->{'id'},
                                    email      => body_parameters->{'email'},
                                    full_name  => body_parameters->{'full_name'},
                                    username   => body_parameters->{'username'},
                                    confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                    created_on => body_parameters->{'created_on'},
                                    updated_on => body_parameters->{'updated_on'},
                              };

            template 'admin/manage/user_edit',   {
                                                        data => {
                                                                    user   => $new_user,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/users', name => 'Manage Users' },
                                                                    { link  => '/admin/manage/users/' . route_parameters->{'id'} . '/view', name => 'View User' },
                                                                    { current  => 1, name => 'Edit User Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        $SCHEMA->txn_do( sub
                            {
                                $user->update(
                                        {
                                            email      => body_parameters->{'email'},
                                            full_name  => body_parameters->{'full_name'},
                                            username   => body_parameters->{'username'},
                                            confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                            updated_on => DateTime->now(),
                                        }
                                )
                            }
        );

        deferred success => "Successfully updated <strong>" . body_parameters->{'username'} . "</strong>.";
        redirect '/admin/manage/users/' . route_parameters->{'id'} . '/view';
    };


=head2 'GET /admin/manage/users/add'

Route to adding a new Caterer/Client account.

=cut

    get '/manage/users/add' => sub
    {
        template 'admin/manage/user_add', {
                                                    data => {
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/users', name => 'Manage Users' },
                                                                { current  => 1, name => 'Add User Record' },
                                                            ],
                                             },
                                             { layout => 'admin' };
    };


=head2 'POST /admin/manage/users/create'

Route for saving new user account information.

=cut

    post '/manage/users/create' => sub
    {
        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    email     => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    full_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username  => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        my $new_user = {
                                email      => body_parameters->{'email'},
                                full_name  => body_parameters->{'full_name'},
                                username   => body_parameters->{'username'},
                                confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                created_on => DateTime->now(),
                          };

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            template 'admin/manage/user_add',   {
                                                        data => {
                                                                    user   => $new_user,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/users', name => 'Manage Users' },
                                                                    { current  => 1, name => 'Add User Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        my $added_user = $SCHEMA->resultset( 'User' )->new(
                                                                    {
                                                                        email      => body_parameters->{'email'},
                                                                        full_name  => body_parameters->{'full_name'},
                                                                        username   => body_parameters->{'username'},
                                                                        password   => passphrase( body_parameters->{'password'} )->generate->rfc2307(),
                                                                        confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                                                        created_on => DateTime->now(),
                                                                    }
                                                                );

        $SCHEMA->txn_do( sub
                            {
                                $added_user->insert
                            }
        );

        deferred success => "Successfully added <strong>" . body_parameters->{'username'} . "</strong>.";
        redirect '/admin/manage/users/' . $added_user->id . '/view';
    };


=head2 'GET /admin/manage/users/<id>/delete'

Route to delete a specific user/client account

=cut

    get '/manage/users/:id/delete' => sub
    {
        unless ( vars->{'is_admin'} )
        {
            redirect '/admin/manage/users/' . route_parameters->{'id'} . '/view';
        }

        my $user = Cater::Admin->get_user_by_id( user_id => route_parameters->{'id'} );
        my $user_name = $user->username;

        $SCHEMA->txn_do( sub
                            {
                                $user->delete
                            }
        );

        deferred success => "Successfully deleted <strong>$user_name</strong>.";
        redirect '/admin/manage/users';
    };



=head2 'GET /admin/manage/admins'

Route to the Admin Management page.

=cut

    get '/manage/admins' => sub
    {
        my $admins = Cater::Admin->get_all_admins();
        template 'admin/manage/admins', {
                                            data => {
                                                        admins => $admins,
                                                    },
                                            breadcrumbs => [
                                                        { link => '/admin/', name => 'ADMIN' },
                                                        { current  => 1, name => 'Manage Admins' },
                                                    ],
                                          },
                                        { layout => 'admin' };
    };


=head2 'GET /admin/manage/admins/<id>/view'

Route viewing a Client's account information.

=cut

    get '/manage/admins/:id/view' => sub
    {
        my $admin = Cater::Admin->get_admin_by_id( admin_id => route_parameters->{'id'} );

        template 'admin/manage/admin_view',   {
                                                    data => {
                                                                admin => $admin,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/admins', name => 'Manage Admins' },
                                                                { current  => 1, name => 'View Admin Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'GET /admin/manage/admins/<id>/edit'

Route for editing admin account information.

=cut

    get '/manage/admins/:id/edit' => sub
    {
        my $admin   = Cater::Admin->get_admin_by_id( admin_id => route_parameters->{'id'} );

        template 'admin/manage/admin_edit',   {
                                                    data => {
                                                                admin   => $admin,
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/admins', name => 'Manage Admins' },
                                                                { link  => '/admin/manage/admins/' . route_parameters->{'id'} . '/view', name => 'View Admin' },
                                                                { current  => 1, name => 'Edit Admin Record' },
                                                            ],
                                                },
                                                { layout => 'admin' };
    };


=head2 'POST /admin/manage/admins/<id>/save'

Route for saving admin account information.

=cut

    post '/manage/admins/:id/save' => sub
    {
        my $admin = Cater::Admin->get_admin_by_id( admin_id => route_parameters->{'id'} );

        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    email     => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    full_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username  => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            my $new_admin = {
                                    id         => route_parameters->{'id'},
                                    admin_type => body_parameters->{'admin_type'},
                                    email      => body_parameters->{'email'},
                                    phone      => body_parameters->{'phone'},
                                    full_name  => body_parameters->{'full_name'},
                                    username   => body_parameters->{'username'},
                                    created_on => body_parameters->{'created_on'},
                                    updated_on => body_parameters->{'updated_on'},
                              };

            template 'admin/manage/admin_edit',   {
                                                        data => {
                                                                    admin   => $new_admin,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/admins', name => 'Manage Admins' },
                                                                    { link  => '/admin/manage/admins/' . route_parameters->{'id'} . '/view', name => 'View Admin' },
                                                                    { current  => 1, name => 'Edit Admin Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        $SCHEMA->txn_do( sub
                            {
                                $admin->update(
                                        {
                                            admin_type => body_parameters->{'admin_type'},
                                            email      => body_parameters->{'email'},
                                            phone      => body_parameters->{'phone'},
                                            full_name  => body_parameters->{'full_name'},
                                            username   => body_parameters->{'username'},
                                            updated_on => DateTime->now(),
                                        }
                                )
                            }
        );

        deferred success => "Successfully updated <strong>" . body_parameters->{'username'} . "</strong>.";
        redirect '/admin/manage/admins/' . route_parameters->{'id'} . '/view';
    };


=head2 'GET /admin/manage/admins/add'

Route to adding a new Caterer/Client account.

=cut

    get '/manage/admins/add' => sub
    {
        template 'admin/manage/admin_add', {
                                                    data => {
                                                            },
                                                    breadcrumbs => [
                                                                { link => '/admin/', name => 'ADMIN' },
                                                                { link  => '/admin/manage/admins', name => 'Manage Admins' },
                                                                { current  => 1, name => 'Add Admin Record' },
                                                            ],
                                             },
                                             { layout => 'admin' };
    };


=head2 'POST /admin/manage/admins/create'

Route for saving new admin account information.

=cut

    post '/manage/admins/create' => sub
    {
        my $form_input = body_parameters->as_hashref;
        my $results = FormValidator::Simple->check(
                                                    $form_input => [
                                                                    email     => [ 'NOT_BLANK', 'EMAIL' ],
                                                                    full_name => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                    username  => [ 'NOT_BLANK', [ 'LENGTH', 4, 20  ] ],
                                                                   ]
                                                  );

        my $new_admin = {
                                email      => body_parameters->{'email'},
                                full_name  => body_parameters->{'full_name'},
                                username   => body_parameters->{'username'},
                                confirmed  => ( body_parameters->{'confirmed'} // 0 ),
                                created_on => DateTime->now(),
                          };

        if ( $results->has_error )
        {
            my $bad_fields = '';
            foreach my $key ( @{ $results->error() } )
            {
                $bad_fields .= "<li>$key</li>\n";
            }
            my $error_message = "The following fields had errors:\n";
            $error_message    .= "<ul>\n$bad_fields</ul>\n";

            warning $error_message;

            template 'admin/manage/admin_add',   {
                                                        data => {
                                                                    admin   => $new_admin,
                                                                },
                                                        msgs => {
                                                                    error_message => $error_message,
                                                                },
                                                        breadcrumbs => [
                                                                    { link => '/admin/', name => 'ADMIN' },
                                                                    { link  => '/admin/manage/admins', name => 'Manage Admins' },
                                                                    { current  => 1, name => 'Add Admin Record' },
                                                                ],
                                                    },
                                                    { layout => 'admin' };
        }

        my $added_admin = $SCHEMA->resultset( 'Admin' )->new(
                                                                    {
                                                                        email      => body_parameters->{'email'},
                                                                        phone      => body_parameters->{'phone'},
                                                                        full_name  => body_parameters->{'full_name'},
                                                                        username   => body_parameters->{'username'},
                                                                        password   => passphrase( body_parameters->{'password'} )->generate->rfc2307(),
                                                                        created_on => DateTime->now(),
                                                                    }
                                                                );

        $SCHEMA->txn_do( sub
                            {
                                $added_admin->insert
                            }
        );

        deferred success => "Successfully added <strong>" . body_parameters->{'username'} . "</strong>.";
        redirect '/admin/manage/admins/' . $added_admin->id . '/view';
    };


=head2 'GET /admin/manage/admins/<id>/delete'

Route to delete a specific admin/client account

=cut

    get '/manage/admins/:id/delete' => sub
    {
        unless ( vars->{'is_admin'} )
        {
            redirect '/admin/manage/admins/' . route_parameters->{'id'} . '/view';
        }

        my $admin = Cater::Admin->get_admin_by_id( admin_id => route_parameters->{'id'} );
        my $admin_name = $admin->username;

        $SCHEMA->txn_do( sub
                            {
                                $admin->delete
                            }
        );

        deferred success => "Successfully deleted <strong>$admin_name</strong>.";
        redirect '/admin/manage/admins';
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
