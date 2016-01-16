package Cater::Account;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.0" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();


=head1 NAME

Cater::Account


=head1 DESCRIPTION AND SYNOPSIS

Module provides an abstraction layer between the three different types of accounts in the app, so that
calls are more uniform and to reduce repetition of code.


=head1 METHODS


=head2 find_account()

Looks up the account in question and returns the account object.

=over 4

=item Input: a hashref to be passed to the find method, with the appropriate query parameters, and a hash containing the C<user_type>.

=item Output: A hashref containing [ C<success>, C<log_message>, C<error_message>, and C<account> (An account object) ]

=back

    my $account = Cater::Account->find_account( { username => $username }, user_type => $user_type );

=cut

sub find_account
{
    my ( $self, $query, %params ) = @_;

    my $user_type = delete $params{'user_type'} // undef;

    my %return = ( success => 0, log_message => '', error_message => '' );
    if ( not defined $query or ref( $query ) ne 'HASH' )
    {
        $return{'error_message'} = 'An error occurred while trying to retrieve Account data.';
        $return{'log_message'}   = "Failed Find Account: Invalid or undefined query provided. Received >$query<.";
        return \%return;
    }

    my $account = undef;
    # Look up username and verify password based on the login-type.
    if ( uc( $user_type ) eq 'USER' )
    {
        $account = $SCHEMA->resultset('User')->find( $query );
    }
    elsif ( uc( $user_type ) eq 'MARKETER' )
    {
        $account = $SCHEMA->resultset('Marketer')->find( $query );
    }
    elsif ( uc( $user_type ) eq 'CLIENT' )
    {
        $account = $SCHEMA->resultset('Client')->find( $query );
    }
    else
    {
        $return{'error_message'} = 'Please select either a User account, Client account, or Marketer account.';
        $return{'log_message'}   = "Failed Find Account: Invalid user type. Received >$user_type<.";
        return \%return;
    }

    if ( not defined $account )
    {
        $return{'error_message'} = 'Invalid username, password, or user type.  Please try again.';
        $return{'log_message'}   = "Failed Find Account: Could not find account >$username< within >$user_type< accounts.";
        return \%return;
    }

    $return{'success'} = 1;
    $return{'account'} = $account;

    return \%return;
}

1;
