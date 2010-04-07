use strict;
use warnings;
package Dist::Zilla::Plugin::BumpVersionFromGit;
# ABSTRACT: provide a version number by bumping the last git release tag

use Dist::Zilla 2 ();
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

This does the [Dist::Zilla::Role::VersionProvider] role.  It finds the last
version number from tags and increments it as the new version used by
Dist::Zilla.

The plugin accepts the following options:

* first_version - if the repository has no tags at all, this version
is used as the first version for the distribution.  It defaults to "0.001".
* version_regexp - regular expression that matches a tag containing
a version.  It should capture the version into $1.  Defaults to ^v(.+)$
which matches the default tag from [Dist::Zilla::Plugin::Git::Tag]

You can also set the {V} environment variable to override the new version.
This is useful if you need to bump to a specific version.  For example, if
the last tag is 0.005 and you want to jump to 1.000 you can set V = 1.000.

*NOTE* -- this module is a stop gap while Dist::Zilla is enhanced to
allow more sophisiticated version number manipulation and may be
deprecated in the future once those changes are complete.

= SEE ALSO

* [Dist::Zilla::Plugin::VersionFromPrev] and 
[Dist::Zilla::Plugin::Git::LastVersion] do something similar but in what
I find to be a more complicated way of doing things

=end wikidoc

=cut

