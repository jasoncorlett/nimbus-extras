#!/usr/bin/env perl
#
# nimbus-group.pl
#

use strict;
use warnings;
use YAML::Tiny qw(LoadFile);

my $nimbusExe = qx(which nimbusapp) || die "Could not locate nimbusapp executable.\n";
chomp $nimbusExe;
die "Nimbusapp ($nimbusExe) not executable.\n" unless -x $nimbusExe;

my $configFile = $ENV{NIMBUS_GROUP_CONFIG} || "$ENV{HOME}/.nimbusapp/groups.yml";
die "Could not find group configuration: $configFile.\n" unless -f $configFile;

my $config = LoadFile($configFile);
my $command = shift @ARGV;

die "'groups' element required in configuration.\n" unless defined $config->{groups};
run_command($command, $config->{groups}{$_}) for map { die "No such group: $_" unless $config->{groups}{$_}; $_ } @ARGV;

sub run_command {
  my $cmd = shift; # Name of command (string)
  my $grp = shift; # Arrayref of group info

  for my $image ( @{ $grp } ) {
    my $img = normalize_image_name($image);
    printf "Running: %s on %s\n", $command, $img;
    system($nimbusExe, $img, $command);
  }
}

sub normalize_image_name {
  my $img = (ref($_[0]) eq 'HASH') ? $_[0]->{image} : $_[0];
  my $result = '';

  die "Invalid image name: $img.\n" unless $img =~ /^(?:(.*?)\/)?(.+?)(?:\.dockerapp)?(?::(.*))?$/;

  # If no namespace is provided, try the default
  # If no default exists, leave the namespace out and let nimbusapp deal with it
  my $ns = ($1) ? $1
    : (defined($config->{defaults}) && defined($config->{defaults}{namespace})) ? $config->{defaults}{namespace}
    : undef;

  return (($ns) ? $ns . '/' : '') . $2 . '.dockerapp:' . $3
}

