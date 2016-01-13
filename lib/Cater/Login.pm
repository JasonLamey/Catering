package Cater::Login;

use Dancer2 appname => 'Cater';
use Dancer2::Plugin::Passphrase;
use Email::Valid;
use Try::Tiny;
use DateTime;

use Cater::User;
use Cater::Marketer;
use Cater::Client;

use Data::Dumper;

use strict;
use warnings;

use version; our $VERSION = qv( "v0.1.0" );

=head1 NAME

Cater::Login

=head1 DESCRIPTION AND USAGE

This module handles all of the login verification, registration, and logout functionality.

=cut

=head1 METHODS

=head2 process_login_credentials()

=over 4

=item Input: hashref containing login credentials and login form data [C<username>, C<password>, C<login_type>].

=item Output: hashref containing success code, error message [C<success>, C<error_message>, C<log_message>].

=back

    my $logged_in = Cater::Login->process_login_credentials( \%login_data );

=cut

sub process_login_credentials
{
    my ( $self, %params ) = @_;

    my $username   = $params{'username'}   // undef;
    my $password   = $params{'password'}   // undef;
    my $login_type = $params{'user_type'}  // 'User';

    my %return  = ( success => 0, error_message => '', log_message => '' );

    foreach my $key ( keys %params ) { debug "$key = >$params{$key}<"; }

    # If we're missing a username or password, let's fail it right now.
    if ( not defined $username )
    {
        $return{'error_message'} = 'You must provide a username.';
        $return{'log_message'}   = 'Failed Login: Username not defined.';
        return \%return;
    }
    if ( not defined $password )
    {
        $return{'error_message'} = 'You must provide a password.';
        $return{'log_message'}   = 'Failed Login: Password not defined.';
        return \%return;
    }

    my $account = undef;
    # Look up username and verify password based on the login-type.
    if ( uc( $login_type ) eq 'USER' )
    {
        $account = Cater::User->retrieve( username => $username );
    }
    elsif ( uc( $login_type ) eq 'MARKETER' )
    {
        $account = Cater::Marketer->retrieve( username => $username );
    }
    elsif ( uc( $login_type ) eq 'CLIENT' )
    {
        $account = Cater::Client->retrieve( username => $username );
    }
    else
    {
        $return{'error_message'} = 'Please select either a User account, Client account, or Marketer account.';
        $return{'log_message'}   = "Failed Login: Invalid user type. Received >$login_type<.";
        return \%return;
    }

    if ( not defined $account )
    {
        $return{'error_message'} = 'Invalid username, password, or user type.  Please try again.';
        $return{'log_message'}   = "Failed Login: Could not find account >$username< within >$login_type< accounts.";
        return \%return;
    }

    # Encrypt the supplied password to see if it matches the found account.
    my $enc_password = passphrase( $password )->generate;

    if ( ! passphrase( $password )->matches( $account->{'password'} ) )
    {
        $return{'error_message'} = 'Invalid username, password, or user type.  Please try again.';
        $return{'log_message'}   = "Failed Login: Invalid password provided for account >$username< within >$login_type< accounts.";
        return \%return;
    }

    # All is good, log the user in.
    $return{'success'} = 1;
    return \%return;
}


=head2 generate_random_string()

Generates a new random string for use with a new account or for a password reset, or as confirmation code tokens.

=over 4

=item Input: none required; can take a hashref of the following for customization: C<string_length> and C<char_set>. String length defines the length of the random password; defaults to 32. Char set defines the particular characters to be used, and is an arrayref, e.g. C<['a'..'z', 'A'..'Z']>, defaults to C<['a'..'z', 'A'..'Z', 0..9]>.

=item Output: A string of randomized chracters

=back

    my $rand_pass = Cater::Login->generate_random_string();
    my $rand_pass = Cater::Login->generate_random_string( { string_length => 32, char_set => ['a'..'z', 'A'..'Z'] } );

=cut

sub generate_random_string
{
    my ( $self, %params ) = @_;

    my $string_length = delete $params{'string_length'} // 32;
    my $char_set      = delete $params{'char_set'}      // ['a'..'z', 'A'..'Z', 0..9];

    return passphrase->generate_random( { length => $string_length, charset => $char_set } );
}


=head2 process_registration_data()

Processes new user information to ensure that it's valid and meets requirements.

=over 4

=item Input: Takes a hashref of account data: [ C<username>, C<full_name>, C<email>, C<password>, C<user_type> ]

=item Output: A hashref containing: [ C<success>, C<error_message>, C<log_message> ].  C<success> is an integer indicating true or false.

=back

    my $registration = Cater::Login->process_registration_data( \%registration_data );

=cut

sub process_registration_data
{
    my ( $self, %params ) = @_;

    my $username  = delete $params{'username'}         // '';
    my $full_name = delete $params{'full_name'}        // '';
    my $email     = delete $params{'email'}            // '';
    my $password  = delete $params{'password'}         // '';
    my $password2 = delete $params{'password_confirm'} // '';
    my $user_type = delete $params{'user_type'}        // 'User';

    my %return = ( success => 0, error_message => '', log_message => '' );
    # Ensure we have all the necessary data.
    if ( not defined $username || $username eq '' )
    {
        $return{'error_message'} = 'You must provide a username.';
        $return{'log_message'}   = 'Registration Error: Blank username provided.';
        return \%return;
    }
    if ( not defined $full_name || $full_name eq '' )
    {
        $return{'error_message'} = 'You must provide a full name.';
        $return{'log_message'}   = 'Registration Error: Blank full_name provided.';
        return \%return;
    }
    if ( not defined $email || $email eq '' )
    {
        $return{'error_message'} = 'You must provide an email address.';
        $return{'log_message'}   = 'Registration Error: Blank email provided.';
        return \%return;
    }
    if ( not defined $user_type || $user_type eq '' )
    {
        $return{'error_message'} = 'You must tell us what kind of User you are.';
        $return{'log_message'}   = 'Registration Error: Blank user_type provided.';
        return \%return;
    }
    if ( not defined $password || $password eq '' )
    {
        $return{'error_message'} = 'You must create a password.';
        $return{'log_message'}   = 'Registration Error: Blank password provided.';
        return \%return;
    }

    # Ensure the Username doens't already exist in the DB
    my $it_exists = '';
    if ( uc( $user_type ) eq 'USER' )
    {
        $it_exists = Cater::User->retrieve( username => $username );
    }
    elsif ( uc( $user_type ) eq 'MARKETER' )
    {
        $it_exists = Cater::Marketer->retrieve( username => $username );
    }
    elsif ( uc( $user_type ) eq 'CLIENT' )
    {
        $it_exists = Cater::Client->retrieve( username => $username );
    }
    else
    {
        $return{'error_message'} = 'You must select a User Type.';
        $return{'log_message'}   = 'Registration Error: Invalid user_type provided: >' . $user_type . '<.';
        return \%return;
    }
    if ( defined $it_exists && ref( $it_exists ) eq 'HASH' )
    {
        $return{'error_message'} = 'The username >' . $username . '< already exists.  You will have to choose a different one.';
        $return{'log_message'}   = 'Registration Error: Username >' . $username . '< already exists in >' . $user_type . '<  database.';
        return \%return;
    }

    # Ensure password and password_confirm match
    if ( $password ne $password2 )
    {
        $return{'error_message'} = 'Password and Password Confirm must match one another.';
        $return{'log_message'}   = 'Registration Error: Password and Password Confirm do not match.';
        return \%return;
    }

    # Ensure that the e-mail address is valid in construction.
    try
    {
        my $is_valid = Email::Valid->address(
                                                -address  => $email,
                                                -mxcheck  => 1,
                                                -tldcheck => 1,
                                            );
    }
    catch
    {
        $return{'error_message'} = 'Your e-mail address does not appear to be valid. Is it spelled correctly?';
        $return{'log_message'}   = 'Registration Error: Email address >' . $email . '< failed validity check: ' .
                                    $Email::Valid::Details . ': ' . $_;
        return \%return;
    };

    # Everything passes. Save the account.
    my $saved = '';
    my $enc_password = passphrase( $password )->generate;
    my %account_data = (
                            id         => undef,
                            username   => $username,
                            full_name  => $full_name,
                            email      => $email,
                            password   => $enc_password->rfc2307(),
                            created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                       );

    if ( uc( $user_type ) eq 'USER' )
    {
        $saved = Cater::User->insert( \%account_data );
    }
    elsif ( uc( $user_type ) eq 'MARKETER' )
    {
        $saved = Cater::Marketer->insert( \%account_data );
    }
    elsif ( uc( $user_type ) eq 'CLIENT' )
    {
        $saved = Cater::Client->insert( \%account_data );
    }

    debug Data::Dumper::Dumper( $saved );

    if ( not defined $saved->id )
    {
        $return{'error_message'} = 'An error occured in saving your account. Please try again.';
        $return{'log_message'}   = 'Registration Error: Account could not be saved for username >' .
                                        $username . '<: ' . Data::Dumper::Dumper( \%account_data );
        return \%return;
    }
    else
    {
        $return{'success'} = 1;
        return \%return;
    }
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
