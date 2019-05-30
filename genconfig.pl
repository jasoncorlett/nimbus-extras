#!/usr/bin/env perl
#

use strict;
use warnings;
use File::Basename;
use YAML::XS qw(LoadFile);

my @files = @ARGV ? @ARGV : glob "*.dockerapp";

die "No files to process.\n" unless @files;

parseFile($_) for @files;

sub parseFile {
    my $fileName = shift;

    my ($meta, undef, undef) = LoadFile($fileName);

    printf "%s %s/%s:%s\n", basename($fileName), $meta->{namespace}, basename($fileName), $meta->{version};
}

