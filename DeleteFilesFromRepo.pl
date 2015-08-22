#!/usr/bin/perl
#
#
# DeleteFilesFromRepo.pl
#
#
# This Perl script takes a list of URIs specified
# in an input file and deletes them using the REST APIs.
#
# This script uses Perl and assumes that
# it is installed on your system. In addition,
# it also uses Curl.
#
#
# Usage:
# 
# GetListTempFilesFromRepo.pl [file] [host] [superuser_id] [superuser_password]
#
# file: this is the input file, and should have one URI value per line.
# host: this includes the port number. For example, "localhost:8080"
# superuser_id : this will usually be the superuser
# superuser_password : the superuser password
#
#
############################################################################


use strict;
use warnings;
use JSON qw(decode_json);


my $file = "UrisToDelete.txt";
my $host = "http://" . "localhost:8080";
my $superuserID = "superuser";
my $superuserPW = "superuser";

$file = $ARGV[0] if (@ARGV > 0);
$host = $ARGV[0] if (@ARGV > 1);
$superuserID = $ARGV[1] if (@ARGV > 2);
$superuserPW = $ARGV[2] if (@ARGV > 3);

#
# Step 1 : Use the REST Login service 
# to authenticate and write a cookie
# to the headers.txt file
#

my $authCommand = 'curl -X "POST" -d "j_username=' . $superuserID . '&j_password=' . $superuserPW .
        '" "' . $host . '/jasperserver-pro/rest/login" --dump-header headers.txt';      

print "$authCommand\n\n";

my $result = `$authCommand`;

#
# Step 2 : Read the headers.txt file and
# pull out the JSESSIONID part of the cookie
#
my $cookieValue = "";

open FILE, "headers.txt";
while (my $line = <FILE>) {
        if ($line =~ /Cookie/) {
                my @elements = split(/ /, $line);
                chop($cookieValue = $elements[1]);
        }
}
close FILE;



# 
# Step 3: Read the file with the 
# URIs and populate the Uris array
#
my @Uris;

open FILE, "$file";
while (my $line = <FILE>) {
        chop ($line);
        push @Uris, $line;
}
close FILE;

 

#
# Step 4: Loop through Uris array and 
# delete them from the repository
#

my $header = '-X "DELETE"';
my $cookie = '--cookie "' . $cookieValue . '"';

foreach my $uri (@Uris) {
        print $uri . "\n";

        my $deleteCmd = "curl -s " . $header . " " . $cookie . " " .
                "\"" . $host .
                '/jasperserver-pro/rest_v2/resources' . $uri . '"';


        print "$deleteCmd\n\n";
        my $resp = `$deleteCmd`;
}
