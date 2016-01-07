package Cater::Login;

use Dancer2 appname => 'Cater';
use Dancer2::Plugin::Passphrase;

use Cater::User;
use Cater::Marketer;
use Cater::Client;

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
    my ( $self, $params ) = @_;

    my $username   = $params->{'username'}   // undef;
    my $password   = $params->{'password'}   // undef;
    my $login_type = $params->{'login_type'} // 'User';

    my %return  = ( success => 0, error_message => '', log_message => '' );
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
        $return{'error_message'} = 'Invalid user type. Cannot login.';
        $return{'log_message'}   = "Failed Login: Invalid user type. Received >$login_type<.";
        # TODO: Log bad user-type
        return \%return;
    }

    if ( not defined $account )
    {
        $return{'error_message'} = 'Invalid username or password.  Please try again.';
        $return{'log_message'}   = "Failed Login: Could not find account >$username< within >$login_type< accounts.";
        # TODO: Log bad username
        return \%return;
    }

    # Encrypt the supplied password to see if it matches the found account.
    my $enc_password = passphrase( $password )->generate;

    if ( $enc_password ne $account->{'password'} )
    {
        $return{'error_message'} = 'Invalid username or password.  Please try again.';
        $return{'log_message'}   = "Failed Login: Invalid password provided for account >$username< within >$login_type< accounts.";
        # TODO: Log bad password
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
    my ( $self, $params ) = @_;

    my $string_length = delete $params->{'string_length'} // 32;
    my $char_set      = delete $params->{'char_set'}      // ['a'..'z', 'A'..'Z', 0..9];

    return passphrase->generate_random( { length => $string_length, charset => $char_set } );
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
