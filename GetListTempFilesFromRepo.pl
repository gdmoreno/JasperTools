#!/usr/bin/perl
#
#
# GetListTempFilesFromRepo.pl
#
#
# This Perl script gets the list of URIs of every 
# element under each tenant's temp folder. It also
# goes through the suborganizations.
#
# This Perl script also uses Python and Curl and assumes that
# they are installed on your system. In addition,
# it uses Perl library for parsing JSON.
#
#
# Usage:
# 
# GetListTempFilesFromRepo.pl [host] [superuser_id] [superuser_password]
#
# host: this includes the port number. For example, "localhost:8080"
# superuser_id : this will usually be the superuser
# superuser_password : the superuser password
#
# It will return a list of URIs under each of these tenant's temp folders
#
############################################################################


use strict;
use warnings;
use JSON qw(decode_json);

my $host = "http://localhost:8080";
my $superuserID = "superuser";
my $superuserPW = "superuser";

$host = $ARGV[0] if (@ARGV > 0);
$superuserID = $ARGV[1] if (@ARGV > 1);
$superuserPW = $ARGV[2] if (@ARGV > 2);

my @tenantTempFolderUris;

# The Curl commands will specify JSON as the return format
my $header = '-H "Accept:application/json"';


# This builds the Curl command to get all the organization tenant URI values
my $getOrgsCmd = "curl -s " .
        $header . " " . "\"" .
        $host .
        "/jasperserver-pro/rest_v2/organizations?q=&includeParents=true&j_username=" .
        $superuserID . "&j_password=" .
        $superuserPW . "\"" . " | python -m json.tool";



# Execute the system command and populate the array tenantTempFolderUris
my $orgs = `$getOrgsCmd`;
my $decodedOrgs = decode_json($orgs);

my @orgDocs = @{ $decodedOrgs->{'organization'} };
foreach my $t (@orgDocs) {
        my $tenantFolderUri = $t->{"tenantFolderUri"};
        push @tenantTempFolderUris, $tenantFolderUri . "/temp";
}

# Add the root-level temp folder to the tenantTempFolderUris array
push @tenantTempFolderUris, "/temp";



# Now: Loop through tenantTempFolderUris array and get
# all the URIs under these individual "temp" folder


foreach my $folder (@tenantTempFolderUris) {
        #print $folder . "\n";
        my $tempFolderName = $folder;


        my $searchCmd = "curl -s " . $header . " " . "\"" . $host .
                "/jasperserver-pro/rest_v2/resources?folderUri=" . $tempFolderName . 
                "&j_username=" .  $superuserID . "&j_password=" . $superuserPW .
                "\"";


        my $resp = `$searchCmd`;

        if ($resp eq "") {
                next;
        } else {
                $resp = `$searchCmd | python -m json.tool`;
        }
        
        my $decoded = decode_json($resp);
        my @resources = @{ $decoded->{'resourceLookup'} };
        foreach my $r ( @resources ) {
                my $uriVal = $r->{"uri"};
                print $uriVal . "\n";
        }
        #print "\n\n";
}
