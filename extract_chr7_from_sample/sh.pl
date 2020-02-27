#! /usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
########################
if (@ARGV != 2){
	print "perl sh.pl dir outdir\n";die;
}
my $dir = $ARGV[0];
my $od = $ARGV[1];
mkdir $od unless (-d $od);
opendir DIR,$dir;
my @project_code = readdir DIR;
closedir DIR;
#########################
open (OUT,">$od/stat.file.xls")or die $!;
open (OUT1,">$od/no_panel.list")or die $!;
open (OUT2,">$od/no_type.list")or die $!;
print OUT "Project_ID\tsample_id\ttissue\tpanel\tbam_dir\tcnv_dir\tchr\tgene_name\tcopy_number\n";
for (my $i=2; $i <@project_code;$i++){
	my $project_code = basename($project_code[$i]);
	my $code_dir = "$dir/$project_code[$i]";
	next if (-f $code_dir);
	opendir DH,$code_dir;
	my @sample_list = readdir DH;
	closedir DH;
	for (my $j=2;$j<@sample_list;$j++){
		next if ($sample_list[$j]!~/panel/ || $sample_list[$j]=~/^H2O|^NC|^sample|^PSC|^CRC|^NTC|^POOL|^CASE/);
		my $bam_dir = "$code_dir/$sample_list[$j]\/basic_analysis\/align\/";
		my $cnv_file = (glob("$code_dir/$sample_list[$j]/cnv/*final.txt"))[0];
		if ($cnv_file){
			my $cmd = "less $cnv_file|grep \'chr7\' >$od/tmp\n";
			system($cmd);
			if (-s "$od/tmp"){
				open (IN,"$od/tmp")or die $!;
				while (<IN>){
					chomp;
					next if (/^#/ || /^sample_id/);
					my (@lines,$type,$panel);
					if ($_ =~ /panel/){
						@lines = split /\s+/,$_;
						$type = (split /-/,$lines[0])[3];
						my @panel = split /_/,$lines[0];
						if($panel[2] =~/panel/){
							$panel = (split /_/,$panel[2])[0];	
						}elsif($panel[3] =~/panel/){
							$panel = $panel[3];
						}elsif($panel[4] =~/panel/){
							$panel = $panel[4];
						}elsif($panel[5] =~/panel/){
							$panel = $panel[5];
						}elsif($panel[6] =~/panel/){
							$panel = $panel[6];
						}elsif($panel[7] =~/panel/){
							$panel = $panel[7];
						}else{
							print OUT1 "panel\t$lines[0]\n";	
						}
						if(!$type){
							print OUT2 "type\t$lines[0]\n";
						}
						print OUT "$project_code\t$lines[0]\t$type\t$panel\t$bam_dir\t$cnv_file\t$lines[1]\t$lines[2]\t$lines[4]\n" if ($type && $panel);
					}
				}
				close IN;
			}
		}
	}

}
close OUT;
