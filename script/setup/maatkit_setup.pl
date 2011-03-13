use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../../extlib/lib/perl5";
use lib "$FindBin::RealBin/../../lib";
use Infra::Log;

use Furl;
use Web::Scraper;
use URI;
use Parallel::ForkManager;

my $root_dir = "$FindBin::RealBin/../..";
my $maatkit_dir = "$root_dir/script/maatkit";
mkdir $maatkit_dir unless(-d $maatkit_dir);

Infra::Log->info("scraping maatkit tool list");
my $res = scraper {
    process '#wrapper ul li a', 'mk-tool[]' => {
        url => '@href',
        file => 'TEXT',
    };
}->scrape(new URI('http://www.maatkit.org/get/'));


my $pm = new Parallel::ForkManager(5);
for my $tool (@{$res->{'mk-tool'}}) {
    my $pid = $pm->start and next;
    my $file = "$maatkit_dir/$tool->{'file'}";
    $pm->finish if(-f $file);
    my $furl = Furl->new;
    open my $fh, '>', $file or die $!;
    Infra::Log->info("download $tool->{'file'}...");
    $furl->request(
        method => 'GET',
        url => $tool->{'url'},
        write_file => $fh,
    );
    close $fh;
    chmod 0755, $file;
    $pm->finish;
}

$pm->wait_all_children;

my $bashrc = '~/.bashrc';
system("echo export PATH=$maatkit_dir:".'\$PATH >> ' . $bashrc)
    unless(grep {$_ eq "$maatkit_dir"} split /:/, `source $bashrc; echo \$PATH`);

