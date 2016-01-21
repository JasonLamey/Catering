use Test::More tests => 3;
use strict;
use warnings;

# the order is important
use Plack::Test;
use HTTP::Request::Common;
use HTTP::Cookies;

use_ok( 'Cater' );

# Setup the test.
my $url  = 'http://localhost';
my $jar  = HTTP::Cookies->new();
my $test = Plack::Test->create( Cater->to_app );

# Create a login session
subtest 'Create User Session' => sub
{
    my $res = $test->request( GET "$url/login" );
    ok( $res->is_success, 'Successful Login' );

    $jar->extract_cookies( $res );
};

# Check session and logout
subtest 'Check User Session' => sub
{
    my $req = GET "$url/logout";

    # add cookies to the request
    $jar->add_cookie_header( $req );

    my $res = $test->request( $req );
    ok( $res->is_success, 'Successful Logout' );
    like( $res->content, qr/successfully logged out/i, 'Received correct logout content' );
};
