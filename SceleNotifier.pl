#!/usr/bin/perlml
print "Content-type: text/html\n\n";

use CGI::Carp qw(fatalsToBrowser);
use feature "say";
use Data::Dumper;
use strict;
use warnings;
use Mojo::DOM;
use WWW::Mechanize;

#~ Config
my $USERNAME = 'USERNAME'; 
my $PASSWORD = 'PASSWORD';
my @COURSES = (177, 189, 172);
my %EMAIL = (
    to  => 'abc@gmail.com',
    from => 'abc@abc.com',
);

#~ START
my $SCELE_URL = 'https://scele.cs.ui.ac.id';
my $COURSE_URL = $SCELE_URL . '/course/view.php';
my $FORUM_URL = $SCELE_URL . '/mod/forum/view.php?id=1';
    
my $dom = Mojo::DOM->new;
my $mech = WWW::Mechanize->new();
$mech -> get($SCELE_URL);
$mech->submit_form(
	form_number => 1,
	fields      => {username => $USERNAME, password => $PASSWORD}
);

my $emailContent = "";
$emailContent .= processHome();
foreach my $id(@COURSES) {
	my $content = processCourse($id);
	if ($content !~ "No recent activity"){
		$emailContent .= "\n\n" . $content;
	}
}
if ($emailContent ne ""){
	sendEmail($emailContent);
}
#~ END

sub sendEmail {
	my $emailContent = shift;
	say $emailContent;
	
	my $to = $EMAIL{to};
	my $from = $EMAIL{from};
	my $subject = 'Scele Notifier';
	my $message = $emailContent;
	 
	open(MAIL, "|/usr/sbin/sendmail -t");
	 
	# Email Header
	print MAIL "To: $to\n";
	print MAIL "From: $from\n";
	print MAIL "Subject: $subject\n\n";
	# Email Body
	print MAIL $message;

	close(MAIL);	
}

sub processCourse {
	my $courseID = shift;
	my $courseURL = $COURSE_URL . '?id=' . $courseID;
	
	$mech -> get($courseURL);
	my $output_page= $mech->content();
	$dom = $dom->parse($output_page);
	my $title = $dom->at('title')->text;
	my $content = $courseURL . "\n". $title . "\n" . $dom->at('div.block_recent_activity .content')->all_text;
	#~ say $content;
	
	return $content;
}

sub processHome {	
	$mech -> get($FORUM_URL);
	my $output_page= $mech->content();
	$dom = $dom->parse($output_page);
	my $title = $dom->at('title')->text;
	my $topic = $mech->find_link( url_regex => qr/discuss.php/ );
	my ($topic_id) = $topic->url() =~ /(\d+)/;
	
	my $topic_file = "last_topic_id.txt";
	my $last_topic_id = 0;
	if (-e $topic_file) {
		open(FILE, "<$topic_file") or die $!;
		$last_topic_id = <FILE>;
	}
	open(FILE, ">$topic_file") or die $!;
	print FILE $topic_id;
	close FILE;
	
	my $content = "";
	if ($topic_id > $last_topic_id){
		$content = $SCELE_URL . "\n" . $topic->url() . "\n" . $topic->text();
	}
	
	return $content;
}
