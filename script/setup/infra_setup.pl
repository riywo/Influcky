use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../../lib";
use Infra::Log;

my $root_dir =  "$FindBin::RealBin/../..";
my $bashrc = "~/.bashrc";

system("cd $root_dir; curl -L http://cpanmin.us | perl - -v -l extlib App::cpanminus")
    unless( -d "$root_dir/extlib");
system("echo export PATH=$root_dir/script:".'\$PATH >> ' . $bashrc)
    unless(grep {$_ eq "$root_dir/script"} split /:/, `source $bashrc; echo \$PATH`);
system("cd $root_dir; $root_dir/extlib/bin/cpanm -v -L extlib --installdeps .");
#system("cd $root_dir; perl Makefile.PL; make test; make clean");

#system("cd $root_dir; perl $root_dir/script/setup/maatkit_setup.pl");
