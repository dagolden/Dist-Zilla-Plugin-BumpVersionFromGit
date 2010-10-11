use strict;
use warnings;
package Dist::Zilla::Plugin::BumpVersionFromGit;
# ABSTRACT: DEPRECATED -- use Dist::Zilla::Plugin::Git::NextVersion instead

use Dist::Zilla 4 ();
use Git::Wrapper;
use version 0.80 ();

use Moose;
use namespace::autoclean 0.09;

with 'Dist::Zilla::Role::VersionProvider';

# -- attributes

has version_regexp  => ( is => 'ro', isa=>'Str', default => '^v(.+)$' );

has first_version  => ( is => 'ro', isa=>'Str', default => '0.001' );

# -- role implementation

sub provide_version {
  my ($self) = @_;

  require Version::Next;

  # override (or maybe needed to initialize)
  return $ENV{V} if exists $ENV{V};

  my $git  = Git::Wrapper->new('.');
  my $regexp = $self->version_regexp;

  my @tags = $git->tag;
  return $self->first_version unless @tags;

  # find highest version from tags
  my ($last_ver) =  sort { version->parse($b) <=> version->parse($a) }
  grep { eval { version->parse($_) }  }
  map  { /$regexp/ ? $1 : ()          } @tags;

  $self->log_fatal("Could not determine last version from tags")
  unless defined $last_ver;

  my $new_ver = Version::Next::next_version($last_ver);
  $self->log("Bumping version from $last_ver to $new_ver");

  $self->zilla->version("$new_ver");
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=for Pod::Coverage
    provide_version

=begin wikidoc

= SYNOPSIS

In your F<dist.ini>:

    [BumpVersionFromGit]
    first_version = 0.001       ; this is the default
    version_regexp  = ^v(.+)$   ; this is the default

= DESCRIPTION

*NOTE* This distribution is *deprecated*.  The module has been
reborn as [Dist::Zilla::Plugin::NextVersion] and included in the
[Dist::Zilla::Plugin::Git] distribution.

=end wikidoc

=cut

