#!/usr/bin/env perl
use v5.36;
use experimental qw(builtin defer for_list try);
use utf8;

use Caroline;
use JSON::PP ();

my $JSON = JSON::PP->new->canonical;
STDOUT->binmode(":utf8");
STDERR->binmode(":utf8");
STDIN->binmode(":utf8");
sub pause { select undef, undef, undef, 0.5 }

my @cmd = @ARGV;
open my $fh, "|-", @cmd or die;
$fh->autoflush(1);

my $caroline = Caroline->new;

my $first = q[{"jsonrpc":"2.0","method":"hello"}];
printf {$fh} "Content-Length: %d\x0d\x0a\x0d\x0a%s", length($first), $first;
pause;

print '# eg: {"method":"hello"}', "\n";
my $id = 1;
while (defined(my $line = $caroline->readline("❯ "))) {
    next if $line !~ /\S/;
    last if $line eq "exit";
    my $req = eval { $JSON->decode($line) };
    if (!$req) {
        warn "invalid json\n";
        next;
    }
    $caroline->history_add($line);
    $req->{"jsonrpc"} = "2.0";
    $req->{"id"} = "id" . $id++;
    my $json = $JSON->encode($req);
    printf {$fh} "Content-Length: %d\x0d\x0a\x0d\x0a%s", length($json), $json;
    pause;
    print "\n";
}
