#!/usr/bin/perl -w
use English;
use warnings;
use strict;

sub outputWrapper($;$) {
    # required
    my $outputFile=shift;
    # optional
    my $outputCompressed=0;
    $outputCompressed=shift if @_;
               
    $outputCompressed = 1 if($outputFile =~ /\.gz$/);
    $outputFile .= ".gz" if(($outputFile !~ /\.gz$/) and ($outputCompressed == 1));
    $outputFile = "| gzip -c > '".$outputFile."'" if(($outputFile =~ /\.gz$/) and ($outputCompressed == 1));
    $outputFile = ">".$outputFile if($outputCompressed == 0);
               
    return($outputFile);
}
 
sub inputWrapper($) {
     my $inputFile=shift;
               
     $inputFile = "gunzip -c '".$inputFile."' | " if(($inputFile =~ /\.gz$/) and (!(-T($inputFile))));
               
     return($inputFile);
}

print "hi - start of the program\n";
print "\n";


# get the input file
my $elementFile=$ARGV[0];

print "elementFile = $elementFile\n";

open(IN,inputWrapper($elementFile)) or die "cannot open < $elementFile - $!";

open(OUT, ">", $elementFile.'.unique.bed') or die "Could not open file $!";
print OUT "track name=$elementFile description='Unique elements'\n";

my $lineNum=0;
my $lastLine="";

my $dup=0;

while(my $line = <IN>) {
	chomp($line);
	
	next if($line =~ /^track/);
	
	print "$lineNum ... \n" if(($lineNum % 100000) == 0);
	
	$lineNum = $lineNum + 1;
	
	my @array=split(/\t/,$line);
	my $numColumns=@array;
	#print "\tfound $numColumns columns\n";
	my $chromosome = $array[0];
	my $orientation = $array [5];
	#my $plusTSS = $array [1];
	#my $minusTSS = $array [2];
	
	my $TSS = ""; 
	if ($orientation eq "+") {
		$TSS = $array[1];
		#print "$plusTSS\n";
	} else {
		$TSS = $array[2];
		#print "$minusTSS\n";
	}	
	
	#print "$TSS\n";
	
	
	my $index=$chromosome."___".$TSS;
	#print "last=$lastLine vs index=$index\n";
	
	if ($index eq $lastLine) {
		$dup = $dup+1;
		#print "\tfound a dup! $dup\n";
		#$lastLine=$index;
		next;
	} else {
		#print "\tnot a dup!\n";
		print OUT "$line\n";
	}
	
	
	
	$lastLine=$index;
	

	
}

print "dup\t$dup\n";
print "lineNum\t$lineNum\n";

close(IN);

close(OUT);
		
print "done\n"; 


