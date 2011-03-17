package Influcky::MySQL;
use strict;
use warnings;
use Class::Accessor::Lite;
use JSON;
use Capture::Tiny qw(capture);
use Carp;

use Influcky::Config;
use Influcky::Log;

my %Defaults = (
    'config' => Influcky::Config->load->{'MySQL'},
    'db' => '',
    'opt' => ['--unbuffered'],
    'host' => 'localhost',
    'port' => 3306,
);
Class::Accessor::Lite->mk_accessors(keys %Defaults);

sub new {
    my $class = shift;
    my $self = bless {
        %Defaults,
        @_ == 1 ? %{$_[0]} : @_,
    }, $class;

    Influcky::Log->debug(encode_json +{%{$self}});

    $self;
}

sub mysql_fork {
    my ($self, $sql, %arg) = @_;

    my ($parent_in, $parent_out);
    my ($child_in, $child_out);
    pipe $parent_out, $child_in;
    pipe $child_out, $parent_in;
    $parent_in->autoflush(1);
    $child_in->autoflush(1);

    my $ret = '';
    if (my $pid = fork) {
        close $parent_in; close $parent_out;

        Influcky::Log->debug("sql: ".$sql);
        print $child_in "$sql";
        close $child_in;

        while (my $line = <$child_out>) {
            $ret .= $line;
        }
        close $child_out;

        waitpid($pid,0);
    } else {
        die "cannot fork: $!" unless defined $pid;
        close $child_in; close $child_out;

        open STDOUT, '>&', $parent_in;
        open STDIN, '<&', $parent_out;

        my $db = $arg{'db'} || $self->db;
        my $opt = $self->_make_opt($arg{'opt'});
        push @{$opt}, $db;

        exec { "mysql" } @{$opt};
    }

    return $ret;
}

sub mysql {
    my ($self, $sql, %arg) = @_;

    my $db = $arg{'db'} || $self->db;
    my $opt = $self->_make_opt($arg{'opt'});
    my $CMD = "mysql " . join(" ", (@{$opt}, $db));
    Influcky::Log->debug("command: ".$CMD);
    Influcky::Log->debug("sql: ".$sql);
    my ($stdout, $stderr) = capture {
        open my $fh, "| $CMD";
        print $fh "$sql";
    };
    if ($stderr) {
        chomp $stderr;
        Influcky::Log->error($stderr);
        croak "exec mysql command failed";
    }
    else {
        return $stdout;
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

    my @opt = @{$self->opt};
    push @opt, "-u".$self->config->{'user'};
    push @opt, "-p".$self->config->{'password'} if($self->config->{'password'} and $self->config->{'password'} ne '');
    push @opt, "-h".$self->host;
    push @opt, "--port=".$self->port;
    push @opt, @{$arg} if ($arg);

    return \@opt;
}

1;
