#!/usr/bin/perl
use strict;
use warnings; # Good to have
use Getopt::Long; # Arg Parse
use FindBin '$Bin'; # Get location
use Time::Piece; # Date and Time Formatting
use Term::ANSIColor; # Colours
use Config::Tiny; # Config time

use experimental qw( switch ); # Sqitch Casee

my $Config = Config::Tiny->read($Bin.'/njatl.cfg') or die "Could not open config file. Check 'njatl.cfg' in same directory as 'njatl.pl'";

my $debug=0;
my $action=''  ; my $content='';
my $greeting=''; my $help='';
# save arguments following -w or --word in the scalar
# =s means that an argument follows
GetOptions( 'action=s' => \$action, 'content=s' => \$content, 'greeting' => \$greeting, 'help' => \$help, 'debug' => \$debug);

if($debug){
    print "Got a=$action - c=$content\n";
    print "Am i using the global array? @ARGV\n";
}

sub help_me {
    return "Usage: Yet Another Todo List\n\taction:STRING [create, list, mark, delete]\n\tcontent:STRING string to be passed or integer for mark and delete actions\n\tgreeting:FLAG optional for greeting in list action\n"
}

# TODO lol this does not work in the mark action
sub list_todos {
    my ($file, $filter) = @_;
    open(my $readfile, '<:encoding(UTF-8)', $file) or die "Could not open todofile '$file'";
    if($debug){print 'in list_todo subroutine: '.$file.' '; print -s $readfile;}
    my $offset=" ";
    if($filter ne ''){
        while(my $line_todo = <$readfile>){ # <> used for files and globs
            next if ($line_todo !~ /\+$filter/); # filter out tags
            $offset = $.;
            chomp $line_todo; # removes trailing new line
            if($line_todo =~ /\[x\]/) {print colored($offset.$line_todo."\n", "bright_green");}
            elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo."\n", "bright_yellow");}
            elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo."\n", "bright_cyan");}
            else{ print $offset.$line_todo."\n";}
        }
    }
    else{
        while(my $line_todo = <$readfile>){ # <> used for files and globs
            $offset = ($.%5==0 ? $. : " ");
            chomp $line_todo; # removes trailing new line
            if($line_todo =~ /\[x\]/) {print colored($offset.$line_todo."\n", "bright_green");}
            elsif($line_todo =~ /\[r\]/) {print colored($offset.$line_todo."\n", "bright_yellow");}
            elsif($line_todo =~ /\[-\]/) {print colored($offset.$line_todo."\n", "bright_cyan");}
            else{ print $offset.$line_todo."\n";}
        }
    }
    print "End of list\n";
    close $readfile;

}
if($help){
    print help_me();
    exit;
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
    if($debug==1){print "in greeting flag, got $greeting.";}
    if($greeting ne ''){ my $date = localtime->strftime('%A, %b %d %Y'); print "$date | Today's Tasks:\n=====================================\n";}
    list_todos($todofile, $content);
    #    open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'"; #    if($content ne ''){ #    while(my $line = <$livefile>){ # <> used for files and globs #        next if ($line !~ /\+$content/); # filter out tags #        chomp $line; # removes trailing new line #        if($line =~ /\[x\]/) {print colored(" ".$line."\n", "green");} #        else{ print $line."\n";} # #    } #} #    else{ #    while(my $line = <$livefile>){ # <> used for files and globs #        chomp $line; # removes trailing new line #        if($line =~ /\[x\]/) {print colored(" ".$line."\n", "bright_green");} #        elsif($line =~ /\[r\]/) {print colored(" ".$line."\n", "bright_yellow");} #        elsif($line =~ /\[-\]/) {print colored(" ".$line."\n", "bright_cyan");} #        else{ print " ".$line."\n";} #    } #} #    print "End of list\n"; #    close $livefile;
}
elsif ($action eq 'mark'){
    # check that we are given a positive integer index
    if($content =~ /^\D+$/){die "Must provide integer argument, got $content";}
    open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    if($debug){print $todofile.' '; print -s $livefile;}
    my @todos;
    while(my $todo = <$livefile>){
        push @todos, $todo if ($todo !~ /^\s+$/);
        #if($todo =~ /^\s+$/){ #   push @todos, (split(/\s/, $todo))[0]."\n"; #}else{ #   push @todos, $todo; #}
    }
    close $livefile;
    if($content > scalar @todos){
        die "Index provided ($content) exceeds todo-list length (".scalar @todos.")";
    }
    given($ARGV[0]){
        when($Config->{status}->{todo}){$todos[$content] =~ s/\[.\]/[ ]/;}
        when($Config->{status}->{progress}){$todos[$content] =~ s/\[.\]/[-]/;}
        when($Config->{status}->{review}){$todos[$content] =~ s/\[.\]/[r]/;}
        when($Config->{status}->{complete}){$todos[$content] =~ s/\[.\]/[x]/;}
        default {die "Must provide valid status. Current Configuration:\n\t- todo: \t$Config->{status}->{todo}\n\t- in-progress \t$Config->{status}->{progress}\n\t- review: \t$Config->{status}->{review}\n\t- complete: \t$Config->{status}->{complete}\n";} }
    #$todos[$content] =~ s/\[ \]/[x]/; # magic!!
    open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    print $livefile @todos;
    close $livefile;

    open(my $readfile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    if($debug){print $todofile.' '; print -s $readfile;}
    my $filter ='';
    if($filter ne ''){
        while(my $line = <$readfile>){ # <> used for files and globs
            next if ($line !~ /\+$filter/); # filter out tags
            chomp $line; # removes trailing new line
            if($line =~ /\[x\]/) {print colored(" ".$line."\n", "bright_green");}
            elsif($line =~ /\[r\]/) {print colored(" ".$line."\n", "bright_yellow");}
            elsif($line =~ /\[-\]/) {print colored(" ".$line."\n", "bright_cyan");}
            else{ print " $line\n";}
        }
    }
    else{
        while(my $line = <$readfile>){ # <> used for files and globs
            chomp $line; # removes trailing new line
            if($line =~ /\[x\]/) {print colored(" ".$line."\n", "bright_green");}
            elsif($line =~ /\[r\]/) {print colored(" ".$line."\n", "bright_yellow");}
            elsif($line =~ /\[-\]/) {print colored(" ".$line."\n", "bright_cyan");}
            else{ print " $line\n";}
        }
    }
    print "End of list\n";
    close $readfile;
}
elsif($action eq 'delete'){
    if($content =~ /^\D+$/){die "Must provide integer argument, got $content";}
    open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    my @todos;
    while(my $todo = <$livefile>){
        if($todo =~ /\>/){
            push @todos, (split(/\s/, $todo))[0]."\n";
        }else{
            push @todos, $todo;
        }
    }
    close $livefile;
    if($content > scalar @todos){
        die "Index provided ($content) exceeds todo-list length (".scalar @todos.")";
    }
    splice(@todos, $content, 1);
    open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    print $livefile @todos;
    close $livefile;
    print @todos;
}
else{
    die "Must provide valid action, got: $content";
}
