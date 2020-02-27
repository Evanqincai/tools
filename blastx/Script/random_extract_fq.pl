#!/usr/bin/perl
use strict;
use warnings;
#use PerlIO::gzip;

my $seqfile=shift;
my $n=shift;
#my $total=shift; ##the total reads counts of the original fastq.
my $record=shift; ##the record of the reads position

if($seqfile=~/gz$/)
#{open IN,"<:gzip","$seqfile" or die "can't open the file:$!";}
#else
{open IN,"$seqfile" or die "Can't open the file:$!";}
my $line=0;
while (<IN>)
{
	$line++;
}
close IN;
my $total=$line/4;

my $p=0;
my %tag;
while (1) {
	my $num=int(rand($total));
	next if (defined $tag{$num});
	$tag{$num}=1;
	$p++;
	last if ($p==$n);
}

open RE,">$record";
foreach my $c (sort {$a<=>$b} keys %tag)
{
	print RE "$c\n";
}
close RE;

my $count=0;
#if($seqfile=~/gz$/)
#{open IN,"<:gzip","$seqfile" or die "can't open the file:$!";}
#else
{open IN,"$seqfile" or die "Can't open the file:$!";}
while (<IN>) {
	chomp;
	$count++;
	if (exists $tag{$count}) {
		s/\@/\>/;
		print "$_\n";
		my $seq=<IN>;
		chomp $seq;
		print "$seq\n";
		<IN>;
		<IN>;
	}
	else
	{
		<IN>;
		<IN>;
		<IN>;
	}
}
close IN;
