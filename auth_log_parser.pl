#!/usr/bin/perl
use warnings;
use strict;
use IO::Uncompress::Gunzip qw( gunzip $GunzipError );

if (@ARGV != 1) {
   print "Usage: 1) perl $0 username\n";
   print "Usage: 2) perl $0 ALL\n";
   exit;
}

#This is so we don't print the first found part
if($ARGV[0] =~ "ALL") { $ARGV[0] = ''; }

#Create array of filenames so the script can parse each of them
my @unsorted;
opendir (DIR, "/var/log/") or die "$!";
my @files = grep {/auth\.log/} readdir DIR;
my %monthdata = ("Jan"=>'01',"Feb"=>'02',"Mar"=>'03',"Apr"=>'04',"May"=>'05',"Jun"=>'06',"Jul"=>'07',"Aug"=>'08',"Sep"=>'09',"Oct"=>'10',"Nov"=>'11',"Dec"=>'12');

#Parse each file in @files. Do the while loop stuff and get next file.
foreach my $file (@files) {
  #Extract logrotated files
  if ($file =~ /\.gz$/) { 
    gunzip "/var/log/$file" => "tmp";
    open(INPUT, "tmp") or die "Failed: $GunzipError\n";
  }
  else { open(INPUT, "/var/log/$file") or die "Could not open: $file\n"; }
   while (<INPUT>) {
     if ($_ =~ m/(Accepted|Failed) (password|publickey) for $ARGV[0]/i) {
        #change months to "##" so they can be sorted later
	$_ =~ s/^(\w\w\w)/$monthdata{substr($_,0,3)}/;
	#changes ex: "Sep  1" to "Sep 01" to allow for correct sorting later on
	$_ =~ s/\s\s/ 0/g; 
	$_ =~ s/Accepted/Accept/;
        $_ =~ s/(sshd\[.*\]\: |ssh2)//g;
        $_ =~ s/password/passwd/;
        $_ =~ s/publickey/pubkey/;
        $_ =~ s/ port \d+//;
	push @unsorted, $_;
    }
    else { next; }
  }
  close (INPUT);
  unlink("tmp");
}
     
#Finds the first occurrence and adds it to the
#first line if the array has anything in it
if ( @unsorted ) {
   open (OUTPUT, ">./project1_output.txt");
   #sorts the array
   my @sorted = sort { $a cmp $b } @unsorted; 
   my %monthdata2 = reverse %monthdata;
   my $firstLine = 1;

   foreach (@sorted) {
     if( $firstLine == 1 && $ARGV[0] =~ '') {
        #extracts the first found timestamp
	$_ =~ s/(\d\d)/$monthdata2{substr($_,0,2)}/;
	my $find = substr $sorted[0], 0, 15;
	print OUTPUT $ARGV[0] . " first found on " . $find . "\n";
	print OUTPUT; #prints the line that first found uses
	$firstLine = 0;
     }
     else{
	 $_ =~ s/^(\d\d)/$monthdata2{substr($_,0,2)}/;
	 print OUTPUT;
     }
  } #close for
   close (OUTPUT);
} #close if(@unsorted)
close DIR;
