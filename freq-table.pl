#!/usr/bin/perl
use strict;
use warnings;

my $octaves = 8;
my $N = $octaves * 12;

sub F {
	my $n = shift;
	my $f = 440.0 * (2.0 ** (($n - 57) / 12.0));
	return int($f / 0.06097); # so sayeth Programmer's Reference
}

print "freqlo:\n";
for (my $i = 0; $i < $N; $i++) {
	my $flo = F($i) & 255;
	print ".byte $flo\n";
}

print "freqhi:\n";
for (my $i = 0; $i < $N; $i++) {
	my $fhi = F($i) >> 8;
	print ".byte $fhi\n";
}
