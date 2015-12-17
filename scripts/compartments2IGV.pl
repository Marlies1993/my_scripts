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

sub round($;$) {
	# required
    my $num=shift;
    # optional
    my $digs_to_cut=0;
    $digs_to_cut = shift if @_;
            
    # my $RoundedNumber = round($myNum,3)
    return($num) if($num eq "NA");
               
    my $roundedNum=$num;
               
    if(($num != 0) and ($digs_to_cut == 0)) {
    	$roundedNum = int($num + $num/abs($num*2));
    } else {
    	$roundedNum = sprintf("%.".($digs_to_cut)."f", $num) if($num =~ /\d+\.(\d){$digs_to_cut,}/);
    }
               
    return($roundedNum);

}

print "hi - start of the program\n";
print "\n";


# get the input file
my $samFile=$ARGV[0];

print "samFile = $samFile\n";

open(IN,inputWrapper($samFile)) or die "cannot open < $samFile - $!";

open(OUT, ">", $samFile.'.IGV.bedGraph') or die "Could not open file $!";
print OUT "track name=$samFile description='norm ATAC-seq signal'\n";

#$string=/user/,ar/desk/ti
#my @tmp=split(/\//,$string);

#$name=$tmp[-1]



my $lineNum=0;
my $zero=0;


while(my $line = <IN>) { 
	chomp($line);
	
	#skip if the line starts with a @ symbol
	if($line =~ /^@/) {
		next;
	}
	
	print "$lineNum ... \n" if(($lineNum % 100000) == 0);
	
	#next if($line =~ /^@/);
	
	$lineNum = $lineNum + 1;

	# actions per line
	
	#print "\n\n";
	#print "lineNumber is $lineNum\n";
	#print" $line\n";
	
	my @array=split(/\t/,$line);
	my $numColumns=@array;
	#print "\tfound $numColumns columns\n";
	
	my $signal = $array [3];
	my $chromosome = $array [0];
	my $posL = $array [1];
	my $posR = $array [2];
	
	#print "$signal\n";
	if($signal eq "nan") {
		$signal = $zero;
		print "found a zero\n";
	}
	
	print OUT "$chromosome\t$posL\t$posR\t$signal\n";
	
}
	

close IN;
close OUT;

print "done\n";
	