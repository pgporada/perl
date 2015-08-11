#!/usr/bin/perl
# WHO:   PGP
# WHAT:  This script will check if the string you input is a palindrome.
# WHERE: Used in an interview for Tome Software

use strict;
use warnings;
use POSIX qw/ceil/;
use feature 'say';

usage() if (@ARGV < 1 || @ARGV == 0);
sub usage {
    say "Usage:";
    say "Enter a string as your argument";
    exit;
}

# Take the first argument as the input
my $arg = $ARGV[0];
chomp $arg;
my @chararray = split //, $arg;

# Get scalar value of array
my $size = @chararray;
say $size;

# Divide the number and round up to find what index-1 our search should stop
my $half = ceil(@chararray / 2);
say $half;

for (my $i=0; $i < $half; $i++) {
    if (lc($chararray[$i]) ne lc($chararray[-$i-1]) ) {
        say "Your string ==> '$arg' <== is NOT a palindrome :(";
        exit;
    }
}
say "Your string ==> '$arg' <== is a palindrome! :)";
