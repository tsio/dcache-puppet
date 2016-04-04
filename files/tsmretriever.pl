#!/usr/bin/perl

use warnings;
use strict;

use IPC::Run3;

use lib '/opt/endit/';
use Endit qw(%conf readconf printlog getusage);

$Endit::logsuffix = 'tsmretriever.log';

readconf('/opt/endit/endit.conf');
die "No basedir!\n" unless $conf{'dirread'};
die "No link dir !\n" unless $conf{'linkdir'};
my $linkdir = $conf{'linkdir'};
my $dir = $conf{'dirread'};
my $listfile = $dir . '/requestlist';


sub checkrequest($) {
	my $req=shift;
	my $rf = $conf{'dirread'} . '/request/' . $req;
	my $pid;
	if(-z $rf) {
		printlog "Zero-sized request file $rf\n";
	}
	open RF, $rf;
	while(<RF>) {
		if($_ =~ /(\d+) (\d+)/) {
			$pid = $1;
		} else {
			printlog "Broken request file $rf\n";
		}
	}
	if(getpgrp($pid) > 0) {
		return 1;
	} else {
		unlink $rf;
		return 0;
	}
}
	
while(1) {
	printlog ": sleeping...\n";
	sleep 60;
	opendir(REQUEST,$dir . '/request/');
	my (@requests) = grep { /^[0-9A-Fa-f]+$/ } readdir(REQUEST);
	closedir(REQUEST);
	next unless @requests;
	open LF, ">", $listfile or die "Can't open listfile: $!";
	my $req;
	printlog ": going through each request in the listfile.\n";
	foreach $req (@requests) {
		if(checkrequest($req)) {
			#print LF "$dir/out/$req\n";
			print LF "$linkdir$req\n";
			printlog ": request $req.\n";
		} else {
			printlog "Deactivating $req due to unexisting pid\n";
		}
	}
	close LF;
	my $indir = $dir . '/in/';
	my @dsmcopts = split /, /, $conf{'dsmcopts'};
	#printlog ": trying DCACHE-TEST node...\n";
	printlog ": trying DCACHE-LOFAR node...\n";
        my @cmd = ('dsmc','retrieve','-replace=no','-followsymbolic=yes',"-filelist=$listfile",$indir);
	my ($in,$out,$err);
	$in="A\n";
	if((run3 \@cmd, \$in, \$out, \$err) && $? ==0) { 
		# files migrated from tape without issue
	} else {
		# something went wrong. figure out what files didn't make it.
		# wait for the hsm script to remove succesful requests
		sleep 60;
		open LF, "<", $listfile;
		my (@requests) = <LF>;
		close LF;
		my $outfile;
		my $returncode;
		foreach $outfile (@requests) {
			my (@l) = split /\//,$outfile;
			my $filename = $l[$#l];
			chomp $filename;
			my $req = $dir . '/request/' . $filename;
			if( -e $req ) {
				printlog ": trying each file individually.\n";
				my @cmd = ('dsmc','retrieve','-replace=no','-followsymbolic=yes',$outfile,$indir);
				my ($in,$out,$err);
				$in="A\n";
				if((run3 \@cmd, \$in, \$out, \$err) && $? ==0) {
					# Went fine this time. Strange..
				} else {
					$returncode=$? >> 8;
					printlog ": warning, dsmc returned $returncode on $outfile";
					printlog ": ERROR OUTPUT: $err\n";
					printlog ": STANDARD OUTPUT: $out";
					open EF, ">", $req . '.err' or warn "Could not open $req.err file: $!\n";
					print EF "32\n";
					close EF;
                                }
			}
		}
	}
	unlink $listfile;
}
