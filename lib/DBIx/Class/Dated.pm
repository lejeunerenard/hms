package DBIx::Class::Dated;

use strict;
use warnings;

use parent 'DBIx::Class';

sub table {
    my ( $class ) = shift;

    $class->next::method(@_);

    $class->add_columns(
        created_on => {
            data_type => 'datetime',
            size      => 32,
            timezone  => 'America/Chicago',
            default_value => \'CURRENT_TIMESTAMP',
            is_nullable => 1,
        },
        updated_on => {
            data_type => 'datetime',
            size      => 32,
            timezone  => 'America/Chicago',
            default_value => \'CURRENT_TIMESTAMP',
            is_nullable => 1,
        },
    );
}

1;
