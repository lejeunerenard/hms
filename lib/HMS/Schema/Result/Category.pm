package HMS::Schema::Result::Category;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Validation::Structure Dated Owned/);

__PACKAGE__->table('categories');

__PACKAGE__->add_columns(
   id => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   house_id => {
      data_type => 'integer',
   },
   name => {
      data_type => 'varchar',
      size => '64',
   },
);

__PACKAGE__->set_primary_key('id');

# ======== Relationships ========
__PACKAGE__->belongs_to(
   house => 'HMS::Schema::Result::House',
   'house_id',
);

1;
