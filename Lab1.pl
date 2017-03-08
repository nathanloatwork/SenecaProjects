#!c:\strawberry\perl\bin\perl.exe

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

use strict;
use warnings;
use DBI;
use CWD;

my ($dataSourceName, $dbh, $userName, $password, $dataBaseName, $dataBase, $driver, $dataBaseConnect, $source);
my ($sqlCommand, $file, @records, $tableName, $sqlStatement, $rv, $id, $recordsRef, $counter, $entry);

$dataBaseName = "bacteria";
$tableName    = "cre";
$dataSourceName = "dbi:SQLite:dbname=bacteria.db";
$driver   = "SQLite";
$dataBase = "bacteria.db";
$dataBaseConnect = "DBI:$driver:dbname=$dataBase";
$userName = $password = "";

$dbh = DBI->connect($dataSourceName, $userName, $password) or die $DBI::errstr;
print "Successfully Opened database...\n";

$dbh->do("DROP TABLE IF EXISTS $tableName");

$sqlStatement = qq(CREATE TABLE $tableName
		  ( ID        INT PRIMARY KEY    NOT NULL,
            URL                  TEXT    NOT NULL,
            LOCUS                TEXT    NOT NULL,
		    DEFINITION           TEXT    NOT NULL,
		    ACCESSION            TEXT     NOT NULL,
		    ORIGIN             TEXT  NOT NULL);
		  );
        
$rv = $dbh->do($sqlStatement);

if($rv < 0) {
   print $DBI::errstr;
}
else {
   print "Successfully Created Table...\n";
}

$id = 0;
foreach my $file ( glob ("*.gb") ) {
    $records[0][$id] = $id+1;
    $id += 1;
}

$counter = 1;
$entry = 0;
while ($counter <= $id){
    $source = "C:/Users/Nathan Lo/Documents/Perl/bacteriaFiles/sequence" . $counter . ".gb";

    open(my $fh, '<:encoding(UTF-8)', $source)
      or die "Could not open file '$source' $!";

    while (my $row = <$fh>) {
      chomp($row);
      $file .= $row;
    }
    
    while ($entry < $counter){ #loop to populate 2D array with downloaded entries
        $source =~ tr/\//\\/;
        $records[1][$entry] = $source;
        $file =~ /(LOCUS.*?)DEFINITION/s;
        $records[2][$entry] = $1;
        $file =~ /(DEFINITION.*?)ACCESSION/s;
        $records[3][$entry] = $1;
        $file =~ /(ACCESSION.*?)VERSION/s;
        $records[4][$entry] = $1;
        $file =~ /(ORIGIN.*)\/\//s;
        $records[5][$entry] = $1;
        $entry++;
    }    

    $counter++;
}
    
for(my $i = 0;  $i < $id; $i++){ #loop to populate database by accessing each array element
    $dbh = DBI->connect($dataBaseConnect, { RaiseError => 1 }) 
        or die $DBI::errstr;
    $sqlStatement = $dbh->prepare( 'INSERT INTO '.$tableName.'( ID, URL, LOCUS, DEFINITION, ACCESSION, ORIGIN )  VALUES (? ,? ,? ,? ,? ,? )');
    $sqlStatement->execute ($records[0][$i],$records[1][$i],$records[2][$i],$records[3][$i],$records[4][$i],$records[5][$i]);
    $dbh->disconnect();
}

$dbh->disconnect( );


