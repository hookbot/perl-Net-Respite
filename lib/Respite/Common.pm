package Respite::Common;

=pod

=head1 NAME

  Respite::Common - Common methods used internally

=head1 SYNOPSIS

    package CustomModule;
    use base 'Respite::Common';

    sub xkey1 { return shift->_configs->{xxx_key} || "unknown" }

=cut

use strict;
use warnings;

our $config;
sub _configs { $config || (eval { require config } or $config::config{'failed_load'} = $@) && ($config = config->load) }

sub config {
    my ($self, $key, $def, $name) = @_;
    $name ||= (my $n = $self->base_class || ref($self) || $self || '') =~ /(\w+)$/ ? lc $1 : '';
    my $c = $self->_configs($name);
    return exists($self->{$key}) ? $self->{$key}
        : exists($c->{"${name}_service_${key}"}) ? $c->{"${name}_service_${key}"}
        : (ref($c->{"${name}_service"}) && exists $c->{"${name}_service"}->{$key}) ? $c->{"${name}_service"}->{$key}
        : exists($c->{"${name}_${key}"}) ? $c->{"${name}_${key}"}
        : (ref($c->{$name}) && exists $c->{$name}->{$key}) ? $c->{$name}->{$key}
        : ref($def) eq 'CODE' ? $def->($self) : $def;
}

1;
