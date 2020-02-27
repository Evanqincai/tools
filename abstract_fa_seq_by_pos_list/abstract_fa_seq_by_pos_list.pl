#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fIn1,$fOut,$fOut1);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
				"fa:s"=>\$fIn1,
				) or &USAGE;
&USAGE unless ($fIn and $fIn1 and $fOut);
my (%hash_s,%hash_l,%gene_id);
my (@a);
my ($min,$name,$length,$seq,$i,$right,$left,$new_seq,$file);
open (IN,"$fIn")||die"Can't open $fIn\n";
open (FA,"$fIn1")||die"Can't open $fIn1\n";
open (OUT,">$fOut")||die"Can't open $fOut\n";
while (<IN>) {#Contig000366	9430	9577
	chomp;
	@a=split;
	$name=$a[0];
	if ($name=~/\:/) {
		$name=(split(/\:/,$name))[1];
	}
	elsif ($name=~/\|/) {
		$name=(split(/\|/,$name))[3];
	}
	else {
		$name=$name;
	}
	$length=abs($a[2]-$a[1])+1;
	$min=&min($a[1],$a[2]);
	push (@{$hash_s{$name}},$min);
	push (@{$hash_l{$name}},$length);
        $gene_id{$a[0]}{$a[1]}{$a[2]} = $a[3];
}
close IN;

$/=">";
while (<FA>) {
	chomp;
	if ($_ ne "") {
		$name=(split(/\s+/,$_))[0];
		if ($name=~/\:/) {
			$name=(split(/\:/,$name))[1];
		}
		elsif ($name=~/\|/) {
			$name=(split(/\|/,$name))[3];
		}
		else {
			$name=$name;
		}
		if (exists $hash_s{$name}) {
			$seq=(split(/\n/,$_,2))[1];
			$seq=~s/\s+//g;
			$seq=~s/\r//g;
			for($i=0 ;$i<@{$hash_s{$name}} ;$i++) {
				$left=${$hash_s{$name}}[$i];
				$length=${$hash_l{$name}}[$i];
				$right=$left+$length-1;
				#$file=$name."_".$left."_".$right;
			        my $right2 = $left + $length -1;
				$file = $gene_id{$name}{$left}{$right2};
				$new_seq=substr($seq,$left-1,$length);
				$new_seq=~s/(.{50})/$1\n/g;
				$new_seq=~s/\n$//;
				print OUT ">$file\n$new_seq\n";
			}
		}
	}
}
close FA;
close OUT;





#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------

sub min {
	my ($x1,$x2)=@_;
	my $min;
	if ($x1 < $x2) {
		$min=$x1;
	}
	else {
		$min=$x2;
	}
	return $min;
}
sub ABSOLUTE_DIR{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub GetTime {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}


sub USAGE {#
	my $usage=<<"USAGE";
Program:
Version: $version
Description:
Usage:
  Options:
  -i  <file>      id-list file          must be given
  -fa <file>      fasta file            must be given
  -o  <file>      outfile               must be given
 
  -h         Help

USAGE
	print $usage;
	exit;
}
