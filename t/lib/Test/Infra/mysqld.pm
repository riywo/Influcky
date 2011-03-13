package Test::Infra::mysqld;
use strict;
use warnings;
use Test::mysqld;
use Test::TCP;
use JSON;
use DBI;

our $SKIP_DROP_DB_MAP = {
    information_schema => 1,
    mysql              => 1,
    test               => 1,
};

my $tempfile = File::Spec->catfile(File::Spec->tmpdir, 'test_mysqld.json');
my $tempfile_slave = File::Spec->catfile(File::Spec->tmpdir, 'test_mysqld_slave.json');

my %CONFIG = (
    'key-buffer-size'                 => '100K',
    'innodb-buffer-pool-size'         => '5M',
    'innodb-log-buffer-size'          => '256K',
    'innodb-additional-mem-pool-size' => '512K',
    'sort-buffer-size'                => '100K',
    'myisam-sort-buffer-size'         => '100K',
    'innodb_use_native_aio' => 0,
    'slow-query-log' => 1,
    'long-query-time' => 0,
);

sub setup {
    my ($class, %config) = @_;

    my $mysqld;
    if ( -e $tempfile ) {
        open my $fh, '<', $tempfile or die $!;
        my $obj = decode_json(join '', <$fh>);
        $mysqld = bless $obj, 'Test::mysqld';
    }
    elsif (my $json = $ENV{TEST_MYSQLD}) {
        my $obj = decode_json $json;
        $mysqld = bless $obj, 'Test::mysqld';
    }
    else {
        $mysqld = Test::mysqld->new(my_cnf => {
            'port' => empty_port(),
            'log-bin' => 'mysql-bin',
            'server-id' => 1,
            'replicate-ignore-db' => 'mysql',
            %CONFIG,
            %config,
        }) or die $Test::mysqld::errstr;

        my $dbh = DBI->connect( $mysqld->dsn, 'root', '' );
        $dbh->do(
            sprintf(
                q|CREATE USER '%s'@'%s' IDENTIFIED BY '%s'|,
                'repl', '127.0.0.1', 'replpass'
            )
        ) or die( $dbh->errstr );
        $dbh->do(
            sprintf(
                q|GRANT REPLICATION SLAVE ON *.* TO '%s'@'%s'|,
                'repl', '127.0.0.1'
            )
        ) or die( $dbh->errstr );
    }

    return $mysqld;
}

sub setup_slave {
    my ($class, $mysqld_master, %config) = @_;

    my $mysqld;
    if ( -e $tempfile_slave ) {
        open my $fh, '<', $tempfile_slave or die $!;
        my $obj = decode_json(join '', <$fh>);
        $mysqld = bless $obj, 'Test::mysqld';
    }
    elsif (my $json = $ENV{TEST_MYSQLD_SLAVE}) {
        my $obj = decode_json $json;
        $mysqld = bless $obj, 'Test::mysqld';
    }
    else {
        $mysqld = Test::mysqld->new(my_cnf => {
            'port'      => empty_port(),
            'server-id' => 2,
            %CONFIG,
            %config,
        }) or die $Test::mysqld::errstr;

        my $dbh_master = DBI->connect( $mysqld_master->dsn, 'root', '' );
        my $master_status = $dbh_master->selectrow_hashref( 'SHOW MASTER STATUS' );
        my $dbh = DBI->connect( $mysqld->dsn, 'root', '' );
        $dbh->do(
            sprintf(
q|CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_USER='%s', MASTER_PASSWORD='%s', MASTER_LOG_FILE='%s', MASTER_LOG_POS=%d|,
                '127.0.0.1', $mysqld_master->my_cnf->{port},
                'repl', 'replpass', $master_status->{File}, $master_status->{Position},
            )
        );
        $dbh->do(q|START SLAVE|);
    }

    return $mysqld;
}

sub cleanup {
    my ($class, $mysqld) = @_;
    my $dbh = DBI->connect($mysqld->dsn, '', '', {
        AutoCommit => 1,
        RaiseError => 1,
    });

    my $rs = $dbh->selectall_hashref('SHOW DATABASES', 'Database');
    for my $dbname (keys %$rs) {
        next if $SKIP_DROP_DB_MAP->{$dbname};
        $dbh->do("DROP DATABASE $dbname");
    }
}

1;
