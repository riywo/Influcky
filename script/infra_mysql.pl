#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use lib "$FindBin::RealBin/../extlib/lib/perl5";
use Getopt::Long qw(:config pass_through no_ignore_case no_auto_abbrev);
use Pod::Usage;
use Infra::MySQL;
use Infra::Log;

#$ENV{INFRA_DEBUG} = 1;
my $help;
GetOptions(
    'e|exec=s' => \my $sql,
    'h|host=s' => \my $host,
    'P|port=i'=> \my $port,
    "help|?" => \$help,
) or $help = 1;
if (!$sql or $help) {
    pod2usage(verbose => 0);
    exit;
}

my $opt = join " ", @ARGV;

my %arg = ();
$arg{'host'} = $host if $host;
$arg{'port'} = $port if $port;

my $mysql = Infra::MySQL->new(%arg);
eval{
    print $mysql->mysql($sql, 'opt' => $opt);
};
if($@){
    chomp $@;
    Infra::Log->error($@);
    exit 1;
}
exit 0;

__END__
=head1 NAME

Infra::MySQL CLI tool

=head1 SYNOPSIS

infra_mysql.pl [options]

  Options:
    *This command can be used the same options as mysql client*

    -e, --exec    execution SQL
    -h, --host    [OPTION]connect hostname. default is localhost
    -P, --port    [OPTION]connect port. default is 3306
    -?, --help    show this help

  more options are passed to mysql client.
  config file is $BASE_DIR/config/$ENV{INFRA_CONFIG}.pl. default is "development.pl".
  you can set it "INFRA_CONFIG=production infra_mysql.pl", ~/.bashrc or etc.

=cut
