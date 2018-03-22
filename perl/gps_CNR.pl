#!/usr/bin/perl
#https://wenku.baidu.com/view/12aa3de483d049649a665818.html #信号解读
use Cwd;
use 5.10.0;
use warnings;
use strict;

my $parameterCount=@ARGV;
my $dir = getcwd;
my @files = qw//;

$parameterCount == 1 or die "You must specify one parameter,and it is a directory name.";

if(-e $ARGV[0]){
	@files = ($ARGV[0]);
}elsif(-d $ARGV[0]) {
	$dir = $ARGV[0];
	@files = glob ($dir);
}

sub countDifferentSalliteReport {
	my ($GP,$GL,$BD,$GN,$PMTK,$OTHER) = (0,0,0,0,0,0);

	open DATA, $_[0] or die "can not open file ,$!";
	open GP ">>GP.csv";
	open GL ">>GL.csv";
	open BD ">>BD.csv";
	open GN ">>GN.csv";
	open PMTK ">>PMTK.csv";
	open OTHER ">>OTHER.csv";

	while(<DATA>){
		# print $_;
		if (!/^\$(.*)/) {
			next; # etc. next,last,continue,redo,goto
		}

		if (/^\$GP/) {
			$GP++;
		} elsif (/^\$GL/) {
			$GL++;
		} elsif(/^\$BD/) {
			$BD++;
		} elsif(/^\$GN/) {
			$GN++;
		} elsif(/^\$PMTK/) {
			$PMTK++;
		} else {
			$OTHER++;
		}
	}
	#$found = "Nothing" unless $found;print "Found: $found\n";
	#print "Found: $found\n" if defined $found;
	print "\$GP = $GP,\$GL = $GL,\$BD = $BD,\$GN = $GN,\$PMTK = $PMTK,\$OTHER = $OTHER";
}

foreach(@files){
	print $_ . "\n";
	countDifferentSalliteReport($_);
}
