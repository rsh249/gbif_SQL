#!/usr/bin/perl
use Cwd;
use JSON;
use Data::Dumper;
use LWP::UserAgent;
use DBI;
use open ':std', ':encoding(UTF-8)';
use POSIX;
#Mysql setup
my $pwd = cwd();
my $today = strftime('%Y-%m-%d', localtime);
#print "$today\n"; exit;
open my $file, '<', "$pwd/last_update_date"; 
$lower_date = <$file>; chomp $lower_date; print "Last Update ON: $lower_date\n";
close $file;

$sql_user = $ARGV[0];
$sql_pw = $ARGV[1];
$sql_h = $ARGV[2];
$db = $ARGV[3];

mysql_ext_connect($sql_user, $sql_pw, $sql_h);

@entire = mysql_ext_describe('gbif_master'); #get field names
@fastfields = mysql_ext_describe('div_base');

for (my $ff = 0; $ff<=$#fastfields; $ff++){
	if($fastfields[$ff] eq 'species'){
		$fastfields[$ff] = 'specificEpithet';
	}
	if($fastfields[$ff] eq 'taxon_str'){
		$fastfields[$ff] = 'species';
	}
	if($fastfields[$ff] eq 'lat'){
		$fastfields[$ff] = 'decimalLatitude';
	}
	if($fastfields[$ff] eq 'lon'){
		$fastfields[$ff] = 'decimalLongitude';
	}
	if($fastfields[$ff] eq 'div_id'){
		$fastfields[$ff] = 'gbifID';
	}

}


######
$upper_date = "3000-01-01"; #hard code this and it will work for the next 983 years

#read update_log_file
#should contain one line with lower date
#$lower_date = '2017-03-07'; #Get from the LOG file or BASH INPUT
$limit = 300; #This is the maximum
$offset = 0; #MUST iterate through this until the endOfRecords tag comes back = 1 instead of =0;
	# $offset = $offset +300; #each iteration
$count = 301; #Get count from the results object and reset. Then check in while
$endOfRecords=0;
$num_dl = 0;
$version = 'v1';
@fields = ();

$xxx = 0;
my $file = "$pwd/update/gbif_master.txt";
my $filefast = "$pwd/update/fast.txt";

open (OUT, ">$file");
open (OUTFAST, ">$filefast");


while($endOfRecords == 0){
	$jstext = get_http_page("https://api.gbif.org/$version/occurrence/search?lastInterpreted=$lower_date,$upper_date&limit=$limit&offset=$offset");

	my $student = decode_json $jstext;

#print($student{'results'}[0]{'month'}); exit;

	my @v = values $student;  
	my @k = keys   $student;
	for(my $i=0; $i < scalar(@v); $i++){
		#print "$k[$i] :: $v[$i]\n";
		if($k[$i] =~ m/results/g){
			$hashref = $student->{$k[$i]};
			my @sv = values $hashref;
			my @sk = keys $hashref;
			for(my $zz=0; $zz < scalar(@sk); $zz++){
				# print"$sk[$zz]\n";
				$again = $sv[$zz];
				#print "$again\n";
				my @sva = values $again;
				my @ska = keys $again;
				for(my $xx=0; $xx < scalar(@ska); $xx++){
					#print"$sva[$xx] :: $ska[$xx]\n";
					push(@fields, $ska[$xx]);
				
				}

			%boopis;
			for(my $xx = 0; $xx<=$#ska; $xx++){
					#print "$ska[$xx]\n";
					if($ska[$xx] eq 'group'){
						$ska[$xx] = 'groups';
					}
					if($ska[$xx] eq 'issues'){
						$ska[$xx] = 'issue';
					}
					if($ska[$xx] eq 'key'){
						$ska[$xx] = 'key_main';
					}
					if($ska[$xx] eq 'media'){
						$ska[$xx] = 'medium';
					}
					if($ska[$xx] eq 'order'){
						$ska[$xx] = 'orderstr';
					}
					if($ska[$xx] eq 'references'){
						$ska[$xx] = 'reference';
					}
					if($ska[$xx] eq 'relations'){
						$ska[$xx] = 'relation';
					}
					if($ska[$xx] eq 'spatial'){
						$ska[$xx] = 'spatia';
					}
					if($ska[$xx] eq 'country'){
						$ska[$xx] = 'countryCode';
					}

					$boopis{$ska[$xx]} = ();
			
				}
			#Print to files for load local infile

				for(my $xx = 0; $xx<=$#sva; $xx++){
		
					## HAsh structured off of the column names from GBIF API.	
					$boopis{$ska[$xx]} = $sva[$xx];
					#print "$ska[$xx]\n";
		

				}
	
				for (my $keynum = 0; $keynum <= $#entire; $keynum++){
					if($keynum != $#entire){
						print OUT "$boopis{$entire[$keynum]}\t";
					} else {
						print OUT"$boopis{$entire[$keynum]}\n";
					}
				}
		
				check_flags('basisOfRecord', 'decimalLatitude', 'decimalLongitude', 'locality'); #Send keys to do a few quality checks
				for (my $keynum = 0; $keynum <= $#fastfields; $keynum++){

					if($keynum != $#fastfields){
						print OUTFAST "$boopis{$fastfields[$keynum]}\t";
					} else {
						print OUTFAST "$boopis{$fastfields[$keynum]}\n";
					}
				}










				#insert into gbif_master

				#mysql_add_record(\@ska, \@sva, 'gbif_master');
				#mysql_add_record(\@ska, \@sva, 'div_base');
				
			}
			$downloaded = scalar(@sk);
		}
	} 
	$offset = $student->{'offset'};
	$count = $student->{'count'};
	$endOfRecords = $student->{'endOfRecords'};
	$num_dl = $num_dl + $downloaded;
	$offset = $offset+$limit;
	#print "\n\n$limit\n$count\n$num_dl\n$endOfRecords\n$offset\n$downloaded\n";
	@fields = uniq(@fields);
	


	####
	#print "Number of fields; $#fields\n";
	print "Count is: $num_dl/$count\n";
	print "Callback #: $xxx\n";
	$xxx++;

}

close(OUT);
close(OUTFAST);
print "Writing SQL batch files...\n";

open (SQLOUT, ">$pwd/update.bat");
print SQLOUT "use $db;\n";
print SQLOUT "alter table gbif_master DISABLE KEYS;\n";
print SQLOUT "LOAD DATA LOCAL INFILE '$pwd/update/gbif_master.txt' REPLACE INTO TABLE gbif_master;\n";
print SQLOUT "alter table gbif_master ENABLE KEYS;\n";
close(SQLOUT);
system("mysql -u$sql_user -p$sql_pw -h$sql_h < $pwd/update.bat");

open (SQLOUTFAST, ">$pwd/updatefast.bat");
print SQLOUTFAST "use $db;\n";
print SQLOUTFAST "alter table div_base DISABLE KEYS;\n";
print SQLOUTFAST "LOAD DATA LOCAL INFILE '$pwd/update/fast.txt' REPLACE INTO TABLE div_base;\n";
print SQLOUTFAST "alter table div_base ENABLE KEYS;\n";
close(SQLOUTFAST);
system("mysql -u$sql_user -p$sql_pw -h$sql_h < $pwd/updatefast.bat");

open (datefile, ">$pwd/last_update_date");
print datefile "$today\n";
close (datefile);

exit;


sub uniq($$) {
    my %seen;
    grep !$seen{$_}++, @_;
}
#fetch_json_page($js[0]);
sub get_http_page($)
{
	my ($wha_page) = @_;
 	my $ua = new LWP::UserAgent;
	my $request = new HTTP::Request('GET', $wha_page);
	$response = $ua->request($request);
	$sul = $response->content;
	 #@unfile = $response->content;
	 #$numlines = chomp(@unfile);
	return $sul;
}


sub check_flags(){
	if($boopis{'hasGeospatialIssues'} eq 'true') {
		$boopis{'hasGeospatialIssues'} = 1;
	} else {
		$boopis{'hasGeospatialIssues'} = 0;
	}
	$boopis{'is_fossil'} = 0;
	$boopis{'is_bad'} = 0;
	$boopis{'no_precision'} = 0;
	$boopis{'cultivated'} = 0;
	$boopis{'is_ambiguous'} = 0;

	if ($boopis{'basisOfRecord'} =~ m/fossil/g or $boopis{'basisOfRecord'} =~ m/FOSSIL/g){
		$boopis{'is_fossil'} = 1;
	} else {$boopis{'is_fossil'} = 0;}
	if ($boopis{'decimalLatitude'} == 0 or $boopis{'decimalLongitude'} == 0){
		$boopis{'is_bad'} = 1;
	}
	$int_lat = int($boopis{'decimalLatitude'});
	$int_lon = int($boopis{'decimalLongitude'});
	if ($int_lat == $boopis{'decimalLatitude'} or $int_lon == $boopis{'decimalLongitude'}){
		$boopis{'no_precision'} = 1;
	}

	if (sprintf("%.1f", $boopis{'decimalLatitude'}) == $boopis{'decimalLatitude'} or sprintf("%.1f", $lon) == $boopis{'decimalLongitude'}){
		$boopis{'no_precision'} = 1;
	}


	if ($boopis{'locality'} =~ m/garden/g or $boopis{'locality'} =~ m/cultivat/g or $boopis{'locality'} =~ m/botani/g){
		$boopis{'cultivated'} = 1;
	}
	
}


sub mysql_add_record($$) {
	my($keyref, $valref, $table) = @_;

	if($table eq 'gbif_master'){
		#replace key values with matching column names\




		for (my $keynum = 0; $keynum <= $#entire; $keynum++){
			if($keynum != $#entire){
				print OUT "$boopis{$entire[$keynum]}\t";
			} else {
				print OUT "$boopis{$entire[$keynum]}\n";
			}
		}
		
		#check_flags('basisOfRecord', 'decimalLatitude', 'decimalLongitude', 'locality'); #Send keys to do a few quality checks
		

		

	} elsif ($table eq 'div_base'){
		#replace key values with column names

		#trim keys and columns to only the ones included in @fastfields
		for (my $keynum = 0; $keynum <= $#fastfields; $keynum++){

			if($keynum != $#fastfields){
				print OUTFAST "$boopis{$fastfields[$keynum]}\t";
			} else {
				print OUTFAST "$boopis{$fastfields[$keynum]}\n";
			}
		}


	} else {return(0);}


	$col_str = join(', ', @$keyref);
	$val_str = join(',', @$valref);

	$mystr = "INSERT INTO $table ($col_str) VALUES ($val_str) ON DUPLICATE KEY UPDATE ($col_str) SET ($val_str);";
	#print "$mystr\n";
#	$sth = $dbhi->prepare($mystr)
    #			or die "Can't prepare $statement: $dbhi->errstr\n";
#	$rv = $sth->execute
 #       	 or die "can't execute the query: $sth->errstr";
#	$rc = $sth->finish;
	
}



sub mysql_ext_connect($$)
{
	my ($mysql_user, $mysql_pwd, $mysql_host) = @_;
	#print "$mysql_user using $mysql_pwd on $mysql_host\n";
	if($dbhi == 0){
		my $connect = "DBI:mysql:database=rh_div_amnh;host=$mysql_host";
		#print "$connect\n";
		$dbhi = DBI->connect($connect, $mysql_user, $mysql_pwd)

			or die "Can\'t connect $statement: $dbhi->errstr\n";
	}
	#print "CONNECTION ESTABLISHED = $dbhi<br>\n";
	return($dbhi);
}
sub mysql_ext_describe($$){
	my ($table) = @_;
	my $mystr = "describe $table";
	my $sth = $dbhi->prepare($mystr)
		or die "Cant prepare $statement: $dbhi->errstr\n";
	my $rv = $sth->execute
		or die "cant execute the query: $sth->errstr";
	my $id_table = $sth->fetchall_arrayref
	        or die "$sth->errstr\n";
	my $rc = $sth->finish;
	
	my $check = $id_table->[0][0]; 
	my @l = ();
	for (my $i = 0; $i < scalar($#{$id_table} ); $i++){
		#print "$id_table->[$i][0]\n";
		$l[$i] = $id_table->[$i][0];

	}
	return(@l);
}

sub mysql_ext_disconnect()
{
	$dbhi->disconnect;
}



