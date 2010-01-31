#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use Term::Terminfo;

# Force vt100 no matter what we're actually on
my $ti = Term::Terminfo->new( "vt100" );

isa_ok( $ti, "Term::Terminfo", '$ti isa Term::TermInfo' );

# Rely on some properties of the vt100 terminfo entry
ok(  $ti->getflag( "am" ), '$ti has am' );
ok( !$ti->getflag( "bce" ), '$ti has not bce' );

is( $ti->getnum( "it" ), 8, '$ti has initial tabs at 8' );

is( $ti->getstr( "cr" ), "\cM", '$ti has ^M cr' );
