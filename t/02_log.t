use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use Test::More;
use Infra::Log;

$ENV{INFRA_DEBUG} = 1;

plan tests => 4;

my $output;

open my $OUT, '>', \$output;
local *STDOUT = *$OUT;
Infra::Log->debug("debug test");
like($output, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[DEBUG\] debug test$/);
close($OUT);

open $OUT, '>', \$output;
local *STDOUT = *$OUT;
Infra::Log->warn("warn test");
like($output, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[WARN\] warn test$/);
close($OUT);

open $OUT, '>', \$output;
local *STDOUT = *$OUT;
Infra::Log->error("error test");
like($output, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[ERROR\] error test$/);
close($OUT);

open $OUT, '>', \$output;
local *STDOUT = *$OUT;
Infra::Log->info("info test");
like($output, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[INFO\] info test$/);
close($OUT);
