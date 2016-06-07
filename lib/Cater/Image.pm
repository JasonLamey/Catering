package Cater::Image;

use strict;
use warnings;

use Dancer2 appname => 'Cater';
use Const::Fast;
use Data::Dumper;
use File::Basename;
use File::DirList;
use FindBin;
use Image::Thumbnail;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.0" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();
const my %IMAGE_SIZES   => (
                            small  => 100,
                            medium => 250,
                            large  => 400,
                           );
const my $IMAGE_DIR            => "$FindBin::Bin/../public/images/";
const my $CACHED_THUMBNAIL_DIR => $IMAGE_DIR . 'cached_thumbs/';
const my $USER_IMAGE_DIR       => $IMAGE_DIR . 'user_images/';
const my $DEFAULT_IMAGE_DIR    => $IMAGE_DIR . 'default/';
const my $IMAGE_UPLOAD_DIR     => "$FindBin::Bin/../public/uploads/";


=head1 NAME

Cater::Image


=head1 DESCRIPTION AND SYNOPSIS

Module provides a library of image tools for handling images.


=head1 METHODS


=head2 get_random_default_thumbnail()

Returns a string which is the PATH to a default thumbnail image.

=over 4

=item Input: A hash containing [ C<user_type>, C<size> ], where C<user_type> is the type of user, and C<size> is the size name in the size hash.

=item Output: A hashref containing a success code, error message, and string containing the path to the thumbnail file.

=cut

sub get_random_default_thumbnail
{
    my ( $self, %params ) = @_;

    my $user_type = delete $params{'user_type'} // undef;
    my $size      = delete $params{'size'}      // 'small';

    if ( not defined $user_type )
    {
        return { success => 0, error => "Missing or invalid user_type: >" . ( $user_type // '' ) . "<", thumbnail => undef };
    }

    my @image_list = File::DirList::list( $DEFAULT_IMAGE_DIR . $user_type . '/', 'n', 1, 1, 0 );

    my $max_index = scalar @{ $image_list[0] };

    my $image_pick = $image_list[0][ int( rand( $max_index ) ) ];
    my $image_name = $image_pick->[13]; # Image name in the array of returned values.
    my $image_path = $DEFAULT_IMAGE_DIR . $user_type . '/' . $image_name;

    my $thumbnail_rv = Cater::Image->get_image_thumbnail( original => $image_path, size => $size );

    return $thumbnail_rv;
}


=head2 get_image_thumbnail()

Returns an string which is the PATH to the thumbnail image. If there isn't a an existing thumbnail, one will be created before returning the PATH.

=over 4

=item Input: A hash containing [ C<original>, C<size> ], where C<original> is the path to the original image, and C<size> refers to a size name in the size hash [C<small>, C<medium>, C<large>].

=item Output: A hashref containing a success code, error message, and string containing the path to the thumbnail file.

=back

    my $thumbnail_rv = Cater::Image->get_image_thumbnail( original => $image_path, size => $size );

=cut

sub get_image_thumbnail
{
    my ( $self, %params ) = @_;

    my $original = delete $params{'original'} // undef;
    my $size     = delete $params{'size'}     // 'small';

    if ( not defined $original )
    {
        return { success => 0, error => 'Undefined original image path.', thumbnail => undef };
    }

    if ( ! -e $original )
    {
        return { success => 0, error => 'Original path file not found.', thumbnail => undef };
    }

    my $thumbpath = Cater::Image->generate_thumbnail_path( original => $original, size => $size );

    my $clean_thumbpath = $thumbpath;
    $clean_thumbpath =~ s/^.*\/public(.*)/$1/;

    if ( ! -e $thumbpath )
    {
        # Create thumbnail
        my $created_rv = Cater::Image->generate_thumbnail( original => $original, thumbnail => $thumbpath, size => $size );

        if ( not $created_rv->{'success'} or not -e $thumbpath )
        {
            return { success => 0, error => 'An error occurred. Could not create the thumbnail.', thumbnail => undef };
        }
    }

    return { success => 1, error => undef, thumbnail => $clean_thumbpath };
}


=head2 generate_thumbnail()

Creates a thumbnail image, based on the original image handed to it.

=over 4

=item Input: A hash containing [ C<original>, C<thumbnail>, C<size> ], where C<original> is the path to the original image, C<thumbnail> is the path to where to save the thumbnail, and C<size> refers to the size in the size hash [ C<small>, C<medium>, C<large> ].

=item Output: A hashref containing a success code, error message.

=back

    my $generated_rv = Cater::Image->generate_thumbnail( original => $original, thumbnail => $thumbnail, size => $size );

=cut

sub generate_thumbnail
{
    my ( $self, %params ) = @_;

    my $original  = delete $params{'original'}  // undef;
    my $thumbnail = delete $params{'thumbnail'} // undef;
    my $size      = delete $params{'size'}      // 'small';

    $size = 'small' if ( lc($size) ne 'small' and lc($size) ne 'medium' and lc($size) ne 'large' );

    return { success => 0, error => 'Invalid or undefined original file path provided.' }  if not defined $original;
    return { success => 0, error => 'Nonexistent original file or file not found.' }       if not -e $original;
    return { success => 0, error => 'Invalid or undefined thumbnail file path provided.' } if not defined $thumbnail;

    my $thumb     = new Image::Thumbnail(
                                            module     => 'Imager',
                                            size       => $IMAGE_SIZES{$size},
                                            quality    => 100,
                                            create     => 1,
                                            input      => $original,
                                            outputpath => $thumbnail,
                                        );

    if ( $thumb->{'error'} )
    {
        return { success => 0, error => $thumb->{'error'} };
    }

    return { success => 1, error => '' };
}


=head2 generate_thumbnail_path()

Returns a string containing the PATH to the thumbnail image, based on the original filename, and size.

=over 4

=item Input: A hash containing [ C<original>, C<size> ], where C<original> is the original path or filename of the image, and C<size> is the size name.

=item Output: A string containing the generated PATH.

=back

    my $thumbnail_path = Cater::Image->generate_thumbnail_path( original => $original, size => $size );

=cut

sub generate_thumbnail_path
{
    my ( $self, %params ) = @_;

    my $original = delete $params{'original'} // undef;
    my $size     = delete $params{'size'}     // 'small';

    my ( $filename, $path, $suffix ) = File::Basename::fileparse( $original, qr/\.[^.]*/ );

    my $thumbpath = $CACHED_THUMBNAIL_DIR . $filename . '_' . lc($size) . $suffix;

    return $thumbpath;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2016 by Jason Lamey

This library is for use by Catering. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
