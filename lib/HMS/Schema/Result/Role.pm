package HMS::Schema::Result::Role;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->table('roles');

__PACKAGE__->load_components(qw/Validation::Structure/);

__PACKAGE__->add_columns(
   'id' => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   'name' => {
      data_type => 'varchar',
      size => '128',
   },
);

__PACKAGE__->set_primary_key('id');

# ======== Relationships ========

__PACKAGE__->has_many(
    role_user => 'HMS::Schema::Result::RoleUser',
    'role',
);
__PACKAGE__->many_to_many(
    users =>
    'role_user',
    'user',
);

1;
