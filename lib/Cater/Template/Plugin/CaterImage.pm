package Cater::Template::Plugin::CaterImage;

use base qw( Template::Plugin );
use Template::Plugin;
use Dancer2 appname => 'Cater';

use Cater::Image;

sub load
{
    my ( $class, $context ) = @_;

    return $class;
}

sub new
{
    my ( $class, $context, @params ) = @_;

    bless
    {
        _CONTEXT => $context,
    }, $class;
}

sub get_image_thumbnail
{
    my ( $self, $params ) = @_;

    my $original = delete $params->{'original'} // undef;
    my $size     = delete $params->{'size'}     // 'small';

    return '' if not defined $original;

    my $thumbnail_rv = Cater::Image->get_image_thumbnail( original => $original, size => $size );

    if ( $thumbnail_rv->{'success'} )
    {
        return $thumbnail_rv->{'thumbnail'};
    }

    return '';
}

sub get_random_default_thumbnail
{
    my ( $self, $params ) = @_;

    my $user_type = delete $params->{'type'} // undef;
    my $size      = delete $params->{'size'} // 'small';

    return '' if not defined $user_type;

    my $thumbnail_rv = Cater::Image->get_random_default_thumbnail( user_type => $user_type, size => $size );

    if ( $thumbnail_rv->{'success'} )
    {
        return $thumbnail_rv->{'thumbnail'};
    }

    return '';
}

1;
