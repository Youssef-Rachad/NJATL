#!/usr/bin/perl
use strict;
use warnings; # Good to have
use Getopt::Long; # Arg Parse
use FindBin '$Bin'; # Get location
# use Time::Piece; # Date and Time Formatting <<- terrible api
use DateTime;
use Term::ANSIColor; # Colours
use Config::Tiny; # Config time

use experimental qw( switch ); # Sqitch Casee
use Term::ReadLine::Perl5;
my $term = Term::ReadLine::Perl5->new("NJATL - Edit todo");
my $Config = Config::Tiny->read($Bin.'/njatl.cfg') or die "Could not open config file. Check 'njatl.cfg' in same directory as 'njatl.pl'";
my @status_names = (
	"$Config->{status}->{todo}    ",
	"$Config->{status}->{progress}",
	"$Config->{status}->{review}  ",
	"$Config->{status}->{complete}"
);
print $status_names[0]=~/^todo\n$/;
my $debug=0   ;
my $action='' ; my $content=''; my $index=''; my $filters=''; my $status='';
my $help=''   ;
# save arguments following -w or --word in the scalar
# =s means that an argument follows
GetOptions(
	'action=s' => \$action  , 'content=s' => \$content,
	'index=i' => \$index    , 'filter=s' => \$filters , 'status=s' => \$status,
	'help' => \$help        , 'debug' => \$debug);

if($help){
	print "__/\\\\\\\\\\_____/\\\\\\______/\\\\\\\\\\\\\\\\\\\\\\_____/\\\\\\\\\\\\\\\\\\_____/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\__/\\\\\\_____________","\n";
	print " _\\/\\\\\\\\\\\\___\\/\\\\\\_____\\/////\\\\\\///____/\\\\\\\\\\\\\\\\\\\\\\\\\\__\\///////\\\\\\/////__\\/\\\\\\_____________","\n";
	print "  _\\/\\\\\\/\\\\\\__\\/\\\\\\_________\\/\\\\\\______/\\\\\\/////////\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
	print "   _\\/\\\\\\//\\\\\\_\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
	print "    _\\/\\\\\\\\//\\\\\\\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
	print "     _\\/\\\\\\_\\//\\\\\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\/////////\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
	print "      _\\/\\\\\\__\\//\\\\\\\\\\\\__/\\\\\\___\\/\\\\\\_____\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
	print "       _\\/\\\\\\___\\//\\\\\\\\\\_\\//\\\\\\\\\\\\\\\\\\______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_","\n";
	print "        _\\///_____\\/////___\\/////////_______\\///________\\///________\\///________\\///////////////__","\n";
	print help_me();
	exit;
}
# Handling shorthand
if($action eq '' and $#ARGV > -1){ $action = $ARGV[0];
	if($debug){print "Got action: $ARGV[0]\n";}
	if($action eq 'create'){ $content = $ARGV[1] ne ''? $ARGV[1] : die "Must provide valid content: got $ARGV[1]"; }
	if($action eq 'mark')  {
		$index     = $ARGV[1] ne ''? $ARGV[1] : die "Must provide valid index: got $ARGV[1]";
		$status    = $ARGV[2] ne ''? $ARGV[2] : die "Must provide valid status: got $ARGV[2]";
	}
	if($action eq 'list')  {
		# If no args follow then list everything
		# If 1 arg then check if it's a status else it's a filter
		# If 2 args then follow [status, filter]
		if(!defined $ARGV[1]){if($debug){print "case 1";}$status = ""; $filters = "";}
		elsif(!defined $ARGV[2]){
			my $firstthing = (split(/\+/, $ARGV[1]))[0];
			foreach (@status_names){
				$firstthing =~ s/\s+$//;
				$_ =~ s/\s+$//;
				if($debug){print "One argument provided - status: '$firstthing' is same as '$_'\n"; }
				if ($firstthing eq $_){
					if($debug){print "One argument provided - status: $ARGV[1] is same as $_\n";}
					$status = $ARGV[1];
					last;
				}
			}
			if($debug){print "One agrument - status: $status";}
			if($status eq ''){$filters = $ARGV[1]; }
	}
		else{if($debug){print "case 3"};$status = $ARGV[1]; $filters = $ARGV[2];}
	}
	if($action eq 'edit')  { $index = $ARGV[1] ne ''? $ARGV[1] : die "Must provide valid index: got $ARGV[1]"; }
	if($action eq 'delete'){ $index = $ARGV[1] ne ''? $ARGV[1] : die "Must provide valid index got $ARGV[1]"; }
}
if($debug){ print "Got a=$action - c=$content - s=$status - f=$filters\n"; print "Am i using the global array (length $#ARGV)? @ARGV\n";}

sub help_me {
	return "Usage: Not Just Another Todo List".
	"\n\taction:STRING\t[create, list, mark, edit, delete]".
	"\n\t\tcreate\tnjatl create 'my todo \@YYYY/MM/DD+project+project'".
	"\n\t\tmark\tnjatl mark idx status".
	"\n\t\tlist\tnjatl list filter+filter status".
	"\n\t\tedit\tnjatl edit idx 'my todo \@YYYY/MM/DD+project'".
	"\n\t\tdelete\tnjatl delete idx".
	"\n\tcontent:STRING\tstring to be passed for create and edit actions".
	"\n\tindex:Integer\tinteger for mark, edit and delete actions. Indices start at 1".
	"\n\thelp:FLAG\tthis message :))".
	"\n\tdebug:FLAG\toptional for debugging messages\n";
}

sub list_todos {
	my $date = DateTime->now->strftime('%A, %b %d %Y'); print "$date | Todo List:\n=====================================\n";
	my ($file, $list_filter, $list_status) = @_;
	die "Must provide file to list todos" unless defined $file;
	$list_filter = '' if !(defined $list_filter);
	$list_status = '' if !(defined $list_status);
	open(my $readfile, '<:encoding(UTF-8)', $file) or die "Could not open todofile '$file'";
	if($debug){print 'in list_todo subroutine: '.$file." size:"; print -s $readfile; print "\n";}
	my $time_now = DateTime->now;
	my $offset=" "; my $urgent="";
	if($list_filter ne '' or $list_status ne ''){
		my %statuses = (
			$Config->{status}->{todo}     => ' ',
			$Config->{status}->{progress} => '-',
			$Config->{status}->{review}   => 'r',
			$Config->{status}->{complete} => 'x'
		);
		my $filter_string = "(".join('|', split(/\+/, $list_filter)).")";
		my $status_string = "(".join('|', map('\['.$statuses{$_}.'\]', split(/\+/, $list_status))).")";
		if($debug){print "\nfilter on regex $filter_string\n";print "\nstatus on regex $status_string\n"; print "\nfilters $list_filter";}
		while(my $line_todo = <$readfile>){ # <> used for files and globs
			next if ($list_filter eq '' ? 0 : $line_todo !~ /\+$filter_string/); # filter out tags
			next if ($list_status eq '' ? 0 : $line_todo !~ /$status_string/); # filter out tags
			$offset = $. - 1; # always get current line number for quick editing
			$offset =~ s/^(\d)$/ $1/;
			chomp $line_todo; # removes trailing new line
			my @todo_date = ($line_todo =~ /(?<=@)(\d{4})\/(\d{2})\/(\d{2})/);
			$urgent = "";
			if($debug){print "Parsed Date: @todo_date\n";}
			if(scalar @todo_date > 0) {
				if($debug){print "We have a due\n";}
				my $diff= DateTime->new(year=>$todo_date[0], month=>$todo_date[1], day=>$todo_date[2], hour=>$time_now->hour, minute=>$time_now->minute, second=>$time_now->second, nanosecond=>$time_now->nanosecond)->subtract_datetime($time_now)->days;
				if($debug){print "Got distance of: $diff\n";}
				$urgent = $diff < $Config->{deadline}->{alarm_days} ? "SOON": "";
				if($debug){print "Tis of urgency: $urgent\n";}
			}
			if($line_todo =~ /\[x\]/)    {print colored($offset.$line_todo."\n", "bright_green");}
			elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo, "bright_yellow")."\t".colored("$urgent", "white", "on_red")."\n";}
			elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo, "bright_cyan")."\t".colored("$urgent", "white", "on_red")."\n";}
			else{ print $offset.$line_todo."\t".colored("$urgent", "white", "on_red")."\n";}
		}
	}
	else{
		while(my $line_todo = <$readfile>){ # <> used for files and globs
			$offset = (($. - 1)%5==0 ? $. - 1 : "  ");
			$offset =~ s/^(\d)$/ $1/;
			chomp $line_todo; # removes trailing new line
			my @todo_date = ($line_todo =~ /(?<=@)(\d{4})\/(\d{2})\/(\d{2})/);
			$urgent = "";
			if($debug){print "Given Todo: $line_todo\nParsed Date: @todo_date\n";}
			if(scalar @todo_date > 0) {
				if($debug){print "We have a due\n";}
				my $diff= DateTime->new(year=>$todo_date[0], month=>$todo_date[1], day=>$todo_date[2], hour=>$time_now->hour, minute=>$time_now->minute, second=>$time_now->second, nanosecond=>$time_now->nanosecond)->subtract_datetime($time_now)->days;
				if($debug){print "Got distance of: $diff\n";}
				$urgent = $diff < $Config->{deadline}->{alarm_days} ? "SOON": "";
				if($debug){print "Tis of urgency: $urgent\n";}
			}
			if($line_todo =~ /\[x\]/)    {print colored($offset.$line_todo."\n", "bright_green");}
			elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo, "rgb440")."\t",colored("$urgent", "white", "on_red")."\n";}
			elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo, "bright_cyan")."\t".colored("$urgent", "white", "on_red")."\n";}
			else{ print $offset.$line_todo."\t".colored("$urgent", "white", "on_red")."\n";}
		}
	}
	print "End of list\n";
	close $readfile;

}
# TODO check that args are valid before accessing todo file
my $todofile = $Bin.'/todo.txt';
if($action eq 'create'){
	open(my $livefile, '>>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	print $livefile "[ ] $content\n";
	print "recorded $content to todo-list\n";
	close $livefile;
}
elsif($action eq 'list'){
	if($debug==1){print "Given filter $filters, status $status\n";}
	list_todos($todofile, $filters, $status);
}
elsif ($action eq 'mark'){
	# check that we are given a positive integer index
	if($index =~ /^\D+$/){die "Must provide integer argument, got $index";}
	open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	if($debug){print $todofile.' '; print -s $livefile;}
	my @todos;
	while(my $todo = <$livefile>){
		push @todos, $todo if ($todo !~ /^\s+$/);
	}
	close $livefile;
	if($index > scalar @todos){
		die "Index provided ($index) exceeds todo-list length (".scalar @todos.")";
	}
	if($debug){print "Got status $status";}
	given($status){
		when($Config->{status}->{todo}){$todos[$index]     =~ s/\[.\]/[ ]/;}
		when($Config->{status}->{progress}){$todos[$index] =~ s/\[.\]/[-]/;}
		when($Config->{status}->{review}){$todos[$index]   =~ s/\[.\]/[r]/;}
		when($Config->{status}->{complete}){$todos[$index] =~ s/\[.\]/[x]/;}
		default {die "Must provide valid status. Current Configuration:\n\t- todo: \t$Config->{status}->{todo}\n\t- in-progress \t$Config->{status}->{progress}\n\t- review: \t$Config->{status}->{review}\n\t- complete: \t$Config->{status}->{complete}\n";} }
	open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	print $livefile @todos;
	close $livefile;
	list_todos($todofile, '', '');
}
elsif($action eq 'delete'){
	if($index =~ /^\D+$/){die "Must provide integer argument, got $index";}
	open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	my @todos;
	while(my $todo = <$livefile>){
		push @todos, $todo if ($todo !~ /^\s+$/);
	}
	close $livefile;
	if($index > scalar @todos){
		die "Index provided ($index) exceeds todo-list length (".scalar @todos.")";
	}
	splice(@todos, $index, 1);
	open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	print $livefile @todos;
	close $livefile;
	list_todos($todofile, '', '');
}
elsif($action eq 'edit'){
	if($index =~ /^\D+$/){die "Must provide integer argument, got $index";}
	open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	my @todos;
	while(my $todo = <$livefile>){
		push @todos, $todo if ($todo !~ /^\s+$/);
	}
	close $livefile;
	if($index > scalar @todos){
		die "Index provided ($index) exceeds todo-list length (".scalar @todos.")";
	}
	if($debug){print $todos[$index];}
	#Deprecated for now
	#my $current_status = ($todos[$index] =~ /\[(.)\]/) ? $1 : " ";
	#if($debug){print "\n current status is: $current_status\n";}
	print "Enter 'cancel' or ctrl-c to cancel the edit\n";
	my $new_todo = $term->readline("Edit: ",$todos[$index]);
	if(lc($new_todo) ne 'cancel'){ $todos[$index] = "$new_todo\n"; }
	open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
	print $livefile @todos;
	close $livefile;
	list_todos($todofile, '', '');
}
else{ die "Must provide valid action, got: $action"; }
