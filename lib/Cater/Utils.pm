package Cater::Utils;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use POSIX;
use Data::Dumper;

use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::Account


=head1 DESCRIPTION AND SYNOPSIS

Module provides a number of helper methods for use on the site.


=head1 METHODS


=head2 calculate_pagination()

Calculates pagination values such as last page, pagination start, pagination end, total pages based
on total row count, current page, and rows per page.

=over 4

=item Input: A hashref containing [ C<row_count>, C<page>, C<per_page> ].

=item Output: A hashref containing the above plus [ C<last_page>, C<pagination_start>, C<pagination_end> ]

=back

    my $pagination = Cater::Utils->calculate_pagination(
                                                        row_count => $row_count,
                                                        page      => $page,
                                                        per_page  => $per_page,
                                                       );

=cut

sub calculate_pagination
{
    my ( $self, %params ) = @_;

    my $row_count = delete $params{'row_count'} // 0;
    my $page      = delete $params{'page'}      // 1;
    my $per_page  = delete $params{'per_page'}  // 25;

    my %pagination = (
                        row_count        => $row_count,
                        page             => $page,
                        per_page         => $per_page,
                        last_page        => 1,
                        pagination_start => 1,
                        pagination_end   => 1,
                     );

    if ( $row_count < $per_page )
    {
        return \%pagination;
    }

    if ( $row_count > $per_page )
    {
        $pagination{'last_page'} = POSIX::ceil( $row_count / $per_page );
    }

    if ( $page > 5 )
    {
        $pagination{'pagination_start'} = int( $page - 5 );
    }

    if ( $page < ( $pagination{'last_page'} - 5 ) )
    {
        $pagination{'pagination_end'} = int( $pagination{'last_page'} - 5 );
    }
    else
    {
        $pagination{'pagination_end'} = $pagination{'last_page'};
    }

    return \%pagination;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
