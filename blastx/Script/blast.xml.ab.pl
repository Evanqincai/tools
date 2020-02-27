### blast xml format abstract script
### from wujun
### should warn this script adopt for the trinity software.

use warnings;
use strict;

my $file=shift;
#my $flag=0;
my $ann=();
my $id=();
open(FILE,$file);
while(<FILE>){
	chomp;
## comp702_c0_seq1 len=229 ~FPKM=235.5 path=[0:0-38 64:39-78 104:79-104 384:105-228]

	if(/\s+\<Iteration\_query-def\>(.*?)<\/Iteration_query-def\>/){
#		if( $flag == 0 ){
#			print "\n";
#		}
#		$id=$1;
		if( $ann ){
			print $id.$ann."\n";
		}
		$ann=();
		$id=$1;
#		my @array=split/\s+/,$value;
#		$array[1]=~s/^len\=//;
#		$array[2]=~s/\~FPKM\=//;
#		print $array[0]."\t".$array[1]."\t".$array[2]."\t";
#		if
#		print $value."\t";
#		$flag=0;
	}
	if(/\<Hit\_def\>(.*?)<\/Hit_def\>/){
		my $value=$1;
		$value=~s/\&gt\;/ /;
		$ann.="\t".$value;
	}
}
