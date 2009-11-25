use strict;
use warnings;

use Module::Build;

eval { require ExtUtils::CBuilder; 1 } or
   die "OS unsupported - missing ExtUtils::CBuilder";

my $cbuilder = ExtUtils::CBuilder->new;

# Stolen from Socket-GetAddrInfo/Build.PL
sub try_compile_run
{
   my ( $name, $source, %extra ) = @_;

   my $test_source = "test-$name.c";

   open( my $test_source_fh, "> $test_source" ) or die "Cannot write $test_source - $!";

   print $test_source_fh $source;

   close $test_source_fh;

   my $test_obj = eval { $cbuilder->compile( source => $test_source ) };

   unlink $test_source;

   if( not defined $test_obj ) {
      print "\nFailed to compile $test_source\n";
      return 0;
   }

   print "Compiled $test_source to $test_obj\n\n";

   my $test_exe = eval { $cbuilder->link_executable( 
         objects => $test_obj,
         ( exists $extra{libs} ? ( extra_linker_flags => "-l$extra{libs}" ) : () ),
   ) };
   END { defined $test_exe and -f $test_exe and unlink $test_exe; }

   unlink $test_obj;

   if( not defined $test_exe ) {
      print "\nFailed to link $test_obj to an executable\n";
      return 0;
   }

   print "Linked $test_obj to $test_exe\n\n";

   if( system( "./$test_exe" ) != 0 ) {
      print "\nFailed to run $test_exe\n";
      unlink $test_exe;
      return 0;
   }

   unlink $test_exe;

   return 1;
}

die "OS unsupported - no term.h" unless try_compile_run "term_h", <<'EOF';
#include <stdio.h>
#include <term.h>
int main(int argc, char *argv[]) {
  TERMINAL *term = cur_term;
  return 0;
}
EOF

my $lib_curses;
foreach (qw( ncurses curses )) {
   next unless try_compile_run "curses", <<'EOF', libs => $_;
#include <stdlib.h>
#include <term.h>
int main(int argc, char *argv[]) {
  setupterm(NULL, 0, NULL);
  return 0;
}
EOF

   $lib_curses = $_;
   last;
}

die "OS unsupported - cannot find lib curses" unless defined $lib_curses;

my $build = Module::Build->new
  (
   module_name => 'Term::Terminfo',
   extra_linker_flags => [ "-l$lib_curses" ],
   requires => {
   },
   configure_requires => {
      'Module::Build' => 0,
      'Module::Build::Compat' => 0,
   },
   build_requires => {
      'Test::More' => 0,
   },
   license => 'perl',
   create_makefile_pl => 'small',
   create_license => 1,
   create_readme  => 1,
  );

$build->create_build_script;
