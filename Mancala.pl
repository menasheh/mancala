#!/usr/bin/perl
use strict;   #Doing this causes extra work, but it also saves work in some occaisions.  Is it worth taking this out later?
use warnings;

sub twoCharString { #TODO - CHOOSE PROPER ORDER FOR METHODS AND ORGANIZE FILE
  my $opvar = shift;
  $opvar = " $opvar" if length($opvar) == 1;
  return $opvar;
}

sub twoDigitString {
  my $opvar = shift;
  $opvar = "0$opvar" if length($opvar) == 1;
  return $opvar;
}

my $mode = 1; #0 is short, #1 is long
my $p0type = 0; #0 = human, 1 = AI.  But AI is supposed to have different levels TODO
my $p1type = 0; #These could technically save defaults
my $moveDelay = 0; # TODO Is there a way to sleep for fractional seconds?

my @mancalaboard; # Why does strict require my?  That's so dumb!!!
my $p0pile;
my $p1pile;
my $pTurn;
my $p0name;
my $p1name;

sub newgame { 
@mancalaboard = ([4,4,4,4,4,4],[4,4,4,4,4,4]);
$p0pile = 0;
$p1pile = 0;
$pTurn = 0; # TODO - randomize this
}

my $textGraphics = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@     @@    @@    @@    @@    @@    @@    @@     @@\n@@     @@ 12 @@ 11 @@ 10 @@ 09 @@ 08 @@ 07 @@     @@\n@@     @@    @@    @@    @@    @@    @@    @@     @@\n@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@\n@@ #1  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #0  @@\n@@     @@    @@    @@    @@    @@    @@    @@     @@\n@@     @@ 01 @@ 02 @@ 03 @@ 04 @@ 05 @@ 06 @@     @@\n@@     @@    @@    @@    @@    @@    @@    @@     @@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";

sub displayboard {
# Clear previous board graphic first?  Once done with GUI, this wont be relevant anyway...
my $index1 = 0;
my $pattern = 0;
my $x = 0;
my $y = 1;
my $screenOut = $textGraphics;
for $index1 (1..12) { #Since this isnt nested, isnt there a default $_ var or something like that that would work foreach?
   if ($index1 > 6) { $x = 1 } else { $x = 0 };
   if ($index1 > 6) { $y = $index1 - 7 } else { $y = $index1 - 1 }; #This makes absolutely no sense, but it works.  That happens a lot in my programs.
   $pattern = twoDigitString($index1);
   $screenOut =~ s/$pattern/twoCharString($mancalaboard[$x][$y])/e;  # Why can't the pattern be a search text subroutine?
};
$screenOut =~ s/#0/twoCharString($p0pile)/e;
$screenOut =~ s/#1/twoCharString($p1pile)/e;
print $screenOut;
}

sub getHumanInput {
    if ($pTurn == 0) {
	print "\n$p0name,";
    } elsif ($pTurn == 1) {
	print "\n$p1name,";
    }
    print " which box would you like to take from?  Boxes are numbered from 1-6, starting at your goal and preceding toward your opponent's.\n\n";
    my $response = <STDIN> // die "Your shell is so old, it can't take input.  But then again, it probably can't display this error message properly either."; # clarify what exactly die is TODO
    if ($response eq "exit\n") { #Regex?  this with more options TODO
	exit;
    }
    while (int($response)==0 || $response > 6 || $mancalaboard[$pTurn][int(6-$response)] == 0) {  # number must be between 1 and 6, inclusive, and have at least 1 marble.
	print "Please choose a box from 1-6 with at least one marble therein.\n\n";
	$response = <STDIN> // die "Your shell is so old, it can't take input.  But then again, it probably can't display this error message properly either.";
	if ($response eq "exit\n") { #Regex this with more options TODO
	    exit;
	}
    }
    return int(6-$response); # This needs to be one less then actual response so it will match the index of the stuff in the @mancalaboard
}

sub getAIInput {
    die "This feature doesn't exist yet!!!";
    exit;
}

sub addToGoal {
    if ($pTurn == 0) {  # I only need one argument before the elsif, so I tried putting it up here outside of braces.  I got something about a Scalar where operator expected....
      $p0pile++;
    } elsif ($pTurn == 1) { $p1pile++; } # This seems to work, but I didnt expect to need that for some reason.
    else {
	print "Menasheh Peromsik is a horrible programmer!";
	exit;
    }
}

sub addByConquer { # HOWTO add optional argument to addToGoal?
    my $conquered = shift(@_);
     if ($pTurn == 0) {  # 
      $p0pile += $conquered; #I don't know if += works
    } elsif ($pTurn == 1) { $p1pile += $conquered; } 
    else {
	print "Menasheh Peromsik is a horrible programmer!";
	exit;
    }
}

sub distribute { # Take start position as argument and go
    # See comment below
    
    my $handPositionY = $pTurn;
    my $handPositionX = shift; #It would be nice to test for correct arguments at sub beginning # defaults to @_
    my $handContents = $mancalaboard[$handPositionY][$handPositionX];
    $mancalaboard[$handPositionY][$handPositionX] = 0;

    while ($handContents > 0) {
        # add one, continue, pay attention to long mode or short mode rules....   remember 1 - posY
        $handPositionX++;
	if ($handPositionX == 6) { # Only add to current player's goal if you're up to the current player's goal!
	    if ($handPositionY == $pTurn) {
		addToGoal();
		$handContents--;
	    }
	    $handPositionY = 1 - $handPositionY;
	    if ($handContents != 0) { # If we're done, leave it this way so that the script will know you should get another turn.
		$handPositionX = -1;
	    }
	} else {
	    $mancalaboard[$handPositionY][$handPositionX]++;
	    $handContents--; # Redundant code is better than redundant execution!  Still some redundant execution though - one extra loop for non-thisguy'sturngoal
	}
	# $handContents--; # Redundant code is better than redundant execution!

	#displayboard(); #This doesn't need to be done if doing AI calculations etc;

	#print "In hand: $handContents";
	#my $garbage = <STDIN>; # There must be a better way to pause... (Also, for testing only)
	sleep $moveDelay;

	if ($handContents == 0) {
	  if ($handPositionX == 6) { #Landed in goal 
	      return (1); # Repeat Turn - different if AI or human, so might want to seperate scripts more???  Or just return something here?  0 for no repeat 1 for repeat?  Also, does this work from within while loop?  Or should it set a variable, allow while to end?  if not, while may never reach the end! Does it matter?
	  } elsif ($mode == 0) { # short mode # Make sure to return 0, or anything other than 1, upon completion.
	      #  )  If empty and on your side and something on other side, put them all in your goal (Optional argument for addToGoal to add multiples?  Or call it multiple times?
	      if (($handPositionY == $pTurn) && ($mancalaboard[$handPositionY][$handPositionX] == 1) && ($mancalaboard[1 - $handPositionY][$handPositionX] != 0)) {
		  # Add both y and 1-y to current player's goal and zero both
		  addByConquer($mancalaboard[$handPositionY][$handPositionX] + $mancalaboard[1 - $handPositionY][5 - $handPositionX]);
		  $mancalaboard[$handPositionY][$handPositionX] = 0;
		  $mancalaboard[1 - $handPositionY][5 - $handPositionX] = 0;
	      }
	      return (0);
	  } elsif ($mode == 1) { # long mode
	      #print "handX $handPositionX handY $handPositionY";
	      #my $otherGarbage == <STDIN>;
	      if ($mancalaboard[$handPositionY][$handPositionX] == 1) {# If empty on your side, finish.  Else continue...  (Last one just added to it)
		  return (0); # Landed in empty space 
	      } else {
	          # Set hand contents to that, zero that, and go on...  (does x need to be changed?)
		  $handContents = $mancalaboard[$handPositionY][$handPositionX];
		  $mancalaboard[$handPositionY][$handPositionX] = 0;
	      }
	  }
	}

	}
}

sub sideSum {
    my $side = shift;
    my $sum = 0;
    foreach (0..5) {
	$sum += $mancalaboard[$side][$_];
    }
    return($sum);
}

sub emptyCheck {
    if (sideSum($pTurn)==0) {
	my $otherSide = sideSum(1 - $pTurn);
	addByConquer($otherSide);
	
	# TODO - CHECK IF ADDTO YOUR SIDE OR OTHER SIDE WHE YOUR SIDE CLEAR

	# According to Tzvi I'll need this: 
	#if ($pTurn==0) {

	#} elsif ($pTurn==1) {

	#} else {
	#    die "Only two players.  Must be somebody's turn."
	#}
	@mancalaboard = ([0,0,0,0,0,0],[0,0,0,0,0,0]);
	#$gameOver = 1;
	goto GameOver;
	return(1); #With the goto, this will never happen.
    } else {
	return(0);
    }
 }

my $repeatTurn = 0;

sub p0turn {
    $pTurn = 0;
    $repeatTurn = 0;
    if ($p0type == 0) {
	do {
	    $repeatTurn = distribute(getHumanInput()) - emptyCheck(); # is it possible for that to not work properly and return anything else, in error?
	    displayboard();
	} while ($repeatTurn == 1);	
    } elsif ($p0type == 1) {
	print "AI not programmed yet";
	exit;
    }
}

sub p1turn { #Is it possible to combine these too methods?
    $pTurn = 1;
    $repeatTurn = 0;
    if ($p1type == 0) {
	do {
	    $repeatTurn = distribute(getHumanInput()) - emptyCheck();
	    displayboard();
	} while ($repeatTurn == 1); #	distribute(getHumanInput()); #Will the flow of execution work properly?  Hmmm... --> Guess not? what was this extra thing doing here?	
    } elsif ($p1type == 1) {
	print "AI not programmed yet";
	exit;
    }
}

print "\n\nThis is the part where we should have some sort of navigatable menu...\n"; # TODO

newgame();
displayboard();

print "Enter a name for Player 1: "; #This isnt so strict... TODO This stuff should also be changeable in the menus
$p0name = <STDIN>; #\
$p0name =~ s/\n//;
print "Enter a name for Player 2: ";
$p1name = <STDIN>;
$p1name =~ s/\n//;

until (0) { # Infinite Loop - broken by a goto.  Is there a much better way to do that, without requireing an if statement before p1turn?
p0turn();
p1turn();
}

GameOver:

displayboard();
print "\n\n";
if ($p0pile > $p1pile) {
    print "$p0name";
} elsif ($p1pile > $p0pile) {
    print "$p1name";
} else { print "Nobody" }
print " Wins!\n\n";
exit;

# print "The human said getHumanInput()" Is this possible?  Call a subroutine in a string?
#print "Human says use box $testInput.";

# TODO - OPTION TO SET mode BEFORE GAME, 


# TODO return brakes question 1-6?

# Then polish, reorganize*, make min version, and start working on GUI or AI (by probability and permutations testing, save data to file if not exist?  or just generate it every time? how long will it take?  better if it can learn?  use cloud? anyway...) TODO

