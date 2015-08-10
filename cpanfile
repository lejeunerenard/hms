requires 'Dancer';
requires 'Dancer::Plugin::DBIC';
requires 'DBIx::Class::PassphraseColumn';
requires 'DBIx::Class::Validation::Structure';
requires 'DBIx::Class::InflateColumn::DateTime';

requires 'MIME::Entity';
requires 'MIME::Lite::TT::HTML';
requires 'Email::Sender::Simple';
requires 'String::Random';
requires 'DateTime::Format::ISO8601';

on 'test' => sub {
   requires 'Test::DBIx::Class';
};
