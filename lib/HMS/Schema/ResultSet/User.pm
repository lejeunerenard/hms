package HMS::Schema::ResultSet::User;

use strict;
use warnings;
use parent 'DBIx::Class::ResultSet';

#--- Get Invited Users -------------------------------------------------------------  
sub get_invited {
   my $me = (my $self = shift)->current_source_alias;
   my $invite_key = shift;

   # If invitation key is present, return only the first User with that key
   return $self->search({
      invitation_key => $invite_key,
   })->first if $invite_key;

   # else return a list of all users with an invitation key
   return $self->search({
      -not => {
         invitation_key => '',
      },
   });
}
#--- Accept invitation -------------------------------------------------------------  
sub accept_invitation {
   my $me = (my $self = shift)->current_source_alias;
   my $invitation_key = shift;

   if (my $user = $self->get_invited($invitation_key)) { 
      return $user->accept_invitation($invitation_key, @_);
   }

   return 0;
}
1;
