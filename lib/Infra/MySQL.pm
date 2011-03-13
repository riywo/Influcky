package Infra::MySQL;
use strict;
use warnings;
use FindBin;
use Class::Accessor::Lite;
use File::Temp qw(tempfile tempdir);

use Infra::Config;

my %Defaults = (
    config => Infra::Config->load->{'MySQL'},
    host => '127.0.0.1',
    port => 3306,
    opt => '',
    dir => undef,
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
    my ($self, $sql, $db, $arg) = @_;
    $db = '' unless $db;

    my $opt = $self->opt;
    $opt .= " -u".$self->config->{'user'};
    $opt .= " -p".$self->config->{'password'} if($self->config->{'password'} and $self->config->{'password'} ne '');
    $opt .= " -h".$self->host;
    $opt .= " --port=".$self->port;
    $opt .= " $arg" if($arg);

    my ($fh, $fname) = tempfile(DIR => $self->dir, SUFFIX => '.sql');
    print $fh $sql;
    close $fh;

    my $ret = `cat $fname | mysql $opt $db`;
    return $ret;
}

1;
