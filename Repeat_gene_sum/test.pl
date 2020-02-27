#! /usr/bin/perl
use strict;
use warnings;

my $gene_name = $ARGV[0];
my $FPKM =$ARGV[1];
my $outdir = $ARGV[2];
if (@ARGV != 3){
	print "perl $0 gene_name FPKM outdir\n";
	die;
}
`mkdir $outdir` unless (-d $outdir);
############################
my %gene;
open (IN,$gene_name) or die $!;
while (<IN>){
	chomp;next if (/^#/ || /^$/);
	$gene{$_} = 1;
}
close IN;
my %FPKM;
open (FPKM,$FPKM) or die $!;
my $title = <FPKM>;
while (<FPKM>){
	chomp;next if (/^#/ || /^$/);
	my @lines = split(/\s+/);
	if (exists $gene{$lines[0]}){
		for (my $i = 1 ; $i <@lines; $i++){
			push @{$FPKM{$lines[0]}{$i}},$lines[$i];		
		}
	}
}
close FPKM;
open (OUT,">$outdir/sum.txt") or die $!;
print OUT "$title";
foreach my $GENE (sort keys %FPKM){
	print OUT  "$GENE\t";
	foreach my $num (sort {$a <=> $b} keys %{$FPKM{$GENE}}){
		my $sum = 0;
		for (my $i=0;$i<@{$FPKM{$GENE}{$num}};$i++){
			my $n = @{$FPKM{$GENE}{$num}};
			$sum = $sum + ${$FPKM{$GENE}{$num}}[$i];
		}
		print OUT "$sum\t";
	}
	print OUT "\n";
}
close OUT;
