package HMS::Schema::Result::House;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Validation::Structure Dated Owned/);

__PACKAGE__->table('houses');

__PACKAGE__->add_columns(
   id => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   name => {
      data_type => 'varchar',
      size => '255',
   },
);

__PACKAGE__->set_primary_key('id');

# ======== Relationships ========

1;
