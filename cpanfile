# cpanfile
requires 'perl', '>= 5.18.2';

requires 'Dancer2',                     '0.163000';
requires 'Dancer2::Session::YAML',      '0.165000';
requires 'Dancer2::Plugin::Passphrase', '3.2.2';
requires 'Dancer2::Plugin::DBIC',       '0.0011';
requires 'Dancer2::Plugin::Emailesque', '0.03';
requires 'Locale::Country',             '3.36';
requires 'Net::LibIDN',                 '0.12';
requires 'Net::DNS',                    '1.04';
requires 'Net::SSLeay',                 '1.72';
requires 'Net::SMTP::SSL',              '1.03';
requires 'Net::SMTP::TLS',              '0.12';
requires 'IO::Socket::SSL',             '2.022';
requires 'DBI',                         '1.634';
requires 'DBD::mysql',                  '4.033';
requires 'DBIx::Class',                 '0.082820';
requires 'Const::Fast',                 '0.014';
requires 'Time::Piece',                 '1.31';
requires 'version',                     '0.9912';
requires 'Email::Valid',                '1.198';
requires 'Try::Tiny',                   '0.24';
requires 'DateTime',                    '1.21';
requires 'Emailesque',                  '1.26';

on 'develop' => sub
{
    requires   'Database::Migrator';
    recommends 'Devel::NYTProf';
};

on 'test' => sub
{
    requires   'Test::More';
    requires   'Data::Faker';
    requires   'Plack::Test';
    requires   'HTTP::Request::Common';
    requires   'HTTP::Cookies';
};
