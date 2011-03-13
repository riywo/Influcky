package Infra::MySQL;
use strict;
use warnings;
use FindBin;
use Class::Accessor::Lite;
use File::Temp qw(tempfile tempdir);

use Infra::Config;
use Infra::Log;

my %Defaults = (
    'config' => Infra::Config->load->{'MySQL'},
    'db' => '',
    'opt' => '',
    'host' => '127.0.0.1',
    'port' => '3306',
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

    $self;
}

sub mysql {
    my ($self, $sql, %arg) = @_;

    my ($fh, $fname) = tempfile(DIR => $self->dir, SUFFIX => '.sql');
    print $fh $sql;
    close $fh;

    my $db = $arg{'db'} ? $arg{'db'} : $self->db;
    my $opt = $self->_make_opt($arg{'opt'});

    my $ret = `cat $fname | mysql $opt $db`;
    return $ret;
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
    if ($self->config->{'socket'}) {
        $opt .= " --socket=".$self->config->{'socket'};
    }
    else {
        $opt .= " -h".$self->host;
        $opt .= " --port=".$self->port;
    }
    $opt .= " $arg" if ($arg);

    return $opt;
}

1;
