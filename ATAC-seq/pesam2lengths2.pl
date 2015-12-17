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
	
	my $length_of_molecule=$array[8];
	
	
	print LENGTHS "\n";
	foreach my $length_of_molecule ( sort {$a<=>$b} ) {
		print LENGTHS "\t$length_of_molecule\t$length\n";
	}
	
}

print "$length_of_molecule\n";

close(IN);

print "done\n";
#close(OUT);
#close (LENGTHS);	
