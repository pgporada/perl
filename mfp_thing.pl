#!/usr/bin/env perl
use warnings;
use strict;
use Getopt::Long;

my $dec_days = 0;
my $inc_days = 0;
my $help;
my $username = "breakdancingcat";
my $lastweek = "7 days ago";

usage() if (@ARGV < 1 or ! GetOptions('d=i' => \$dec_days . 'h' => \$help . 'i=i' => \$inc_days . 'u=s' => \$username . 'w' => \$lastweek));

sub usage {
        my $BOLD  = `tput bold || tput md`;
	my $RESET = `tput sgr0 || tput me`;
        print "Unknown option: @_\n" if ( @_ );
        print "usage: $0 [ " . $BOLD . "-d #" . $RESET . " ] [ " . $BOLD . "-i #" . $RESET . " ] [ " . $BOLD . "-h" . $RESET . " ] [ " . $BOLD . "-u username" . $RESET . " ] [ " . $BOLD ."-w" . $RESET . " ]\n\n";
        print "\t" . $BOLD . "-d" . $RESET . "   :   Specify a number to decrement X days and a print a single entry\n";
        print "\t" . $BOLD . "-h" . $RESET . "   :   Show this usage message\n";
        print "\t" . $BOLD . "-i" . $RESET . "   :   Specify a number to increment X days and print a range of entries\n";
        print "\t" . $BOLD . "-u" . $RESET . "   :   Defaults to breakdancingcat\n";
        print "\t" . $BOLD . "-w" . $RESET . "   :   Print entries for the past week\n\n";
	print "----Examples----\n";
	print "To run with defaults for the current day: mfpscraper.pl\n";
	print "To run yesterdays date with a different user: "  . $BOLD . "mfpscraper.pl -d 1 -u username " . $RESET . "\n";
	print "To get the range from 5 days ago to yesterday: "  . $BOLD . "mfpscraper.pl -d 5 -i 5"  . $RESET . "\n";
	print "To print the past week: " . $BOLD . "mfpscraper.pl -w" . $RESET . "\n";
       
       exit;
}

