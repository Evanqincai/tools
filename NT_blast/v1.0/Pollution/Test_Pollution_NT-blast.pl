#!/usr/bin/perl -w
#
#Copyright (c)BIO_MARK 2012
#Writer:		 Wang ChunMei<wangchm@biomarker.com.cn>
#Program Data:	 2012.
#Modifier:		 Wang ChunMei<wangchm@biomarker.com.cn>
#Last Modified:  2012.
#modify by wangchm 2012-10-24, blast by lib instead of Lane_lib 
my $ver="1.1";

use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

######################.........................................
my %opts;
GetOptions(\%opts,"fqdir=s","num=s","only_mRNA","cpu=s","od=s","h" );

#&help()if(defined $opts{h});
if (!defined($opts{fqdir})||!defined($opts{od})||defined($opts{h}))
{
		print <<"Usage End.";
	
	 Description:

		                         version:$ver

	 usage:Regular projects check pollution by blast with NT database


             -fqdir                 fq file dir                                      must be given

             -num                     every library blast num[default 2000]       option

             -only_mRNA               choice mRNA(library name as:*-T[0-9]* or *-E[0-9]*) do blast               option

             -cpu                     do blast cup num[default 16]       option

             -od                      outdir                                       must be given

             -h                   help document

Usage End.
	exit;
}
#####

###############Time
my $Time_start;
$Time_start=sub_format_datetime(localtime(time()));
print "\nStart Time:[$Time_start]\n\n";
################
my $config=$opts{config};
my $fqdir=$opts{fqdir};
my $BlastNum=defined $opts{num} ? $opts{num}: 2000;
my $cpu=defined $opts{cpu} ? $opts{cpu}: 16;
my $curdir=`pwd`;chomp $curdir;
chdir $fqdir;$fqdir=`pwd`;chomp $fqdir;chdir $curdir;
my $outdir=$opts{od};
mkdir $outdir if(!-d $outdir);
chdir $outdir;$outdir=`pwd`;chomp $outdir;chdir $curdir;

##1 Every library picks up 10,000 reads which  convert from fastq to fasta format
#calculation Q20 for avoid error coming from low quailty 
my $fa="$outdir/Pollution_NTblast.fa";
#open FA,">$fa"||die "Can't creat the file: [$fa]\n";
#my @fq=glob "$fqdir/*_1.fq";
#my %Quality;my %filter;
#my $TotalReads;
#foreach my $fq1 (@fq)
#{
#	#next if($fq1=~/other/i);
#
#	my $base=basename($fq1);my @seg=split /\_/,$base;
#	if (defined $opts{only_mRNA}) 
#	{
#		next if($base!~/\-T[0-9]|\-E[0-9]|CK|T/);
#	}
#	$base=$seg[0]."_".$seg[1];
#	if (exists $filter{$base}) 
#	{
#		next;
#	}
#	else
#	{
#		$filter{$base}=1;
#	}
#	open IN,$fq1||die "Can't open the file: [$fq1]\n";
#	my $count;
#	my ($Qtotal,$Q20total);
#	while (<IN>) 
#	{
#		my $seq=<IN>;
#		<IN>;
#		my $qual=<IN>;
#		#my ($seq,$qual)=(split /\n/,$_)[1,3];
#		chomp $seq;chomp $qual;
#		my @q=unpack("C*",$qual);
#		my @q20=grep {$_>=54} @q;
#		next if(@q20!=@q);
#		$count++;
#		last if($count>$BlastNum);
#		$Qtotal+=@q;$Q20total+=@q20;
#		print FA ">$base\-$count\n$seq\n";
#	}
#	$Quality{$base}=int($Q20total/$Qtotal*10000)/100;
#	$TotalReads+=$count;
#	close IN;
#}
#close FA;
#exit if(!-s $fa);
#$/="\n";
##output quality statistics 
#my $QualStat="$outdir/Quality.stats.xls";
#open Q,">$QualStat"||die "Can't creat the file: [$QualStat]\n";
#foreach  (sort keys %Quality) 
#{
#	print Q "L00$_\t$Quality{$_}\n";
#}
#close Q;

###2.Run annotations pipeline
#my $cuts=int($TotalReads/50)+1;
#print "perl $Bin/Annotation/Plant_pipeline/Anno_pipeline.pl $fa --cuts $cuts --nt --outdir $outdir --cpu 50\n";
#system "perl $Bin/Annotation/Plant_pipeline/Anno_pipeline.pl $fa --cuts $cuts --nt --outdir $outdir --cpu 50";
#system "perl /share/nas1/mengf/bin/Project/RNA_seq/Anno_Pipline/Plant_pipeline/Anno_pipeline.pl $fa --annotation 1 --nt --outdir $outdir --cpu 10";
system "$Bin/blastall -b 100 -v 100 -p blastn -e 1e-05 -F F -d /share/nas2/database/ncbi/nt -i $fa -a $cpu  -o $fa.nt.blast";
system "perl $Bin/Annotation/Plant_pipeline/blast_parser.pl -nohead -tophit 1 -topmatch 1 $fa.nt.blast > $fa.nt.blast.tab.best";

open (NT,"$fa.nt.blast.tab.best")or die "cant open file $fa.nt.blast.tab.best";
open (OUT,">$fa.nt.blast.tab.best.anno.txt")or die "cant open file $fa.nt.blast.tab.best.anno.txt";
print OUT "#NtGeneID\tAnnotation\n";
while (<NT>) 
{
	chomp;
	my @anno = split /\t/, $_;
	print OUT "$anno[0]\t$anno[15]\n";
}
close OUT;
close NT;



my %LibStat;
my %LibOutput;
my %count;
open IN,"$fa.nt.blast.tab.best.anno.txt"|| die "cant open file $fa.nt.blast.tab.best.anno.txt";
<IN>;
while (<IN>) 
{
	chomp;
	my @col=split /\t/,$_;
	my $name=$col[0];$name=~s/\-\d+$//;
	$LibOutput{$name}.="$_\n";
	
	my @tmp=split /\s+/,$col[1];#print "$col[1]\n$tmp[0]\n$tmp[1]\n";die;
	if (!$tmp[0] or !$tmp[1]) 
	{
		warn "There is no space in species name: $col[1]\n";
		next;
	}
	my $AlignmentSpeice="$tmp[0] $tmp[1]";
	$LibStat{$name}{$AlignmentSpeice}++;
	$count{$name}++;
}
my $PoStat="$outdir/summary.Pollution.stats.xls";
my $SimplifyPoStat="$outdir/Simplify.Pollution.stats.xls";
my $Simple_SimplifyPoStat="$outdir/Simplify.Pollution.Simple.stats.xls";
open OUT,">$PoStat"||die "Can't creat the file: [$PoStat]\n";
open SIM,">$SimplifyPoStat"||die "Can't creat the file: [$SimplifyPoStat]\n";
open SIMINF,">$Simple_SimplifyPoStat"||die "Can't creat the file: [$Simple_SimplifyPoStat]\n";
print SIMINF	"#Sample\tNT_AlignRatio\tfirst_align(percent)\tsecond_align(percent)\n";
foreach my $k1 (sort keys %LibStat) 
{
	my %simplify;
	my $simplify;my $other=0;my $len=0;
	foreach my $k2 (sort {$LibStat{$k1}{$b} <=> $LibStat{$k1}{$a}}keys %{$LibStat{$k1}}) 
	{
		my $ratio=int ($LibStat{$k1}{$k2}/$count{$k1}*10000)/100;
		print OUT "$k1\:\t$k2\t$ratio\n";
		$len=length($k2)if ($len<length($k2));
		if ($ratio>=1) 
		{
			$simplify{$k2}=$ratio;
		}
		else
		{
			$other+=$ratio;
		}
		
	}
	$other=int($other*100)/100 if ($other!=0);
	print SIM  "$k1\n";
	print SIMINF	"$k1\t";
	my $AlignRatio=(int($count{$k1}/$BlastNum*10000))/100;
	print SIM  "BlastNum:$BlastNum\tAlignNum:$count{$k1}\tAlignRatio:$AlignRatio\%\n";
	print SIMINF	"$AlignRatio\%\t";
	my $syj=1;
	foreach my $s (sort {$simplify{$b}<=>$simplify{$a}} keys %simplify) 
	{
		printf SIM "\t%-${len}s\%-4s\n",$s,$simplify{$s};
		print SIMINF "$s\($simplify{$s}\)\t" if($syj==1);
		print SIMINF "$s\($simplify{$s}\)\n" if($syj==2);
		
		$syj++;
	}
		printf SIM "\t%-${len}s\%-4s\n","Other",$other;
		print SIMINF "Other\($other\)\n" if($syj==2);

	print SIM "\n\n";
}
close OUT;
close SIM;
close SIMINF;
system "mkdir  $outdir/LibAnno" if(!-d "$outdir/LibAnno");
foreach my $k1 (sort keys %LibOutput) 
{
	my $DivideFile="$outdir/LibAnno/$k1.Pollution_NTblast.fa.nt.anno.txt";
	open OUT,">$DivideFile"||die "Can't creat the file: [$DivideFile]\n";
	print OUT $LibOutput{$k1};
	close OUT;
}

###############Time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

###############Subs





sub sub_format_datetime  
{
	#Time calculation subroutine
    my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}
