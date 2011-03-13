use inc::Module::Install;
name 'Infra';
all_from 'lib/Infra.pm';

requires 'DBI';
requires 'JSON';
requires 'Furl';
requires 'Web::Scraper';
requires 'Parallel::ForkManager';

tests 't/*.t';
author_tests 'xt';

default_test_target(
    includes       => ['t/lib'],
    run_on_prepare => ['t/script/setup_mysqld.pl'],
);

test_requires 'Test::More';
test_requires 'Test::TCP';
test_requires 'Test::mysqld';
auto_set_repository;
auto_include;
WriteAll;
