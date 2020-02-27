#! /use/bin/perl

use strict;
use warnings;

my $vcf = $ARGV[0];
my $outfile = $ARGV[1];

if (@ARGV!=2){
	print "perl anno_vcf.pl <vcf_file> <outfile>\n";die;
}
open (IN,$vcf) or die $!;
open (OUT,">$outfile") or die $!;

while (<IN>){
	chomp;
	next if (/^$/ || /^#/ || /^Chr/);
	my @lines = split(/\t/,$_);
	my $alt_type = $lines[61];
	my @alt_info = split(/:/,$alt_type);
	my @alt_num = split(/\//,$alt_info[0]);
	if (@alt_num == 2){
		print OUT "$_\n";
	}else{
		my $info = join("\t",@lines[0..60]);
		my $alt_after = join(":",@alt_info[1..(scalar @alt_info)-1]);
		for (my $i = 0;$i<(@alt_num-1);$i++){
			my $genotype = $alt_num[0]."/".$alt_num[$i+1];
			my $end_info = $info."\t".$genotype.":".$alt_after;
			if ($i == 0){
				print OUT "$end_info\n";
			}else{
				my $next_lines =<IN>;
				chomp($next_lines);
				my @lines_next = split(/\t/,$next_lines);
				my $alt_type_next = $lines_next[61];
				my @alt_info_next = split(/:/,$alt_type_next);
				my $info_next = join("\t",@lines_next[0..60]);
				my $alt_after_next = join(":",@alt_info_next[1..(scalar @alt_info_next)-1]);
				my $end_info_next = $info_next."\t".$genotype.":".$alt_after_next;
				print OUT "$end_info_next\n";
			}
		}
	}

}
close IN;
close OUT;
