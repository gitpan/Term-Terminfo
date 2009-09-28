#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use Term::Terminfo;

# Force vt100 no matter what we're actually on
my $ti = Term::Terminfo->new( "vt100" );

isa_ok( $ti, "Term::Terminfo", '$ti isa Term::TermInfo' );

# Rely on some properties of the vt100 terminfo entry
ok(  $ti->getflag( "xon" ), '$ti has xon' );
ok( !$ti->getflag( "bce" ), '$ti has not bce' );

is( $ti->getnum( "cols" ), 80, '$ti has 80 cols' );

is( $ti->getstr( "cr" ), "\cM", '$ti has ^M cr' );
