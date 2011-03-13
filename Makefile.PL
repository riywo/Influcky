use FindBin;
use lib "$FindBin::RealBin/extlib/lib/perl5";
use inc::Module::Install;
name 'Infra';
all_from 'lib/Infra.pm';

requires 'DBI';
requires 'JSON';
requires 'Furl';
requires 'Web::Scraper';
requires 'Parallel::ForkManager';
requires 'Capture::Tiny';
requires 'File::chdir';

tests 't/*.t';
author_tests 'xt';

default_test_target(
    includes       => ['t/lib','extlib/lib/perl5'],
    run_on_prepare => ['t/script/setup_mysqld.pl'],
);

test_requires 'Test::More';
test_requires 'Test::TCP';
test_requires 'Test::mysqld';
test_requires 'Data::Section::Simple';

auto_set_repository;
auto_include;
WriteAll;
