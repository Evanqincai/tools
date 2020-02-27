#! /usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
#############################
my $sample_list = $ARGV[0];
my $read_num = $ARGV[1];
my $outdir = $ARGV[2];
unless (@ARGV == 3){
	print "perl $0 sample.list read_num outdir\n";die;
}
unless (-d $outdir){
	`mkdir -p $outdir/fasta`;
}
my $blastx = "/lustre/rdi/user/licq/research/diamond/ncbi-blast-2.7.1+/bin/blastx";
my $nr = "/lustre/rdi/user/licq/project/RNA-Seq/20180827_henan_RNA/diamond/NR/nr";
#############################random and blastx
open (IN,$sample_list) or die $!;
open (OUT,">$outdir/work_sh") or die $!;
while(<IN>){
	chomp;next if (/^#/ || /^$/);
	if (-f $_){
		my $fa_name = (split (/.fastq/,basename($_)))[0];
		print OUT "perl $Bin/random_extract_fq.pl $_ $read_num $outdir/fasta/$fa_name.random >$outdir/fasta/$fa_name.fasta\n";
		print OUT "$blastx -query  $outdir/fasta/$fa_name.fasta -out $outdir/$fa_name.fasta.readxml -evalue 10 -max_target_seqs 1 -outfmt 5 -db $nr -num_threads 5\n";
		print OUT "perl $Bin/blast.xml.ab.pl $outdir/$fa_name.fasta.readxml >$outdir/parsed.$fa_name.fasta.readxml\n";
		print OUT "perl $Bin/extract_species.pl $read_num $outdir/parsed.$fa_name.fasta.readxml >$outdir/summarized.parsed.$fa_name.fasta.xls\n";
	}else{
		print "Please check your file\n";die;
	}
}
close IN;
close OUT;
`sh $outdir/work_sh `;
