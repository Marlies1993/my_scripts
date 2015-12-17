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

open (LENGTHS, ">", $samFile.'.LENGTHS2') or die "Could not open file $!";



my $lineNum=0;
my $number_of_reads=0;
my $cis=0;
my $trans=0;
my $zeros=0;
my $chrM=0;

my %chrCounterHash=();
#my %lengthCounterHash=();

my $smaller_180bp=0;
my $one_nucleosome=0;
my $two_nucleosome=0;
my $three_nucleosome=0;
my $large_fragments=0;


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
	
	my $readID=$array[0];
	my $chromosome1=$array[2];
	my $chromosome2=$array[6];
	my $posL=$array[3];
	my $posR=$array[7];
	my $sequence=$array[9];
	my $length_of_molecule=$array[8];
			
	#skip if the line is chrM 
	# number == != > < >= <=
	# string eq ne
	
	if($length_of_molecule < 0) {
		#print "found a negative\n";
		next;
	}
	
	if($length_of_molecule >= 0) {
		$number_of_reads = $number_of_reads + 1;
	}
	
	
	if($chromosome1 eq "chrM") {
		$chrM = $chrM +1;
		next;
	}
	
	if($chromosome2 eq "=") {
		$cis = $cis + 1;
		#$cis += 1;
		#$cis++;
	} else {
		$trans = $trans + 1;
		next;
	}
	
	if($length_of_molecule == 0) {
		$zeros = $zeros +1;
		next;
	}
	
	if($length_of_molecule > 2000) {
		next;
	}
	
	
	$chrCounterHash{$chromosome1}++;
	
	#$lengthCounterHash{$length_of_molecule}++;	

	
	if(($lineNum % 1000000) == 0) {
		print "$readID\t$chromosome1\t$posL\t$length_of_molecule\t$sequence\n";
	}
	
	
	if($length_of_molecule < 180) {
		$smaller_180bp = $smaller_180bp +1;
	}
	
	if(($length_of_molecule > 180) and ($length_of_molecule < 320)) {
		$one_nucleosome = $one_nucleosome + 1;
	}
	
	if(($length_of_molecule > 320) and ($length_of_molecule < 500)) {
		$two_nucleosome = $two_nucleosome + 1;
	}
	
	if(($length_of_molecule > 500) and ($length_of_molecule < 750)) {
		$three_nucleosome = $three_nucleosome + 1;
	}
	
	if($length_of_molecule > 750) {
		$large_fragments = $large_fragments +1;
	}
	
	my $posR_50 = ($posR+50);
	my $totalread = ($posR-$posL);	
	
	print LENGTHS "$length_of_molecule\n";
	
	# do what we want here to each line,
}


#close(OUT);
#close (LENGTHS);

close(IN);

#foreach my $length_of_molecule ( sort {$a<=>$b} ) {
	#my $length=$length_of_molecule;
	#print "\t$length_of_molecule\t$length\n";
#}

close(LENGTHS);

print "done\n";

#print "\n";
	
#print "lineNum\t$lineNum\n";
#print "number of reads\t$number_of_reads\n";
#print "chrM\t$chrM\t";
#my $chrM_pc=(($chrM/$number_of_reads)*100);print "chrM_pc\t$chrM_pc\n";
#print "cis\t$cis\t";
#my $cis_pc=(($cis/$number_of_reads)*100);print "cis_pc\t$cis_pc\n";
#print "trans\t$trans\t";
#my $trans_pc=(($trans/$number_of_reads)*100);print "trans_pc\t$trans_pc\n";
#print "zeros\t$zeros\t";
#my $zeros_pc=(($zeros/$number_of_reads)*100);print "zeros_pc\t$zeros_pc\n";
#my $valid_reads = ($number_of_reads - $chrM - $trans - $zeros);
#print "valid reads\t$valid_reads\t";
#my $valid_reads_pc=(($valid_reads/$number_of_reads)*100);
#print "valid_reads_pc\t$valid_reads_pc\n";

#print "\n";

#print "chrCounterHash\n";
#foreach my $chromosome ( sort keys %chrCounterHash ) {
	#my $occurance=$chrCounterHash{$chromosome};
	#print "\t$chromosome\t$occurance\n";
	#my $pc=(($occurance/$number_of_reads)*100);
	#print "\pc\t$pc\n";
	#my $pc_valid=(($occurance/$valid_reads)*100);
	#print "pc_valid\t$pc_valid\n";
	#print "\n";
#}



#print LOG "\n";

#print LOG "smaller_180bp\t$smaller_180bp\t";my $smaller_180bp_pc=(($smaller_180bp/$valid_reads)*100);
#print LOG "smaller_180bp_pc_valid\t$smaller_180bp_pc\n";
#print LOG "one_nucleosome\t$one_nucleosome\t";my $one_nucleosome_pc=(($one_nucleosome/$valid_reads)*100);
#print LOG "one_nucleosome_pc_valid\t$one_nucleosome_pc\n";
#print LOG "two_nucleosome\t$two_nucleosome\t";my $two_nucleosome_pc=(($two_nucleosome/$valid_reads)*100);
#print LOG "two_nucleosome_pc_valid\t$two_nucleosome_pc\n";
#print LOG "three_nucleosome\t$three_nucleosome\t";my $three_nucleosome_pc=(($three_nucleosome/$valid_reads)*100);
#print LOG "three_nucleosome_pc_valid\t$three_nucleosome_pc\n";
#print LOG "large_fragments\t$large_fragments\t";my $large_fragments_pc=(($large_fragments/$valid_reads)*100);
#print LOG "large_fragments_pc_valid\t$large_fragments_pc\n";

#print LOG "\n";

#close(LOG);


	
