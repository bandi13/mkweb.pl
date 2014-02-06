#!/usr/bin/perl -w
use strict;
###############################################################################
# mkweb.pl version 1.5
# Written by Fekete Andras
# Released under the GNU Public license.
# You may modify this code but you are required to leave this header intact.
# Also you must give me credit where credit is due. Other than that, feel free
# to redistribute, modify, or just plain use this program.
# If you find any bugs or changes you've made that you'd like to pass back to
# me, drop me a line at "iamfeketeandras  (at) gmail d_o_t com"
#
# This program basically creates a website out of any pictures you may have
# stored in a specified folder. I originally designed it for my personal
# family photo collection. I have rewritten it to generate thumbnails in
# a separate folder so it won't clutter your images. I have been planning
# to make it place the HTML files in the Thumbnail folder aswell, but it
# works and I don't really want to change it now.
# 
# You'll need need perl, image-magick(to generate thumbnails), and apache or
# some other web server. This code was designed to run on a linux box, but
# with a bit of tinkering, it should work on a Windows based system too.
###############################################################################

my $titleColor = "#60c0ff"; # title frame background color
my $dirColor = "#bbddff"; # left frame background color
my $indexColor = "#bbddff"; # right frame background color
my $htmlRoot = "/~pictures"; # This string will get prepended to all links
my $owner = "Andras \& Beth"; # This is the name that appears in thet title frame

###############################################################################
# DO NOT EDIT AFTER HERE UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# I don't really like commenting my code, so as the great Lance Boyle (Megarace) once said:
# "And now, you are on your own Enforcer..."
###############################################################################

if(!defined($ARGV[0])) { print "Usage: $0 <folderName> [<HTMLRootDir> [<ownerName>]]\n"; exit; }
my $webfolder = $ARGV[0];
if(defined($ARGV[1])) { $htmlRoot = $ARGV[1]; }
if(defined($ARGV[2])) { $owner = $ARGV[2]; }

$webfolder =~ s/ /\\ /g;
open(INDEX,">$webfolder/index.html") || die "Couldn't create $webfolder/index.html!";
print INDEX "<HTML>\n<TITLE>$owner\'s pictures<\/TITLE>\n\n";
print INDEX "	<FRAMESET ROWS=\"5%,95%\">\n";
print INDEX "		<FRAME NAME=\"TITLE\" SRC=\"title.html\">\n";
print INDEX "		<FRAME NAME=\"MAIN\" SRC=\"main.html\">\n";
print INDEX "	<\/FRAMESET>\n";
print INDEX "	<NOFRAMES>Your browser doesn't support frames. Get a real one!</NOFRAMES>\n";
print INDEX "<\/HTML>\n";
close(INDEX);

open(MAIN,">$webfolder/main.html") || die "Couldn't create $webfolder/main.html";
print MAIN "<HTML>\n";
print MAIN "	<FRAMESET COLS=\"23%,77%\">\n";
print MAIN "		<FRAME NAME=\"DIRECTORIES\" SRC=\"directories.html\">\n";
print MAIN "		<FRAME NAME=\"FILES\" SRC=\"files.html\">\n";
print MAIN "	<\/FRAMESET>\n";
print MAIN "<\/HTML>\n";
close(MAIN);

open(TITLE,">$webfolder/title.html") || die "Couldn't create title.html!";
print TITLE "<HTML>\n<BODY BGCOLOR=\"$titleColor\">\n";
print TITLE "<CENTER><FONT SIZE=\"3\">$owner\'s pictures<\/FONT>\n";
print TITLE "<\/CENTER>\n<\/BODY>\n<\/HTML>\n";
close(TITLE);

parseDir("",1);

sub parseDir {
	my $relative = shift;
	my $absolute = "$webfolder/$relative";
	my $parent = shift;
	printf "$absolute >\n";
	if(!-e "$webfolder/Thumbs/$relative") { mkdir("$webfolder/Thumbs/$relative",0755); }
	system("rm -f \"$absolute\"/*.thm \"$absolute\"/*.THM \"$absolute\"/Thumbs.db");
	if(!-e "$absolute/main.html") {
		my $MAIN;
		open($MAIN,">$absolute/main.html") || die "Couldn't create $absolute/main.html";
		print $MAIN "<HTML>\n";
		print $MAIN "	<FRAMESET COLS=\"23%,77%\">\n";
		print $MAIN "		<FRAME NAME=\"DIRECTORIES\" SRC=\"directories.html\">\n";
		print $MAIN "		<FRAME NAME=\"FILES\" SRC=\"files.html\">\n";
		print $MAIN "	<\/FRAMESET>\n";
		print $MAIN "<\/HTML>\n";
		close($MAIN);
	}
	my $DIRS;
	open($DIRS,">$absolute/directories.html") || die "Couldn't create $absolute/directories.html!";
	print $DIRS "<HTML>\n<BODY BGCOLOR=\"$dirColor\">\n";
	if($parent != 1) { print $DIRS "<BR><A HREF=\"../main.html\" TARGET=\"MAIN\">Parent folder<\/A>\n"; }
	my $counter = 1;
	my $FILES;
	open($FILES,">$absolute/files.html") || die "Couldn't create $absolute/files.html!";
	print $FILES "<HTML>\n<BODY BGCOLOR=\"$indexColor\">\n";
	if(-e "$absolute/description.txt") {
		my $DESC;
		open($DESC,"$absolute/description.txt") || die "Couldn't open $absolute/description.txt!";
		print $FILES "<FONT SIZE=3>\n";
		while(<$DESC>) { print $FILES "<BR>$_"; }
		print $FILES "<BR><\/FONT>\n";
		close($DESC);
	}
	print $FILES "<TABLE BORDER=\"1\">\n<TR>";
	my $i = 0;
	opendir(WEBFOLDER,$absolute) || die "Couldn't open $absolute!";
	foreach $_ (sort readdir(WEBFOLDER)) {
		if( -d "$absolute/$_" ) {
			if (!(/\.$/)) { # if not ".." || "."
				chmod(0755,"$absolute/$_");
				if(!/Thumbs/) {
					print $DIRS "<BR>$counter : <A HREF=\"$_/main.html\" TARGET=\"MAIN\">$_<\/A>\n";
					parseDir("$relative/$_",0);
					$counter++;
				}
			}
		} else {
			if (!(/\.html$/) && !(/description\.txt$/)) {
				chmod(0644,"$absolute/$_");
				if(!(/png/)) {
					my $lg = $_;
					s/[jJ][pP][gG]$/jpg/;
					s/[jJ][pP][eE][gG]$/jpg/;
					s/[pP][pP][mM]$/ppm/;
					s/[gG][iI][fF]$/gif/;
					s/[bB][mM][pP]$/bmp/;
					if(/\.jpg$/ || /\.ppm$/ || /\.gif$/ || /\.bmp$/) {
						s/\.jpg$/\.png/;
						s/\.ppm$/\.png/;
						s/\.gif$/\.png/;
						s/\.bmp$/\.png/;
						my $sm = $_;
						if ((!-e "$webfolder/Thumbs/$relative/$sm") || (-M "$webfolder/Thumbs/$relative/$sm" > -M "$absolute/$lg")) { system("convert -geometry 300x400 \"$absolute/$lg\" \"$webfolder/Thumbs/$relative/$sm\"\n"); }
						print $FILES "<TD><a href=\"$lg\"><img src=\"$htmlRoot/Thumbs/$relative/$sm\"><\/a><\/TD>";
					} else {
						print $FILES "<TD><a href=\"$lg\">$lg<\/a><\/TD>";
					}
					if($i == 2) { print $FILES "<\/TR>\n<TR>\n"; $i = 0; } else { $i++; }
				}
			}
		}
	}
	closedir(WEBFOLDER);
	if($i != 0) { print $FILES "<\/TR>\n"; }
	print $FILES "<\/TABLE><\/BODY>\n<\/HTML>\n";
	close($FILES);
	print $DIRS "<\/BODY>\n<\/HTML>\n";
	close($DIRS);
}
