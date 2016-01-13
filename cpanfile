# cpanfile
requires 'perl', '>= 5.18.2';

requires 'Dancer2',                     '0.163000';
requires 'Dancer2::Session::YAML',      '0.165000';
requires 'Dancer2::Plugin::Passphrase', '3.2.2';
requires 'Locale::Country',             '3.36';
requires 'DBI',                         '1.634';
requires 'DBD::mysql',                  '4.033';
requires 'Class::DBI',                  '3.0.17';
requires 'Const::Fast',                 '0.014';
requires 'Time::Piece',                 '1.31';
requires 'version',                     '0.9912';
requires 'Email::Valid',                '1.198';
requires 'Net::DNS',                    '1.04';
requires 'Try::Tiny',                   '0.24';
requires 'DateTime',                    '1.21';

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
