#! /usr/bin/env perl

#For cron
#   5 * * * * perl ./hacker_news_logger.pl

use warnings;
use strict;

my $file = "./hacker_news_log.txt";
my $webpage = "./hacker_news_log.html";
my $vtime = time - 3*24*60*60;		#store last 3 days
my $leastPoints = 50;
unless (-e $file){
	`touch $file`;
}

my %cur_links;
open(my $fdesc, "<", $file);
while(<$fdesc>){
	my $title = $_;
	chomp $title;
	my $link = <$fdesc>;
	chomp $link;
	my $time = <$fdesc>;
	chomp $time;
	<$fdesc>;
	if($time > $vtime){
		$cur_links{$title} = [$link, $time];
	}
}
close $fdesc;

my $page = `wget -O - -q news.ycombinator.com`;
#my @matches = ($page =~ m/class="title"><a[^<]*/g);
my @matches = ($page =~ m/class="title"><a.*?points/g);
foreach my $line(@matches){
	$line =~ m/([0-9]*) points/;
	if($1 < $leastPoints){
		next;
	}
	$line =~ m/.*>(.*?)<\/a>/;
	my $title = $1;
	$line =~ m/href="(.*?)"/;
	my $link = $1;
	if ($link =~ m/^item\?id=/){
		$link = "http://news.ycombinator.com/".$link;
	}
	$cur_links{$title} = [$link, time];
}

open(my $write, ">", $file);
open(my $web, ">", $webpage);
my $index = 0;
foreach my $key (sort keys %cur_links){
	print $write $key."\n".$cur_links{$key}[0]."\n".$cur_links{$key}[1]."\n\n";
	printf $web("%s  %s\n", $index, ' <a target="_blank" href="'.$cur_links{$key}[0].'">'.$key.'</a><br/>');
	$index+=1;
}
close $web;
close $write;
