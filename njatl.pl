#!/usr/bin/perl
use strict;
use warnings; # Good to have
use Getopt::Long; # Arg Parse
#use Cwd 'abs_path';
use FindBin '$Bin'; # Get location
use Time::Piece; # Date and Time Formatting
use Term::ANSIColor; # Colours

my $debug=0;
my $greeting=''; my $help='';
# save arguments following -w or --word in the scalar
# =s means that an argument follows
GetOptions( 'action=s' => \my $action, 'content=s' => \my $content, 'greeting' => \$greeting, 'help' => \$help);


if($debug==1){
    print "$action - $content\n";
}

if($help ne ''){
    print "Usage: Yet Another Todo List\n\taction:STRING [create, list, mark, delete]\n\tcontent:STRING string to be passed or integer for mark and delete actions\n\tgreeting:FLAG optional for greeting in list action\n";
    exit;
}
my $todofile = $Bin.'/todo.txt';
if($action eq 'create'){
    open(my $livefile, '>>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    print $livefile "[ ] $content\n";
    print "recorded $content to todo-list\n";
    close $livefile;
}
elsif($action eq 'list'){
    if($debug==1){print "in greeting flag, got $greeting.";}
    if($greeting ne ''){ my $date = localtime->strftime('%A, %b %e %Y'); print "$date | Today's Tasks:\n=====================================\n";}
    open(my $livefile, '<:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    if($content ne ''){
    while(my $line = <$livefile>){ # <> used for files and globs
        next if ($line !~ /$content/);
        chomp $line; # removes trailing new line
        if($line =~ /\[x\]/) {print colored($line."\n", "green");}
        else{ print $line."\n";}

    }
}
    else{
    while(my $line = <$livefile>){ # <> used for files and globs
        chomp $line; # removes trailing new line
        if($line =~ /\[x\]/) {print colored($line."\n", "green");}
        else{ print $line."\n";}
    }
}
    print "End of list\n";
    close $livefile;
}
elsif ($action eq 'mark'){
    # check that we are given a positive integer index
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
    $todos[$content] =~ s/\[ \]/[x]/; # magic!!
    open($livefile, '>:encoding(UTF-8)', $todofile) or die "Could not open todofile '$todofile'";
    print $livefile @todos;
    close $livefile;
    print @todos;
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
