package HMS::Schema;

use strict;
use warnings;

use parent 'DBIx::Class::Schema';

our $VERSION = 1;

__PACKAGE__->load_namespaces();

1;
