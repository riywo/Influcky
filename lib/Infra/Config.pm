package Infra::Config;
use strict;
use warnings;
use File::Spec;
use File::chdir;

sub load {
    my $self = shift;
    my %conf = @_ == 1 ? %{$_[0]} : @_;

    my $env = $conf{environment} || 'development';
    my $fname = File::Spec->catfile(_base_dir($self), 'config', "${env}.pl");
    my $config = do $fname or die "Cannot load configuration file: $fname";
    return $config;
}

sub _base_dir {
    my $path = shift;
    $path =~ s!::!/!g;
    if (my $libpath = $INC{"$path.pm"}) {
        $libpath =~ s!(?:blib/)?lib/+$path\.pm\Z!!;
        $CWD = $libpath;
        $libpath = $CWD;
        File::Spec->rel2abs($libpath || './');
    } else {
        File::Spec->rel2abs('./');
    }
}

1;
