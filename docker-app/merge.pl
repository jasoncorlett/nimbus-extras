#!/usr/bin/env perl

use 5.030;
use Carp;

use YAML::XS qw(LoadFile Dump);
use List::Util qw(uniq);

my @data = map { [ LoadFile($_) ] } @ARGV;

for my $doc (0..2) {
    print Dump merge( map { $_->[$doc] } @data );
}

sub merge {
    my $left = shift;
    my $right = shift;

    return merge(merge($left, $right), @_) if @_;

    return $left if !defined $right;
    return $right if !defined $left;

    ref($left) ne ref($right) and
        croak "Attempt to merge " . (ref($left) || 'SCALAR') . " with " . (ref($right) || 'SCALAR');

    ref($left) eq 'HASH' and
        return {
            map {
                if ($_ eq 'environment') {
                    $_ => merge(kv_map($left->{$_}), kv_map($right->{$_}))
                }
                else {
                    $_ => merge($left->{$_}, $right->{$_})
                }
            }
            uniq map { keys %$_ } $left, $right
        };
    
    ref($left) eq 'ARRAY' and
        return [ uniq(@$left, @$right) ];

    # Scalar
    return $left;
}

# Convert array of KEY=VALUE scalars into a hashref
sub kv_map {
    my $data = shift;

    ref($data) eq 'HASH' and return $data;
    ref($data) ne 'ARRAY' and croak "Invalid Key-Value type: " . (ref($data) || 'SCALAR');

    return { map { split '=', $_, 2 } $data->@* };
}
