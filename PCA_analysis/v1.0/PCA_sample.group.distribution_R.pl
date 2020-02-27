#!/usr/bin/perl -w

use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);

my $programe_dir = basename($0);
my $path         = dirname($0);

my $ver    = "1.0";
my $Data   = "2012/9/12";
my $BEGIN  = time();

#######################################################################################

my ($pos,$group,$out,$show);
GetOptions(
			"pos:s"	=>	\$pos,
			"group:s"	=>	\$group,
			"show:s"=>\$show,
			"k:s"	=>	\$out,
			"h|?"	=>	\&help,
			) || &help;
&help unless ($pos && $group && $out);

sub help
{
	print <<"	Usage End.";
    Description:
        Writer  : $Writer
        Data    : $Data
        Version : $ver
        function: ......
    Usage:
        -pos          infile     must be given
        -group        groupfile  must be given
        -show          0/1             must be given
             0   not show the name of sample corresponding to the plot in result
             1   show the name of sample corresponding to the plot in result
        -k            keyname    must be given
        -h            Help document
	Usage End.
	exit;
}

#######################################################################################
my $Time_Start;
$Time_Start = sub_format_datetime(localtime(time()));
print "\nStart $programe_dir Time :[$Time_Start]\n\n";
#######################################################################################

my @color = ("\"#5d8aa8\"","\"#e32636\"","\"#ffbf00\"","\"#9966cc\"","\"#a4c639\"","\"#cd9575\"","\"#915c83\"","\"#008000\"","\"#00ffff\"","\"#7fffd4\"","\"#4b5320\"","\"#e9d66b\"","\"#b2beb5\"","\"#87a96b\"","\"#ff9966\"","\"#a52a2a\"","\"#fdee00\"","\"#6e7f80\"","\"#007fff\"","\"#89cff0\"","\"#f4c2c2\"","\"#21abcd\"","\"#848482\"","\"#98777b\"","\"#de5d83\"","\"#00ba4e\"","\"#873260\"","\"#b5a642\"","\"#1dacd6\"","\"#66ff00\"","\"#bf94e4\"","\"#ff007f\"","\"#d19fe8\"","\"#004225\"","\"#a52a2a\"");
#foreach my $c (@color) {
#	print $c,"\n";
#}
#die;
open (IN,"$group") || die $!;
my @subspecies;my %subspecies;
while (<IN>) {
	chomp;s/\r$//;next if (/^$/);
	my (undef,$client,$bmk,@a) = split;
	if (/^number/||/^\#number/) {
		@subspecies = @a;
	}else {
		for (my $i = 0;$i<@a;$i++) {
			$subspecies{$subspecies[$i]}{$bmk} = $a[$i];
		}
	}
}
close IN;
#print Dumper %subspecies;die;
my ($eigvalue,$eweight,@variance,$vari_sin,$pca_sum
,@a,
$pca1_percent,$pca2_percent,$pca3_percent,$p1,$p2,$p3);
open (IN,"$pos") || die "$!";
my %pca;
while (<IN>) {
chomp;s/\r$//;next if (/^$/);
	if (/^EIGVALUE/) {
		($eigvalue,$eweight,@variance) = split/	/,$_;
	foreach $vari_sin (@variance) {
	$pca_sum += $vari_sin;
		}
	}else
	{
	chomp;next if (/^$/||/^EIGVALUE/);
	@a = split;
	$pca{$a[0]}{'pca1'} = $a[2];
	$pca{$a[0]}{'pca2'} = $a[3];
	$pca{$a[0]}{'pca3'} = $a[4];
}
}
$pca1_percent = $variance[0]*100/$pca_sum;
$p1 = sprintf "%.2f%%","$pca1_percent";


$pca2_percent = $variance[1]*100/$pca_sum;
$p2 = sprintf "%.2f%%","$pca2_percent";


$pca3_percent = $variance[2]*100/$pca_sum;
$p3 = sprintf "%.2f%%","$pca3_percent";
close IN;

foreach my $subspecies (sort keys %subspecies) {
	#open (OUT,">$out.$subspecies.axis") || die $!;
	#print OUT "ID\t$subspecies\tpca1\tpca2\tpca3\n";
	my (@bmk,@col,@pca1,@pca2,@pca3,@bmk_group);my (%group,%col);
	foreach my $bmk (sort keys %{$subspecies{$subspecies}}) {
		if ($pca{$bmk}{'pca1'}) {
			#print OUT "$bmk\t$subspecies{$subspecies}{$bmk}\t$pca{$bmk}{'pca1'}\t$pca{$bmk}{'pca2'}\t$pca{$bmk}{'pca3'}\n";
			#print $subspecies{$subspecies}{$bmk};die;
			$group{$subspecies{$subspecies}{$bmk}} = "";
			push @bmk,$bmk;
			push @pca1,$pca{$bmk}{'pca1'};
			push @pca2,$pca{$bmk}{'pca2'};
			push @pca3,$pca{$bmk}{'pca3'};
			push @bmk_group,$subspecies{$subspecies}{$bmk};
		}
	}
	#close OUT;

	my $pca1 = join ",",@pca1;
	my $pca2 = join ",",@pca2;
	my $pca3 = join ",",@pca3;
	my $bmk_r = join "\",\"",@bmk;
	$bmk_r="\"$bmk_r\"";
	my $bmk_group=join "\",\"",@bmk_group;
	#print $bmk_group;die;
	my @group = (sort keys %group);
	my $groupnum = @group;
	my $group = join "\",\"",@group;
	my @groupcolor;
	for (my $i = 0;$i<@group;$i++) {
		$col{$group[$i]} = $color[$i];
		push @groupcolor,$color[$i];
	}
	for (my $i=0;$i<@bmk;$i++) {
		push @col,$col{$subspecies{$subspecies}{$bmk[$i]}};
		#push @col,$col{$subspecies{$subspecies}};
	}
	my $col = join ",",@col;
	my $groupcolor = join ",",@groupcolor;
	open (OUT,">$out.$subspecies.R") || die "$!";
	print OUT <<"	R.End";
pdf(file="$out.$subspecies.pdf")
par(mfrow<-c(3,1))
pca1 <- c($pca1)
pca2 <- c($pca2)
pca3 <- c($pca3)
bmk_r <- c($bmk_r)
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
if ($show == 1) {
plot (pca1,pca2,main="$subspecies",xlab="PC1 ($p1)",ylab="PC2 ($p2)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca1,pca2,bmk_r,col="black",pos= 3)                                              #对样品进行添加名称

plot (pca1,pca3,main="$subspecies",xlab="PC1 ($p1)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca1,pca3,bmk_r,col="black",pos= 3)

plot (pca2,pca3,main="$subspecies",xlab="PC2 ($p2)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca2,pca3,bmk_r,col="black",pos= 3)

png(file="$out.$subspecies.1.png")
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
plot (pca1,pca2,main="$subspecies",xlab="PC1 ($p1)",ylab="PC2 ($p2)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca1,pca2,bmk_r,col="black",pos=3)

png(file="$out.$subspecies.2.png")
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
plot (pca1,pca3,main="$subspecies",xlab="PC1 ($p1)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca1,pca3,bmk_r,col="black",pos= 3)

png(file="$out.$subspecies.3.png")
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
plot (pca2,pca3,main="$subspecies",xlab="PC2 ($p2)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.3,0))
text(pca2,pca3,bmk_r,col="black",pos= 3)
}else{
plot (pca1,pca2,main="$subspecies",xlab="PC1 ($p1)",ylab="PC2 ($p2)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))
plot (pca1,pca3,main="$subspecies",xlab="PC1 ($p1)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))
plot (pca2,pca3,main="$subspecies",xlab="PC2 ($p2)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))

png(file="$out.$subspecies.1.png")
par(mar=c(6, 4, 6, 9), xpd=TRUE)
plot (pca1,pca2,main="$subspecies",xlab="PC1 ($p1)",ylab="PC2 ($p2)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))

png(file="$out.$subspecies.2.png")
par(mar=c(6, 4, 6, 9), xpd=TRUE)
plot (pca1,pca3,main="$subspecies",xlab="PC1 ($p1)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))

png(file="$out.$subspecies.3.png")
par(mar=c(6, 4, 6, 9), xpd=TRUE)
plot (pca2,pca3,main="$subspecies",xlab="PC2 ($p2)",ylab="PC3 ($p3)",col=c($col),cex=1.5,pch=19)
legend("topright",legend=c(\"$group\"),col=c($groupcolor),pch=19,inset=c(-0.35,0))
}
dev.off()
	R.End
	close OUT;
	`R --slave < $out.$subspecies.R`;
`rm $out.$subspecies.R`;
## for windows R
	open (OUT,">$out.$subspecies.3d.R") || die "$!";
	print OUT <<"	3dR.End";


library(scatterplot3d)

pca1 <- c($pca1)
pca2 <- c($pca2)
pca3 <- c($pca3)
bmk_r <- c($bmk_r)
if ($show == 1) {
col=c($col)
legend=c(\"$group\")
legendcor=c($groupcolor)
png(file="$out.$subspecies.3d.png")
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
s3d <- scatterplot3d(pca1,pca2,pca3,color=col,pch=19,angle=25,xlab="PC1 ($p1)",ylab="PC2 ($p2)",zlab="PC3 ($p3)")
s3d.coords <- s3d\$xyz.convert(pca1, pca2, pca3)
legend("topright",legend=legend,col=legendcor,pch=19,bg="white",xpd=TRUE,inset=-0.1)
text(s3d.coords\$x, s3d.coords\$y,labels=bmk_r, pos=3)

pdf(file="$out.$subspecies.3d.pdf")
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
s3d <- scatterplot3d(pca1,pca2,pca3,color=col,pch=19,angle=25,xlab="PC1 ($p1)",ylab="PC2 ($p2)",zlab="PC3 ($p3)")
s3d.coords <- s3d\$xyz.convert(pca1, pca2, pca3)
legend("topright",legend=legend,col=legendcor,pch=19,bg="white",xpd=TRUE,inset=-0.1)
text(s3d.coords\$x, s3d.coords\$y,labels=bmk_r, pos=3)
dev.off()
}else{
    col=c($col)
    legend=c(\"$group\")
    legendcor=c($groupcolor)
    png(file="$out.$subspecies.3d.png")
    par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
    scatterplot3d(pca1,pca2,pca3,color=col,pch=19,angle=25,xlab="PC1 ($p1)",ylab="PC2 ($p2)",zlab="PC3 ($p3)")
    legend("topright",legend=legend,col=legendcor,pch=19,bg="white",xpd=TRUE,inset=-0.1)

    pdf(file="$out.$subspecies.3d.pdf")
    par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
    scatterplot3d(pca1,pca2,pca3,color=col,pch=19,angle=25,xlab="PC1 ($p1)",ylab="PC2 ($p2)",zlab="PC3 ($p3)")
    legend("topright",legend=legend,col=legendcor,pch=19,bg="white",xpd=TRUE,inset=-0.1)
    dev.off()
}
#plot3d(pca1,pca2,pca3,point.col = as.numeric(as.factor(group)),xlab="pca1",ylab="pca2",zlab="pca3",type="s",radius=0.01,main="subspecies",axes=TRUE,top=TRUE,box=TRUE)
#rgl.postscript("$out.$subspecies.3d.pdf", "pdf", drawText = TRUE)
	3dR.End
	close OUT;
	`/share/nas2/genome/biosoft/R/3.1.1/bin/R --slave < $out.$subspecies.3d.R`;
	`rm $out.$subspecies.3d.R`;
}
#grid(col="gray")	#加网格

#######################################################################################
my $Time_End;
$Time_End = sub_format_datetime(localtime(time()));
print "\nEnd $programe_dir Time :[$Time_End]\n\n";
&Runtime($BEGIN);
#######################################################################################

sub sub_format_datetime #Time calculation subroutine
{
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}

sub Runtime # &Runtime($BEGIN);
{
	my ($t1)=@_;
	my $t=time()-$t1;
	print "Total $programe_dir elapsed time : [",&sub_time($t),"]\n";
}

sub sub_time
{
	my ($T)=@_;chomp $T;
	my $s=0;my $m=0;my $h=0;
	if ($T>=3600) {
		my $h=int ($T/3600);
		my $a=$T%3600;
		if ($a>=60) {
			my $m=int($a/60);
			$s=$a%60;
			$T=$h."h\-".$m."m\-".$s."s";
		}else{
			$T=$h."h-"."0m\-".$a."s";
		}
	}else{
		if ($T>=60) {
			my $m=int($T/60);
			$s=$T%60;
			$T=$m."m\-".$s."s";
		}else{
			$T=$T."s";
		}
	}
	return ($T);
}

sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
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

