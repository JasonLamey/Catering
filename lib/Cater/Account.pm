package Cater::Account;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;
use Data::Dumper;

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

Looks up the account in question and returns the account object, uses the DBIx::Class find method.

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
    if (
            not defined $query
            or
            (
                ref( $query ) ne 'HASH'
                and
                ref( $query ) ne 'ARRAY'
            )
        )
    {
        $return{'error_message'} = 'An error occurred while trying to retrieve Account data.';
        $return{'log_message'}   = "Failed Find Account: Invalid or undefined query provided. Received >" .
                                    Dumper( $query ) . "<.";
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
        $return{'log_message'}   = "Failed Find Account: Could not find account within >$user_type< accounts. Query: >" .
                                    Dumper( $query ) . "<";
        return \%return;
    }

    $return{'success'} = 1;
    $return{'account'} = $account;

    return \%return;
}


=head2 search_account()

Looks up the account in question and returns the account object, using the DBIx::Class search method.

=over 4

=item Input: a hashref or arrayref to be passed to the search method, with the appropriate query parameters, and a hash containing the C<user_type>.

=item Output: A hashref containing [ C<success>, C<log_message>, C<error_message>, and C<account> (An account object) ]

=back

    my $account = Cater::Account->search_account( [ { username => $username }, { email => $email } ], user_type => $user_type );

=cut

sub search_account
{
    my ( $self, $query, %params ) = @_;

    my $user_type = delete $params{'user_type'} // undef;

    my %return = ( success => 0, log_message => '', error_message => '' );
    if (
            not defined $query
            or
            (
                ref( $query ) ne 'HASH'
                and
                ref( $query ) ne 'ARRAY'
            )
        )
    {
        $return{'error_message'} = 'An error occurred while trying to retrieve Account data.';
        $return{'log_message'}   = "Failed Search Account: Invalid or undefined query provided. Received >" .
                                    Dumper( $query ) . "<.";
        return \%return;
    }

    my $account = undef;
    # Look up username and verify password based on the login-type.
    if ( uc( $user_type ) eq 'USER' )
    {
        $account = $SCHEMA->resultset('User')->search( $query );
    }
    elsif ( uc( $user_type ) eq 'MARKETER' )
    {
        $account = $SCHEMA->resultset('Marketer')->search( $query );
    }
    elsif ( uc( $user_type ) eq 'CLIENT' )
    {
        $account = $SCHEMA->resultset('Client')->search( $query );
    }
    else
    {
        $return{'error_message'} = 'Please select either a User account, Client account, or Marketer account.';
        $return{'log_message'}   = "Failed Search Account: Invalid user type. Received >$user_type<.";
        return \%return;
    }

    if ( not defined $account )
    {
        $return{'error_message'} = 'Invalid username, password, or user type.  Please try again.';
        $return{'log_message'}   = "Failed Search Account: Could not find account within >$user_type< accounts. Query: >" .
                                    Dumper( $query ) . "<.";
        return \%return;
    }

    $return{'success'} = 1;
    $return{'account'} = $account;

    return \%return;
}


=head2 save_basic_account_data()

Saves the basic, initial registration data for any account type.

=over 4

=item Input: A hashref containing [ C<username>, C<full_name>, C<poc_name>, C<email>, C<password> ], and a hash of C<user_type>.

=item Output: A hashref containing [ C<success>, C<error_message>, C<log_message>, C<account> (account object) ]

=back

    my $saved = Cater::Account->save_basic_account_data( \%account_data, user_type => $user_type );

=cut

sub save_basic_account_data
{
    my ( $self, $account_data, %params ) = @_;

    my $user_type = delete $params{'user_type'} // undef;

    my %return = ( success => 0, log_message => '', error_message => '' );

    if ( not defined $user_type )
    {
        $return{'log_message'} = 'Failed Basic Acct Save: Undefined user type.';
        $return{'error_message'} = 'There was an error in saving your account information. Please try again later.';
        return \%return;
    }

    if ( not defined $account_data or ref( $account_data ) ne 'HASH' )
    {
        $return{'log_message'} = 'Failed Basic Acct Save: Undefined or invalid account_data provided: >' . Dumper( $account_data ) . '<.';
        $return{'error_message'} = 'There was an error in saving your account information. Please try again later.';
        return \%return;
    }

    my $saved = '';
    if ( uc( $user_type ) eq 'USER' )
    {
        delete $account_data->{'poc_name'};
        $saved = $SCHEMA->resultset('User')->create( $account_data );
    }
    elsif ( uc( $user_type ) eq 'MARKETER' )
    {
        delete $account_data->{'full_name'};
        $saved = $SCHEMA->resultset('Marketer')->create( $account_data );
    }
    elsif ( uc( $user_type ) eq 'CLIENT' )
    {
        delete $account_data->{'full_name'};
        $saved = $SCHEMA->resultset('Client')->create( $account_data );
    }

    $return{'success'} = 1;
    $return{'saved'}   = $saved;

    return \%return;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
