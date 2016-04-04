#!/usr/bin/perl

use warnings;
use strict;

use IPC::Run3;

use lib '/opt/endit/';
use Endit qw(%conf readconf printlog getusage);

$Endit::logsuffix = 'tsmretriever.log';

readconf('/opt/endit/endit.conf');
die "No basedir!\n" unless $conf{'dirread'};
my $dir = $conf{'dirread'};
my $listfile = $dir . '/requestlist';
my $dcuser=$conf{'dcuser'};

	
while(1) {
        my $cmd_ch = "sudo echo chown -R ".$dcuser.":".$dcuser." ".$dir."/in";
        system($cmd_ch);
		if ( $? == -1 )
		{
  			print " $cmd_ch  failed: $!\n";
		}
	sleep 60;
}

