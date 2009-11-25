/*  You may distribute under the terms of either the GNU General Public License
 *  or the Artistic License (the same terms as Perl itself)
 *
 *  (C) Paul Evans, 2009 -- leonerd@leonerd.org.uk
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <term.h>

MODULE = Term::Terminfo    PACKAGE = Term::Terminfo

void
_init(self)
    HV *self

  PREINIT:
    char *termtype;
    TERMINAL *oldterm;

    HV *flags, *nums, *strs;

    int i;

  CODE:
    termtype = SvPV_nolen(*hv_fetch(self, "term", 4, 0));

    oldterm = cur_term;

    setupterm(termtype, 0, NULL);

    flags = newHV();
    nums  = newHV();
    strs  = newHV();

    for(i = 0; boolnames[i]; i++) {
      const char *name = boolnames[i];
      if(tigetflag(boolnames[i]))
        hv_store(flags, name, strlen(name), newSViv(1), 0);
    }

    for(i = 0; numnames[i]; i++) {
      const char *name = numnames[i];
      int value = tigetnum(numnames[i]);

      if(value == -1)
        continue;

      hv_store(nums, name, strlen(name), newSViv(value), 0);
    }

    for(i = 0; strnames[i]; i++) {
      const char *name = strnames[i];
      char *value = tigetstr(strnames[i]);

      if(!value)
        continue;

      hv_store(strs, name, strlen(name), newSVpv(value, 0), 0);
    }

    hv_store(self, "flags", 5, newRV_noinc((SV*)flags), 0);
    hv_store(self, "nums",  4, newRV_noinc((SV*)nums),  0);
    hv_store(self, "strs",  4, newRV_noinc((SV*)strs),  0);

    oldterm = set_curterm(oldterm);
    del_curterm(oldterm);

    XSRETURN_UNDEF;
