#!/usr/bin/perl
# WHO:   PGP
# WHAT:  This script will check if the string you input is a palindrome.
use strict;
use warnings;
use POSIX qw/ceil/;
use feature 'say';

usage() if (@ARGV < 1);
sub usage {
    say "Usage:";
    say "Enter a string as your argument";
    say "Example:";
    say "$0 \"taco cat\"";
    exit;
}

sub check_palindrome {
    my $uarg = shift;
    my $orig = $uarg;

    # Remove all non-alphanumeric chars
    $uarg =~ s/[^\w]//g;
    
    my @chararray = split //, $uarg;
    
    # Get scalar value of array
    my $size = @chararray;
    
    # Divide the number and round up to find where our search should stop
    my $half = ceil(@chararray / 2);

    for (my $i=0; $i < $half; $i++) {
        if (lc($chararray[$i]) ne lc($chararray[-$i-1]) ) {
            say "Your string ==> '$orig' <== is NOT a palindrome :(";
            exit;
        }
    }
    say "Your string ==> '$orig' <== is a palindrome! :)";
}

my $arg = $ARGV[0];
chomp $arg;
check_palindrome($arg)
