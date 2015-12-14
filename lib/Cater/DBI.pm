package Cater::DBI;

use base 'Class::DBI';
use Const::Fast;

const my $DB_NAME => 'dbi:mysql:catering';
const my $DB_USER => 'caterit';
const my $DB_PASS => 'CoMeCaTeR4Me';

Cater::DBI->connection( $DB_NAME, $DB_USER, $DB_PASS );

1;
