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
my $samFile=$ARGV[0];

print "samFile = $samFile\n";

open(IN,inputWrapper($samFile)) or die "cannot open < $samFile - $!";

open(OUT, ">", $samFile.'.unique.bedGraph') or die "Could not open file $!";
print OUT "track name=$samFile description='ATAC-seq signal'\n";

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


	my $chromosome1=$array[0];
	my $posL=$array[1];
	my $posR=$array[2];
	
	

	my $index=$chromosome1."___".$posL."___".$posR;
	#print "last=$lastLine vs index=$index\n";
	
	if ($index eq $lastLine) {
		$dup = $dup+1;
		#print "\tfound a dup! $dup\n";
		$lastLine=$index;
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

#print OUT "$chromosome1\t$posL\t$posR_50\t$readID\t1000\t.\t$posL\t$posR_50\t0\t2\t50,50\t$totalread\n";

close(OUT);
		
print "done\n"; 


