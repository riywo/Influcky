use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";
use Test::More;
use Capture::Tiny qw(capture);
use Infra::Log;

$ENV{INFRA_DEBUG} = 1;

my $stdout;
($stdout, undef) = capture { Infra::Log->debug("debug test"); };
note $stdout;
like($stdout, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[DEBUG\] debug test loged at [^ ]* line \d+$/);

($stdout, undef) = capture { Infra::Log->warn("warn test"); };
note $stdout;
like($stdout, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[WARN\] warn test loged at [^ ]* line \d+$/);

($stdout, undef) = capture { Infra::Log->error("error test"); };
note $stdout;
like($stdout, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[ERROR\] error test loged at [^ ]* line \d+$/);

($stdout, undef) = capture { Infra::Log->info("info test"); };
note $stdout;
like($stdout, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[INFO\] info test loged at [^ ]* line \d+$/);

done_testing;
