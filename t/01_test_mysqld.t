use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use Test::Infra::mysqld;
use Test::More;

note "setup mysqld...";
my $mysqld = Test::Infra::mysqld->setup() or die $Test::mysqld::errstr;
note $mysqld->dsn;
note "setup mysqld slave...";
my $mysqld_slave = Test::Infra::mysqld->setup_slave($mysqld) or die $Test::mysqld::errstr;
note $mysqld_slave->dsn;

is(
    $mysqld->dsn,
    "DBI:mysql:dbname=test;host=127.0.0.1;port=".$mysqld->my_cnf->{'port'}.";user=root",
    'check dsn',
);
my $dbh_master = DBI->connect($mysqld->dsn, 'root', '',
    +{ RaiseError => 1, AutoCommit => 0, });
ok($dbh_master, 'connect to mysqld');

is(
    $mysqld_slave->dsn,
    "DBI:mysql:dbname=test;host=127.0.0.1;port=".$mysqld_slave->my_cnf->{'port'}.";user=root",
    'check dsn slave',
);
my $dbh_slave = DBI->connect($mysqld_slave->dsn, 'root', '',
    +{ RaiseError => 1, AutoCommit => 1, });
ok($dbh_slave, 'connect to mysqld_slave');

$dbh_master->do(q|CREATE DATABASE replication|) or die($dbh_master->errstr);
$dbh_master->do(q|USE replication|) or die($dbh_master->errstr);
$dbh_master->do(
q|CREATE TABLE test ( time int unsigned not null ) ENGINE=InnoDB|
) or die($dbh_master->errstr);
my $time = time;
$dbh_master->do( q|INSERT INTO test(time) VALUES(?)|, undef, $time ) or die($dbh_master->errstr);
$dbh_master->commit or die($dbh_master->errstr);
 
note( explain( $dbh_master->selectall_arrayref(q|SELECT * FROM test|) ) );

sleep 1;
 
note( explain( $dbh_slave->selectall_arrayref(q|SHOW DATABASES|) ) );
$dbh_slave->do(q|USE replication|);
note( explain( $dbh_slave->selectall_arrayref(q|SHOW TABLES|) ) );
note( explain( $dbh_slave->selectall_arrayref(q|SELECT * FROM test|) ) );

is($dbh_slave->selectrow_arrayref(q|select time from test|)->[0], $time, 'chech slave data is same to master');

$dbh_master->disconnect or die($dbh_master->errstr);
$dbh_slave->disconnect or die($dbh_slave->errstr);

$dbh_master = DBI->connect($mysqld->dsn, 'root', '',
    +{ RaiseError => 1, AutoCommit => 0, });
$dbh_slave = DBI->connect($mysqld_slave->dsn, 'root', '',
    +{ RaiseError => 1, AutoCommit => 1, });

Test::Infra::mysqld->cleanup($mysqld);
note( explain( $dbh_master->selectall_arrayref(q|show databases like 'replication'|)));
is(scalar @{$dbh_master->selectall_arrayref(q|show databases like 'replication'|)}, 0, 'master cleaned up');
sleep 1;
is(scalar @{$dbh_slave->selectall_arrayref(q|show databases like 'replication'|)}, 0, 'slave cleaned up');

done_testing;
