#!/usr/bin/perl
# WHO:   PGP
# WHAT:  This script will check if the string you input is a palindrome.
use strict;
use warnings;
use POSIX qw/ceil/;
use feature 'say';

usage() if (@ARGV < 1 || @ARGV > 1);
sub usage {
    say "Usage:";
    say "Enter a string as your first and only argument";
    exit;
}

sub check_palindrome {
    my $uarg = shift;
    my @chararray = split //, $uarg;

    # Get scalar value of array
    my $size = @chararray;

    # Divide the number and round up to find where our search should stop
    my $half = ceil(@chararray / 2);

    for (my $i=0; $i < $half; $i++) {
        if (lc($chararray[$i]) ne lc($chararray[-$i-1]) ) {
            say "Your string ==> '$uarg' <== is NOT a palindrome :(";
            exit;
        }
    }
    say "Your string ==> '$uarg' <== is a palindrome! :)";
}

my $arg = $ARGV[0];
chomp $arg;
check_palindrome($arg)
