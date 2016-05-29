#!/usr/bin/env perl

use strict;
use warnings;

use v5.18;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Dancer2 appname => 'Cater';
use Dancer2::Plugin::Passphrase;
use Const::Fast;
use Data::Dumper;
use Data::Faker;
use DateTime;
use WWW::Lipsum;

use Cater::DBSchema;

use version; our $VERSION = qv( "v0.1.0" );

const my $SCHEMA => Cater::DBSchema->get_schema_connection();
const my $NUM_CATERERS      => 20;
const my $NUM_MARKETERS     => 20;
const my $NUM_USERS         => 20;
const my $MAX_NUM_ADS       => 5;
const my $MAX_NUM_REVIEWS   => 10;
const my $MAX_NUM_BOOKMARKS => 5;

# SEE https://metacpan.org/pod/Data::Faker FOR DETAILS ON HOW TO MAKE CUSTOM PLUGINS IF NEEDED.

my $faker = Data::Faker->new();

populate_caterers();
populate_marketers();
populate_users();
populate_caterer_listings();
populate_caterer_locations();
populate_marketer_ads();
#populate_user_bookmarks();
#populate_caterer_reviews();

# ---------------------------------

sub populate_caterers
{
    say 'Creating Caterer Accounts...';
    my $num_created = 0;

    for ( 1..$NUM_CATERERS )
    {
        my $new_caterer = {
                            username   => $faker->username,
                            password   => passphrase( 'test' )->generate->rfc2307(),
                            poc_name   => $faker->name,
                            company    => $faker->company,
                            email      => $faker->email,
                            phone      => $faker->phone_number,
                            street1    => $faker->street_address,
                            city       => $faker->city,
                            state      => $faker->us_state_abbr,
                            country    => 'US',
                            zip        => $faker->us_zip_code,
                            confirmed  => 1,
                            created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                          };

        my $added_caterer = $SCHEMA->resultset( 'Client' )->new( $new_caterer );
        $SCHEMA->txn_do( sub
                            {
                                $added_caterer->insert
                            }
                        );
        $num_created++;
    }

    say "\tTotal Caterer Accounts Created: $num_created";
}

sub populate_marketers
{
    say 'Creating Marketer Accounts...';
    my $num_created = 0;

    for ( 1..$NUM_MARKETERS )
    {
        my $new_marketer = {
                            username   => $faker->username,
                            password   => passphrase( 'test' )->generate->rfc2307(),
                            poc_name   => $faker->name,
                            company    => $faker->company,
                            email      => $faker->email,
                            phone      => $faker->phone_number,
                            street1    => $faker->street_address,
                            city       => $faker->city,
                            state      => $faker->us_state_abbr,
                            country    => 'US',
                            zip        => $faker->us_zip_code,
                            confirmed  => 1,
                            created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                          };

        my $added_marketer = $SCHEMA->resultset( 'Marketer' )->new( $new_marketer );
        $SCHEMA->txn_do( sub
                            {
                                $added_marketer->insert
                            }
                        );
        $num_created++;
    }

    say "\tTotal Marketer Accounts Created: $num_created";
}

sub populate_users
{
    say 'Creating User Accounts...';
    my $num_created = 0;

    for ( 1..$NUM_USERS )
    {
        my $new_user = {
                            username   => $faker->username,
                            password   => passphrase( 'test' )->generate->rfc2307(),
                            full_name  => $faker->name,
                            email      => $faker->email,
                            confirmed  => 1,
                            created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                          };

        my $added_user = $SCHEMA->resultset( 'User' )->new( $new_user );
        $SCHEMA->txn_do( sub
                            {
                                $added_user->insert
                            }
                        );
        $num_created++;
    }

    say "\tTotal User Accounts Created: $num_created";
}

sub populate_caterer_listings
{
    my $num_created = 0;
    say 'Fetching Caterer Accounts To Create Listings...';

    my $caterer_rs = $SCHEMA->resultset( 'Client' )->search( undef, { order_by => { -asc => 'company' } } );

    while ( my $caterer = $caterer_rs->next )
    {
        my $lipsum = WWW::Lipsum->new();
        # Create slogan text.
        my $slogan = $lipsum->generate( what => 'words', amount => 10, start => 0 ) or die $lipsum->error;
        # Create about text.
        my $about  = $lipsum->generate( what => 'paras', amount => 2, html => 1, start => 0 ) or die $lipsum->error;
        # Create special offer.
        my $special_offer = undef;
        my $make_so = int( rand( 2 ) );
        if ( $make_so == 1 )
        {
            $special_offer = $lipsum->generate( what => 'words', amount => 20, html => 0, start => 0 ) or die $lipsum->error;
        }

        my $new_listing = {
                             company       => $caterer->company,
                             slogan        => $slogan,
                             about         => $about,
                             cuisine_types => '',
                             special_offer => $special_offer,
                             created_on    => DateTime->now( time_zone => 'UTC' )->datetime,
                          };

        $caterer->create_related( 'listing', $new_listing );
        $num_created++;
    }
    say "\tTotal Caterer Listings Created: $num_created";
}

sub populate_caterer_locations
{
    my $num_created = 0;
    say 'Fetching Caterer Accounts To Create Locations...';

    my $caterer_rs = $SCHEMA->resultset( 'Client' )->search( undef, { order_by => { -asc => 'company' } } );

    while ( my $caterer = $caterer_rs->next )
    {
        my $make_loc = int( rand( 5 ) ) + 1;
        for ( 1..$make_loc )
        {
            my $new_location = {
                                name    => $faker->city,
                                phone   => $faker->phone_number,
                                street1 => $faker->street_address,
                                city    => $faker->city,
                                state   => $faker->us_state_abbr,
                                postal  => $faker->us_zip_code,
                                country => 'US',
                                email   => $faker->email,
                                website => $faker->domain_name,
                                created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                              };

            $caterer->create_related( 'locations', $new_location );
            $num_created++;
        }
    }
    say "\tTotal Caterer Listings Created: $num_created";
}

sub populate_marketer_ads
{
    my $num_created = 0;
    say 'Fetching Marketer Accounts To Create Ads...';

    my $marketer_rs = $SCHEMA->resultset( 'Marketer' )->search( undef, { order_by => { -asc => 'company' } } );

    while ( my $marketer = $marketer_rs->next )
    {
        my $make_ad = int( rand( 5 ) ) + 1;
        for ( 1..$make_ad )
        {
            my $lipsum = WWW::Lipsum->new();
            # Create headline text.
            my $headline = $lipsum->generate( what => 'words', amount => 10, start => 0 ) or die $lipsum->error;
            # Create body text.
            my $body     = $lipsum->generate( what => 'paras', amount => 2, html => 1, start => 0 ) or die $lipsum->error;
            my $new_advert = {
                                headline => $headline,
                                body     => $body,
                                phone    => $faker->phone_number,
                                email    => $faker->email,
                                website  => $faker->domain_name,
                                created_on => DateTime->now( time_zone => 'UTC' )->datetime,
                              };

            $marketer->create_related( 'advertisements', $new_advert );
            $num_created++;
        }
    }
    say "\tTotal Marketer Advertisements Created: $num_created";
}
