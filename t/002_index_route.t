use Test::More tests => 4;
use strict;
use warnings;

# the order is important
use Plack::Test;
use HTTP::Request::Common;

use_ok( 'Cater' );

# Create app
my $app = Cater->to_app;
isa_ok( $app, 'CODE' );

# Create a testing object.
my $test = Plack::Test->create( $app );

my $response = $test->request( GET '/' );
ok( $response->is_success, 'Successful request' );
like( $response->content, qr/Perl is dancing/, 'Correct response content' );
