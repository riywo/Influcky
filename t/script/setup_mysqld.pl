use FindBin;
use lib "$FindBin::Bin/../../extlib/lib/perl5";
use Test::Infra::mysqld;
use JSON;

$SIG{INT} = sub { CORE::exit 1 };
$mysqld = Test::Infra::mysqld->setup;
$ENV{TEST_MYSQLD} = encode_json +{ %$mysqld };
$mysqld_slave = Test::Infra::mysqld->setup_slave($mysqld);
$ENV{TEST_MYSQLD_SLAVE} = encode_json +{ %$mysqld_slave };
