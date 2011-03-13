package Infra::Log;
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

    printf "%s [%s] %s\n", $time, $tag, $msg;
}

1;
