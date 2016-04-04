package Endit;
use strict;
use warnings;
use IPC::Run3;
use POSIX qw(strftime);
require File::Compare;

our (@ISA, @EXPORT_OK);
BEGIN {
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(%conf readconf printlog printclean_out getusage dirhash clean_out);
}


our $logsuffix;
our $logclean_out;
our %conf;

sub readconf($) {
	my $conffile = shift;
	my $key;
	my $val;
#	warn "opening conffile $conffile";
	open CF, '<'.$conffile or die "Can't open conffile: $!";
	while(<CF>) {
		next if $_ =~ /^#/;
		chomp;
		($key,$val) = split /: /;
		next unless defined $val;
		$conf{$key} = $val;
	}
}

sub printlog($) {
	my $msg = shift;
	my $now = strftime '%Y-%m-%d %H:%M:%S ', localtime;
	open LF, '>>' . $conf{'logdir'} . '/' . $logsuffix or warn "Failed to open " . $conf{'logdir'} . '/' . $logsuffix . ": $!";
	print LF $now . $msg;
	close LF;
}

sub printclean_out($) {
        my $msg = shift;
        open LF, '>>' . $conf{'logdir'} . '/' . $logclean_out or warn "Failed to open " . $conf{'logdir'} . '/' . $logclean_out . ": $!";
        print LF $msg;
        close LF;
}

# Return filessystem usage (gigabytes)
sub getusage($) {
        my $dir = shift;
        my ($out,$err,$size);
        my @cmd = ('du','-ks',$dir);
        if((run3 \@cmd, \undef, \$out, \$err) && $? ==0) {
                ($size, undef) = split ' ',$out;
        } else {
                # failed to run du, probably just a disappearing file.
                printlog "failed to run du: $err\n";
		# Return > maxusage to try again in a minute or two
                return $conf{'maxusage'} + 1024;
        }
        return $size/1024/1024;
}

# Return filessystem usage (percent)
#sub getusage($) {
#	my $dir = shift;
#	my($bsize, $frsize, $blocks, $bfree, $bavail, $files, $ffree, $favail,
#		$fsid, $basetype, $flag, $namemax, $fstr) = statvfs($dir);
#
#	if(!defined($bsize)) {
#		printlog "Unable to statvfs $dir: $!\n";
#		exit 35;
#	}
#
#	my $fssize = $frsize * $blocks;
#	my $fsfree = $frsize * $bavail;
#
#	return (($fssize-$fsfree)/$fssize)*100;
#}

# Based on the text (typically pnfsid), return a number on an even spread
# between 0 and n-1. Based on the last $chars of the md5 in hex.
sub dirhash() {
	my $text = shift;
	my $n = shift;
	my $chars = 8;

	if(!defined($n)) {
		printlog "dirhash called without n!\n";
	}

	if($n > 16**$chars) {
		printlog "dirhash: warning: n > 16^chars, $n > 16**$chars\n";
	}

	my $md5 = md5_hex($text);
	
	my $md5s = substr $md5, -$chars, $chars;
	my $hash = $md5s % $n;
	return $hash;
}

# sierrathedog04, jonathansamuel@yahoo.com, August 2001                         
# First parameter is the target or VOB directory.                               
# Optional second parameter is the source or current directory.                 

# Ver. 1.1, Sept. 13, 2001. Now uses File::Compare instead of diff;             
# Modified printouts so only files are listed. (Not directories).               

# Ver. 1.2 Sept. 19, 2001. Accepts optional parameters 'modified' and 'created' followed by directory names. If these parameters are used then the program will copy all modified files to the modified directory and all changed files to the changed directory.

# Ver. 1.3 Aug. 16, 2013. Original here: http://nixcraft.com/coding-general/16699-perl-compare-2-folders-find-deleted-new-files.html#post32395 and here: http://www.perlmonks.org/?node_id=105157. Modified by c.manzano@fz-juelich.de
sub clean_out {

	printlog "\n";

	my $targetDir = shift || die "Please pass the name of a target directory enclosed in quotes. \n";
	chomp $targetDir;
	$targetDir =~ s#/$##; # Removes any trailing forward slash from the directory.
	unless (-d $targetDir) {
        	die "$targetDir is not a valid target directory.\nPlease pass the name of a valid target directory enclosed in quotes.  \n";
	}

	my $sourceDir = shift || die "Please pass the name of a source directory enclosed in quotes. \n";
	chomp $sourceDir;
	$sourceDir =~ s#/$##; # Removes any trailing forward slash from the directory.
	unless (-d $sourceDir) {
        	die "$sourceDir is not a valid source directory.\nPlease pass the name of a valid source directory enclosed in quotes.  \n";
	}

	opendir THISDIR, $sourceDir;
	my @allFiles = grep { $_ ne '.' and $_ ne '..' && -f "$sourceDir/$_"}  readdir THISDIR;
	printlog "Source files in $sourceDir: @allFiles\n";
	closedir THISDIR;

	foreach (@allFiles) {
		printlog ": checking $_\n";
        	if (File::Compare::compare("$sourceDir/$_", "$targetDir/$_") < 0) {
			printlog ": sleeping 2\n";
			sleep 2;
			if (File::Compare::compare("$sourceDir/$_", "$targetDir/$_") < 0) {
				printlog ": sleeping 2\n";
				sleep 2;
                		if (File::Compare::compare("$sourceDir/$_", "$targetDir/$_") < 0) {
					printlog "$_ found in source directory $sourceDir but not in target directory $targetDir\n";
                			unlink "$sourceDir/$_";
                			printlog "$sourceDir/$_ deleted!\n";
					printclean_out "/DEFAULT/$_\n";
				}
			}
        	}
	}
	printlog "\n...Finished checking source.\n";
}

1;
