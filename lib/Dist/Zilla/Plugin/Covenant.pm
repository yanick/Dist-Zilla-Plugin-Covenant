package Dist::Zilla::Plugin::Covenant;
# ABSTRACT: add the author's pledge to the distribution

=head1 SYNOPSIS

In dist.ini:

    [Covenant]
    version = 1
    pledge_file = AUTHOR_PLEDGE

=head1 DESCRIPTION

C<Dist::Zilla::Plugin::Covenant> adds the file
'I<AUTHOR_PLEDGE>' to the distribution. The author(s)
as defined in I<dist.ini> is taken as being the pledgee(s).

The I<META> file of the distribution is also modified to
include a I<x_author_pledge> stanza.

=head1 CONFIGURATION OPTIONS

=head2 version

Version of the pledge to use. 

Defaults to '1' (the only version currently existing).

=head2 pledge_file

Name of the file holding the pledge.

Defaults to 'AUTHOR_PLEDGE'.

=cut


use 5.20.0;
use warnings;

use Moose;
use Dist::Zilla::File::InMemory;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::TextTemplate
    Dist::Zilla::Role::MetaProvider
/;

use experimental 'signatures';

has pledge_file => (
    is      => 'ro',
    default => 'AUTHOR_PLEDGE',
);

sub metadata {
    return { 'x_author_pledge' => { 'version' => 1 } };
}

has '+zilla' => (
    handles => { 
        distribution_name => 'name',
        authors           => 'authors',
    }
);

has pledge => (
    is => 'ro',
    lazy => 1,
    default => sub($self) {
        $self->fill_in_string(
            pledge_template(), {   
                distribution => $self->distribution_name,
                author       => join ', ', @{ $self->authors },
            }
        );
    },
);

sub gather_files ($self) {
    $self->add_file(
        Dist::Zilla::File::InMemory->new({ 
            content => $self->pledge,
            name    => $self->pledge_file,
        })
    );
}

sub pledge_template {
    return <<'END_PLEDGE';

# CPAN Covenant for {{ $distribution }}

I, {{ $author }}, hereby give modules@perl.org permission to grant co-maintainership 
to {{ $distribution }}, if all the following conditions are met:

   (1) I haven't released the module for a year or more
   (2) There are outstanding issues in the module's public bug tracker
   (3) Email to my CPAN email address hasn't been answered after a month
   (4) The requester wants to make worthwhile changes that will benefit CPAN

In the event of my death, then the time-limits in (1) and (3) do not apply.

END_PLEDGE
}

__PACKAGE__->meta->make_immutable;

1;
