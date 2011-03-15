#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use lib "$FindBin::RealBin/../../extlib/lib/perl5";
use File::Spec;
use JSON;
use Test::Influcky::mysqld;

my $tempfile = File::Spec->catfile(File::Spec->tmpdir, 'test_mysqld.json');
my $tempfile_slave = File::Spec->catfile(File::Spec->tmpdir, 'test_mysqld_slave.json');

$SIG{'INT'} = *purge;
END { purge(); }

print "Starting mysqld...";
my $mysqld = Test::Influcky::mysqld->setup;
my $log = File::Spec->catfile($mysqld->{'base_dir'}, qw/tmp mysqld.log/);
printf " started at %s\n", $mysqld->{'my_cnf'}{'socket'};
print "log file: $log\n";
print $mysqld->dsn."\n";

print "Starting mysqld slave...";
my $mysqld_slave = Test::Influcky::mysqld->setup_slave($mysqld);
my $log_slave = File::Spec->catfile($mysqld_slave->{'base_dir'}, qw/tmp mysqld.log/);
printf " started at %s\n", $mysqld_slave->{'my_cnf'}{'socket'};
print "log file: $log_slave\n";
print $mysqld_slave->dsn."\n";

{
    my $json = encode_json({ %$mysqld });
    open my $fh, '>', $tempfile or die $!;
    $fh->print($json);
    $fh->close;
}
{
    my $json = encode_json({ %$mysqld_slave });
    open my $fh, '>', $tempfile_slave or die $!;
    $fh->print($json);
    $fh->close;
}

sleep 3 while (-e $tempfile and -e $tempfile_slave);

sub purge {
    unlink $tempfile;
    unlink $tempfile_slave;
    print "Shutting down mysqld...\n";
    exit;
}
