#!/usr/bin/perl

use warnings;
use strict;

use IPC::Run3;
use POSIX qw(strftime);

use lib '/opt/endit/';
use Endit qw(%conf readconf printlog printclean_out getusage clean_out);

$Endit::logsuffix = 'tsmcleaning.log';
$Endit::logclean_out = 'clean_out.log';

readconf('/opt/endit/endit.conf');
warn "No logdir!\n" unless $conf{'logdir'};
die "No basedir!\n" unless $conf{'dirwrite'};
die "No link dir !\n" unless $conf{'linkdir'};
my $linkdir=$conf{'linkdir'};



printlog "No timeout!\n" unless $conf{'timeout'};
printlog "No minusage!\n" unless $conf{'minusage'};

sub is_folder_empty {
    my $dirname = shift;
    opendir(my $dh, $dirname) or die "Not a directory";
    return scalar(grep { $_ ne "." && $_ ne ".." } readdir($dh)) == 0;
}

my $dirout = '/pool02/out/';
my $dir = $linkdir;

opendir THISDIR, $dirout;
my @allFiles = grep { $_ ne '.' and $_ ne '..' && -f "$dirout/$_"}  readdir THISDIR;
printlog "Source files in $dirout: @allFiles\n";
closedir THISDIR;

foreach (@allFiles) {
	printlog ": checking $_\n";
	if (-e $dir . $_) {
		printlog ": file $dir$_ exists\n";
		printlog ": not removing $dirout$_\n";
	} else {
		printlog ": sleeping 4\n";
		sleep 4;
		if (-e $dir . $_) {
			printlog ": file $dir$_ exists\n";
			printlog ": not removing $dirout$_\n"
		} else {
			printlog ": file $dir$_ doesn't exist\n";
			printlog ": removing: unlink $dirout$_\n";
			unlink "$dirout$_";
		}
	}
}
printlog ": end cleaning\n";
