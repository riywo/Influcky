use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../../lib";

my $root_dir =  "$FindBin::RealBin/../..";
my $bashrc = "~/.bashrc";

print "install cpanm...\n";
system("cd $root_dir; curl -L http://cpanmin.us | perl - -v -l extlib App::cpanminus")
    unless( -d "$root_dir/extlib");

print "install Module::Install...\n";
system("cd $root_dir; yes | $root_dir/extlib/bin/cpanm -v -L extlib inc::Module::Install");
system("cd $root_dir; yes | $root_dir/extlib/bin/cpanm -v -L extlib Module::Install::AuthorTests");
system("cd $root_dir; yes | $root_dir/extlib/bin/cpanm -v -L extlib Module::Install::Repository");
system("cd $root_dir; yes | $root_dir/extlib/bin/cpanm -v -L extlib Module::Install::TestTarget");

print "PATH...\n";
system("echo export PATH=$root_dir/script/tool:".'\$PATH >> ' . $bashrc)
    unless(grep {$_ eq "$root_dir/script/tool"} split /:/, `source $bashrc; echo \$PATH`);
system("echo export PATH=$root_dir/script:".'\$PATH >> ' . $bashrc)
    unless(grep {$_ eq "$root_dir/script"} split /:/, `source $bashrc; echo \$PATH`);

print "Installdeps...\n";
system("cd $root_dir; $root_dir/extlib/bin/cpanm -v -L extlib --installdeps .");

print "make test...\n";
system("cd $root_dir; perl -Mlib=extlib/lib/perl5 Makefile.PL; make test; make clean");

