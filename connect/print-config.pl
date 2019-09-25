#!/usr/bin/env perl

use 5.030;
use XML::Simple;
use Data::Dump qw(pp);

my $dom = XMLin('C:\Projects\Connect\4.2\docs\Nimbus Connect 4.2.xml', forcearray => [ 'DataSource' ]);

while (my ($dsName, $ds) = each $dom->{DataSources}->{DataSource}->%*) {
    say $dsName;
    while (my ($propName, $prop) = each $ds->{Properties}->{Property}->%*) {
        say "\t$propName = " . ((ref $prop->{value}) ? pp($prop->{value}) : $prop->{value});
    }
    say '';
}

while (my ($syncName, $sync) = each $dom->{Synchronizations}->{Synchronization}->%*) {
    printf "%s\n", $syncName;
    printf "\t%s <= %s (%s)\n", $sync->{target}, $sync->{source}, $sync->{direction};

    for my $type ($sync->{TypeMaps}->{TypeMap}->@*) {
        printf "\t\t%s <= %s (%s)\n", $type->{target}, $type->{source}, $type->{direction};

        for my $prop ($type->{PropertyMaps}->{PropertyMap}->@*) {
            printf "\t\t\t%s <= %s (%s)\n", $prop->{targetPropertyLabel}, $prop->{sourcePropertyLabel}, $prop->{direction};

            for my $value ($prop->{ValueMaps}->{ValueMap}->@*) {
                printf "\t\t\t\t%s <= %s\n", $value->{targetValue}, $value->{sourceValue};
            }
        }
        printf "\n";
    }

    my $project = $sync->{ProjectMaps}->{ProjectMap};
    printf "\t\t%s => %s\n", $project->{target}, $project->{source};

    printf "\n";
}

