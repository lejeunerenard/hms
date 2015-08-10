package HMS::Schema::Result::User;

use strict;
use warnings;

use parent 'DBIx::Class::Core';

use MIME::Entity;
use MIME::Lite::TT::HTML;
use Email::Sender::Simple 'sendmail';
use String::Random;
use DateTime::Format::ISO8601;

__PACKAGE__->load_components(qw/PassphraseColumn InflateColumn::DateTime Validation::Structure Dated/);

__PACKAGE__->table('users');

__PACKAGE__->add_columns(
   id => {
      data_type => 'integer',
      is_auto_increment => 1,
   },
   email => {
      data_type => 'varchar',
      size => '128',
      val_override => 'email',
   },
   password => {
      data_type => 'varchar',
      size => '255',
      val_override => 'password',

      # Hashing params
      passphrase => 'crypt',
      passphrase_class => 'BlowfishCrypt',
      passphrase_args => {
          cost => 14,
          salt_random => 1,
      },
      passphrase_check_method => 'authenticate',
   },
   first_name => {
      data_type => 'varchar',
      size => '64',
   },
   last_name => {
      data_type => 'varchar',
      size => '64',
   },
   invited_on => {
      data_type => 'datetime',
      timezone => 'America/Chicago',
      is_nullable => 1,
   },
   invitation_key => {
      data_type => 'varchar',
      size => '255',
      is_nullable => 1,
   },
   is_email_confirmed => {
      data_type => 'boolean',
      is_nullable => 1,
      default_value => 0,
   },
   email_confirmation_key => {
      data_type => 'varchar',
      size => '255',
      is_nullable => 1,
   },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([ qw/email/ ]);

# -------- Relationships --------
__PACKAGE__->has_many(
    role_user => 'HMS::Schema::Result::RoleUser',
    'user',
);
__PACKAGE__->many_to_many(
    roles =>
    'role_user',
    'role',
);

# -------- Helper functions --------

# Get complete name
sub name {
   my $self = shift;

   my $name = '';

   $name .= $self->first_name if $self->first_name;
   $name .= ' ' if $name ne '' and $self->last_name;
   $name .= $self->last_name if $self->last_name;

   return $name;
}

#--- Recovery Email -------------------------------------------------------------
sub send_recovery_email {
   my $self = shift;
   my %options = @_;
   my $user_id = ($options{user_id}) ? $options{user_id} : $self->id;
   my $host = ($options{host}) ? $options{host} : ($ENV{host}) ? $ENV{host} : $ENV{HTTP_HOST};
   my $from = ($options{from}) ? $options{from} : 'support@lejeunerenard.com';

   my $random = new String::Random;
   $random->{'A'} = [ '0'..'9','A'..'Z', 'a'..'z' ];
   my $password = ($options{password}) ? $options{password} : $random->randpattern("A"x12);

   my $user = $self->result_source->resultset->find( $user_id );

   $user->update({ password => $password });

   my $txt_body =
'Your password has been reset. Your new password is:
'.$password.'

To login, go to http://'.$host.'/login

This is an automated email. Please do not reply to this email.';
   my $html_body =
'<p>Your password has been reset. Your new password is:</p>
<p>'.$password.'</p>
<p>&nbsp;</p>
<p>To login, go to <a href="http://'.$host.'/login">http://'.$host.'/login</a></p>
<p>&nbsp;</p>
<p>This is an automated email. Please do not reply to this email.</p>';

### Create the top-level, and set up the mail headers:
   my $script_name = $ENV{_};
   if ($script_name !~ /dbic-migration/g) {
    my $top = MIME::Entity->build(  Type     => "multipart/alternative",
                                    From     => $from,
                                    To       => $user->email,
                                    Subject  => "Password Recovery");

    ### Attachment #1: a simple text version:
    $top->attach(Data        => $txt_body,
                 Type        => "text/plain",
                 Encoding    => "8bit");

    ### Attachment #2: a html version:
    $top->attach(Data        => $html_body,
                 Type        => "text/html",
                 Encoding    => "8bit");
   return sendmail $top;
   }

}

#--- Recovery Email -------------------------------------------------------------
sub send_email_confirmation {
   my $self = shift;
   my %options = @_;
   my $host = ($options{host}) ? $options{host} : ($ENV{host}) ? $ENV{host} : $ENV{HTTP_HOST};
   my $route = ($options{route}) ? $options{route} : '/users/email_confirm/';
   my $from = ($options{from}) ? $options{from} : 'support@lejeunerenard.com';
   my $template_opt = $options{template};

   # template defaults
   my $template = {
      text => 'users/email_confirmation.tt',
      html => 'users/email_confirmation-html.tt',
      path => '../views/',
   };

   # Override default template options
   $template->{$_} = $template_opt->{$_} foreach ( keys %$template_opt );

   my $random = new String::Random;
   $random->{'A'} = [ '0'..'9','A'..'Z', 'a'..'z' ];
   # Generate email_confirmation_key using the size of the email_confirmation_key field
   my $email_confirmation_key = $random->randpattern("A"x$self->column_info('email_confirmation_key')->{size});

   $self->update({
      email_confirmation_key => $email_confirmation_key,
      is_email_confirmed => 0,
   }); # Update fields

   my $tmpl_params = {
      email_confirm_key => $email_confirmation_key,
      name => $self->name,
      first_name => $self->first_name,
      last_name => $self->last_name,
      host => $host,
      route => $route,
   };

    my $msg = MIME::Lite::TT::HTML->new(
       From     => $from,
       To       => $self->email,
       Subject  => "Email Confirmation",
       Template => {
          text => $template->{text},
          html => $template->{html},
       },
       TmplOptions => {
          INCLUDE_PATH => $template->{path}
       },
       TmplParams => $tmpl_params,
    );

    return $email_confirmation_key if $msg->send;

    return 0;
}

#--- Recovery Email -------------------------------------------------------------
sub confirm_email {
   my $self = shift;
   my $key = shift;

   if ($self->email_confirmation_key eq $key) {
      $self->update({
         email_confirmation_key => '',
         is_email_confirmed => 1,
      });
      return 1;
   } else {
      return 0;
   }
}

#--- Does the user have an outstanding invitation? -------------------------------------------------------------
sub is_invited {
   my $self = shift;
   return ($self->invitation_key) ? 1 : 0;
}

#--- Send Invitation to User -------------------------------------------------------------
sub send_invitation {
   my $self = shift;
   my %options = @_;
   my $host = ($options{host}) ? $options{host} : ($ENV{host}) ? $ENV{host} : $ENV{HTTP_HOST};
   my $route = ($options{route}) ? $options{route} : '/users/confirm_invite/';
   my $from = ($options{from}) ? $options{from} : 'support@lejeunerenard.com';
   my $subject = ($options{subject}) ? $options{subject} : "User Account Invitation";
   my $template_opt = $options{template};

   # template defaults
   my $template = {
      text => 'users/email_invitation.tt',
      html => 'users/email_invitation-html.tt',
      path => '../views/',
   };

   # Override default template options
   $template->{$_} = $template_opt->{$_} foreach ( keys %$template_opt );

   my $random = new String::Random;
   $random->{'A'} = [ '0'..'9','A'..'Z', 'a'..'z' ];
   # Generate email_confirmation_key using the size of the email_confirmation_key field
   my $invitation_key = $random->randpattern("A"x$self->column_info('invitation_key')->{size});

   $self->update({
      invitation_key => $invitation_key,
      invited_on => DateTime->today->ymd,
   }); # Update fields

   my $tmpl_params = {
      invitation_key => $invitation_key,
      name => $self->name,
      first_name => $self->first_name,
      last_name => $self->last_name,
      host => $host,
      route => $route,
   };

    my $msg = MIME::Lite::TT::HTML->new(
       From     => $from,
       To       => $self->email,
       Subject  => $subject,
       Template => {
          text => $template->{text},
          html => $template->{html},
       },
       TmplOptions => {
          INCLUDE_PATH => $template->{path}
       },
       TmplParams => $tmpl_params,
    );

    return $invitation_key if $msg->send;

    return 0;
}

#--- Accept invitation -------------------------------------------------------------
# This function is meant to be called only after the User has be otherwise validated. Its a last line of defense against people jacking a user's invite.
sub accept_invitation {
   my $self = shift;
   my $invitation_key = shift;
   my %options = @_;
   my $expiration_range = ($options{expiration_range}) ? $options{expiration_range} : DateTime::Duration->new(
      days => 1,  # By default invitations expire in 1 day
   );

   # Check if invitation key
   if ($self->invitation_key eq $invitation_key) {
      my $invited_on = DateTime::Format::ISO8601->parse_datetime( $self->invited_on );
      # Make sure its not too old
      if ( DateTime->compare(DateTime->today, $invited_on->add_duration($expiration_range) ) != 1 )  {
         # Clear invite key so it cannot be used again
         $self->update({
            invitation_key => '',
         });
         return 1;
      # If too old remove the invite key
      } else {
         $self->update({
            invitation_key => '',
         });
      }
   }

   return 0;
}

1;
