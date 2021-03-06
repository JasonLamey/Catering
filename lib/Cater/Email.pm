package Cater::Email;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Emailesque;

use Const::Fast;

const my $SYSTEM_FROM  => 'Catering Online System <cateringonline@gmail.com>';
const my %EMAIL_CONFIG => (
                            ssl    => 1,
                            driver => 'smtp',
                            host   => 'smtp.googlemail.com',
                            port   => 465,
                            user   => 'jasonlamey@gmail.com',
                            pass   => 'Phant0m9',
                          );

=head1 NAME

Cater::Email


=head1 SYNOPSIS AND DESCRIPTION

Functionality used for sending various e-mails to site users and admins.


=head1 METHODS


=head2 preflight_checklist()

Performs a series of basic pre-send error checks to ensure all necessary information for sending an e-mail
has been provided. These checks are common to all of the e-mail sending functions.

=over 4

=item Input: Takes a hash containing [ C<email>, C<username>, C<full_name>, C<email_type> ]. Email_type is the name of the e-mail being sent.

=item Output: Hashref containing [ C<success>, C<error_message>, C<log_message> ].  Success is an integer (0/1).

=back

    my $preflight = Cater::Email->preflight_checklist(
                                                       username   => $username,
                                                       email      => $email_address,
                                                       full_name  => $full_name,
                                                       email_type => $email_type,
                                                     );

=cut

sub preflight_checklist
{
    my ( $self, %params ) = @_;

    my $username   = delete $params{'username'}   // undef;
    my $full_name  = delete $params{'full_name'}  // undef;
    my $email      = delete $params{'email'}      // undef;
    my $email_type = delete $params{'email_type'} // 'E-mail';

    my %return = ( success => 0, log_message => '', error_message => '' );
    # Need a username or a full_name for addressing an e-mail to a recipient.
    if ( ( not defined $username ) and ( not defined $full_name ) )
    {
        $return{'error_message'} = "Could not send the $email_type because you didn't provide a username or full name.";
        $return{'log_message'}   = "Email Preflight Failed: Could not send $email_type because no username or full name was provided.";
        return \%return;
    }

    # Cannot send an e-mail without an e-mail address...
    if ( not defined $email )
    {
        $return{'error_message'} = "Could not send the $email_type because you didn't provide an e-mail address.";
        $return{'log_message'}   = "Email Preflight Failed: Could not send $email_type because no 'To:' e-mail address was provided.";
        return \%return;
    }

    # Nothing failed, let's return.
    $return{'success'} = 1;
    return \%return;
}


=head2 send_registration_confirmation()

Sends a new registrant an e-mail containing an account confirmation code used to activate their account
and confirm the validity of their e-mail address.

=over 4

=item Input: Takes a hash containing [ C<email>, C<ccode>, C<username>, C<full_name> ]

=item Output: Hashref containing [ C<success>, C<error_message>, C<log_message> ].  Success is an integer (0/1).

=back

    my $sent_email = Cater::Email->send_registration_confirmation(
                                                                    username  => $username,
                                                                    ccode     => $confirmation_code,
                                                                    email     => $email_address,
                                                                    full_name => $full_name,
                                                                 );

=cut

sub send_registration_confirmation
{
    my ( $self, %params ) = @_;

    my $username  = delete $params{'username'}  // undef;
    my $full_name = delete $params{'full_name'} // undef;
    my $email     = delete $params{'email'}     // undef;
    my $ccode     = delete $params{'ccode'}     // undef;

    my %return = ( success => 0, log_message => '', error_message => '' );

    # Must have a bare minimum of values to proceed.
    my $preflight = Cater::Email->preflight_checklist(
                                                        username   => $username,
                                                        full_name  => $full_name,
                                                        email      => $email,
                                                        email_type => 'Confirmation E-mail',
                                                     );

    if ( ! $preflight->{'success'} )
    {
        $return{'log_message'}   = $preflight->{'log_message'};
        $return{'error_message'} = $preflight->{'error_message'};
        return \%return;
    }

    my $send_email = Emailesque->new(
                                ssl     => $EMAIL_CONFIG{'ssl'},
                                driver  => $EMAIL_CONFIG{'driver'},
                                host    => $EMAIL_CONFIG{'host'},
                                port    => $EMAIL_CONFIG{'port'},
                                user    => $EMAIL_CONFIG{'user'},
                                pass    => $EMAIL_CONFIG{'pass'},
                                to      => Cater::Email->format_address(
                                                                        username  => $username,
                                                                        full_name => $full_name,
                                                                        email     => $email,
                                                                       ),
                                from    => $SYSTEM_FROM,
                                subject => 'Catering Site Registration Confirmation',
                                type    => 'html',
    );

    $send_email->send( { message => template( 'email/registration_confirm.tt', {
                                                                                username  => $username,
                                                                                full_name => $full_name,
                                                                                ccode     => $ccode,
                                                                               },
                                                                               { layout => undef },
                                            ),
                       }
    );

    $return{'success'} = 1;
    return \%return;
}


=head2 format_address()

Creates a valid To: e-mail address.  If a username or full name are provided, then an address in the format of C<Full Name E<lt>email@address.comE<gt>>
is provided. Otherwise, just the e-mail address is returned.  C<undef> is returned if no valid e-mail address is supplied.

=over 4

=item Input: Hash containing [C<username> (optional), C<full_name> (optional), and/or C<email>].

=item Ouptut: String containing the formatted e-mail address, or C<undef>.

=back

    my $to = Cater::Email->format_address( username => $username, full_name => $full_name, email => $email );

=cut

sub format_address
{
    my ( $self, %params ) = @_;

    my $username  = delete $params{'username'}  // undef;
    my $full_name = delete $params{'full_name'} // undef;
    my $email     = delete $params{'email'}     // undef;

    if ( not defined $email ) { return undef };

    if ( not defined $username && not defined $full_name )
    {
        return $email;
    }

    return ( defined $full_name ) ? "$full_name <$email>" : "$username <$email>";
}

1;
