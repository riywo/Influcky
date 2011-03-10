use inc::Module::Install;
name 'Infra';
all_from 'lib/Infra.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
