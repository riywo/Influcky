use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use Test::More;
use Infra::Config;
use JSON;

my $base_dir = "$FindBin::RealBin/..";
my $fname = "$base_dir/config/development.pl";
my $config = do $fname or die "Cannot load configuration file: $fname";

is(
    encode_json(Infra::Config->load),
    encode_json($config),
    "development.pl"
);

done_testing;
