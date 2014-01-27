#!/usr/bin/perl -w

# Written by some dude from a random Google search, this was useful to me a grand total of once. Maybe it will help you
use warnings;
use strict;

use Socket;

my $host = 'localhost';
my $port = '8009';

# The host and port arguments can be specified by either space or colon
# separating the values.
if (scalar(@ARGV) >= 2) {
    $host = shift @ARGV;
    $port = shift @ARGV;
}
elsif (scalar(@ARGV) == 1) {
    if ($ARGV[0] =~ /:/) {
        ($host, $port) = split /:/, shift @ARGV, 2;
    }
    else {
        $host = shift @ARGV;
    }
}

# If the port has anything other than numbers, assume it is an /etc/services
# name.
if ($port =~ /\D/) {
    $port = getservbyname $port, 'tcp' ;
    die "Bad port: $port" unless $port;
}

my $iaddr = inet_aton($host) or die "No such host: $host";

# Get a printable IP address from the in_addr_t type returned by inet_aton().
my $ip = join('.', unpack('C4', $iaddr));

# Now that the port value is a number, and the host (if it was originally a
# name) has been resolved to an IP address, then print a status header like
# the real ping does.
print "AJP PING $host ($ip) port $port\n";

my $paddr = sockaddr_in($port, $iaddr) or die $!;

# Grab the number for TCP out of /etc/protocols.
my $proto = getprotobyname 'tcp' ;

my $sock;
# PF_INET and SOCK_STREAM are constants imported by the Socket module.  They
# are the same as what is defined in sys/socket.h.
socket $sock, PF_INET, SOCK_STREAM, $proto or die $!;

# This is the ping packet.  For detailed documentation, see
# http://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html
# I stole the exact byte sequence from
# http://sourceforge.net/project/shownotes.php?group_id=128058&release_id=438456
# instead of fully understanding the packet structure.
my $ping = pack 'C5'    # Format template.
    , 0x12, 0x34        # Magic number for server->container packets.
    , 0x00, 0x01        # 2 byte int length of payload.
    , 0x0A              # Type of packet. 10 = CPing.
;

# If the connection is closed, log a decent message.
$SIG{PIPE} = sub { die $!; };

connect $sock, $paddr or die $!;

syswrite $sock, $ping or die $!;

print 'Sent:     ';
for my $value (unpack 'C5', $ping) {
    printf '%02d ', $value;
}
print "\n";

my $pong;

$pong = 0;

sysread $sock, $pong, 5 or die $!;

print 'Received: ';
for my $value (unpack 'C5', $pong) {
    printf '%02d ', $value;
}
print "\n";

close $sock or warn $!;

# This is the expected pong packet.  That is, this is what Tomcat sends back
# to indicate that it is operating OK.
my $expected = pack 'C5'    # Format template.
    , 0x41, 0x42            # Magic number for container->server packets.
    , 0x00, 0x01            # 2 byte int length of payload.
    , 0x09                  # Type of packet. 9 = CPong reply.
;

print 'Expected: ';
for my $value (unpack 'C5', $expected) {
    printf '%02d ', $value;
}
print "\n";

if ($pong eq $expected) {
    print "Server pong OK.\n";
    exit 0;
}

print "Server pong FAILED.\n";
exit 1;
