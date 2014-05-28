#!/usr/bin/env perl
use warnings;
use strict;
use Term::ANSIColor qw(:constants);

my $cur_position = 'X';
my $undiscovered = '-';
my $revealed = 'o';
my $impasse = '#';
my $count_N = 0;
my $count_S = 0;
my $count_E = 0;
my $count_W = 0;

system("clear"); 

# data structure: Y[0], X[1], has_been_revealed?[2], boss[3], exit N[4], exit S[5], exit E[6], exit W[7]
my @MapAoA = ( [0,0,0,0,], #This first array  is current Y[0], current X[1], previous Y[2], previous X[3]
	       [0,0,1,0,0,1,0,0], #[1] array.
	       [1,0,0,0,1,1,0,0], #[2] array..
	       [2,0,0,0,1,1,0,0], #[3] array...
	       [3,0,0,0,1,1,0,0], #[4] etc
	       [4,0,0,0,1,0,1,0], #[5] etc.
	       [0,1,0,0,0,0,0,0], #[6] etc..
	       [1,1,0,0,0,0,0,0], #[7] etc...
	       [2,1,0,0,0,1,1,0], #[8]
	       [3,1,0,0,1,1,0,0], #[9]
	       [4,1,0,0,1,0,0,1], #[10]
	       [0,2,0,0,0,1,1,0], #[11]
	       [1,2,0,0,1,0,1,0], #[12]
	       [2,2,0,0,0,0,1,1], #[13]
	       [3,2,0,0,0,1,0,0], #[14]
	       [4,2,0,0,1,0,1,0], #[15]
	       [0,3,0,0,0,0,1,1], #[16]
	       [1,3,0,0,0,1,0,1], #[17]
	       [2,3,0,0,1,1,0,1], #[18]
	       [3,3,0,0,1,1,0,0], #[19]
	       [4,3,0,0,1,0,0,1], #[20]
	       [0,4,0,0,0,1,0,1], #[21]
	       [1,4,0,0,1,1,0,0], #[22]
	       [2,4,0,1,0,1,0,0], #[23]
	       [3,4,0,0,0,1,0,0], #[24]
	       [4,4,0,0,0,0,0,0]  #[25]
	     );

sub CHECK_MAP {
    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
            if ($MapAoA[0]->[0] == $i && $MapAoA[0]->[1] == $j) { 
	        print "[$cur_position]"; 
		
		# Sets the previous location
		#splice @{$MapAoA[0]},2,0,@{$MapAoA[0]}->[0];
		#splice @{$MapAoA[0]},3,0,@{$MapAoA[0]}->[1];
		push @{$MapAoA[0]},@{$MapAoA[0]}->[0];
		shift @{$MapAoA[0]};
		push @{$MapAoA[0]},@{$MapAoA[0]}->[1];
		shift @{$MapAoA[0]};
		
		# Sets the current y and current x location based on the $i and $j value
		#splice @{$MapAoA[0]},0,0,$i;
		#splice @{$MapAoA[0]},1,0,$j;
		push @{$MapAoA[0]},$i;
		shift @{$MapAoA[0]};
		push @{$MapAoA[0]},$j;
		shift @{$MapAoA[0]};
            }
            elsif (@{$MapAoA[$j]} == 1 && $MapAoA[0]->[0] != $i && $MapAoA[0]->[1] != $j) { print "[$revealed]"; }
            else { print "[$undiscovered]"; }
            }
        print "\n";
    }
}


sub TRAVEL_DIR {
    print "Which direction do you choose to travel? [NESW]\n=> ";
    my $input = uc(<STDIN>);
    chomp($input);

    if ($input =~ 'N') { 
        print "You travelled North\n";
        
	$count_N+=1;
    }
    elsif ($input =~ 'S') { 
        print "You travelled South\n";
	$count_S+=1;
	push @{$MapAoA[0]},$count_S;
	shift @{$MapAoA[0]};
    }
    elsif ($input =~ 'E') {
        print "You travelled East\n";

	$count_E+=1;
    }
    elsif ($input =~ 'W') {
        print "You travelled West\n";

	$count_W+=1;
    }
    else { TRAVEL_DIR(); }
}


sub main {
    while(1) {
        system("clear");
#	for my $i ( 0 .. $#MapAoA ) {
#	      for my $j ( 0 .. $#{ $MapAoA[$i] } ) {
#	          print $MapAoA[$i][$j];
#	      }
#	      print "\n";
#	}

        print @$_, "\n" foreach ( @MapAoA );
        print "\n";
        CHECK_MAP();
	TRAVEL_DIR();
    }
}

main();
