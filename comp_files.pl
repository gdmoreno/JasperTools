#!/usr/bin/perl
#
# comp_files.pl
#
# Compares the Spring configuration files for a customer that  has modified their files
# to the default ones that are available in the vanilla version of the product.
# 
# Instructions:
#   1. Put the entire set of modified set of files into one directory. This will be your first parameter
#   2. Put the standard set of files into another directory. This will be your second parameter
# Usage: 
# comp_files.pl [directory with modified files] [directory with standard files]
#
# Results get written out to the results.txt file.
#
#############################################################################################

$modifiedDir = $ARGV[0];
@files = `ls $modifiedDir`;
$standardDir = $ARGV[1];
$arraySize = @files;
%RESULTS = ();

for ($i = 0; $i < $arraySize; $i++) {
	$file = $files[$i];
	chop ($file);

	$otherFile = `ls $standardDir/$file`;
	chop ($otherFile);

	if ($otherFile eq "") {
		push @noMatches, $file;
		next;

	} else {
		$command = "diff -w $modifiedDir/$file $otherFile\n";
		$result = `$command`;
		chop $result;
		if ($result eq "") {
			push @NoDifferences, $file;
		} else {
			push @HasDifferences, $file;
			$RESULTS{$file} = $result;
		}
	}
	
}

open RESULTS, ">results.txt";

print RESULTS "NO MATCHES\n";
$sizeNM = @noMatches;
for ($i = 0; $i < $sizeNM; $i++) {
	print RESULTS "$noMatches[$i]\n";
}

$sizeND = @NoDifferences;


print  RESULTS "\nHAS DIFFERENCES\n";
$sizeHD = @HasDifferences;
for ($i = 0; $i < $sizeHD; $i++) {
	print RESULTS "$HasDifferences[$i]\n";
}


print RESULTS "\nSummary:\n";
print RESULTS "Total Files     :  $arraySize\n";
print RESULTS "No Differences  :  $sizeND\n";
print RESULTS "Has Differences :  $sizeHD\n";
print RESULTS "No Matches      :  $sizeNM\n\n";

foreach my $file (keys %RESULTS) {
	print RESULTS " ============== $file ========================= \n";
	print RESULTS $RESULTS{$file};
	print RESULTS "\n\n";
}
close RESULTS;
