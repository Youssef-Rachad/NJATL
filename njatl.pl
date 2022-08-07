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
my $greeting=0; my $help=''   ;
# save arguments following -w or --word in the scalar
# =s means that an argument follows
GetOptions(
    'action=s' => \$action  , 'content=s' => \$content,
    'index=i' => \$index    , 'filter=s' => \$filters , 'status=s' => \$status,
    'greeting' => \$greeting, 'help' => \$help        , 'debug' => \$debug);

if($help){ # YATL on Slant Relief
    #    print '__/\\\________/\\\_____/\\\\\\\\\_____/\\\\\\\\\\\\\\\__/\\\_____________        ', "\n";
    #    print ' _\///\\\____/\\\/____/\\\\\\\\\\\\\__\///////\\\/////__\/\\\_____________       ', "\n";
    #    print '  ___\///\\\/\\\/_____/\\\/////////\\\_______\/\\\_______\/\\\_____________      ', "\n";
    #    print '   _____\///\\\/______\/\\\_______\/\\\_______\/\\\_______\/\\\_____________     ', "\n";
    #    print '    _______\/\\\_______\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\_____________    ', "\n";
    #    print '     _______\/\\\_______\/\\\/////////\\\_______\/\\\_______\/\\\_____________   ', "\n";
    #    print '      _______\/\\\_______\/\\\_______\/\\\_______\/\\\_______\/\\\_____________  ', "\n";
    #    print '       _______\/\\\_______\/\\\_______\/\\\_______\/\\\_______\/\\\\\\\\\\\\\\\_ ', "\n";
    #    print '        _______\///________\///________\///________\///________\///////////////__', "\n";
    #    YATL in blocks
print "__/\\\\\\\\\\_____/\\\\\\______/\\\\\\\\\\\\\\\\\\\\\\_____/\\\\\\\\\\\\\\\\\\_____/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\__/\\\\\\_____________","\n";
print " _\\/\\\\\\\\\\\\___\\/\\\\\\_____\\/////\\\\\\///____/\\\\\\\\\\\\\\\\\\\\\\\\\\__\\///////\\\\\\/////__\\/\\\\\\_____________","\n";
print "  _\\/\\\\\\/\\\\\\__\\/\\\\\\_________\\/\\\\\\______/\\\\\\/////////\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
print "   _\\/\\\\\\//\\\\\\_\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
print "    _\\/\\\\\\\\//\\\\\\\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
print "     _\\/\\\\\\_\\//\\\\\\/\\\\\\_________\\/\\\\\\_____\\/\\\\\\/////////\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
print "      _\\/\\\\\\__\\//\\\\\\\\\\\\__/\\\\\\___\\/\\\\\\_____\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_____________","\n";
print "       _\\/\\\\\\___\\//\\\\\\\\\\_\\//\\\\\\\\\\\\\\\\\\______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\_______\\/\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\_","\n";
print "        _\\///_____\\/////___\\/////////_______\\///________\\///________\\///________\\///////////////__","\n";
#    print " .-----------------. .----------------.  .----------------.  .----------------.  .----------------.", "\n";
#    print "| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |", "\n";
#    print "| | ____  _____  | || |     _____    | || |      __      | || |  _________   | || |   _____      | |", "\n";
#    print "| ||_   \\|_   _| | || |    |_   _|   | || |     /  \\     | || | |  _   _  |  | || |  |_   _|     | |", "\n";
#    print "| |  |   \\ | |   | || |      | |     | || |    / /\\ \\    | || | |_/ | | \\_|  | || |    | |       | |", "\n";
#    print "| |  | |\\ \\| |   | || |   _  | |     | || |   / ____ \\   | || |     | |      | || |    | |   _   | |", "\n";
#    print "| | _| |_\\   |_  | || |  | |_' |     | || | _/ /    \\ \\_ | || |    _| |_     | || |   _| |__/ |  | |", "\n";
#    print "| ||_____|\\____| | || |  `.___.'     | || ||____|  |____|| || |   |_____|    | || |  |________|  | |", "\n";
#    print "| |              | || |              | || |              | || |              | || |              | |", "\n";
#    print "| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |", "\n";
#    print " '----------------'  '----------------'  '----------------'  '----------------'  '----------------'", "\n";
    print help_me();
    exit;
}
# Handling shorthand
#if($action eq '' and $#ARGV > -1){ $action = $ARGV[0];
#    if($action eq 'create'){$content   = $ARGV[1] ne ''? $ARGV[1]     : die "Must provide valid content: got $ARGV[1]";}
#    if($action eq 'mark')  {$index     = $ARGV[1] ne ''? $ARGV[1] - 1 : die "Must provide valid index: got $ARGV[1]";
#                            $status    = $ARGV[2] ne ''? $ARGV[2]     : die "Must provide valid status: got $ARGV[2]";}
#    if($action eq 'list')  {$filters   = $#ARGV > 0 ? (grep(!/^$ARGV[1]$/, @status_names) ?  'argv is long and element one is not a status' : '')     : '';
#                            $status    = $#ARGV == 2   ? $ARGV[2]     : $#ARGV == 1 and (grep(/^$ARGV[1]$/, @status_names) ne '')? $ARGV[1] : $ARGV[0];}
#    if($action eq 'edit')  {$index     = $ARGV[1] ne ''? $ARGV[1] - 1 : die "Must provide valid index: got $ARGV[1]";
#                            $content   = $ARGV[2] ne ''? $ARGV[2]     : die "Must provide valid content: got $ARGV[2]";}
#    if($action eq 'delete'){$index     = $ARGV[1] ne ''? $ARGV[1] - 1 : die "Must provide valid index got $ARGV[1]";}
#}
#else{
#    die "Must provide valid action";
#}
if($debug){ print "Got a=$action - c=$content\n"; print "Am i using the global array (length $#ARGV)? @ARGV\n"; }

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
    "\n\tgreeting:FLAG\toptional for greeting in list action".
    "\n\thelp:FLAG\tthis message :))".
    "\n\tdebug:FLAG\toptional for debugging messages\n";
}

sub list_todos {
    my ($file, $filter, $status) = @_;
    die "Must provide file to list todos" unless defined $file;
    $filter = '' if !(defined $filter);
    $status = '' if !(defined $status);
    open(my $readfile, '<:encoding(UTF-8)', $file) or die "Could not open todofile '$file'";
    if($debug){print 'in list_todo subroutine: '.$file." size:"; print -s $readfile; print "\n";}
    #my $time_now = Time::Piece->new(); #https://stackoverflow.com/questions/22676764/getting-minutes-difference-between-two-timepiece-objects
    my $time_now = DateTime->now;
    my $offset=" "; my $urgent="";
    if($filter ne '' or $status ne ''){
        my %statuses = (
            $Config->{status}->{todo}     => ' ',
            $Config->{status}->{progress} => '-',
            $Config->{status}->{review}   => 'r',
            $Config->{status}->{complete} => 'x'
        );
        my $filter_string = "(".join('|', split(/\+/, $filter)).")";
        if($debug){print "\nfilter on regex $filter_string\n";}
        while(my $line_todo = <$readfile>){ # <> used for files and globs
            next if ($filter eq '' ? 0 : $line_todo !~ /\+$filter_string/); # filter out tags
            next if ($status eq '' ? 0 : $line_todo !~ /\[$statuses{$status}\]/); # filter out tags
            $offset = $. - 1; # always get current line number for quick editing
	    $offset =~ s/^(\d)$/ $1/;
            chomp $line_todo; # removes trailing new line
	    my @todo_date = ($line_todo =~ /(?<=@)\/(\d{4})\/(\d{2})\/(\d{2})/);
	    if($debug){print "Parsed Date: @todo_date\n";}
	    #my $urgent = DateTime->new(year=>$todo_date[0], month=>$todo_date[1], day=>$todo_date[2], hour=>$time_now->hour, minute=>$time_now->minute, second=>$time_now->second, nanosecond=>$time_now->nanosecond)->subtract_datetime($time_now)->days < $Config->{deadline}->{alarm_days} ? "\tSOON": "";
            if($line_todo =~ /\[x\]/)    {print colored($offset.$line_todo."\n", "bright_green");}
            elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo, "bright_yellow")." ".colored("$urgent", "white", "on_red")."\n";}
            elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo, "bright_cyan")." ".colored("$urgent", "white", "on_red")."\n";}
            else{ print $offset.$line_todo." ".colored("$urgent", "white", "on_red")."\n";}
        }
    }
    else{
        while(my $line_todo = <$readfile>){ # <> used for files and globs
            $offset = (($. - 1)%5==0 ? $. - 1 : "  ");
	    $offset =~ s/^(\d)$/ $1/;
            chomp $line_todo; # removes trailing new line
	    my @todo_date = ($line_todo =~ /(?<=@)\/(\d{4})\/(\d{2})\/(\d{2})/);
	    if($debug){print "Given Todo: $line_todo\nParsed Date: @todo_date\n";}
	    #my $urgent = DateTime->new(year=>$todo_date[0], month=>$todo_date[1], day=>$todo_date[2], hour=>$time_now->hour, minute=>$time_now->minute, second=>$time_now->second, nanosecond=>$time_now->nanosecond)->subtract_datetime($time_now)->days < $Config->{deadline}->{alarm_days} ? "\tSOON": "";
#$urgent = int(($time_now->strptime($line_todo =~/(?<=@)(\d{4}\/\d{2}\/\d{2})/, "%Y/%m/%d") - $time_now)->days + 0.99) < $Config->{deadline}->{alarm_days} ? "\tSOON": "";
            if($line_todo =~ /\[x\]/)    {print colored($offset.$line_todo."\n", "bright_green");}
            elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo, "rgb440")." ".colored("$urgent", "white", "on_red")."\n";}
            elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo, "bright_cyan")." ".colored("$urgent", "white", "on_red")."\n";}
            else{ print $offset.$line_todo." ".colored("$urgent", "white", "on_red")."\n";}
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
    if($debug==1){print "in greeting flag, got $greeting.\tGiven filter $filters, status $status\n";}
    if($greeting ne ''){ my $date = DateTime->now->strftime('%A, %b %d %Y'); print "$date | Todo List:\n=====================================\n";}
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
    $todos[$index] = "[ ] $content\n";
    open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    print $livefile @todos;
    close $livefile;
    list_todos($todofile, '', '');
}
else{ die "Must provide valid action, got: $action"; }
