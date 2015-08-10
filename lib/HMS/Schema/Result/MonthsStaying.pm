package HMS::Schema::Result::MonthsStaying;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Validation::Structure Dated Owned/);

__PACKAGE__->table('months_staying');

__PACKAGE__->add_columns(
   id => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   user_id => {
      data_type => 'integer',
   },
   house_id => {
      data_type => 'integer',
   },
   month => {
      data_type => 'integer',
   },
   year => {
      data_type => 'integer',
   },
   percentage => {
      data_type => 'decimal',
      size => [3,2]
   },
);

__PACKAGE__->set_primary_key('id');

# ======== Relationships ========
__PACKAGE__->belongs_to(
   user => 'HMS::Schema::Result::User',
   'user_id',
);
__PACKAGE__->belongs_to(
   house => 'HMS::Schema::Result::House',
   'house_id',
);

1;
