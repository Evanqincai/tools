#! /usr/bin/perl

use strict;
use warnings;

$/ = ">";
my %seq;
open (FA,"$ARGV[0]") or die $!;
while (<FA>){
	chomp;
	next if (/^$/);
	my ($chr,$seq) = split(/\n/,$_,2);
	$seq =~s/\n//g;
	$seq{$chr} = $seq;
}
close FA;

$/="\n";
open (POS,$ARGV[1]) or die $!;
open (OUT,">pos_sequence.fa") or die $!;
while (<POS>){
	chomp;
	next if (/^$/);
	my @lines = split(/\s+/,$_);
	if ($seq{$lines[0]}){
		my $lens = $lines[2] - $lines[1];
		my $sequence = substr($seq{$lines[0]},$lines[1],$lens);
		print OUT ">$lines[0]\n$sequence\n"; 
	}
}
close POS;
close OUT;
