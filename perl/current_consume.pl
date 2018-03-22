#!/usr/bin/perl

use Cwd;
use 5.10.0;
use warnings;


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

sub printEvenArray {
	local $n = scalar(@_);
	# print "\$n = $n\n";
	for (my $index = 0; $index <$n ; $index++) {
		if($index % 2 != 0 || $index == 0){next;}
		# print "index = $index ,arr[$index] = $_[$index]\t";
		print "$_[$index]";
		if($index+1 != $n){print ","};
	}
	print "\n";
}

sub printSeperatorLine {
	print "=" x 80;
	print "\n";
}

sub countCurrentConsume {
	# print "$_[0]\n";
	open DATA, $_[0] or die "can not open file ,$!";
	# Estimated power use (mAh):
	#   Capacity: 3000, Computed drain: 12.1, actual drain: 0
	#   Screen: 11.0
	#   Wifi: 1.04 ( cpu=0.00000244 wifi=1.04 )
	#   Idle: 0.0346
	while(<DATA>){
		if(/^\s+Estimated power use/../^\s*$/){
			if ($_ =~ m/Uid\s+(.*): (\d+\.\d+)\s+\((.*)\)/) {
				if (!$first) { $first++;printSeperatorLine;}
				# print "Uid = $1,Total_consume = $2,consume_list = $3\n";
				my @array = split/[ =]/,$3;
				# print " $1,$2,";
				# print "\$3 = $3\t";
				printEvenArray(@array);
			}
			else {
				if (!$second) { $second++;printSeperatorLine;}
				print;
			}
		}

	}
	# closed(DATA);
}

foreach(@files){
	printSeperatorLine;
	print $_ . "\n";
	countCurrentConsume($_);
}
