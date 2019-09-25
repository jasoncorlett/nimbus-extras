#!/usr/bin/env perl
use 5.030;
use YAML::XS qw(LoadFile Dump);
use Getopt::Long;

my %overrideParams = ();

GetOptions(
    'set|s=s' => \%overrideParams
);

my $variable_match = qr/( \$\{ (\w+) \} )/x;

my (undef, $compose, $rawParams) = LoadFile(shift // usage(1));
print Dump walk($compose, process_params($rawParams, \%overrideParams));

sub walk {
    my $node = shift;
    my $params = shift;

    ref($node) eq 'ARRAY' and
        return [ map { walk($_, $params) } $node->@* ];

    ref($node) eq 'HASH' and 
        return { map { $_ => walk($node->{$_}, $params) } keys $node->%* };

    return $node =~ s/$variable_match/$params->{$2} || $1/reg;
}

sub process_params {
    my $params = shift;
    my $override = shift;

    while (my ($k, $v) = each $override->%*) {
        $params->{$k} = $v;
    }

    my $cont = 1;
    my $loop = 10;

    while ($cont && $loop--) {
        $cont = 0;
        while (my ($k, $v) = each $params->%*) {
            $cont += $params->{$k} =~ s/$variable_match/$params->{$2} || $1/eg;
        }
    }

    return $params;
}

sub usage {
    say '';
    say qq{perl $0 <some_file.dockerapp>};
    say '';

    exit(shift) if @_;
}
