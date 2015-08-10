use strict;
use warnings;

use lib qw{ ./t/lib };

use Test::More;
use Test::Deep;
use Test::Exception;

use Test::DBIx::Class {
   schema_class => 'HMS::Schema',
   fixture_class => '::Populate',
}, 'User' => { -as => 'Users' };

subtest 'constructor' => sub {
    my $user = Users->create({
        email => 'test@example.com',
        password => 'secretz',
        first_name => 'bob',
        last_name => 'fredericson',
    });

    # Wont be a resultset if we forget a required field
    is_result $user;
    # Attributes
    can_ok $user, qw/
        id
        email
        password
        first_name
        last_name
        invited_on
        invitation_key
        is_email_confirmed
        email_confirmation_key
        created_on
        updated_on
    /;
    # other subs
    can_ok $user, qw/
        name
        send_recovery_email
        send_email_confirmation
        confirm_email
        is_invited
        send_invitation
        accept_invitation
    /;
};

done_testing;
