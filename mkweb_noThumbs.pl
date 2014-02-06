#!/usr/bin/perl -w
use strict;

my $titleColor = "#60c0ff";
my $dirColor = "#bbddff";
my $indexColor = "#bbddff";
my $webfolder = $ARGV[0];
my $owner = "Andras \& Beth";

if(!defined($ARGV[0])) { print "Usage: $0 <folderName> [<ownerName>]\n"; exit; }
if(defined($ARGV[1])) { $owner = $ARGV[1]; }

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

parseDir($webfolder,1);

sub parseDir {
	my $curfolder = shift;
	my $parent = shift;
	printf "$curfolder >\n";
	system("rm -f \"$curfolder\"/*.thm \"$curfolder\"/*.THM \"$curfolder\"/Thumbs.db");
	if(!-e "$curfolder/main.html") {
		my $MAIN;
		open($MAIN,">$curfolder/main.html") || die "Couldn't create $curfolder/main.html";
		print $MAIN "<HTML>\n";
		print $MAIN "	<FRAMESET COLS=\"23%,77%\">\n";
		print $MAIN "		<FRAME NAME=\"DIRECTORIES\" SRC=\"directories.html\">\n";
		print $MAIN "		<FRAME NAME=\"FILES\" SRC=\"files.html\">\n";
		print $MAIN "	<\/FRAMESET>\n";
		print $MAIN "<\/HTML>\n";
		close($MAIN);
	}
	my $DIRS;
	open($DIRS,">$curfolder/directories.html") || die "Couldn't create $curfolder/directories.html!";
	print $DIRS "<HTML>\n<BODY BGCOLOR=\"$dirColor\">\n";
	if($parent != 1) { print $DIRS "<BR><A HREF=\"../main.html\" TARGET=\"MAIN\">Parent folder<\/A>\n"; }
	my $counter = 1;
	my $FILES;
	open($FILES,">$curfolder/files.html") || die "Couldn't create $curfolder/files.html!";
	print $FILES "<HTML>\n<BODY BGCOLOR=\"$indexColor\">\n";
	if(-e "$curfolder/description.txt") {
		my $DESC;
		open($DESC,"$curfolder/description.txt") || die "Couldn't open $curfolder/description.txt!";
		print $FILES "<FONT SIZE=3>\n";
		while(<$DESC>) { print $FILES "<BR>$_"; }
		print $FILES "<BR><\/FONT>\n";
		close($DESC);
	}
	print $FILES "<TABLE BORDER=\"1\">\n<TR>";
	my $i = 0;
	opendir(WEBFOLDER,$curfolder) || die "Couldn't open $curfolder!";
	foreach $_ (sort readdir(WEBFOLDER)) {
		if( -d "$curfolder/$_" ) {
			if (!(/\.$/)) { # if not ".." || "."
				chmod(0755,"$curfolder/$_");
				print $DIRS "<BR>$counter : <A HREF=\"$_/main.html\" TARGET=\"MAIN\">$_<\/A>\n";
				parseDir("$curfolder/$_",0);
				$counter++;
			}
		} else {
			if (!(/\.html$/) && !(/description\.txt$/)) {
				chmod(0644,"$curfolder/$_");
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
						if (!-e "$curfolder/$sm") { system("convert -geometry 300x400 \"$curfolder/$lg\" \"$curfolder/$sm\"\n"); }
						print $FILES "<TD><a href=\"$lg\"><img src=\"$sm\"><\/a><\/TD>";
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
