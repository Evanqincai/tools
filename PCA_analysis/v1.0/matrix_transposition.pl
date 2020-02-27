if(@ARGV!=1)
{
	print "usage:  perl  $0  matrix <f>.\n";
	exit;
}
open(IN,"$ARGV[0]");
my $r=0;
my @matrix;
while(<IN>)
{
	chomp;
	my @line=split;
	my $c=0;
	foreach(@line)
	{
		$matrix[$c][$r]=$_;
		$c++;
	}
	$r++;
}

for $i(0..$#matrix)
{
	for $j(0..$#{$matrix[$_]})
	{
		print "$matrix[$i][$j]";
		print "\t" if($j!=$#{$matrix[$_]});
	}
	print "\n";
}

close(IN);

