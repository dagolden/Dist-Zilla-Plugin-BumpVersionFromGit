#!perl

use strict;
use warnings;

use Dist::Zilla     1.093250;
use Git::Wrapper;
use Path::Class;
use Test::More      tests => 6;
use Test::Exception;


# build fake repository
chdir( dir('t', 'version-regexp') );
system "git init";
my $git   = Git::Wrapper->new('.');
$git->add(".");
$git->commit({ message => 'import' });
my ($zilla, $version);

# with no tags and no initialization, should get default
$zilla = Dist::Zilla->from_config;
$version = $zilla->version;
is( $version, "0.01", "default is 0.01" ); # set in dist.ini

# initialize it
{
    local $ENV{V} = "1.23";
    $zilla = Dist::Zilla->from_config;
    is( $zilla->version, "1.23", "initialized with \$ENV{V}" );
}

# tag it
$git->tag("release-v1.2.3");
ok( (grep { /release-v1\.2\.3/ } $git->tag), "wrote v1.2.3 tag" );

{
    $zilla = Dist::Zilla->from_config;
    is( $zilla->version, "v1.2.4", "initialized from last tag" );
}

# tag it
$git->tag("release-1.23");
ok( (grep { /release-1\.23/ } $git->tag), "wrote v1.23 tag" );

{
    $zilla = Dist::Zilla->from_config;
    is( $zilla->version, "1.24", "initialized from last tag" );
}


# clean & exit
dir( '.git' )->rmtree;
exit;

