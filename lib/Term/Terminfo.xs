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

    HV *flags_by_capname, *nums_by_capname, *strs_by_capname;
    HV *flags_by_varname, *nums_by_varname, *strs_by_varname;

    int i;
    SV *sv;

  CODE:
    termtype = SvPV_nolen(*hv_fetch(self, "term", 4, 0));

    oldterm = cur_term;

    setupterm(termtype, 0, NULL);

    flags_by_capname = newHV();
    nums_by_capname  = newHV();
    strs_by_capname  = newHV();

    flags_by_varname = newHV();
    nums_by_varname  = newHV();
    strs_by_varname  = newHV();

    for(i = 0; boolnames[i]; i++) {
      const char *capname = boolnames[i];
      const char *varname = boolfnames[i];
      if(!tigetflag(capname))
        continue;

      sv = newSViv(1);
      SvREADONLY_on(sv);

      hv_store(flags_by_capname, capname, strlen(capname), sv, 0);
      hv_store(flags_by_varname, varname, strlen(varname), SvREFCNT_inc(sv), 0);
    }

    for(i = 0; numnames[i]; i++) {
      const char *capname = numnames[i];
      const char *varname = numfnames[i];
      int value = tigetnum(capname);

      if(value == -1)
        continue;

      sv = newSViv(value);
      SvREADONLY_on(sv);

      hv_store(nums_by_capname, capname, strlen(capname), sv, 0);
      hv_store(nums_by_varname, varname, strlen(varname), SvREFCNT_inc(sv), 0);
    }

    for(i = 0; strnames[i]; i++) {
      const char *capname = strnames[i];
      const char *varname = strfnames[i];
      char *value = tigetstr(capname);

      if(!value)
        continue;

      sv = newSVpv(value, 0);
      SvREADONLY_on(sv);

      hv_store(strs_by_capname, capname, strlen(capname), sv, 0);
      hv_store(strs_by_varname, varname, strlen(varname), SvREFCNT_inc(sv), 0);
    }

    hv_store(self, "flags_by_capname", 16, newRV_noinc((SV*)flags_by_capname), 0);
    hv_store(self, "nums_by_capname",  15, newRV_noinc((SV*)nums_by_capname),  0);
    hv_store(self, "strs_by_capname",  15, newRV_noinc((SV*)strs_by_capname),  0);

    hv_store(self, "flags_by_varname", 16, newRV_noinc((SV*)flags_by_varname), 0);
    hv_store(self, "nums_by_varname",  15, newRV_noinc((SV*)nums_by_varname),  0);
    hv_store(self, "strs_by_varname",  15, newRV_noinc((SV*)strs_by_varname),  0);

    oldterm = set_curterm(oldterm);
    del_curterm(oldterm);

    XSRETURN_UNDEF;
