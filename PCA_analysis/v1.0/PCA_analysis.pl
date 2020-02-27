#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $BEGIN_TIME=time();
my $version="1.0.0";
$Script=~s/\.pl//g;
my @Times=localtime();
my $year=$Times[5]+1990;
my $month=$Times[4]+1;
my $day=$Times[3];
#######################################################################################
#
# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut,$key,$group,$show,@group);
GetOptions(
				"help|?" =>\&USAGE,
				"in:s"=>\$fIn,
				"outdir:s"=>\$fOut,
				"group:s{1,}"=>\@group,
		        "show:s"=>\$show,
				) or &USAGE;
&USAGE unless ($fIn and $fOut and @group );

$key='PCA_analysis';
$show=1 if(defined $show);
$show||=0;
mkdir $fOut if (!-d $fOut);
$fOut=AbsolutePath("dir",$fOut);
$fIn=AbsolutePath("file",$fIn);
$group=$fOut.'/group.list';
#open LG,">$fOut/$key.$Script.." || die $!;
open OUT,">$group";
print OUT "#number\tclient\tbioinfo\tgroup\n";
    my $n=1;
foreach  (@group) {
    my ($group_id,$sample)=split /:/;
    my @sample_id=split /\,/,$sample;
    print "@sample_id\n";
    foreach  (@sample_id) {
        print OUT "$n\t$_\t$_\t$group_id\n";
        $n++;
    }
}
close OUT;

# -f 输入文件  -pa 对数组进行主成分分析   -na 数据标准化  -ca m 减去中位数  -u 输出文件名
#print LG "$Bin/cluster -f $fIn -pa -na -ca m -u $fOut/$key.cluster\n";
`$Bin/cluster -f $fIn -pa -na -ca m -u $fOut/$key.cluster`;

#print LG "perl $Bin/matrix_transposition.pl $fOut/$key.cluster_array.coords.txt > $fOut/$key.cluster_pca_array.coords.txt.trans\n" ;
`perl $Bin/matrix_transposition.pl $fOut/$key.cluster_pca_array.coords.txt > $fOut/$key.cluster_pca_array.coords.txt.trans`;

#print LG "perl $Bin/PCA_sample.group.distribution_R.pl -pos $fOut/$key.cluster_pca_array.coords.txt.trans -group $group -k $fOut/$key\n";
`perl $Bin/PCA_sample.group.distribution_R.pl -pos $fOut/$key.cluster_pca_array.coords.txt.trans -group $group -k $fOut/$key -show $show `;
`rm $fOut/$key.cluster_pca_array.coords.txt`;
`rm $fOut/$key.cluster_pca_array.coords.txt.trans`;
`rm $fOut/$key.cluster_pca_array.pc.txt`;


open LOG,">$fOut/readme.txt" ;
print LOG <<"README";
+------------------------------------------------------------------------------+
|                              PCA分析结果                                     |
+------------------------------------------------------------------------------+
目录结构及文件说明：
|--readme.txt       this is the help file ;
|--group.list       this is the group list which was used in the PCA analysis;
`--.txt    this is the result file with sample ;

README

#close LG;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------
sub AbsolutePath{
        my ($type,$input) = @_;

        my $return;

        if ($type eq 'dir')
        {
                my $pwd = `pwd`;
                chomp $pwd;
                chdir($input);
                $return = `pwd`;
                chomp $return;
                chdir($pwd);
        }
        elsif($type eq 'file')
        {
                my $pwd = `pwd`;
                chomp $pwd;

                my $dir=dirname($input);
                my $file=basename($input);
                chdir($dir);
                $return = `pwd`;
                chop $return;
                $return .="/".$file;
                chdir($pwd);
        }
        return $return;
}

sub USAGE {#
	my $usage=<<"USAGE";
	Program:$Script
	Version:$version	[$month:$day:$year]
	Options:
        -in            input array     must be given
        -outdir        outdir          must be given
        -group         group file      must be given
        -show          wheather show Sample ID,0 or 1,defult 0  options
        -h             Help
USAGE
	print $usage;
	exit;
}
