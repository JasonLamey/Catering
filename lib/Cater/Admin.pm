package Cater::Admin;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Dancer2::Plugin::Passphrase;

use Email::Valid;
use Try::Tiny;
use DateTime;
use Const::Fast;
use Data::Dumper;

use version; our $VERSION = qv( "v0.1.0" );

use Cater::DBSchema;

const my $SCHEMA => Cater::DBSchema->get_schema_connection();
$SCHEMA->storage->debug(1);   # UNCOMMENT IN ORDER TO DUMP SQL DEBUG MESSAGES TO LOGS

=head1 NAME

Cater::Admin

=head1 DESCRIPTION AND SYNOPSIS

This module handles all of Admin-related calls and functions.

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

    my %return  = ( success => 0, error_message => '', log_message => '' );

    # If we're missing a username or password, let's fail it right now.
    if ( not defined $username )
    {
        $return{'error_message'} = 'You must provide a username.';
        $return{'log_message'}   = 'Failed Admin Login: Username not defined.';
        return \%return;
    }
    if ( not defined $password )
    {
        $return{'error_message'} = 'You must provide a password.';
        $return{'log_message'}   = 'Failed Admin Login: Password not defined.';
        return \%return;
    }

    my $account = $SCHEMA->resultset('Admin')->find( { username => $username } );

    unless ( defined $account && ref( $account ) eq 'Cater::DBSchema::Result::Admin' ) # TODO: Ensure that the object returned is the proper kind of object.
    {
        $return{'error_message'} = 'Invalid username or password.  Please try again.';
        $return{'log_message'}   = "Failed Admin Login: No such account found for admin login: account >$username< / password >$password< .";
        return \%return;
    }

    # Encrypt the supplied password to see if it matches the found account.
    if ( ! passphrase( $password )->matches( $account->password ) )
    {
        $return{'error_message'} = 'Invalid username or password.  Please try again.';
        $return{'log_message'}   = "Failed Admin Login: Invalid password provided for admin login: account >$username< / password >$password< .";
        return \%return;
    }

    # All is good, log the user in.
    $return{'success'} = 1;
    return \%return;
}


=head2 get_index_stats()

Returns a hashref of site-related stats for quick reference on the Admin index page.

=over 4

=item Input: None.

=item Output: Returns a hashref containing status values.

=back

    my $stats = Cater::Admin->get_index_stats();

=cut

sub get_index_stats
{
    my ( $self ) = @_;

    my %stats = ();

    # USER STATS:
    # Num Users
    $stats{'num_users'}     = $SCHEMA->resultset('User')->search( {} )->count();
    # Num Clients
    $stats{'num_clients'}   = $SCHEMA->resultset('Client')->search( {} )->count();
    # Num Marketers
    $stats{'num_marketers'} = $SCHEMA->resultset('Marketer')->search( {} )->count();

    return \%stats;
}


=head2 get_admin_user()

Returns the admin user object for the supplied admin username.

=over 4

=item Input: Hash containing a C<username> key with the admin's username as the value.

=item Output: The Admin object found.

=back

    my $admin_user = Cater::Admin->get_admin_user( username => $username );

=cut

sub get_admin_user
{
    my ( $self, %params ) = @_;
    my $username = delete $params{'username'} // undef;

    return if ( not defined $username );

    my $admin_user = $SCHEMA->resultset( 'Admin' )->find( { username => $username } );

    return $admin_user;
}


=head2 get_all_caterers()

Returns all found clients from the database.

=over 4

=item Input: None (at this time)

=item Output: An arrayref containing all records found.

=back

    my $caterers = Cater::Admin->get_all_caterers();

=cut

sub get_all_caterers
{
    my ( $self, %params ) = @_;

    my @caterers = $SCHEMA->resultset( 'Client' )->search( undef, { order_by => { -asc => [ qw/ company poc_name / ] } } );

    return \@caterers;
}


1;
