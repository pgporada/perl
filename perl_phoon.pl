#!/usr/bin/perl
#
#   phoon - show the phase of the moon
#
#   Translated from Jef Poskanzer's phoon.c (http://www.acme.com/software/phoon/)
#   and John Walker's moontool.c astro libraries (http://www.fourmilab.ch/moontool/)
#   by James Allenspach <jima@legnog.com>. The copyright from the original source:
#   
#   ** Copyright (C) 1986,1987,1988,1995 by Jef Poskanzer <jef@mail.acme.com>.
#   ** All rights reserved.
#   **
#   ** Redistribution and use in source and binary forms, with or without
#   ** modification, are permitted provided that the following conditions
#   ** are met:
#   ** 1. Redistributions of source code must retain the above copyright
#   **    notice, this list of conditions and the following disclaimer.
#   ** 2. Redistributions in binary form must reproduce the above copyright
#   **    notice, this list of conditions and the following disclaimer in the
#   **    documentation and/or other materials provided with the distribution.
#   ** 
#   ** THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#   ** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   ** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ** ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#   ** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#   ** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#   ** OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#   ** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   ** LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#   ** OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   ** SUCH DAMAGE.
#


use Date::Parse;
use POSIX;
use strict;

use constant {

    SECSPERMINUTE   => 60,
    SECSPERHOUR     => (60 * 60),
    SECSPERDAY      => (24 * 60 * 60),
    PI              => 3.1415926535897932384626433,
    DEFAULTNUMLINES => 23,
    ASPECTRATIO     => 0.5,         # If you change the aspect ratio, the canned backgrounds won't work.


    epoch           => 2444238.5,   # 1980 January 0.0

# Constants defining the Sun's apparent orbit

    elonge          => 278.833540,  # Ecliptic longitude of the Sun at epoch 1980.0
    elongp          => 282.596403,  # Ecliptic longitude of the Sun at perigee
    eccent          => 0.016718,    # Eccentricity of Earth's orbit
    sunsmax         => 1.495985e8,  # Semi-major axis of Earth's orbit, km
    sunangsiz       => 0.533128,    # Sun's angular size, degrees, at semi-major axis distance

# Elements of the Moon's orbit, epoch 1980.0

    mmlong          => 64.975464,   # Moon's mean lonigitude at the epoch 
    mmlongp         => 349.383063,  # Mean longitude of the perigee at the epoch
    mlnode          => 151.950429,  # Mean longitude of the node at the epoch
    minc            => 5.145396,    # Inclination of the Moon's orbit
    mecc            => 0.054900,    # Eccentricity of the Moon's orbit 
    mangsiz         => 0.5181,      # Moon's angular size at distance a from Earth 
    msmax           => 384401.0,    # Semi-major axis of Moon's orbit in km 
    mparallax       => 0.9507,      # Parallax at distance a from Earth 
    synmonth        => 29.53058868, # Synodic month (new Moon to new Moon) 
    lunatbase       => 2423436.0,   # Base date for E. W. Brown's numbered series of lunations (1923 January 16) 

# Properties of the Earth

    earthrad        => 6378.16,     #  Radius of Earth in kilometres 

    EPSILON         =>  1E-6,

};

my $usage = "usage:  $0  [ -l <lines> ]  [ <date/time> ]\n";

sub putseconds {
    my($secs) = @_;
    my($days,$hours,$minutes);
    
    $days = int($secs / SECSPERDAY);
    $secs -= $days * SECSPERDAY;
    $hours = int($secs / SECSPERHOUR);
    $secs -= $hours * SECSPERHOUR;
    $minutes = int($secs / SECSPERMINUTE);
    $secs -= $minutes * SECSPERMINUTE;

    return sprintf( "%ld %2ld:%02ld:%02ld", $days, $hours, $minutes, $secs );
}

sub unix_to_julian {
    return $_[0] / 86400.0 + 2440587.4999996666666666666;
}


sub fixangle { return ($_[0] - 360.0 * (POSIX::floor($_[0] / 360.0))); }
sub torad { return ($_[0] * (PI / 180.0)); }    # Deg->Rad
sub todeg { return ($_[0] * (180.0 / PI)); }    # Rad->Deg

sub dsin  { return sin(torad($_[0]));      }    # sin from Deg
sub dcos  { return cos(torad($_[0]));      }    # cos from Deg

sub kepler {    # solve the equation of Kepler
    my($m, $ecc) = @_;
    my($e,$delta);

    $e = $m = torad($m);
    do {
        $delta = $e - $ecc * sin($e) - $m;
        $e -= $delta / (1 - $ecc * cos($e));
    } while (abs ($delta) > EPSILON);
    return $e;
}


sub phase {
    my($pdate) = @_;

    # Calculation of the Sun's position 

    my($Day) = $pdate - epoch;  # Date within epoch 
    my($N) = fixangle((360 / 365.2422) * $Day); # Mean anomaly of the Sun 
    my($M) = fixangle($N + elonge - elongp);    # Convert from perigee co-ordinates to epoch 1980.0
    my($Ec) = kepler($M, eccent);   # Solve equation of Kepler */
    $Ec = sqrt((1 + eccent) / (1 - eccent)) * tan($Ec / 2);
    $Ec = 2 * todeg(atan($Ec)); # True anomaly
    my($Lambdasun) = fixangle($Ec + elongp);    # Sun's geocentric ecliptic longitude
    
    # Orbital distance factor
    my($F) = ((1 + eccent * cos(torad($Ec))) / (1 - eccent * eccent));
    my($SunDist) = sunsmax / $F;    # Distance to Sun in km 
    my($SunAng) = $F * sunangsiz;   # Sun's angular size in degrees

    # Calculation of the Moon's position 

    # Moon's mean longitude
    my($ml) = fixangle(13.1763966 * $Day + mmlong);

    # Moon's mean anomaly 
    my($MM) = fixangle($ml - 0.1114041 * $Day - mmlongp);

    # Moon's ascending node mean longitude 
    my($MN) = fixangle(mlnode - 0.0529539 * $Day);

    # Evection
    my($Ev) = 1.2739 * sin(torad(2 * ($ml - $Lambdasun) - $MM));

    # Annual equation
    my($Ae) = 0.1858 * sin(torad($M));

    # Correction term 
    my($A3) = 0.37 * sin(torad($M));

    # Corrected anomaly 
    my($MmP) = $MM + $Ev - $Ae - $A3;

    # Correction for the equation of the centre 
    my($mEc) = 6.2886 * sin(torad($MmP));

    # Another correction term 
    my($A4) = 0.214 * sin(torad(2 * $MmP));

    # Corrected longitude 
    my($lP) = $ml + $Ev + $mEc - $Ae + $A4;

    # Variation 
    my($V) = 0.6583 * sin(torad(2 * ($lP - $Lambdasun)));

    # True longitude 
    my($lPP) = $lP + $V;

    # Corrected longitude of the node 
    my($NP) = $MN - 0.16 * sin(torad($M));

    # Y inclination coordinate 
    my($y) = sin(torad($lPP - $NP)) * cos(torad(minc));

    # X inclination coordinate 
    my($x) = cos(torad($lPP - $NP));

    # Ecliptic longitude 
    my($Lambdamoon) = todeg(atan2($y, $x));
    $Lambdamoon += $NP;

    # Ecliptic latitude 
    my($BetaM) = todeg(asin(sin(torad($lPP - $NP)) * sin(torad(minc))));

    # Calculation of the phase of the Moon 

    # Age of the Moon in degrees 
    my($MoonAge) = $lPP - $Lambdasun;

    # Phase of the Moon 
    my($MoonPhase) = (1 - cos(torad($MoonAge))) / 2;

    # Calculate distance of moon from the centre of the Earth 

    my($MoonDist) = (msmax * (1 - mecc * mecc)) /
       (1 + mecc * cos(torad($MmP + $mEc)));

    # Calculate Moon's angular diameter 

    my($MoonDFrac) = $MoonDist / msmax;
    my($MoonAng) = mangsiz / $MoonDFrac;

    # Calculate Moon's parallax 

    my($MoonPar) = mparallax / $MoonDFrac;

    return (
        fixangle($MoonAge) / 360.0,                 # terminator phase angle
        $MoonPhase,                                 # moon phase
        synmonth * (fixangle($MoonAge) / 360.0),    # age of moon in days
        $MoonDist,                                  # distance in km
        $MoonAng,                                   # angular diameter in degrees
        $SunDist,                                   # distance to Sun
        $SunAng,                                    # Sun's angular diameter
    );
}


# jyear - Convert Julian date to year, month, day.

sub jyear {
    my($td) = @_;
    my($j,$d,$y,$m);

    $td += 0.5;                #Astronomical to civil 
    $j = POSIX::floor($td);
    $j -= 1721119.0;
    $y = POSIX::floor(((4 * $j) - 1) / 146097.0);
    $j = ($j * 4.0) - (1.0 + (146097.0 * $y));
    $d = POSIX::floor($j / 4.0);
    $j = POSIX::floor(((4.0 * $d) + 3.0) / 1461.0);
    $d = ((4.0 * $d) + 3.0) - (1461.0 * $j);
    $d = POSIX::floor(($d + 4.0) / 4.0);
    $m = POSIX::floor(((5.0 * $d) - 3) / 153.0);
    $d = (5.0 * $d) - (3.0 + (153.0 * $m));
    $d = POSIX::floor(($d + 5.0) / 5.0);
    $y = (100.0 * $y) + $j;
    if ($m < 10.0) {
        $m += 3;
    } else {
        $m -= 9;
        ++$y;
    }
    return ($y,$m,$d);
}


# meanphase -  Calculates time of the mean new Moon for a given base date.  This argument K to this function is
# the precomputed synodic month index, given by:
#
#   K = (year - 1900) * 12.3685
#
# where year is expressed as a year and fractional year.

sub meanphase {
    my($sdate,$k) = @_;
    my($t,$t2,$t3,$nt1);

    # Time in Julian centuries from 1900 January 0.5
    $t = ($sdate - 2415020.0) / 36525;
    $t2 = $t * $t;          # Square for frequent use 
    $t3 = $t2 * $t;         # Cube for frequent use 

    $nt1 = 2415020.75933 + synmonth * $k
        + 0.0001178 * $t2
        - 0.000000155 * $t3
        + 0.00033 * dsin(166.56 + 132.87 * $t - 0.009173 * $t2);

    return $nt1;
}


# truephase -  Given a K value used to determine the mean phase of the new moon, and a phase
# selector (0.0, 0.25, 0.5, 0.75), obtain the true, corrected phase time.

sub truephase {
    my($k, $phase) = @_;
    my($t,$t2,$t3, $pt, $m, $mprime, $f);
    my($apcor) = 0;

    $k += $phase;   # Add phase to new moon time 
    $t = $k / 1236.85;  # Time in Julian centuries from 1900 January 0.5 
    $t2 = $t * $t;      # Square for frequent use 
    $t3 = $t2 * $t;     # Cube for frequent use 
    $pt = 2415020.75933        # Mean time of phase 
         + synmonth * $k
         + 0.0001178 * $t2
         - 0.000000155 * $t3
         + 0.00033 * dsin(166.56 + 132.87 * $t - 0.009173 * $t2);

    $m = 359.2242               # Sun's mean anomaly 
        + 29.10535608 * $k
        - 0.0000333 * $t2
        - 0.00000347 * $t3;
    $mprime = 306.0253          # Moon's mean anomaly 
        + 385.81691806 * $k
        + 0.0107306 * $t2
        + 0.00001236 * $t3;
    $f = 21.2964                # Moon's argument of latitude 
        + 390.67050646 * $k
        - 0.0016528 * $t2
        - 0.00000239 * $t3;
    if (($phase < 0.01) || (abs($phase - 0.5) < 0.01)) {

       # Corrections for New and Full Moon 

       $pt +=     (0.1734 - 0.000393 * $t) * dsin($m)
            + 0.0021 * dsin(2 * $m)
            - 0.4068 * dsin($mprime)
            + 0.0161 * dsin(2 * $mprime)
            - 0.0004 * dsin(3 * $mprime)
            + 0.0104 * dsin(2 * $f)
            - 0.0051 * dsin($m + $mprime)
            - 0.0074 * dsin($m - $mprime)
            + 0.0004 * dsin(2 * $f + $m)
            - 0.0004 * dsin(2 * $f - $m)
            - 0.0006 * dsin(2 * $f + $mprime)
            + 0.0010 * dsin(2 * $f - $mprime)
            + 0.0005 * dsin($m + 2 * $mprime);
       $apcor = 1;
    } elsif ((abs($phase - 0.25) < 0.01 || (abs($phase - 0.75) < 0.01))) {
       $pt +=     (0.1721 - 0.0004 * $t) * dsin($m)
            + 0.0021 * dsin(2 * $m)
            - 0.6280 * dsin($mprime)
            + 0.0089 * dsin(2 * $mprime)
            - 0.0004 * dsin(3 * $mprime)
            + 0.0079 * dsin(2 * $f)
            - 0.0119 * dsin($m + $mprime)
            - 0.0047 * dsin($m - $mprime)
            + 0.0003 * dsin(2 * $f + $m)
            - 0.0004 * dsin(2 * $f - $m)
            - 0.0006 * dsin(2 * $f + $mprime)
            + 0.0021 * dsin(2 * $f - $mprime)
            + 0.0003 * dsin($m + 2 * $mprime)
            + 0.0004 * dsin($m - 2 * $mprime)
            - 0.0003 * dsin(2 * $m + $mprime);
       if ($phase < 0.5) {
          # First quarter correction 
          $pt += 0.0028 - 0.0004 * dcos($m) + 0.0003 * dcos($mprime);
       } else {
          # Last quarter correction 
          $pt += -0.0028 + 0.0004 * dcos($m) - 0.0003 * dcos($mprime);
       }
       $apcor = 1;
    }
    if (!$apcor) {
       die "TRUEPHASE called with invalid phase selector.\n";
    }
    return $pt;
}


# phasehunt5 - Find time of phases of the moon which surround the current date.  Five phases are found, starting
# and ending with the new moons which bound the current lunation.

sub phasehunt5 {
    my($sdate) = @_;
    my($adate, $k1, $k2, $nt1, $nt2, $yy, $mm, $dd);

    $adate = $sdate - 45;

    ($yy,$mm,$dd) = jyear($adate);
    $k1 = POSIX::floor(($yy + (($mm - 1) * (1.0 / 12.0)) - 1900) * 12.3685);

    $adate = $nt1 = meanphase($adate, $k1);
    while (1) {
        $adate += synmonth;
        $k2 = $k1 + 1;
        $nt2 = meanphase($adate, $k2);
        if ($nt1 <= $sdate && $nt2 > $sdate) {
            last;
        }
        $nt1 = $nt2;
        $k1 = $k2;
    }
    return [
        truephase ($k1, 0.0),
        truephase ($k1, 0.25),
        truephase ($k1, 0.5),
        truephase ($k1, 0.75),
        truephase ($k2, 0.0),
    ];
}

# phasehunt2 -  Find time of phases of the moon which surround the current date.  Two phases are found.

sub phasehunt2 {
    my($sdate) = @_;
    
    my(@phases,@which,$phases5);

    $phases5 = phasehunt5( $sdate );
    $phases[0] = $phases5->[0];
    $which[0] = 0.0;
    $phases[1] = $phases5->[1];
    $which[1] = 0.25;
    if ( $phases[1] <= $sdate ) {
        $phases[0] = $phases[1];
        $which[0] = $which[1];
        $phases[1] = $phases5->[2];
        $which[1] = 0.5;
        if ( $phases[1] <= $sdate ) {
            $phases[0] = $phases[1];
            $which[0] = $which[1];
            $phases[1] = $phases5->[3];
            $which[1] = 0.75;
            if ( $phases[1] <= $sdate ) {
                $phases[0] = $phases[1];
                $which[0] = $which[1];
                $phases[1] = $phases5->[4];
                $which[1] = 0.0;
            }
        }
    }
    return \@which, \@phases;
}


sub putmoon {
    my($t, $numlines, $atfiller) = @_;
    my $secsynodic = 29*SECSPERDAY + 12*SECSPERHOUR + 44*SECSPERMINUTE + 3;

    my(%background) = (
    
        '18' => [   "             .----------.            ",
                    "         .--'   o    .   `--.        ",
                    "       .'@  @@@@@@ O   .   . `.      ",
                    "     .'@@  @@@@@@@@   @@@@   . `.    ",
                    "   .'    . @@@@@@@@  @@@@@@    . `.  ",
                    "  / @@ o    @@@@@@.   @@@@    O   @\\ ",
                    "  |@@@@               @@@@@@     @@| ",
                    " / @@@@@   `.-.    . @@@@@@@@  .  @@\\",
                    " | @@@@   --`-'  .  o  @@@@@@@      |",
                    " |@ @@                 @@@@@@ @@@   |",
                    " \\      @@    @   . ()  @@   @@@@@  /",
                    "  |   @      @@@         @@@  @@@  | ",
                    "  \\  .   @@  @\\  .      .  @@    o / ",
                    "   `.   @@@@  _\\ /     .      o  .'  ",
                    "     `.  @@    ()---           .'    ",
                    "       `.     / |  .    o    .'      ",
                    "         `--./   .       .--'        ",
                    "             `----------'            "
        ],
        
        '19' => [   "              .----------.             ",
                    "          .--'   o    .   `--.         ",
                    "       .-'@  @@@@@@ O   .   . `-.      ",
                    "     .' @@  @@@@@@@@   @@@@   .  `.    ",
                    "    /     . @@@@@@@@  @@@@@@     . \\   ",
                    "   /@@  o    @@@@@@.   @@@@    O   @\\  ",
                    "  /@@@@                @@@@@@     @@@\\ ",
                    " . @@@@@   `.-./    . @@@@@@@@  .  @@ .",
                    " | @@@@   --`-'  .      @@@@@@@       |",
                    " |@ @@        `      o  @@@@@@ @@@@   |",
                    " |      @@        o      @@   @@@@@@  |",
                    " ` .  @       @@     ()   @@@  @@@@   '",
                    "  \\     @@   @@@@        . @@   .  o / ",
                    "   \\   @@@@  @@\\  .           o     /  ",
                    "    \\ . @@     _\\ /    .      .-.  /   ",
                    "     `.    .    ()---        `-' .'    ",
                    "       `-.    ./ |  .   o     .-'      ",
                    "          `--./   .       .--'         ",
                    "              `----------'             "
        ],
        'pumpkin19' => [        "              @@@@@@@@@@@@             ",
                                "          @@@@@@@@@@@@@@@@@@@@         ",
                                "       @@@@@@@@@@@@@@@@@@@@@@@@@@      ",
                                "     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    ",
                                "    @@@@        @@@@@@@@        @@@@   ",
                                "   @@@@@@      @@@@@@@@@@      @@@@@@  ",
                                "  @@@@@@@@    @@@@@@@@@@@@    @@@@@@@@ ",
                                " @@@@@@@@@@  @@@@@@  @@@@@@  @@@@@@@@@@",
                                " @@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@",
                                " @@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@",
                                " @@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@",
                                " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
                                "  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ",
                                "   @@@@@                @@      @@@@@  ",
                                "    @@@@@@                    @@@@@@   ",
                                "     @@@@@@@@              @@@@@@@@    ",
                                "       @@@@@@@@@        @@@@@@@@@      ",
                                "          @@@@@@@@@@@@@@@@@@@@         ",
                                "              @@@@@@@@@@@@             "
        ],

        '21' => [   "                .----------.               ",
                    "           .---'   O   . .  `---.          ",
                    "        .-'@ @@@@@@  .  @@@@@    `-.       ",
                    "      .'@@  @@@@@@@@@  @@@@@@@   .  `.     ",
                    "     /   o  @@@@@@@@@  @@@@@@@      . \\    ",
                    "    /@  o   @@@@@@@@@.  @@@@@@@   O    \\   ",
                    "   /@@@  .   @@@@@\@o   @@@@@@@@@@     @@\\  ",
                    "  /@@@@@            . @@@@@@@@@@@@@ o @@@\\ ",
                    " .@@@@@ O  `.-./ .     @@@@@@@@@@@@    @@ .",
                    " | @@@@   --`-'      o    @@@@@@@@ @@@@   |",
                    " |@ @@@       `   o     .  @@  . @@@@@@@  |",
                    " |      @@  @        .-.    @@@  @@@@@@@  |",
                    " `  . @       @@@    `-'  . @@@@  @@@@  o '",
                    "  \\     @@   @@@@@ .         @@  .       / ",
                    "   \\   @@@@  @\\@@    /  . O   .    o  . /  ",
                    "    \\o  @@     \\ \\  /       .   .      /   ",
                    "     \\    .    .\\.-.___  .     .  .-. /    ",
                    "      `.         `-'             `-'.'     ",
                    "        `-.  o  / |    o   O  .  .-'       ",
                    "           `---.    .    .  .---'          ",
                    "                `----------'               "
        ],
        '22' => [   "                .------------.               ",
                    "            .--'   o     . .  `--.           ",
                    "         .-'    .    O   .      . `-.        ",
                    "       .'@    @@@@@@@   .  @@@@@     `.      ",
                    "     .'@@@  @@@@@@@@@@@   @@@@@@@  .   `.    ",
                    "    /     o @@@@@@@@@@@   @@@@@@@      . \\   ",
                    "   /@@  o   @@@@@@@@@@@.   @@@@@@@   O    \\  ",
                    "  /@@@@   .   @@@@@@\@o    @@@@@@@@@@    @@@\\ ",
                    "  |@@@@@               . @@@@@@@@@@@@  @@@@| ",
                    " /@@@@@  O  `.-./  .      @@@@@@@@@@@   @@  \\",
                    " | @@@@    --`-'      o    . @@@@@@@ @@@@   |",
                    " |@ @@@  @@  @ `   o  .-.     @@  . @@@@@@  |",
                    " \\             @@@    `-'  .   @@@  @@@@@@  /",
                    "  | . @  @@   @@@@@ .          @@@@  @@@ o | ",
                    "  \\     @@@@  @\\@@    /  .  O   @@ .     . / ",
                    "   \\  o  @@     \\ \\  /          . . o     /  ",
                    "    \\      .    .\\.-.___   .  .  .  .-.  /   ",
                    "     `.           `-'              `-' .'    ",
                    "       `.    o   / |     o   O   .   .'      ",
                    "         `-.    /     .      .    .-'        ",
                    "            `--.        .     .--'           ",
                    "                `------------'               "
        ],

        
        '23' => [   "                 .------------.                ",
                    "             .--'  o     . .   `--.            ",
                    "          .-'   .    O   .       . `-.         ",
                    "       .-'@   @@@@@@@   .  @@@@@      `-.      ",
                    "      /@@@  @@@@@@@@@@@   @@@@@@@   .    \\     ",
                    "    ./    o @@@@@@@@@@@   @@@@@@@       . \\.   ",
                    "   /@@  o   @@@@@@@@@@@.   @@@@@@@   O      \\  ",
                    "  /@@@@   .   @@@@@@\@o    @@@@@@@@@@     @@@ \\ ",
                    "  |@@@@@               . @@@@@@@@@@@@@ o @@@@| ",
                    " /@@@@@  O  `.-./  .      @@@@@@@@@@@@    @@  \\",
                    " | @@@@    --`-'       o     @@@@@@@@ @@@@    |",
                    " |@ @@@        `    o      .  @@   . @@@@@@@  |",
                    " |       @@  @         .-.     @@@   @@@@@@@  |",
                    " \\  . @        @@@     `-'   . @@@@   @@@@  o /",
                    "  |      @@   @@@@@ .           @@   .       | ",
                    "  \\     @@@@  @\\@@    /  .  O    .     o   . / ",
                    "   \\  o  @@     \\ \\  /         .    .       /  ",
                    "    `\\     .    .\\.-.___   .      .   .-. /'   ",
                    "      \\           `-'                `-' /     ",
                    "       `-.   o   / |     o    O   .   .-'      ",
                    "          `-.   /     .       .    .-'         ",
                    "             `--.       .      .--'            ",
                    "                 `------------'                "
        ],
        
        '24' => [   "                  .------------.                 ",
                    "             .---' o     .  .   `---.            ",
                    "          .-'   .    O    .       .  `-.         ",
                    "        .'@   @@@@@@@   .   @@@@@       `.       ",
                    "      .'@@  @@@@@@@@@@@    @@@@@@@   .    `.     ",
                    "     /    o @@@@@@@@@@@    @@@@@@@       .  \\    ",
                    "    /@  o   @@@@@@@@@@@.    @@@@@@@   O      \\   ",
                    "   /@@@   .   @@@@@@\@o     @@@@@@@@@@     @@@ \\  ",
                    "  /@@@@@               .  @@@@@@@@@@@@@ o @@@@ \\ ",
                    "  |@@@@  O  `.-./  .       @@@@@@@@@@@@    @@  | ",
                    " / @@@@    --`-'       o      @@@@@@@@ @@@@     \\",
                    " |@ @@@     @  `           .   @@     @@@@@@@   |",
                    " |      @           o          @      @@@@@@@   |",
                    " \\       @@            .-.      @@@    @@@@  o  /",
                    "  | . @        @@@     `-'    . @@@@           | ",
                    "  \\      @@   @@@@@ .            @@   .        / ",
                    "   \\    @@@@  @\\@@    /  .   O    .     o   . /  ",
                    "    \\ o  @@     \\ \\  /          .    .       /   ",
                    "     \\     .    .\\.-.___    .      .   .-.  /    ",
                    "      `.          `-'                 `-' .'     ",
                    "        `.   o   / |      o    O   .    .'       ",
                    "          `-.   /      .       .     .-'         ",
                    "             `---.       .      .---'            ",
                    "                  `------------'                 "
        ],
        
        '29' => [   "                      .--------------.                     ",
                    "                 .---'  o        .    `---.                ",
                    "              .-'    .    O  .         .   `-.             ",
                    "           .-'     @@@@@@       .             `-.          ",
                    "         .'@@   @@@@@@@@@@@       @@@@@@@   .    `.        ",
                    "       .'@@@  @@@@@@@@@@@@@@     @@@@@@@@@         `.      ",
                    "      /@@@  o @@@@@@@@@@@@@@     @@@@@@@@@     O     \\     ",
                    "     /        @@@@@@@@@@@@@@  @   @@@@@@@@@ @@     .  \\    ",
                    "    /@  o      @@@@@@@@@@@   .  @@  @@@@@@@@@@@     @@ \\   ",
                    "   /@@@      .   @@@@@@ o       @  @@@@@@@@@@@@@ o @@@@ \\  ",
                    "  /@@@@@                  @ .      @@@@@@@@@@@@@@  @@@@@ \\ ",
                    "  |@@@@@    O    `.-./  .        .  @@@@@@@@@@@@@   @@@  | ",
                    " / @@@@@        --`-'       o        @@@@@@@@@@@ @@@    . \\",
                    " |@ @@@@ .  @  @    `    @            @@      . @@@@@@    |",
                    " |   @@                         o    @@   .     @@@@@@    |",
                    " |  .     @   @ @       o              @@   o   @@@@@@.   |",
                    " \\     @    @       @       .-.       @@@@       @@@      /",
                    "  |  @    @  @              `-'     . @@@@     .    .    | ",
                    "  \\ .  o       @  @@@@  .              @@  .           . / ",
                    "   \\      @@@    @@@@@@       .                   o     /  ",
                    "    \\    @@@@@   @@\\@@    /        O          .        /   ",
                    "     \\ o  @@@       \\ \\  /  __        .   .     .--.  /    ",
                    "      \\      .     . \\.-.---                   `--'  /     ",
                    "       `.             `-'      .                   .'      ",
                    "         `.    o     / | `           O     .     .'        ",
                    "           `-.      /  |        o             .-'          ",
                    "              `-.          .         .     .-'             ",
                    "                 `---.        .       .---'                ",
                    "                      `--------------'                     "
        ],
        'hubert29' => [ "                      .--------------.                     ",
                        "                 .---'  o        .    `---.                ",
                        "              .-'    .    O  .         .   `-.             ",
                        "           .-'     @@@@@@       .             `-.          ",
                        "         .'@@   @@@@@@@@@@@       @@@@@@@   .    `.        ",
                        "       .'@@@  @@@@@ ___====-_  _-====___ @         `.      ",
                        "      /@@@  o _--~~~#####//      \\\\#####~~~--_ O     \\     ",
                        "     /     _-~##########// (    ) \\\\##########~-_  .  \\    ",
                        "    /@  o -############//  :\\^^/:  \\\\############-  @@ \\   ",
                        "   /@@@ _~############//   (\@::@)   \\\\############~_ @@ \\  ",
                        "  /@@@ ~#############((     \\\\//     ))#############~ @@ \\ ",
                        "  |@@ -###############\\\\    (oo)    //###############- @ | ",
                        " / @ -#################\\\\  / \"\" \\  //#################- . \\",
                        " |@ -###################\\\\/      \\//###################-  |",
                        " | _#/:##########/\\######(   /\\   )######/\\##########:\\#_ |",
                        " | :/ :#/\\#/\\#/\\/  \\#/\\##\\  :  :  /##/\\#/  \\/\\#/\\#/\\#: \\: |",
                        " \\ \"  :/  V  V  \"   V  \\#\\: :  : :/#/  V   \"  V  V  \\:  \" /",
                        "  | @ \"   \"  \"      \"   / : :  : : \\   \"      \"  \"   \"   | ",
                        "  \\ .  o       @  @@@@ (  : :  : :  )  @@  .           . / ",
                        "   \\      @@@    @@@@ __\\ : :  : : /__            o     /  ",
                        "    \\    @@@@@   @@\\@(vvv(VVV)(VVV)vvv)       .        /   ",
                        "     \\ o  @@@       \\ \\  /  __        .   .     .--.  /    ",
                        "      \\      .     . \\.-.---                   `--'  /     ",
                        "       `.             `-'      .                   .'      ",
                        "         `.    o     / | `           O     .     .'        ",
                        "           `-.      /  |        o             .-'          ",
                        "              `-.          .         .     .-'             ",
                        "                 `---.        .       .---'                ",
                        "                      `--------------'                     "
        ],
        '32' => [       "                         .--------------.                        ",
                        "                   .----'  o        .    `----.                  ",
                        "                .-'     .    O  .          .   `-.               ",
                        "             .-'      @@@@@@       .              `-.            ",
                        "           .'@     @@@@@@@@@@@       @@@@@@@@    .   `.          ",
                        "         .'@@    @@@@@@@@@@@@@@     @@@@@@@@@@         `.        ",
                        "       .'@@@ o   @@@@@@@@@@@@@@     @@@@@@@@@@      o    `.      ",
                        "      /@@@       @@@@@@@@@@@@@@  @   @@@@@@@@@@  @@     .  \\     ",
                        "     /            @@@@@@@@@@@   .  @@   @@@@@@@@@@@@     @@ \\    ",
                        "    /@  o     .     @@@@@@ o       @   @@@@@@@@@@@@@@ o @@@@ \\   ",
                        "   /@@@                        .       @@@@@@@@@@@@@@@  @@@@@ \\  ",
                        "  /@@@@@                     @      .   @@@@@@@@@@@@@@   @@@   \\ ",
                        "  |@@@@@     o      `.-./  .             @@@@@@@@@@@@ @@@    . | ",
                        " / @@@@@           __`-'       o          @@       . @@@@@@     \\",
                        " |@ @@@@ .        @    `    @            @@    .     @@@@@@     |",
                        " |   @@       @                    o       @@@   o   @@@@@@.    |",
                        " |          @                             @@@@@       @@@       |",
                        " |  . .  @      @  @       o              @@@@@     .    .      |",
                        " \\            @                .-.      .  @@@  .           .   /",
                        "  |    @   @   @      @        `-'                     .       / ",
                        "  \\   .      @   @                   .            o            / ",
                        "   \\     o          @@@@   .                .                 /  ",
                        "    \\       @@@    @@@@@@        .                    o      /   ",
                        "     \\     @@@@@   @@\\@@    /         o           .         /    ",
                        "      \\  o  @@@       \\ \\  /  ___         .   .     .--.   /     ",
                        "       `.      .       \\.-.---                     `--'  .'      ",
                        "         `.             `-'       .                    .'        ",
                        "           `.    o     / |              O      .     .'          ",
                        "             `-.      /  |         o              .-'            ",
                        "                `-.           .         .      .-'               ",
                        "                   `----.        .       .----'                  ",
                        "                         `--------------'                        "
        ],


    );

    my(@qlits) = (
    "New Moon +     ",
    "First Quarter +",
    "Full Moon +    ",
    "Last Quarter + ",
    );
    my(@nqlits) = (
    "New Moon -     ",
    "First Quarter -",
    "Full Moon -    ",
    "Last Quarter - ",
    );

    # Find the length of the atfiller string.
    my($atflrlen) = length( $atfiller );

    # Figure out the phase.
    my($jd) = unix_to_julian( $t );
    
    my($pctphase,$cphase,$aom,$cdist,$cangdia, $csund, $csuang) = phase($jd);
    my($angphase) = $pctphase * 2.0 * PI;
    my($mcap) = -cos( $angphase );

    my($clocknow) = time;
    # Randomly cheat and generate Hubert.
    if ( time % 13 == 3 && $cphase > 0.8 ) {
        $numlines = 29;
        $clocknow = 3;
    }

    # Figure out how big the moon is. 
    my($yrad) = $numlines / 2.0;
    my($xrad) = $yrad / ASPECTRATIO;
    my($numcols) = $xrad * 2;

    # Figure out some other random stuff.
    my($midlin) = int($numlines / 2);
    my($which,$phases) = phasehunt2($jd);

    # Now output the moon, a slice at a time.
    my($atflridx) = 0;
    for ( my $lin = 0; $lin < $numlines; ++$lin ) {
    
        # Compute the edges of this slice.
        my($y) = $lin + 0.5 - $yrad;
        my($xright) = $xrad * sqrt( 1.0 - ( $y * $y ) / ( $yrad * $yrad ) );
        my($xleft) = -$xright;
        if ( $angphase >= 0.0 && $angphase < PI ) {
            $xleft = $mcap * $xleft;
        } else {
            $xright = $mcap * $xright;
        }

        my($colleft)  = int($xrad + 0.5) + int($xleft + 0.5);
        my($colright) = int($xrad + 0.5) + int($xright + 0.5);
    
        # Now output the slice.
        my($col) = 0;
        for ( $col = 0; $col < $colleft; ++$col ) { print " "; }
        for ( ; $col <= $colright; ++$col ) {
        my($c) = '@';
        if (exists($background{$numlines})) {
            $c = substr($background{$numlines}->[$lin], $col, 1);

            if ($numlines == 19 && (localtime(time))[4] == 9 && $clocknow % (33 - (localtime(time))[3]) == 1) {
                $c = substr($background{pumpkin19}->[$lin], $col, 1);
            } elsif ($numlines == 29 && $clocknow % 23 == 3) {
                $c = substr($background{hubert29}->[$lin], $col, 1);
            }
        }
        
        if ($c ne '@') {
            print $c;
        } else {
            print substr($atfiller,$atflridx++,1);
            $atflridx %= $atflrlen;
        }
    }
    
        if ( $numlines <= 27 ) {
            # Output the end-of-line information, if any.
            if ( $lin == $midlin - 2 ) {
                print "\t" . $qlits[int($which->[0] * 4.0 + 0.001)];
            } elsif ( $lin == $midlin - 1) {
                print "\t" . putseconds(int(($jd - $phases->[0]) * SECSPERDAY));
            } elsif ( $lin == $midlin ) {
                print "\t" . $nqlits[int($which->[1] * 4.0 + 0.001)];
            } elsif ( $lin == $midlin + 1 ) {
                print "\t" . putseconds(int(($phases->[1] - $jd) * SECSPERDAY));
            }
        }
    
        print "\n";
    }
}



#
# main
#

my($numlines) = DEFAULTNUMLINES;

if ($ARGV[0] eq '-l') {
    shift @ARGV;
    if ($ARGV[0] == 0) { print $usage; exit 1; }  # just in case the user types in "-l not_a_number"
    $numlines = int(shift @ARGV) || DEFAULTNUMLINES;
}

my($t) = 0;

if (@ARGV >= 1 && @ARGV <= 3) {  # date provided ?
    $t = str2time(join(' ', @ARGV));
    if (!defined($t)) { print $usage; exit 1; }
} elsif (@ARGV == 0) {
    $t = time;
} else {
    print $usage; exit 1;
}

# Pseudo-randomly decide what the moon is made of, and print it.
if (time % 17 == 3) {
    putmoon($t, $numlines, 'GREENCHEESE');
} else {
    putmoon($t, $numlines, '@');
}

exit 0;

__END__

=head1 NAME

phoon - show the PHase of the mOON

=head1 SYNOPSIS

phoon [-l lines] [date]

=head1 DESCRIPTION

I<Phoon> displays the phase of the moon, either currently
or at a specified date / time.
Unlike other such programs, which just tell you how long since first quarter
or something like that, phoon I<shows> you the phase with a cute little picture.
You can vary the size of the picture with the -l flag, but only some
sizes have pictures defined - other sizes use @'s.

The perl version is a direct translation of the original C version, and 
includes all of the features, moon images and Easter eggs of the original
program.

=head1 SEE ALSO

perl(1).

=head1 AUTHOR

Translated from Jef Poskanzer's original phoon.c and John Walker's
moontool.c by James Allenspach E<lt>jima@legnog.comE<gt>. See the source of
the program for copyright information.

=cut
