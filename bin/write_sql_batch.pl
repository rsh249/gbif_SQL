#!/usr/bin/perl

use Cwd;
 
#-- get current directory
my $pwd = cwd();
my $pbs_dir =  $ENV{'PBS_O_WORKDIR'};
print "$pwd\n$pbs_dir\n";
my $pwd = $pbs_dir;


$main = $ARGV[0];
$db = $ARGV[1];
$main = "$pwd/$main";
print "$pwd/load.bat\n";
print "$main\n";
open (MYFILE, ">$pwd/load.bat");
open (MYFILEFAST, ">$pwd/loadfast.bat");

opendir my $dir, "$main" or die "Cannot open $main\n";
my @files = readdir $dir;
closedir $dir;

print MYFILE "use $db;\n";
print MYFILE "ALTER TABLE gbif_master DISABLE KEYS;\n";

print MYFILEFAST "use rh_div_amnh;\n";
print MYFILEFAST "ALTER TABLE div_base DISABLE KEYS;\n";
for (my $i = 0; $i <= $#files; $i++){
		#print "$i: $files[$i]\n";
	if (-e "$main/gbif_$i.txt"){
		print MYFILE "LOAD DATA LOCAL INFILE '$main/gbif_$i.txt' INTO TABLE gbif_master;\n";
	} 
	if (-e "$main/fast_$i.txt"){
		print MYFILEFAST "LOAD DATA LOCAL INFILE '$main/fast_$i.txt' INTO TABLE div_base;\n";
	}

}

print MYFILE "ALTER TABLE gbif_master ENABLE KEYS;\n";
print MYFILEFAST "ALTER TABLE div_base ENABLE KEYS;\n";
close(MYFILE);
close(MYFILEFAST);

exit;


