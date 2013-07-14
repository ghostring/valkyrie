#!/usr/bin/perl -w
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
use List::MoreUtils qw(uniq);
use Net::SMTP::SSL;
use Time::localtime;
use Config::YAML::Tiny;
no warnings "uninitialized";

# require packetcapture;
# packetcapture();

# autoflush
$|=1;

HERE:
######################
# read configuration #
######################

my $config = Config::YAML::Tiny->new(config=>'/etc/valkyrie/config.yml');


####################
# regex IP address #
####################

    sub ipfilter () {
      open (R, "</var/log/valkyrie/valkyrie.pcap");
      open (W, ">/var/log/valkyrie/filter.log");
      my @ip = <R>;
      my @filter = uniq @ip;
      print W "@filter\n";
      close (W);
      close (R);
   }

   sub ipsuspect() {
      ipfilter();
      my $date = localtime;
      open (R, "/var/log/valkyrie/filter.log");
      open (W1, ">/var/log/valkyrie/ip.txt");
      open (W2, ">/var/log/valkyrie/ip2.txt");
      while(<R>) {
      chomp ;
	  if ($_ =~ m/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\z/) {
	  print W1 "$_\n";
	  print W2 "IP $_ has been detected at $date\n";
	  }
	}
  
      unlink ($config->get_pathfilter);
      close (W1);
      close (W2);
    }


    sub checkfile() {
      ipsuspect();
      my $locate = 'var/log/valkyrie/iplist.txt';
      # check existing file
      unless (-e $locate){ 
      system "cp /var/log/valkyrie/ip.txt /var/log/valkyrie/iplist.txt";
      }
    }

checkfile();

######################################
# grep failed password and cron jobs #
######################################
open (R, "/var/log/valkyrie/ip.txt");
open (W, ">>/var/log/valkyrie/iplist.txt");
open (CRON, ">>/var/spool/cron/crontabs/root");


my ($sec,$min,$hour) = localtime;
my $date = sprintf "%02d",$hour;
my $u = sprintf "%02d",$date+3;
my $v = sprintf "%02d",$date+10; 

$u = ~ s/25/01/; $u =~ s/26/02/; $u =~ s/27/03/;
$v = ~ s/25/01/; $v =~ s/26/02/; $v =~ s/27/03/;

my @keys = <R>;
while ((my $key, my $value) = each @keys) {
my $h = grep(/$value/, <W>);

    if ($h eq 1){
    print CRON "1 $v * * * iptables -j DROP -p tcp --destination-port 22 -D INPUT -s $value\n";
#     system "iptables -j DROP -D INPUT -p tcp -s $value\n";
    system "iptables -j DROP -p tcp -A INPUT -s $value\n";
    }

    else {

    open (IP, "/var/log/valkyrie/ip.txt");
    open (MSG,"/var/log/messages");
    open (CRON, ">>/var/spool/cron/crontabs/root");

    my $word = grep (/Failed password/ , <MSG>);

	  if ($word >= 2){
	  my $t = $config->get_desport;

		if ($t eq 'all'){
		  while (<IP>){
		  chomp;

		  print CRON "* $u * * * iptables -j DROP -p tcp -D INPUT -s $_\n";
		  system "iptables -j DROP -p tcp -A INPUT -s $_\n";
	       #  system "iptables -j DROP -p tcp -A OUTPUT -d $_\n";
		  }
		}

		else {
		  while (<IP>){
		  chomp;
		  print  CRON "* $u * * * iptables -j DROP -p tcp --destination-port 22 -D INPUT -s $_\n";
		  system "iptables -j DROP -p tcp --destination-port $t -A INPUT -s $_";
	       #  system "iptables -j DROP -p tcp --destination-port $t -A OUTPUT -d $_";
		  }
		}

close CRON;

###################################
# log will be sent to admin email # 
###################################

open (WRITE, "/var/log/valkyrie/ip2.txt");
my @file = <WRITE>;
close (WRITE);

my $mail = Net::SMTP::SSL->new(
        $config->get_smtp,
        Port  => $config->get_port,
        Debug => $config->get_debug,
        );

$mail->auth( $config->get_username, $config->get_password ) || die "bad username/password or check your connection\n";
$mail->mail($ENV{USER});
$mail->to($config->get_sendto);    
# sending data
$mail->data();
$mail->datasend("To: ". $config->get_sendto ."\n");
$mail->datasend("Subject: log notification\n\n");
$mail->datasend("\n");
$mail->datasend("@file\n");
$mail->dataend();

$mail->quit;

system "echo > /var/log/messages";
unlink ("/var/log/valkyrie/ip.txt","/var/log/valkyrie/ip2.txt");

goto HERE; 
}

    }
}

close R; close W, close CRON;
goto HERE;
