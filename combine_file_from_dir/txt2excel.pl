#!/usr/bin/env perl
use strict;
use warnings;
use IO::File;
#use Spreadsheet::WriteExcel;
use lib '/home/fuzhl4317/workdir/perllib/lib/perl5' ;
use Excel::Writer::XLSX;
use Data::Dump;
use File::Basename qw(basename dirname);
use Encode;
sub H{ 
	my $text = shift;
 	return decode('utf-8',$text); # 进行转码
}
#my $converter = Text::Iconv -> new ("utf-8", "utf-8");


die "perl $0 input outputname\n" if ( $#ARGV<1 );

my @file=(glob "$ARGV[0]/*.xls");
my $out="$ARGV[0]/$ARGV[1]";


#time","contamination","QC","QC_other","SnvIndel","CNV","TMB","germline","Fusion","Fusion_detail"

# Create a new workbook called simple.xls and add a worksheet
my $workbook = Excel::Writer::XLSX->new( "$out.xlsx" );
my $format = $workbook->add_format();
$format->set_bold();
$format->set_color( 'blue' );

foreach my  $file (@file){
	my $name=basename($file);
	$name=~s/.txt|.xls//;
	#my $fhi = IO::File->new("<$file");
	open (my $fhi ,"<$file") or die $!;
	my $worksheet = $workbook->add_worksheet("$name");
	# The general syntax is write($row, $column, $token). Note that row and
	# column are zero indexed
	#
	# Write some text
	#$worksheet->write(0, 0, "Hi Excel!");
	my $i = 0;
	while (<$fhi>) {
		my @data=split '\t', $_;
		for my $j (0..$#data){
			$worksheet->write( $i, $j, H($data[$j]) );
			#print $data[$j];
		}
		$i++;

	}
	$fhi->close();
	print "$file\n";
}
$workbook->close();

