package Dist::Zilla::Plugin::Covenant;
# add the author's pledge to the distribution

use strict;
use warnings;

use Moose;
use Dist::Zilla::File::InMemory;

with 'Dist::Zilla::Role::InstallTool';
with 'Dist::Zilla::Role::TextTemplate';

sub setup_installer {
    my $self = shift;
    my $manual_installation;
    (my $main_package = $self->zilla->name) =~ s!-!::!g;

    my $pledge = $self->fill_in_string(
        pledge_template(), {   
            distribution        => $self->zilla->name,
            author => $self->zilla->author,
        }
    );

    my $file = Dist::Zilla::File::InMemory->new({ 
            content => $pledge,
            name    => 'AUTHOR_PLEDGE',
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
