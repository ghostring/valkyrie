#!/usr/bin/perl -w
#
#
# Daemon of valkyrie program
# Copyright (C) Gika Megawan <mail@gika09.info>     
# This program is published under a GPLv3 license 
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNEC-
# TION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use strict;
use Daemon::Control;
no warnings "uninitialized";

my $usage = $ARGV[0];

my $daemon = Daemon::Control->new({
        name        => "Valkyrie daemon...",
        path        => '/opt/valkyrie',
        lsb_start   => '$syslog $remote_fs',
        lsb_stop    => '$syslog',
        program     => '/opt/valkyrie/valkyrieMain.pl',
        pid_file    => '/var/log/valkyrie/valkyrie.pid',
        stderr_file => '/dev/null',
        stdout_file => '/dev/null',

        fork        => 2, 
        });

    if ($usage eq 'start'){
# 	system "/usr/bin/perl /opt/valkyrie/fix/packetcapture.pm &";
	$usage = $daemon->do_start;
     }
    elsif ($usage eq 'stop'){
	unlink ("/var/log/valkyrie/ip.txt","/var/log/valkyrie/ip2.txt");
# 	my $proc = `ps ax | grep /opt/valkyrie/fix/packetcapture.pm`;
# 	(my $owner,my $pid,my $junk) = split(' ',$proc);
# 	system "kill $owner";
	$usage = $daemon->do_stop;
     }
    elsif ($usage eq 'restart'){
	$usage = $daemon->do_restart;
    }
    elsif ($usage eq 'status'){
	$usage = $daemon->do_status;
     }
    else {
    print "Usage: valkyrie [start,stop,restart,status]\n";
    }