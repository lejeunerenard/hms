package HMS::Schema::Result::RoleUser;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime Dated/);

__PACKAGE__->table('role_user');

__PACKAGE__->add_columns( qw/role user/ );

__PACKAGE__->set_primary_key(qw/role user/);

__PACKAGE__->belongs_to(
    role =>
    'HMS::Schema::Result::Role',
    'role'
);
__PACKAGE__->belongs_to(
    user =>
    'HMS::Schema::Result::User',
    'user'
);

1;
