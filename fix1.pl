#!/usr/bin/env perl
# Fixes some issues in the Albanian POS corpus.
# Copyright © 2020 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;

my $sent_id_prefix = '';
GetOptions
(
    'sent_id_prefix=s' => \$sent_id_prefix
);
if($sent_id_prefix !~ m/^[A-Za-z0-9_]+$/)
{
    print STDERR ("Usage: perl fix1.pl --sent_id_prefix thisfileid\n");
    die("Invalid sent_id_prefix '$sent_id_prefix'");
}

my @sentence = ();
my $isent = 0;
while(<>)
{
    push(@sentence, $_);
    if(m/^\s*$/)
    {
        process_sentence(@sentence);
        @sentence = ();
    }
}



#------------------------------------------------------------------------------
# Once a sentence has been read, processes it and prints it.
#------------------------------------------------------------------------------
sub process_sentence
{
    $isent++; # global counter
    my @sentence = @_;
    # Sort lines to those that start with a number (nodes and multi-word tokens)
    # and those that don't. The latter must be labeled as comments and must precede
    # all numbered lines.
    my @comments = ();
    my @nodes = ();
    my $normal_node_encountered = 0;
    foreach my $line (@sentence)
    {
        # Strip all lines of their terminating character(s), then add it again.
        # This way all lines will be terminated using the LF character only
        # (Unix-style).
        $line =~ s/\r?\n$//;
        if($line =~ m/^\#/)
        {
            push(@comments, $line.chr(10));
        }
        elsif($line =~ m/^\d/)
        {
            push(@nodes, $line.chr(10));
            if($line =~ m/^\d+\t/)
            {
                $normal_node_encountered = 1;
            }
        }
        elsif($line =~ m/^\s*$/)
        {
            # Do nothing. This is the empty line that terminates the sentence.
        }
        else
        {
            # We should not be here because such lines should not exist.
            # Make it a comment.
            $line = '#'.$line.chr(10);
            push(@comments, $line);
        }
    }
    # If the sentence is empty, ignore it and do not print it.
    if(!$normal_node_encountered)
    {
        $isent--;
        return;
    }
    # If the comments contain the sent_id attribute, rename it orig_sent_id.
    # We will generate our own sent_id and make sure it also identifies the
    # source file, so the ids are unique across the entire corpus.
    # Similarly, if there is a text attribute, rename it orig_text, we will
    # later generate the text from the word forms and from SpaceAfter=No.
    foreach my $comment (@comments)
    {
        $comment =~ s/^\#\s*(sent_id|text)\s*=/\# orig_$1 =/;
    }
    # Generate our sentence id with the prefix.
    my $sent_id_line = '# '."sent_id = $sent_id_prefix-$isent\n";
    unshift(@comments, $sent_id_line);
    # Re-assemble the sentence, comments first.
    @sentence = (@comments, @nodes, chr(10));
    # Print the fixed sentence.
    print(join('', @sentence));
}
