package DBIx::Class::Owned;

use strict;
use warnings;

use parent 'DBIx::Class';

sub table {
    my ( $class ) = shift;

    $class->next::method(@_);

    $class->add_columns(
        owner_id => {
            data_type => 'integer',
        },
    );

    # Setup relationship
    $class->belongs_to(
        owner => 'HMS::Schema::Result::User',
        'owner_id',
    );
}

1;
