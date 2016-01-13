package Cater::DBI;

use base 'Class::DBI';

use strict;
use warnings;

use Const::Fast;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Cater::DBI


=head1 DESCRIPTION AND USAGE

Database subclass of Class::DBI for the Cater app.

=cut

const my $DB_NAME => 'dbi:mysql:catering';
const my $DB_USER => 'caterit';
const my $DB_PASS => 'CoMeCaTeR4Me';

__PACKAGE__->connection(
                        $DB_NAME,
                        $DB_USER,
                        $DB_PASS,
                        {
                            PrintError => 0,
                            RaiseError => 1,
                            ChopBlanks => 1,
                            ShowErrorStatement => 1,
                            AutoCommit => 0,
                        },
                       );

1;
