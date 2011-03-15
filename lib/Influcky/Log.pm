package Influcky::Log;
use strict;
use warnings;
use HTTP::Date qw(time2iso);

sub error {
    my $class = shift;
    $class->_log('ERROR',@_);
}

sub warn {
    my $class = shift;
    $class->_log('WARN',@_);
}

sub info {
    my $class = shift;
    $class->_log('INFO',@_);
}

sub debug {
    my $class = shift;
    return unless $ENV{INFRA_DEBUG};
    $class->_log('DEBUG',@_);
}

# ---------------------------------------------------

sub _log {
    my ($class, $tag, $msg) = @_;
    my $time = time2iso(time);
    my ($package, $fname, $line) = caller(1);
    $package = $fname if ($package eq 'main');

    printf "%s [%s] %s loged at %s line %s\n", $time, $tag, $msg, $package, $line;
}

1;
