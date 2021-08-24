#!/usr/bin/perl

use warnings;
use File::Basename qw(basename);
use feature "switch";

my $date	 = localtime;
my $cos 	 = "default";
my $domain	 = "zmail.lab"; 
my $password = "xtest123x";

my $file1 = "oaccounts.zmp";
open(FH1, '>', $file1) or die $!;

# sanitize password
$password =~ s/\"/\\\"/g;

open(UFH, '<', "allusers.csv") or die $!;
while (<UFH>) {
    chomp;
    next if /^\s*$/;    # skip empty lines
    next if /^#/;       # skip # lines

    #GivenName,Surname,City,ZipCode,CountryCode,Country,EmailAddress,samAccountName,Username,TelephoneNumber,TelephoneCountryCode,Department,Manager,Title
    my ( $fn, $ln, $city, $zip, $co, $country, $uname, $ph, $phcode, $dept, $manager, $title ) = split( /,/, $_, 12 );
    $title =~ s/\r//g;    
    my $displayname = $fn . ( defined($ln) ? " $ln" : "" );
    my $phone = "+" . $phcode . $ph;
	$title =~ tr/\015//d;
    
	my $man = lc $manager;
	$uname = lc $uname;
    print FH1 (
        qq{ca $uname\@$domain $password},
        ( defined($fn)       	? qq{ givenName "$fn"}         		: () ),
        ( defined($ln)          ? qq{ sn "$ln"}                  	: () ),
        ( defined($displayname) ? qq{ displayName "$displayname"} 	: () ),
        ( defined($country) 	? qq{ co "$country"} 				: () ),
        ( defined($city)		? qq{ l "$city"}					: () ),
        ( defined($zip)			? qq{ postalCode "$zip"}			: () ),
        ( defined($phone)		? qq{ telephoneNumber "$phone"}		: () ),
        ( defined($title)		? qq{ title "$title"}				: () ),
        ( defined($dept)		? qq{ ou "$dept"}					: () ),
        ( defined($man)			? qq{ manager "uid=$man,ou=people,dc=zmail,dc=lab"}: () ),
        qq{ zimbraNotes "ORG Testing"},
        qq{\n}
    );
}
close(UFH);
close(FH1);

print ("\nRun the following commands to ...\n1. Create the zmail.lab domain and GALsync account.\n2. Create users with the hierarchy structure in GAL.\n\n");
print ("1.\tzmprov cd zmail.lab\n");
print ("2.\tzmgsautil createAccount -a galsync@zmail.lab -n zimbra --domain zmail.lab -t zimbra -s `zmhostname` -p 1d\n");
print ("3.\tzmprov -f oaccounts.zmp\n");
print ("4.\tzmgsautil fullSync -a galsync@zmail.lab -n zimbra\n\n");