#!/usr/bin/perl
use DBI;
use DBD::mysql;
use Cwd;
use POSIX;
 
#-- get current directory
my $pwd = cwd();
my $today = strftime('%Y-%m-%d', localtime);



$main = $ARGV[0];

$sql_user = $ARGV[1];
$sql_pw = $ARGV[2];
$sql_h = $ARGV[3];

mysql_ext_connect($sql_user, $sql_pw, $sql_h);

opendir my $dir, "$main" or die "Cannot open $main\n";
my @files = readdir $dir;
closedir $dir;



for ($nn = 0; $nn<=$#files; $nn++){
	if ($files[$nn] =~ m/occurrence.txt/g){
		print "OPENING: $main/$files[$nn]\n\n";
		open (MYFILE, "$main/$files[$nn]");
	}
}


@entire = mysql_ext_describe('gbif_master');
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


$c = 0;
$d = 0;
$n = 0;
$n = open_new($n); 


while (<MYFILE>) {
	chomp;
	if($c == 0){
		$header = $_;
		@head = split(/\t/, $header);
		%boopis;
		for(my $xx = 0; $xx<=$#head; $xx++){
			if($head[$xx] eq 'group'){
				$head[$xx] = 'groups';
			}
			if($head[$xx] eq 'issues'){
				$head[$xx] = 'issue';
			}
			if($head[$xx] eq 'key'){
				$head[$xx] = 'key_main';
			}
			if($head[$xx] eq 'media'){
				$head[$xx] = 'medium';
			}
			if($head[$xx] eq 'order'){
				$head[$xx] = 'orderstr';
			}
			if($head[$xx] eq 'references'){
				$head[$xx] = 'reference';
			}
			if($head[$xx] eq 'relations'){
				$head[$xx] = 'relation';
			}
			if($head[$xx] eq 'spatial'){
				$head[$xx] = 'spatia';
			}
			if($head[$xx] eq 'country'){
				$head[$xx] = 'countryCode';
			}
			$boopis{$head[$xx]} = ();

			
		}
		
	} elsif ($c>= 1) {

		my @ne = split(/\t/, $_);

		for(my $xx = 0; $xx<=$#ne; $xx++){

			## HAsh structured off of the column names from GBIF API.	
			$boopis{$head[$xx]} = $ne[$xx];


		}

		for (my $keynum = 0; $keynum <= $#entire; $keynum++){
			if($keynum != $#entire){
				print OUT "$boopis{$entire[$keynum]}\t";
			} else {
				print OUT "$boopis{$entire[$keynum]}\n";
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

		

		if($c == ($d+100000))
		{ 

			$n = open_new($n);
			$d=$c;	
			print "$d\n\n";

		} else {

		}
	}
	$c++;

}
close (MYFILE);

open (datefile, ">$pwd/last_update_date");
print datefile "$today\n";
close (datefile);

print "Lines: $c\n"; 
print "EXITING\n";

mysql_ext_disconnect();
exit;

sub open_new($$) 
{
	close (OUT);
	close (OUTFAST);
	if (-e "$main/repos"){} else {
		mkdir("$main/repos");
	}
	
	my ($i) = @_;
	my $file = "$main/repos/gbif_$i.txt";
	my $filefast = "$main/repos/fast_$i.txt";
	#print "$file\n";
	open (OUT, ">$file");
	open (OUTFAST, ">$filefast");
	$i++; #Increment file count
	return $i;
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

