#!/usr/bin/perl
use Data::Dumper qw(Dumper);
use feature qw(switch);
use strict;
no warnings;

my $cmd=$ARGV[0];
if (!$cmd) {
	$cmd="HEAT";
}

my $temp=$ARGV[1] || 22;


my %ir = (	 7 => [ 0b11110010, 0b00001101, 0b00000001, 0b11111110, 0b00100001, 0b00000001, 0b00100000 ],
		 9 => [ 0b11110010, 0b00001101, 0b00000011, 0b11111100, 0b00000001, 0b01010000, 0b00000000, 0b00000000, 0b01010001 ],
		10 => [ 0b11110010, 0b00001101, 0b00000100, 0b11111011, 0b00001001, 0b01010000, 0b00000000, 0b00000000, 0b00000011, 0b01011010 ] );

my %temps = (   17 => 0b00000000,
		18 => 0b00010000,
		19 => 0b00100000,
		20 => 0b00110000,
		21 => 0b01000000,
		22 => 0b01010000,
		23 => 0b01100000,
		24 => 0b01110000,
		25 => 0b10000000,
		26 => 0b10010000,
		27 => 0b10100000,
		28 => 0b10110000,
		29 => 0b11000000,
		30 => 0b11010000 );

my %fans = (    6 => 0b00000000, #auto
		0 => 0b00100000, #quiet
		1 => 0b01000000, #1
		2 => 0b01100000,
		3 => 0b10000000,
		4 => 0b10100000,
		5 => 0b11000000 );

my %modes = (	"COOL" => 0b00000001,
		"DRY"  => 0b00000010,
		"HEAT" => 0b00000011,
		"AUTO" => 0b00000000 );
	
my $bytes=0;

my $mode='HEAT';
my $temp=22;  #  17-30
my $fan=6;    #   0-6
my $off=0;
my $swing=1;
my $resetfilter=0;
#my $comfort_until=time
my $hipower=0;
my $eco=0;
my @codes;
my $bins;

given ($cmd) {
	when (/^HEAT/) {
		$bytes=9;
		$ir{9}[5] &= ~0b11110000; $ir{9}[5] |= $temps{$temp};
		$ir{9}[6] &= ~0b11110111; $ir{9}[6] |= $fans{$fan};
					  $ir{9}[6] |= $modes{$cmd};
		$ir{9}[8] = $ir{9}[4] ^ $ir{9}[5] ^ $ir{9}[6] ^ $ir{9}[7];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s][%s]",$bins,$bins);
	}
	when (/^COOL/) {
		$bytes=9;
		$ir{9}[5] &= ~0b11110000; $ir{9}[5] |= $temps{$temp};
		$ir{9}[6] &= ~0b11110111; $ir{9}[6] |= $fans{$fan};
					  $ir{9}[6] |= $modes{$cmd};
		$ir{9}[8] = $ir{9}[4] ^ $ir{9}[5] ^ $ir{9}[6] ^ $ir{9}[7];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s][%s]",$bins,$bins);
	}
	when (/^DRY/) {
		$bytes=9;
		$ir{9}[5] &= ~0b11110000; $ir{9}[5] |= $temps{$temp};
		$ir{9}[6] &= ~0b11110111; $ir{9}[6] |= $fans{$fan};
					  $ir{9}[6] |= $modes{$cmd};
		$ir{9}[8] = $ir{9}[4] ^ $ir{9}[5] ^ $ir{9}[6] ^ $ir{9}[7];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s][%s]",$bins,$bins);
	}
	when (/^AUTO/) {
		$bytes=9;
		$ir{9}[5] &= ~0b11110000; $ir{9}[5] |= $temps{$temp};
		$ir{9}[6] &= ~0b11110111; $ir{9}[6] |= $fans{$fan};
					  $ir{9}[6] |= $modes{$cmd};
		$ir{9}[8] = $ir{9}[4] ^ $ir{9}[5] ^ $ir{9}[6] ^ $ir{9}[7];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s][%s]",$bins,$bins);
	}
	when (/^OFF/) {
		$bytes=9;
		$ir{9}[5] &= ~0b11110000; $ir{9}[5] |= $temps{$temp};
		$ir{9}[6] &= ~0b11110111; $ir{9}[6] |= $fans{$fan};
					  $ir{9}[6] |= $modes{$cmd};
		                          $ir{9}[6] |= 0b00000100;
		$ir{9}[8] = $ir{9}[4] ^ $ir{9}[5] ^ $ir{9}[6] ^ $ir{9}[7];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s][%s]",$bins,$bins);
	}
#	when (/^ECO/) {
#                $bytes=10;
#		$ir{10}[5] &= ~0b11110000; $ir{10}[5] |= $temps{$temp};
#		$ir{10}[6] &= ~0b11110111; $ir{10}[6] |= $fans{$fan};
#					   $ir{10}[6] |= $modes{$cmd};
#		$ir{10}[8] &= ~0b00000011; $ir{10}[6] |= 0b00000011;
#		$ir{10}[9] = $ir{10}[4] ^ $ir{10}[5] ^ $ir{10}[6] ^ $ir{10}[7] ^ $ir{10}[8];
#	when (/^ECO/) {
#                $bytes=10;
#		$ir{10}[5] &= ~0b11110000; $ir{10}[5] |= $temps{$temp};
#		$ir{10}[6] &= ~0b11110111; $ir{10}[6] |= $fans{$fan};
#					   $ir{10}[6] |= $modes{$cmd};
#		$ir{10}[8] &= ~0b00000011; $ir{10}[6] |= 0b00000001;
#		$ir{10}[9] = $ir{10}[4] ^ $ir{10}[5] ^ $ir{10}[6] ^ $ir{10}[7] ^ $ir{10}[8];
#	}
	when (/^SWINGOFF/) {
		$bytes=7;
		$ir{7}[5] &= ~0b00000011; $ir{7}[5] |= 0b00000010;
		$ir{7}[6] = $ir{7}[4] ^ $ir{7}[5];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s]",$bins);
	}
	when (/^SWING$/) {
                $bytes=7;
		$ir{7}[5] &= ~0b00000011; $ir{7}[5] |= 0b00000001;
		$ir{7}[6] = $ir{7}[4] ^ $ir{7}[5];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s]",$bins);
	}
	when (/^SWINGFIX/) {
                $bytes=7;
		$ir{7}[5] &= ~0b00000011; $ir{7}[5] |= 0b00000000;
		$ir{7}[6] = $ir{7}[4] ^ $ir{7}[5];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s]",$bins);
	}
	when (/^RESETFILTER/) {
                $bytes=7;
		$ir{7}[5] &= ~0b01100000; $ir{7}[5] |= 0b01100000;
		$ir{7}[6] = $ir{7}[4] ^ $ir{7}[5];
                @codes = @{ %ir{$bytes} };
		$bins=join("", map { sprintf "%08b", $_ } @codes);
		$bins=sprintf("[%s]",$bins);
	}
	default { exit; }
}



use ExtUtils::testlib;   # adds blib/* directories to @INC
use txpulses;

my $pin=1<<12;

printf("Transmit: "); printf "%02x ", $_  for @codes;

my $ret = txpulses::txpulses($pin,38000,4330,4350,500,1650,550,8300,$bins);

if ($ret<0) {
	print "Error.\n";
} else {
	print "... Sent.\n";
}

