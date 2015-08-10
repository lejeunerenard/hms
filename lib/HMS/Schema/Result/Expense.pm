package HMS::Schema::Result::Expense;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Validation::Structure Dated Owned/);

__PACKAGE__->table('expenses');

__PACKAGE__->add_columns(
   id => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   house_id => {
      data_type => 'integer',
   },
   category_id => {
      data_type => 'integer',
   },
   name => {
       data_type => 'varchar',
       size => 255,
   },
   description => {
      data_type => 'text',
      size => '1000',
      is_nullable => 1,
   },
   amount => {
      data_type => 'decimal',
      size => [8,2]
   },
   month => {
      data_type => 'integer',
   },
   year => {
      data_type => 'integer',
   },
);

__PACKAGE__->set_primary_key('id');

# ======== Relationships ========
__PACKAGE__->belongs_to(
   house => 'HMS::Schema::Result::House',
   'house_id',
);
__PACKAGE__->belongs_to(
   category => 'HMS::Schema::Result::Category',
   'category_id',
);

1;
