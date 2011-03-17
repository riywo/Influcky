use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use lib "$FindBin::RealBin/../extlib/lib/perl5";
use Test::More;
use Influcky::Config;
use JSON;

my $base_dir = "$FindBin::RealBin/..";
my $env = $ENV{INFLUCKY_CONFIG} || 'development';
my $fname = "$base_dir/config/$env.pl";
my $config = do $fname or die "Cannot load configuration file: $fname";

is(
    encode_json(Influcky::Config->load),
    encode_json($config),
    "$env.pl"
);

done_testing;
