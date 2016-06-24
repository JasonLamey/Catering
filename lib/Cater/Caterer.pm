package Cater::Caterer;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;
use Data::Dumper;
use DateTime;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.3" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();


=head1 NAME

Cater::Caterer


=head1 DESCRIPTION AND SYNOPSIS

Module provides a library of caterer-related functionality for use throughout the whole site.


=head1 METHODS


=head2 get_all_cuisine_types()

Returns an arrayref of all known cuisine types in the database.

=over 4

=item Input: None

=item Output: An arrayref containing [ C<name>, C<sort_by> ]

=back

    my $cuisines = Cater::Caterer->get_all_cuisine_types();

=cut

sub get_all_cuisine_types
{
    my ( $self ) = @_;

    my @cuisines = $SCHEMA->resultset('CuisineType')->search(
        undef,
        {
            order_by => { -asc => 'sort_by' },
        },
    );

    return \@cuisines;
}


=head2 get_random_caterers()

Returns an array of Clients, either matched to a zip, or chosen at random if a zip is unavailable or undetectable.

=over 4

=item Input: A hash containing [ C<zipcodes>, C<max_caterers> ], where C<zipcodes> is an arrayref of zipcodes (default undef), and C<max_caterers> is the max caterers returned (default 3).

=item Output: An array containing Client objects.

=back

    my @caterers = Cater::Caterer->get_random_caterers( zip => $zip, max_caterers => $max_caterers );

=cut

sub get_random_caterers
{
    my ( $self, %params ) = @_;

    my $zipcodes     = delete $params{'zipcodes'}     // undef;
    my $max_caterers = delete $params{'max_caterers'} // 3;

    my %where = ();
    if ( defined $zipcodes )
    {
        $where{zip}{'-in'} = $zipcodes;
    }

    my @caterers = $SCHEMA->resultset('Client')->search(
        \%where,
        {
            order_by => \"RAND()",
            rows     => $max_caterers,
        },
    );

    return @caterers;
}


=head2 get_caterer_by_id()

Return a Cater::Client object for the specified ID.  Returns C<undef> if none are found.

=over 4

=item Input: An integer containing the ID to search for.

=item Output: A Cater::Client object, or C<undef> if nothing is found.

=back

    my $caterer = Cater::Caterer->get_caterer_by_id( $id );

=cut

sub get_caterer_by_id
{
    my ( $self, $user_id ) = @_;

    return undef if not defined $user_id;
    return undef if $user_id !~ /^\d+$/;

    my $caterer = $SCHEMA->resultset('Client')->find( $user_id );

    return $caterer;
}


=head2 add_view()

Increment a Client's view count for the current date.

=over 4

=item Input: An integer containing the ID to search for.

=item Output: Boolean denoting success.

=back

    my $counted = Cater::Caterer->add_view( $id );

=cut

sub add_view
{
    my ( $self, $user_id ) = @_;

    return undef if not defined $user_id;
    return undef if $user_id !~ /^\d+$/;

    my $view_count = $SCHEMA->resultset('CatererView')->find_or_create(
                                                                        {
                                                                            client_id => $user_id,
                                                                            date      => DateTime->now( time_zone => 'UTC' )->date,
                                                                        }
                                                                      );
    $view_count->update( { count => \'count + 1' } );

    return 1;
}


=head2 get_account_stats()

Fetches all pertinent account performance statistics.

=over 4

=item Input: An integer containing the ID for the user.

=item Output: A hashref, keyed on each stat [ C<total_views>, C<week_views>, C<total_bookmarks>, C<week_bookmarks>, C<today_leads>, C<week_leads>, C<month_leads> ].

=back

    my $stats = Cater::Caterer->get_account_stats( $id );

=cut

sub get_account_stats
{
    my ( $self, $user_id ) = @_;

    return undef if not defined $user_id;
    return undef if $user_id !~ /^\d+$/;

    my %stats = ();

    # Create relative dates.
    my $today       = DateTime->now( time_zone => 'UTC' );
    my $week_begin  = $today->clone();
    my $month_begin = $today->clone();

    $today = $today->date();

    # Calculate beginning of the week.
    my $day_of_week = $week_begin->day_of_week();
    $week_begin->subtract( days => $day_of_week % 7 );
    $week_begin = $week_begin->date();

    # Calculate the beginning of the month.
    $month_begin->set_day( 1 );
    $month_begin = $month_begin->date();

    my $total_views = $SCHEMA->resultset('CatererView')->search(
                                                                { client_id => $user_id },
                                                                {
                                                                    select => [ { sum => 'count' } ],
                                                                    as     => [ 'total_views' ],
                                                                }
                                                               );
    $stats{total_views} = $total_views->first->get_column('total_views');

    my $week_views = $SCHEMA->resultset('CatererView')->search(
                                                                {
                                                                    client_id => $user_id,
                                                                    date => [ -and => { '>=', $week_begin }, { '<=', $today } ]
                                                                },
                                                                {
                                                                    select => [ { sum => 'count' } ],
                                                                    as     => [ 'total_views' ],
                                                                }
                                                              );
    $stats{week_views} = $week_views->first->get_column('total_views');

    return \%stats;
}


=head2 bookmark_caterer()

Adds or removes a bookmark record for a User/Caterer.

=over 4

=item Input: Takes a hash containing [ C<caterer_id>, C<user_id>, and C<toggle> ]. Toggle is a 1 or -1, with 1 meaning add, and -1 meaning remove.

=item Output: A success boolean.

=back

    my $bookmarked = Cater::Caterer->bookmark_caterer( caterer_id => $caterer_id, user_id => $user_id, toggle => $toggle );

=cut

sub bookmark_caterer
{
    my ( $self, %params ) = @_;

    my $caterer_id = delete $params{'caterer_id'} // undef;
    my $user_id    = delete $params{'user_id'}    // undef;
    my $toggle     = delete $params{'toggle'}     // undef;

    if (
        not defined $caterer_id
        or
        not defined $user_id
        or
        not defined $toggle
    )
    {
        return 0;
    }

    if ( $toggle == 1 )
    {
        my $bookmark = $SCHEMA->resultset('UserBookmark')->create(
                                                                    {
                                                                        user_id    => $user_id,
                                                                        client_id  => $caterer_id,
                                                                        created_on => DateTime->now( time_zone => 'UTC' ),
                                                                    }
                                                                 );
        return 1;
    }
    else
    {
        $SCHEMA->resultset('UserBookmark')->search(
                                                    {
                                                        user_id   => $user_id,
                                                        client_id => $caterer_id,
                                                    }
                                                  )->delete;
        return 1;
    }

    return 0;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
