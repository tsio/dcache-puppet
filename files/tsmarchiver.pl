#!/usr/bin/perl

use warnings;
use strict;

use IPC::Run3;
use POSIX qw(strftime);

use lib '/opt/endit/';
use Endit qw(%conf readconf printlog printclean_out getusage clean_out);

$Endit::logsuffix = 'tsmarchiver.log';
$Endit::logclean_out = 'clean_out.log';

readconf('/opt/endit/endit.conf');
warn "No logdir!\n" unless $conf{'logdir'};
die "No basedir!\n" unless $conf{'dirwrite'};
die "No link dir !\n" unless $conf{'linkdir'};
my $linkdir=$conf{'linkdir'};
my $timer = $conf{'timeout'};

printlog "No timeout!\n" unless $conf{'timeout'};
printlog "No minusage!\n" unless $conf{'minusage'};

sub is_folder_empty {
    my $dirname = shift;
    opendir(my $dh, $dirname) or die "Not a directory";
    return scalar(grep { $_ ne "." && $_ ne ".." } readdir($dh)) == 0;
}

while(1) {
	my $dirout = $conf{'dirwrite'} . "/out/";
	#my $dir = $conf{'dirwrite'} . '/out/';
	my $dir = $linkdir;
	my $cleanDir = $dir;
	my $usage = getusage($dirout);
	
	printlog ": usage = $usage\n";
	while (($usage<$conf{'minusage'} && $timer<$conf{'timeout'}) || is_folder_empty($dirout)) {
		printlog ": Only $usage used, sleeping a while (slept $timer)\n";
		sleep 60;
		$timer+=60;
		$usage = getusage($dirout);
	}
    $timer = 0; 
	my $date=strftime "%Y%m",localtime;
	my @dsmcopts = split /, /, $conf{'dsmcopts'};

	opendir THISDIR, $cleanDir;
        my @allFiles = grep { $_ ne '.' and $_ ne '..' && -f "$cleanDir/$_"}  readdir THISDIR;
        printlog ": files in $cleanDir: @allFiles\n";
        closedir THISDIR;

	my @cmd = ('dsmc','archive','-v2archive','-deletefiles',"-description=$date","$dir*");
	my ($out,$err);
	if((run3 \@cmd, \undef, \$out, \$err) && $? ==0) { 
		printlog $out if $conf{'verbose'};
		# files migrated to tape without issue
		#clean_out("$dir","$dirout");

		foreach (@allFiles) {
                	if(-e $dir . $_) {
                        	printlog ": file $dir$_ exists\n";
                        	printlog ": not removing $dirout$_\n";
                	} else {
                        	printlog ": file $dir$_ doesn't exist\n";
                        	printlog ": removing: unlink $dirout$_\n";
				unlink "$dirout$_";
                	}
        	}

	} else {
		# something went wrong. log and hope for better luck next time?
		printlog localtime() . ": warning, dsmc archive failure: $!\n";
		printlog $err;
		printlog $out;
	}
}
