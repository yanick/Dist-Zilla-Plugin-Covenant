package Dist::Zilla::Plugin::Covenant;
# ABSTRACT: add the author's pledge to the distribution

=head1 SYNOPSIS

In dist.ini:

    [Covenant]
    version = 1
    pledge_file = AUTHOR_PLEDGE

=head1 DESCRIPTION

C<Dist::Zilla::Plugin::Covenant> adds the file
'I<AUTHOR_PLEDGE>' to the distribution. The author
as defined in I<dist.ini> is taken as being the pledgee.

The I<META> file of the distribution is also modified to
include a I<x_author_pledge> stanza.

=head1 CONFIGURATION OPTIONS

=head2 version

Version of the pledge to use. 

Defaults to '1'.

=head2 pledge_file

Name of the file holding the pledge.

Defaults to 'AUTHOR_PLEDGE'.

=cut


use strict;
use warnings;

use Moose;
use Dist::Zilla::File::InMemory;

with 'Dist::Zilla::Role::InstallTool';
with 'Dist::Zilla::Role::TextTemplate';

has pledge_file => (
    is => 'ro',
    default => 'AUTHOR_PLEDGE',
);

sub setup_installer {
    my $self = shift;

    $self->zilla->distmeta->{x_author_pledge} = {
        version => 1,
    };

    my $pledge = $self->fill_in_string(
        pledge_template(), {   
            distribution        => $self->zilla->name,
            author => join( ', ', @{ $self->zilla->authors } ),
        }
    );

    my $file = Dist::Zilla::File::InMemory->new({ 
            content => $pledge,
            name    => $self->pledge_file,
        }
    );

    $self->add_file($file);
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
no Moose;
1;
