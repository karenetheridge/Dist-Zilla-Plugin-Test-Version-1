use strict;
use warnings;
use Test::More;
use Test::DZil;
use Test::Script 1.05;
use Test::NoTabs;
use File::chdir;
use Path::Class qw( file );

my $tzil = Builder->from_config(
  {
    dist_root    => 'corpus/a',
  },
  {
    add_files => {
      'source/dist.ini' => simple_ini(
        {},
        ['GatherDir'],
        ['FileFinder::ByName / MyFinder' => {
          dir => 'lib/X1',
        }],
        ['Test::Version' => {
          finder => 'MyFinder',
        }]
      ),
      'source/lib/X1/Foo.pm' => "package X1::Foo;\nour \$VERSION = 1.00;\n1;\n",
      'source/lib/X2/Bar.pm' => "package X2::Bar;\n1;\n",
    }
  },
);

$tzil->build;

is $tzil->prereqs->as_string_hash->{develop}->{requires}->{'Test::Version'}, '1', 'needs Test::Version 1';

my $fn = $tzil
  ->tempdir
  ->subdir('build')
  ->subdir('xt')
  ->subdir('release')
  ->file('test-version.t')
  ;

ok ( -e $fn, 'test file exists');

note $fn->slurp;

do {
  local $CWD = $tzil->tempdir->subdir('build')->stringify;
  #note "CWD = $CWD";
  notabs_ok      ( file(qw( xt release test-version.t ))->stringify, 'test has no tabs'    );
  script_compiles( file(qw( xt release test-version.t ))->stringify, 'check test compiles' );
  script_runs    ( file(qw( xt release test-version.t ))->stringify, 'check test runs'     );
};

done_testing;
