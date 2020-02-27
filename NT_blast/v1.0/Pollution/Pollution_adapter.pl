#!/usr/bin/perl -w
#
#Copyright (c)BIO_MARK 2012
#Writer:		 wangchunmei<wangchm@biomarker.com.cn>
#Program Data:	 2012.
#Modifier:		 wangchunmei<wangchm@biomarker.com.cn>
#Last Modified:  2012.
my $ver="1.0";

use strict;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

######################请在写程序之前，一定写明时间、程序用途、参数说明；每次修改程序时，也请做好注释工作
my %opts;
GetOptions(\%opts,"Finish=s","RecConfig=s","RunConfig=s","num=s","od=s","h" );

#&help()if(defined $opts{h});
if (!defined($opts{Finish})||!defined($opts{RunConfig})||!defined($opts{RecConfig})||!defined($opts{od})||defined($opts{h}))
{
		print <<"Usage End.";
	
	 Description:check adapter pollution for Trans and DEG

		                         version:$ver

	 usage:
 
             -Finish     <dir>             Finishe dir                                  must be given

             -RunConfig <file>                 run config file                          must be given

             -RecConfig  <file>            recognize config file                        must be given

             -num  <num>            choice Reads number to check pollution[default 300000 Reads]  option

             -od          <dir>            outdir                                        must be given

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
#finish dir /home/basecall/base.workdir/Basecall_Test/Data/Finish.C1-100,101-107,108-207


my $FinishDir=$opts{Finish};
my $outdir=$opts{od};

my $config=$opts{RunConfig};
my $RecConfig=$opts{RecConfig};
my $num=defined $opts{num}?$opts{num}:300000;
system "mkdir -p $outdir" if(!-d $outdir);
my $curdir=`pwd`;chomp $curdir;
chdir $outdir;$outdir=`pwd`;chomp $outdir;chdir $curdir;
chdir $FinishDir;$FinishDir=`pwd`;chomp $FinishDir;chdir $curdir;

my $hostname=`hostname`;

my %lib_type;
GetConfig($config,\%lib_type);

my $date=$1 if($config=~/config\_(\d\d\d\d\d\d)\.txt/);

my $shp="$outdir/AdpterPollution.sh";
open(SHP,">$shp") || die "cat't open the file [$shp]\n";

#$/="\@";
my @SampleDir=glob "$FinishDir/FastqData/Sample*";
my $phred;
foreach my $Sdir (@SampleDir) 
{
	my $Name=basename($Sdir);
	$Name=~s/Sample_//;
	next if(($lib_type{$Name} ne "Trans") and ($lib_type{$Name} ne "DEG"));
	my @fq1=glob("$Sdir/*_R1_*.fastq");
	#my @fq2=glob("$Sdir/*_R2_*.fastq");
	next if (!$fq1[0]);
	my $prodir="$outdir/$Name\_project\_20$date\_batch0";
	mkdir $prodir if(!-d "$prodir");
	my $pcon="config-$Name.txt";
	system "cp $RecConfig $prodir/$pcon";
	open FQ1,">$prodir/$Name\_1.fq"||die "Can't open the file: [$prodir/$Name\_1.fq]\n";
	open FQ2,">$prodir/$Name\_2.fq"||die "Can't open the file: [$prodir/$Name\_2.fq]\n";
	my $count;my $qual_sieve;
	Lable1:foreach my $fq1 (@fq1) 
	{
		my $fq2=$fq1;$fq2=~s/_R1_/_R2_/;
		open IN1,"$fq1"||die "Can't open the file: [$fq1]\n";
		open IN2,"$fq2"||die "Can't open the file: [$fq2]\n";
		while (<IN1>) 
		{
			my $id1=$_;my $id2=<IN2>;
			my $seq1=<IN1>;my $seq2=<IN2>;
			my $xx1=<IN1>;my $xx2=<IN2>;
			my $qual1=<IN1>;my $qual2=<IN2>;
			chomp $seq1;chomp $seq2;chomp $qual1;chomp $qual2;
			my @q1=unpack("C*",$qual1);my @q2=unpack("C*",$qual2);
#			if (!$phred) 
#			{
#				foreach  (@q1) 
#				{
#					if ($_<73) 
#					{
#						$phred=33;
#					}
#					elsif($_<84)
#					{
#						$phred=64
#					}
#				}
#				next if(!$phred);
#			}
#			my $Q20=$phred+20;
			#my @q20_fq1=grep {$_>=$Q20} @q1;
			#my @q20_fq2=grep {$_>=$Q20} @q2;
			#next if(@q20!=@q);
			$count++;
			print FQ1 "$id1$seq1\n$xx1$qual1\n";
			print FQ2 "$id2$seq2\n$xx2$qual2\n";
			if($count>$num)
			{
				close IN1;close IN2;
				last Lable1;
			}
			

		}
		close IN1;close IN2;
		if($count>$num)
		{
			last Lable1;
		}
	}
	close FQ1;close FQ2;
	
	print SHP "cd $prodir && perl $Bin/Trans_Adapter_Recognize/Trans_Rawseq_recognize.v1.pl -fq1 $Name\_1.fq -fq2 $Name\_2.fq -config $pcon -N N -o Pair.fa.recognize  \n";
}
close SHP;

if ($hostname=~/compute-0-19/) 
{
	print "cd $outdir && perl $Bin/multi-process.pl -cpu 16  $shp";
	system "cd $outdir && perl $Bin/multi-process.pl -cpu 16  $shp";
}
else
{
	print "ssh -Y compute-0-19 cd $outdir && perl $Bin/multi-process.pl -cpu 16  $shp";
	system "ssh -Y compute-0-19 cd $outdir && perl $Bin/multi-process.pl -cpu 16  $shp";
}



###############Time
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd Time :[$Time_End]\n\n";

###############Subs


######
sub GetConfig
{
	my ($in,$lib_type)=@_;
	open(IN,"$in") || die "can't open the file [$in]\n";
	while(<IN>)
	{
		chomp;
		next if(/Lane/ || /^$/);
		my @tmp=split(/\s+/,$_);
		$$lib_type{"$tmp[2]_$tmp[3]"}=$tmp[1];
	}
	close(IN);
}
#######



sub sub_format_datetime  
{
	#Time calculation subroutine
    my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
    sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}
