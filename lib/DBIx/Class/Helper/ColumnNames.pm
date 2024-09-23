package DBIx::Class::Helper::ColumnNames;

use v5.20;
use warnings;

use parent 'DBIx::Class::ResultSet';

use Ref::Util qw( is_plain_hashref is_ref );

# RECOMMEND PREREQ: Ref::Util::XS

use experimental qw( lexical_subs postderef signatures );

use namespace::clean;

sub get_column_names ($self) {
    my @columns;

    state sub _get_name {
        my ($col) = @_;
        if ( is_plain_hashref($col) ) {
            my ($name) = keys $col->%*;
            return $name;
        }
        else {
            die "Cannot determine column name from a reference" if is_ref($col);
            return $col =~ s/^\w+\.//r;
        }
    }

    $self->_normalize_selection( my $attrs = $self->{attrs} );

    for my $key (qw/ columns +columns as +as /) {
        next unless $attrs->{$key};
        push @columns, map { _get_name($_) } $attrs->{$key}->@*;
    }

    return $self->result_source->columns unless @columns;

    return @columns;
}

1;
