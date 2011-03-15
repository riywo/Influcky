use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use lib "$FindBin::RealBin/../extlib/lib/perl5";
use Test::More;
use Influcky::Config;
use JSON;

my $base_dir = "$FindBin::RealBin/..";
my $fname = "$base_dir/config/$ENV{INFLUCKY_CONFIG}.pl";
my $config = do $fname or die "Cannot load configuration file: $fname";

is(
    encode_json(Influcky::Config->load),
    encode_json($config),
    "$ENV{INFLUCKY_CONFIG}.pl"
);

done_testing;
