#!/home/bif701_163a09/software/bin/perl

use strict;
use warnings;

use CGI;
use LWP::Simple;
use Mail::Sendmail;
use Email::Valid;

# The Content-type: directive is required by the web-server to tell the
# browser the type of data stream that is being processed!
# The Content-type: directive MUST appear before ANY output and must be
# appended with two (2) newlines!!!

#Oath:

#Student Assignment Submission Form
#==================================
#I/we declare that the attached assignment is wholly my/our
#own work in accordance with Seneca Academic Policy.  No part of this
#assignment has been copied manually or electronically from any
#other source (including web sites) or distributed to other students.

#Name(s)                                          Student ID(s)
#Nathan Lo                                        013491154
#---------------------------------------------------------------

my $cgi = new CGI;
my (@attributes, $tmpAttr, $baseURL, $genbankFile, $virus, $ncbiURL, $rawData);
my (@tmpArray, @genbankData, $start, $i, $result, $mailTo);

@attributes = $cgi->param('attributes');
$virus = $cgi->param('viruses');
$mailTo = $cgi->param('mailto');

$baseURL = "ftp://ftp.ncbi.nih.gov/genomes/Viruses/";

print "Content-type: text/html\n\n";

print "<html><head><title>Genbank Results...</title></head>\n";
print "<body><pre>\n";

#print "Test Genbank solution\n";
#print "virus selected is: '$virus'\n";
$ncbiURL = $baseURL . $virus;
#print "full URL: $ncbiURL\n";


@tmpArray = split('/', $virus);  # capture the accession number from the string
$genbankFile = $tmpArray[1];     # the 2nd element of the array after the split '/'
#print "genbank file to write is: $genbankFile\n";

unless(-e $genbankFile) {
   $rawData = get($ncbiURL); # this function should download the genbank file
			     # and store it in the current working directory
   open(FD, "> $genbankFile") || die("Error opening file... $genbankFile $!\n");
   print FD $rawData;
   close(FD);
}

# slurp the genbank file into a scalar!
$/ = undef;
open(FD, "< $genbankFile") || die("Error opening file... $genbankFile $!\n");
$rawData = <FD>;
close(FD);

$result = "";
$start = 1;
$i = 1;

foreach $tmpAttr (@attributes) {
   if($tmpAttr =~ /LOCUS/) {
      $rawData =~ /(LOCUS.*?)DEFINITION/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /DEFINITION/) {
      $rawData =~ /(DEFINITION.*?)ACCESSION/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /ACCESSION/) {
      $rawData =~ /(ACCESSION.*?)VERSION/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow    
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /VERSION/) {
      $rawData =~ /(VERSION.*?)KEYWORDS/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /KEYWORDS/) {
      $rawData =~ /(KEYWORDS.*?)SOURCE/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /SOURCE/) {
      $rawData =~ /(SOURCE.*?)ORGANISM/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /ORGANISM/) {
      $rawData =~ /(ORGANISM.*?)REFERENCE/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /REFERENCE/) {
      $rawData =~ /(REFERENCE.*)COMMENT/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /AUTHORS/) {
      while($rawData =~ /(AUTHORS.*?)TITLE/gs){
            print "$1";
            $result .= $1;  # storing the result in a scalar to allow
      } 		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /TITLE/) {
      while($rawData =~ /(TITLE.*?)JOURNAL/gs){
            print "$1";
            $result .= $1;  # storing the result in a scalar to allow
      }		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /JOURNAL/) {
      while($rawData =~ /(JOURNAL.*?)PUBMED/gs){
            print "$1";
            $result .= $1;  # storing the result in a scalar to allow
      }      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /MEDLINE/) {
      while($rawData =~ /(PUBMED.*?)REFERENCE/gs){
            print "$1";
            $result .= $1;  # storing the result in a scalar to allow
      }		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /FEATURES/) {
      $rawData =~ /(FEATURES.*?)ORIGIN/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /BASECOUNT/) {
      my $d;
      $rawData =~ /(ORIGIN.*)\/\//s;
      $d = $1;
      print(baseCount($d));
      $result .= baseCount($d);  # storing the result in a scalar to allow
		      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /ORIGIN/) {
      $rawData =~ /(ORIGIN.*)\/\//s;
      print "$1";
      $result .= $1;
   }
}

sub baseCount($){ #baseCount subroutine which counts each nucleotide
      my $nCount;
      $nCount = shift(@_);
      return("A: " . $nCount =~ s/[a]//g .  " T: " . $nCount =~ s/[t]//g . " C: " . $nCount =~ s/[c]//g . " G: " . $nCount =~ s/[g]//g . "\n");
}

unless( Email::Valid->address($mailTo) ) { #email validation
    print "Sorry, that email address is not valid!";
}

my %mail = ( To      => $mailTo,
	     From    => 'ntlo@myseneca.ca',
	     Message => "$result"
	   );

sendmail(%mail) or die $Mail::Sendmail::error;
print "OK! Sent mail message...\n";

print "</pre></body></html>\n";
