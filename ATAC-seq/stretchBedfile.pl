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
my $bedFile=$ARGV[0];

print "bedFile = $bedFile\n";

open(IN,inputWrapper($bedFile)) or die "cannot open < $bedFile - $!";
open (OUT, ">", $bedFile.'.streched.bed') or die "Could not open file $!";

#open (LENGTHS, ">", $samFile.'.LENGTHS2') or die "Could not open file $!";
#print LENGTHS "track name=$samFile description='LENGTHS2 ATAC-seq signal'\n";


my $lineNum=0;

while(my $line = <IN>) { 
	chomp($line);
	
	# skip if the line starts with a @ symbol
	if($line =~ /^@/) {
		next;
	}
	
	print "$lineNum ... \n" if(($lineNum % 100000) == 0);
	
	#next if($line =~ /^@/);
	
	$lineNum = $lineNum + 1;

	
	my @array=split(/\t/,$line);
	my $numColumns=@array;
	#print "\tfound $numColumns columns\n";
	
	my $chromosome = $array[0];
	my $posL = $array[1];
	my $posR = $array[2];
	
	#print "\t$chromosome\t$posL\t$posR\n";
	
	my $posLnew = ($posL - 500);
	my $posRnew = ($posR + 500); 
	
	print OUT "$chromosome\t$posLnew\t$posRnew\t$array[3]\t$array[4]\n";
}

close(IN);
close (OUT);

print "done\n";
#close(OUT);
#close (LENGTHS);
	