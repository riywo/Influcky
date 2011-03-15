use FindBin;
use lib "$FindBin::Bin/../../extlib/lib/perl5";
use Test::Influcky::mysqld;
use JSON;

$SIG{INT} = sub { CORE::exit 1 };
$mysqld = Test::Influcky::mysqld->setup;
$ENV{TEST_MYSQLD} = encode_json +{ %$mysqld };
$mysqld_slave = Test::Influcky::mysqld->setup_slave($mysqld);
$ENV{TEST_MYSQLD_SLAVE} = encode_json +{ %$mysqld_slave };
