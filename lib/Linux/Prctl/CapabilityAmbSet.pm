package Linux::Prctl::CapabilityAmbSet;

use strict;
use warnings;

use Linux::Prctl;
use Tie::Hash;
use Carp qw(croak);

use vars qw(@ISA);
@ISA = qw(Tie::StdHash);

sub TIEHASH {
    my ($class, $error, $flag) = @_;
    if ($error) { croak $error; }
    my $self = {__flag => $flag};
    return bless($self, $class);
}

sub cap {
    my ($self, $cap) = @_;
    croak("Unknown capability: $cap") unless grep { $_ eq 'CAP_' . uc($cap) } @Linux::Prctl::EXPORT_OK;
    my ($error, $val) =  Linux::Prctl::constant('CAP_' . uc($cap));
    if ($error) { croak $error; }
    return $val
}

sub cap_ambset {
    shift;
    return Linux::Prctl->can('cap_ambset')->(@_);
}

sub cap_ambget {
    shift;
    return Linux::Prctl->can('cap_ambget')->(@_);
}

sub STORE {
    my ($self, $key, $value) = @_;
    $key = $self->cap($key);
    $self->cap_ambset($key, $value);
}

sub FETCH {
    my ($self, $key) = @_;
    $key = $self->cap($key);
    return $self->cap_ambget($key);
}

1;

