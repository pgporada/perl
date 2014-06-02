#!/usr/bin/env perl
use warnings;
use strict;
#use Term::ANSIColor qw(:constants);
use Term::ExtendedColor qw(:all);

my $user_color_choice = "sandybrown";
my $cur_position = 'X';
my $undiscovered = ' ';
my $revealed = fg('blue3','-');
my $impasse = fg($user_color_choice,'#');
my $shop = fg('yellow9','$');
my $count_NS = 0;
my $count_EW = 0;
my $is_shop = 0;
my $has_bomb = 0;
my $impasse01_cleared = 0;
my $impasse11_cleared = 0;

system("clear"); 

#Location on the grid = current X[0], current Y[1], previous X[2], previous Y[3]
my @MapLoc = (0,0,0,0);

# data structure: X[0], Y[1], state[2], boss[3], exit N[4], exit S[5], exit E[6], exit W[7]
#states will be 0=undiscovered,1=discovered,2=impasse,3=shop
my @MapAoA = ( [0,0,1,0,0,1,0,0], #[0] array.
	       [1,0,2,0,1,1,0,0], #[1] array..
	       [2,0,0,0,1,1,0,0], #[2] array...
	       [3,0,0,0,1,1,0,0], #[3] etc
	       [4,0,0,0,1,0,1,0], #[4] etc.
	       [0,1,0,0,0,0,0,0], #[5] etc..
	       [1,1,2,0,0,0,0,0], #[6] etc...
	       [2,1,0,0,0,1,1,0], #[7]
	       [3,1,0,0,1,1,0,0], #[8]
	       [4,1,0,0,1,0,0,1], #[9]
	       [0,2,0,0,0,1,1,0], #[10]
	       [1,2,0,0,1,0,1,0], #[11]
	       [2,2,0,0,0,0,1,1], #[12]
	       [3,2,0,0,0,1,0,0], #[13]
	       [4,2,0,0,1,0,1,0], #[14]
	       [0,3,0,0,0,0,1,1], #[15]
	       [1,3,0,0,0,1,0,1], #[16]
	       [2,3,3,0,1,1,0,1], #[17]
	       [3,3,0,0,1,1,0,0], #[18]
	       [4,3,0,0,1,0,0,1], #[19]
	       [0,4,0,0,0,1,0,1], #[20]
	       [1,4,0,0,1,1,0,0], #[21]
	       [2,4,0,1,0,1,0,0], #[22]
	       [3,4,0,0,0,1,0,0], #[23]
	       [4,4,0,0,0,0,0,0]  #[24]
	     );

sub CHECK_MAP {
    # Inner/Outer exist so that I can get 0-24 for X,Y to access the correct array and check if the 
    # current spot has been revealed. Without these, the entire row or column would be marked as revealed
    my $innerCount = 0;
    my $outerCount = 0;
    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
	    # Prints your current position out from the @MapLoc array
            if ($MapLoc[0] == $j && $MapLoc[1] == $i) { 
	        print "[$cur_position]";
		# Changes the current positions state to "1" to reveal it
		# Upon traveling, the CHECK_MAP function is called so this will update your map correctly
		if (@{$MapAoA[$innerCount]}->[2] == 0) { splice @{$MapAoA[$innerCount]},2,1,1; }
		# This allows the shop to be revealed, by default it is hidden. Basically it checks 
		# if the state is set to 3 then updates the $is_shop global var accordingly. 
		# Probably not the smartest way, but eh it works so hey!
		if (@{$MapAoA[$innerCount]}->[2] == 3) { $is_shop = 1; }
	    }
	    elsif (@{$MapAoA[$innerCount]}->[2] == 3 && $is_shop == 1) { print "[$shop]"; }
            elsif (@{$MapAoA[$innerCount]}->[2] == 2) { print "[$impasse]"; }
            elsif (@{$MapAoA[$innerCount]}->[2] == 1) { print "[$revealed]"; }
	    else { print "[$undiscovered]"; }
	    $innerCount+=1;
            }
        print "\n";
	$outerCount+=1;
    }
}


sub TRAVEL_DIR {
    print "Which direction do you choose to travel? [NESW]\n=> ";
    my $input = uc(<STDIN>);
    chomp($input);

    # @MapLock is (X,Y,X,Y) current X[0], current Y[1], previous X[2], previous Y[3]
    if ($input =~ 'N') { 
        print "You travelled North\n";
	$count_NS -= 1;
	if ($MapLoc[1] <= 0) { 
	    splice @MapLoc,1,1,0;
	    $count_NS += 1;
	}
	elsif (@{$MapAoA[2]} == 2) {
	    splice @MapLoc,1,1,$count_NS;
	    $count_NS += 1;
	}
	else {
	    splice @MapLoc,3,1,$count_NS+1; # Previous
	    splice @MapLoc,1,1,$count_NS; #Current
	}
    }

    elsif ($input =~ 'S') { 
        print "You travelled South\n";
	$count_NS += 1;
	if ($MapLoc[1] >= 4) {
	    splice @MapLoc,1,1,4;
	    $count_NS -= 1;
	}
	elsif (@{$MapAoA[2]} == 2) { 
	    splice @MapLoc,1,1,$count_NS;
	    $count_NS -= 1;
	}
	else {
	    splice @MapLoc,3,1,$count_NS-1; # Previous
	    splice @MapLoc,1,1,$count_NS; # Current
	}
    }

    elsif ($input =~ 'E') {
        print "You travelled East\n";
	$count_EW += 1;
	if ($MapLoc[0] >= 4 && @{$MapAoA[2]} != 2) {
	    splice @MapLoc,0,1,4;
	    $count_EW -= 1;
	}
	elsif (@{$MapAoA[2]} == 2) {
	    splice @MapLoc,0,1,$MapLoc[2];
	    $count_EW -= 1;
	}
	else {
	    splice @MapLoc,2,1,$count_EW-1; # Previous 
	    splice @MapLoc,0,1,$count_EW; # Current
	}
    }

    elsif ($input =~ 'W') {
        print "You travelled West\n";
	$count_EW -= 1;

	if ($MapLoc[0] <= 0) {
	    splice @MapLoc,0,1,0;
	    $count_EW += 1;
	}
	elsif (@{$MapAoA[2]} == 2) {
	    $count_EW += 1;
	    splice @MapLoc,0,1,$count_EW;
	}
	else {
	    splice @MapLoc,2,1,$count_EW+1; # Previous
	    splice @MapLoc,0,1,$count_EW; # Current
	}
    }

}

sub main {
    while(1) {
       system("clear");

       # Debug data structure stuff
       # print @$_, "\n" foreach ( @MapAoA );
       print "0123\n";
       print "XYXY\n";
       print "CCPP\n";
       print $_  foreach ( @MapLoc );
       print "\n";
       CHECK_MAP();
       TRAVEL_DIR();
    }
}

main();
