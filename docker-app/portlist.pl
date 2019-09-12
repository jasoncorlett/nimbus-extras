#!/usr/bin/env perl
#

use strict;
use warnings;
use YAML::XS qw(LoadFile);

my %externalPorts = ();

my @files = @ARGV ? @ARGV : glob "*.dockerapp";

parseFile($_) for @files;

while (my ($port, $used) = each %externalPorts) {
    print "Warning: $port used $used times.\n" if $used > 1;
}

sub parseFile {
    my $fileName = shift;

    my ($meta, $compose, $settings) = LoadFile($fileName);

    while (my ($serviceName, $service) = each %{$compose->{services}}) {
        for my $portInfo ( @{$service->{ports}} ) {
            my ($external, $internal) = split ":", $portInfo;

            my ($externalVar, $externalPort) = parsePort($external, $settings);
            my ($internalVar, $internalPort) = parsePort($internal, $settings);

            printf "%20s %10s %10s %30s %30s\n", $serviceName, $externalPort, $internalPort, $externalVar // '', $internalVar // '';

            $externalPorts{$externalPort}++;
        }
    }
}

sub parsePort {
    my $expression = shift;
    my $settings = shift;

    if ($expression =~ /\${(.*)}/) {
        return $1, $settings->{$1};
    }
    else {
        return undef, $expression;
    }
}
