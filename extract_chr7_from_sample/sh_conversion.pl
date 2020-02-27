#! /usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);
########################
if (@ARGV != 3){
	print "perl sh.pl dir outdir\n";die;
}
my $dir = $ARGV[0];
my $od = $ARGV[1];
my $genelist = $ARGV[2];
mkdir $od unless (-d $od);
opendir DIR,$dir;
my @project_code = readdir DIR;
closedir DIR;
#########################
my @gene;
open (GENE,$genelist) or die $!;
while (<GENE>){
	chomp;next if (/^#/);
	push @gene,$_;
}
close GENE;
my $genename = join("\t",@gene);
#print $gene[5];die;
open (OUT,">$od/stat.file.xls")or die $!;
open (OUT1,">$od/no_panel.list")or die $!;
open (OUT2,">$od/no_type.list")or die $!;
print OUT "Project_ID\tsample_id\ttissue\tpanel\tbam_dir\tcnv_dir\t$genename\n";
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
				my (@tmp_gene,$type,$panel,@tmp_cnv);
				open (IN,"$od/tmp")or die $!;
				while (<IN>){
					chomp;
					next if (/^#/ || /^sample_id/);
					my @lines;
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
						#print "$type\n$panel\n";
						push @tmp_gene,$lines[2];
						push @tmp_cnv,$lines[4];
#						print OUT "$project_code\t$lines[0]\t$type\t$panel\t$bam_dir\t$cnv_file\t$lines[1]\t$lines[2]\t$lines[4]\n" if ($type && $panel);
					}
				}
				close IN;
				#print "$type\n$panel\n";die;
				my @gene_cnv;
				for (my $m=0;$m<@gene;$m++){
					my $tag = 0;
					for (my $k=0;$k<@tmp_gene;$k++){
						if ($gene[$m] eq $tmp_gene[$k]){
							push @gene_cnv,$tmp_cnv[$k];
							$tag = 1;
						}
					}
					if ($tag == 0){
						push @gene_cnv,"--";
					}
				}
				my $gene_cnv = join("\t",@gene_cnv);
				#print "$gene_cnv";die;
				print OUT "$project_code\t$sample_list[$j]\t$type\t$panel\t$bam_dir\t$cnv_file\t$gene_cnv\n" if ($type && $panel);
				
			}
		}
	}

}
close OUT;
