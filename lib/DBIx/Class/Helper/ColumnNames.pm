package DBIx::Class::Helper::ColumnNames;

# ABSTRACT: Retrieve column names from a resultset

use v5.20;
use warnings;

use parent 'DBIx::Class';

use Ref::Util qw( is_plain_hashref is_ref );

# RECOMMEND PREREQ: Ref::Util::XS

use experimental qw( lexical_subs postderef signatures );

use namespace::clean;

our $VERSION = 'v0.1.2';

=head1 SYNOPSIS

In a resultset:

  package MyApp::Schema::ResultSet::Wobbles;

  use base qw/DBIx::Class::ResultSet/;

  __PACKAGE__->load_components( qw/
      Helper::ColumnNames
  /);

This adds a L</get_column_names> method to the resultset.

=head1 DESCRIPTION

This method is useful for simple applications that extract a column header from arbitrary result sets, to display an
HTML table or to export as a spreadsheet, for example.

=method get_column_names

  my @header = $rs->get_column_names;

This method attempts to return the column names of the resultset.

If no columns are specified using the C<columns> or C<select> attributes, then it will return the default columns names.

=cut

sub get_column_names ($self) {
    my @columns;

    state sub _get_name ($col) {
        if ( is_plain_hashref($col) ) {
            my (@names) = grep { $_ !~ /^\-/ } keys $col->%*;
            return @names;
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

=head1 CAVEATS

This module is experimental, and relies on some internals from L<DBIx::Class>.

=head1 SUPPORT FOR OLDER PERL VERSIONS

This module requires Perl v5.20 or later.

Future releases may only support Perl versions released in the last ten years.

=head1 SEE ALSO

L<DBIx::Class>

=head1 append:AUTHOR

The initial development of this module was sponsored by Science Photo
Library L<https://www.sciencephoto.com>.

=cut

1;
