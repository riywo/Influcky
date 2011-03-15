package Influcky::MySQL;
use strict;
use warnings;
use FindBin;
use Class::Accessor::Lite;
use File::Temp qw(tempfile tempdir);
use JSON;
use Capture::Tiny qw(capture);
use Carp;

use Influcky::Config;
use Influcky::Log;

my %Defaults = (
    'config' => Influcky::Config->load->{'MySQL'},
    'db' => '',
    'opt' => '',
    'host' => 'localhost',
    'port' => 3306,
    'dir' => undef,
);
Class::Accessor::Lite->mk_accessors(keys %Defaults);

sub new {
    my $class = shift;
    my $self = bless {
        %Defaults,
        @_ == 1 ? %{$_[0]} : @_,
    }, $class;

    if (!$self->dir) {
        $self->dir(tempdir(CLEANUP => 1));
    }

    Influcky::Log->debug(encode_json +{%{$self}});

    $self;
}

sub mysql {
    my ($self, $sql, %arg) = @_;

    my ($fh, $fname) = tempfile(DIR => $self->dir, SUFFIX => '.sql');
    print $fh $sql;
    close $fh;

    my $db = $arg{'db'} || $self->db;
    my $opt = $self->_make_opt($arg{'opt'});

    my $CMD = "cat $fname | mysql $opt $db";
    Influcky::Log->debug($CMD);
    my $ret;
    my (undef, $stderr) = capture {
        $ret = `$CMD`;
    };
    if ($? != 0) {
        chomp $stderr;
        Influcky::Log->error($stderr);
        croak "exec mysql command failed";
    }
    else {
        return $ret;
    }
}

sub mysqldump_ddl {
    my ($self, %arg) = @_;

}

sub mysqldump_data {
    my ($self, %arg) = @_;

}

sub _make_opt {
    my ($self, $arg) = @_;

    my $opt = $self->opt;
    $opt .= " -u".$self->config->{'user'};
    $opt .= " -p".$self->config->{'password'} if($self->config->{'password'} and $self->config->{'password'} ne '');
    $opt .= " -h".$self->host;
    $opt .= " --port=".$self->port;
    $opt .= " $arg" if ($arg);

    return $opt;
}

1;
