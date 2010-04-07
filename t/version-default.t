#!perl

use strict;
use warnings;
use lib 't/lib';

use Dist::Zilla;
use Dist::Zilla::Tester;
use Git::Wrapper;
use Path::Class;
use Test::More      tests => 6;
use Test::Exception;
use File::pushd;

## Tests start here

{
  my $tzil = Dist::Zilla::Tester->from_config(
    { dist_root => 'corpus/version-default' },
  );
  ok( $tzil, "created test dist from corpus/version-default");
  my $wd = pushd $tzil->tempdir->subdir('source');

  system "git init";
  my $git   = Git::Wrapper->new('.');
  $git->add(".");
  $git->commit({ message => 'import' });
  my ($zilla, $version);

  # with no tags and no initialization, should get default
  $zilla = Dist::Zilla::Tester->from_config( {dist_root => "."} );
  $version = $zilla->version;
  is( $version, "0.001", "default is 0.001" );

  # initialize it
  {
      local $ENV{V} = "1.23";
      $zilla = Dist::Zilla::Tester->from_config( {dist_root => "."} );
      is( $zilla->version, "1.23", "initialized with \$ENV{V}" );
  }

  # tag it
  $git->tag("v1.2.3");
  ok( (grep { /v1\.2\.3/ } $git->tag), "wrote v1.2.3 tag" );

  {
      $zilla = Dist::Zilla::Tester->from_config( {dist_root => "."} );
      is( $zilla->version, "1.2.4", "initialized from last tag" );
  }

  # tag it
  $git->tag("v1.23");
  ok( (grep { /v1\.23/ } $git->tag), "wrote v1.23 tag" );

  {
      $zilla = Dist::Zilla::Tester->from_config( {dist_root => "."} );
      is( $zilla->version, "1.24", "initialized from last tag" );
  }

}

done_testing;

