use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use Test::Infra::mysqld;
use Test::More;
use Data::Section::Simple qw(get_data_section);

use Infra::MySQL;
use Data::Dumper;

note "setup mysqld...";
my $mysqld = Test::Infra::mysqld->setup() or die $Test::mysqld::errstr;
note $mysqld->dsn;
Test::Infra::mysqld->cleanup($mysqld);

$mysqld->dsn =~ /host=([^;]+)/; my $host = $1;
$mysqld->dsn =~ /port=([^;]+)/; my $port = $1;

my $mysql = Infra::MySQL->new(
    config => {
        user => 'root',
        password => '',
    },
    host => $host,
    port => $port,
);

my $DB = 'hoge';
my $TABLE = 'fuga';
my $ddl = get_data_section('ddl.sql');
$ddl =~ s/<% DB %>/$DB/g;
$ddl =~ s/<% TABLE %>/$TABLE/g;
note explain $mysql->mysql($ddl);

my $sql = get_data_section('insert.sql');
for my $i (1..100) {
    (my $sql_temp = $sql) =~ s/<% TABLE %>/$TABLE/g;
    my $str = _get_rand_str(20);
    $sql_temp =~ s/<% DATA %>/$str/g;
    $mysql->mysql($sql_temp, $DB);
}

is(
    $mysql->mysql("select count(*) from $TABLE", $DB, "--skip-column-name"),
    "100\n", "count"
);


Test::Infra::mysqld->cleanup($mysqld);
done_testing;

#-----------------------------------------------------------------------

sub _get_rand_str {
    my $length = shift;
    my @letter = (('a'..'z'), ('A'..'Z'), (0..9));
    my $res ='';
    $res .= $letter[int(rand()*(scalar @letter))] for (1..$length);
    return $res;
}

__DATA__
@@ ddl.sql
CREATE DATABASE `<% DB %>`;
USE `<% DB %>`;
CREATE TABLE `<% TABLE %>` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

@@ insert.sql
INSERT INTO `<% TABLE %>`(`value`) VALUES ('<% DATA %>');
