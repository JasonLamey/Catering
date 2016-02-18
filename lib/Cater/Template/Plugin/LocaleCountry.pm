package Cater::Template::Plugin::LocaleCountry;

use base qw( Template::Plugin );
use Template::Plugin;

use Locale::Country;

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

sub country2code
{
    my ( $self, $country ) = @_;

    return Locale::Country::country2code( $country, 'alpha-2' );
}

sub code2country
{
    my ( $self, $code ) = @_;

    return Locale::Country::code2country( $code, 'alpha-2' );
}

1;
