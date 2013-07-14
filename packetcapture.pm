#!/usr/bin/perl
#
#
# Part of valkyrie                          
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
use Net::Pcap::Easy;

open (LOG, ">/var/log/valkyrie/valkyrie.pcap");

my $npe = Net::Pcap::Easy->new(
    dev              => "yourdevice",
    #filter           => " ",
    packets_per_loop => 10,
    bytes_to_capture => 1024,
    timeout_in_ms    => 0,
    promiscuous      => 0,

 tcp_callback => sub {
    my ($npe, $ether, $ip, $tcp, $header ) = @_;
#     print LOG "TCP packet : $ip->{src_ip}:$tcp->{src_port} -> $ip->{dest_ip}:$tcp->{dest_port}\n";
if ($tcp->{dest_port} == "22") { 
    print LOG "$ip->{src_ip}\n";
#   print LOG "TCP packet : $ip->{src_ip} -> $ip->{dest_ip}:$tcp->{dest_port}\n";
}
    }
);
 
1 while $npe->loop;
close(LOG);
