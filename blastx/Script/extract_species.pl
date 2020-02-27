#!/usr/bin/perl
my $N=shift;
my $file=shift;
my %hash;
open IN, $file;

my $n;
while (<IN>) {
	chomp;
	my @tmp=split /\t/;
	if ($tmp[1]=~/\s\[(.+?)\]/) {
		#print "$tmp[0]\t$1\n";
		if (defined $hash{$1}) {
			$hash{$1}++;
			$n++;
		}
		else
		{
			$hash{$1}=1;
			$n++;
		}
	}
}
close IN;

## sort
my @sorted=map {{($_=>$hash{$_})}}
   sort{$hash{$b} <=> $hash{$a}
   or $a cmp $b
   }keys %hash;
## print
foreach my $hashref(@sorted){
	my ($key,$value) = each %$hashref;
	my $Nrate=100*$value/$N;
	my $nrate=100*$value/$n;


	print $key."\t".$value."\t";
	printf "%.2f",$Nrate;
	print "\%"."\t";
	printf "%.2f",$nrate;
	print "\%"."\n";

}            

