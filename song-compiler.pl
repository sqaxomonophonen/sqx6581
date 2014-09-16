#!/usr/bin/perl
use strict;
use warnings;

my %prototypes;

sub oph ($) {
	my $path = shift;
	open F, "<", $path or die("$path: $!");
	while (<F>) {
		if (/^\s*(\w+):;\(([^)]*)\)/) {
			my $cmd = $1;
			$prototypes{$cmd} = $2;
			my $n = length $2;
			print "; SQX command '$cmd', $n argument(s)\n";
		}
		print $_;
	}
	close F;
}

sub sqx ($) {
	my $bytes = 0;
	my $path = shift;
	open F, "<", $path or die("$path: $!");
	my %lists;
	my $listref;

	while (my $line = <F>) {
		while ($line) {
			$line =~ s/^\s+//g;
			last if substr($line,0,1) eq ";";
			$line =~ /^([a-zA-Z0-9_*$(,)]*:?)(.*)$/;
			last if (not $1) and (not $2);
			die("?SYNTAX ERROR in: $line") if (not $1) and $2;
			my $token = $1;
			$line = $2;
			if ($token =~ /^(.+):$/) {
				my $label = $1;
				die "$label defined more than once" if exists $lists{$label};
				my @newlist;
				$listref = \@newlist;
				$lists{$label} = $listref;
			} else {
				die "no label for $token" if not $listref;
				push @$listref, $token;
			}
		}
	}
	close F;

	die "no song (*:) definition" if not exists $lists{"*"};

	print "sqx_songs: .word " . join(",", @{$lists{"*"}}) . "\n";
	$bytes += 2 * @{$lists{"*"}};
	my %seen;
	my @ptns;
	my %ptni;
	foreach my $track (grep { not $seen{$_}++ } @{$lists{"*"}}) {
		die "no list for track '$track'" if not exists $lists{$track};
		print "$track: .byte ";
		foreach my $ptn (@{$lists{$track}}) {
			if (not exists $ptni{$ptn}) {
				$ptni{$ptn} = scalar @ptns;
				push @ptns, $ptn;
			}
			print "$ptni{$ptn},";
			$bytes++;
		}
		print "\$ff\n";
		$bytes++;
	}

	print "sqx_patterns_lo: .byte " . join(",", map { "<$_" } @ptns) . "\n";
	print "sqx_patterns_hi: .byte " . join(",", map { ">$_" } @ptns) . "\n";
	$bytes += 2 * @ptns;

	%seen = ();
	my @cmds;
	my %cmdi;
	foreach my $ptn (@ptns) {
		print "$ptn: .byte ";
		foreach my $call (@{$lists{$ptn}}) {
			$call =~ /^(\w+)\((.*)\)$/ or die("invalid call '$call'");
			my $cmd = $1;
			my @args = split /,/, $2;

			die "no prototype for cmd '$cmd'" if not exists $prototypes{$cmd};

			if (not exists $cmdi{$cmd}) {
				$cmdi{$cmd} = scalar @cmds;
				push @cmds, $cmd;
			}

			print "$cmdi{$cmd},";
			$bytes++;
			foreach my $proto (split //, $prototypes{$cmd}) {
				die "unknown proto $proto" if $proto ne '$';
				die "too few args for $cmd" if not @args;
				my $arg = shift @args;
				print "$arg,";
				$bytes++;
			}
			die "too many args for $cmd" if @args;
		}
		print "\$ff\n";
		$bytes++;
	}

	print "sqx_commands_lo: .byte " . join(",", map { "<$_" } @cmds) . "\n";
	print "sqx_commands_hi: .byte " . join(",", map { ">$_" } @cmds) . "\n";
	$bytes += 2 * @cmds;

	print "; song data: $bytes bytes\n";
}

my $got_sqx = 0;

foreach (@ARGV) {
	if (/\.oph$/) {
		oph $_;
	} elsif (/\.sqx$/) {
		die "only one .sqx allowed" if $got_sqx;
		sqx $_;
		$got_sqx = 1;
	} else {
		die "invalid file extension for $_";
	}
	print "\n";
}

