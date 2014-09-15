#!/usr/bin/perl
use strict;
use warnings;

sub pad {
	my $str = shift;
	return $str . ("\x00" x (0x20 - length $str));
}

print "PSID";
print pack("n", 2); # version
print pack("n", 0x7c); # data offset
print pack("n", 0); # load address (assume .prg)
print pack("n", hex shift); # init address
print pack("n", hex shift); # play address
print pack("n", shift); # num songs
print pack("n", 1); # start song
print pack("L", 0); # speed bits; all vertical blank
print pad(shift); # song name
print pad(shift); # composer
print pad(shift); # copyright
print pack("n", 0x14); # PAL + MOS6581
print pack("C", 0); # no ---- pages
print pack("C", 0); # -- free -----
print pack("n", 0); # reserved
