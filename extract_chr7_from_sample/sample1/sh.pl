#! /usr/bin/perl

my $in1 = $ARGV[0];
my $in2 = $ARGV[1];
my $od = $ARGV[2];
my @gene;
open (IN,$in1) or die $!;
while (<IN>){
	chomp;next if (/^$/);
	push @gene,$_;
}
close IN;

my $head = `less $in2|head -n 1`;
my @title = split /\s+/,$head;

my @code;
for (my $i=0;$i<@gene;$i++){
	for (my $j=0;$j<@title;$j++){
		if ($gene[$i] eq $title[$j]){
			push 
		}
	}
}
