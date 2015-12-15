# cpanfile
requires 'perl', '>= 5.18.2';

requires 'Dancer',          '1.3123';
requires 'Locale::Country', '3.36';
requires 'Class::DBI',      '3.0.17';
requires 'Const::Fast',     '0.014';
requires 'Time::Piece',     '1.31';
requires 'version',         '0.9912';

on 'develop' => sub
{
    requires   'Database::Migration';
    recommends 'Devel::NYTProf';
};

on 'test' => sub
{
    requires   'Test::More';
    requires   'Data::Faker';
};
