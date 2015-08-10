package HMS::Schema::ResultSet::Role;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

#--- recursive_find_id -------------------------------------------------------------  
sub recursive_find_id {
   my $me = (my $self = shift)->current_source_alias;
   my $id = shift;

   # Loop through results in result set
   while( my $role = $self->next ) {
      # If this is the role return true
      return 1 if $role->id == $id;

      # Recurse down children to see if they are "the one"
      if ($role->children->count and $role->children->recursive_find_id($id)) {
         return 1;
      }
   }

   # If you found nothing, then return false
   return 0;
}

1;
