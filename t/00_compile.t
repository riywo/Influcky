use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/lib";
use lib "$FindBin::RealBin/../lib";

use Test::More;

BEGIN { 
    use_ok 'Influcky';
    use_ok 'Influcky::Log';
    use_ok 'Influcky::MySQL';
}

done_testing;
