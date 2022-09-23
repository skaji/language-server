#!/usr/bin/env perl
use v5.36;
use experimental qw(builtin defer for_list try);
use utf8;

use Caroline;
use JSON::PP ();

my @cmd = @ARGV;
my $process = Process->new(@cmd);
defer { $process->kill }

$process->write(q[{"jsonrpc":"2","method":"hello","id":"id0"}]);
print $process->read, "\n";

my $JSON = JSON::PP->new->canonical;
STDOUT->binmode(":utf8");
STDERR->binmode(":utf8");
STDIN->binmode(":utf8");

my $caroline = Caroline->new;

my $INT; $SIG{INT} = sub { $INT++ };
my $id = 1;
while (defined(my $line = $caroline->readline("❯ "))) {
    last if $INT;
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
    $process->write($JSON->encode($req));
    print $process->read, "\n";
}

package Process {
    sub new ($class, @cmd) {
        pipe my $stdin_read, my $stdin_write;
        pipe my $stdout_read, my $stdout_write;
        my $pid = fork // die;
        if ($pid == 0) {
            close $stdin_write;
            close $stdout_read;
            open \*STDIN, "<&", $stdin_read or die;
            open \*STDOUT, ">&", $stdout_write or die;
            exec { $cmd[0] } @cmd;
            exit 255;
        }
        close $stdin_read;
        close $stdout_write;
        bless { buf => '', pid => $pid, stdin => $stdin_write, stdout => $stdout_read }, $class;
    }
    sub read ($self) {
        my $length = $self->_read_content_length;
        $self->_read_content($length);
    }
    sub _read_content_length ($self) {
        while (1) {
            if ($self->{buf} =~ s/\AContent-Length: (\d+)\x0d\x0a\x0d\x0a//) {
                return $1;
            }
            $self->_read;
        }
    }
    sub _read_content ($self, $length) {
        while (1) {
            if (length($self->{buf}) >= $length) {
                return substr $self->{buf}, 0, $length, '';
            }
            $self->_read;
        }
    }
    sub _read ($self) {
        $self->{stdout}->sysread( $self->{buf}, 65536, length($self->{buf}) );
    }
    sub write ($self, $str) {
        $self->{stdin}->syswrite( sprintf "Content-Length: %d\x0d\x0a\x0d\x0a%s", length($str), $str );
    }
    sub kill ($self) {
        kill TERM => $self->{pid};
        waitpid $self->{pid}, 0;
    }
}
