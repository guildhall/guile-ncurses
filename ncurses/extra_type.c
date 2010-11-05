/*
  extra_type.c

  Copyright 2009, 2010 Free Software Foundation, Inc.

  This file is part of GNU Guile-Ncurses.

  Guile-Ncurses is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  Guile-Ncurses is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with Guile-Ncurses.  If not, see
  <http://www.gnu.org/licenses/>.
*/
#include <config.h>

#define _GNU_SOURCE
#include <assert.h>
#include <libguile.h>
#include <termios.h>
#include <libintl.h>

#include "compat.h"
#include "extra_type.h"

scm_t_bits termios_tag;

SCM equalp_termios (SCM x1, SCM x2);
size_t gc_free_termios (SCM x);
SCM mark_termios (SCM x);
int print_termios (SCM x, SCM port, scm_print_state * pstate);


/* termios -- in C, a TERMIOS.  In Scheme, a smob that contains the pointer */

int
_scm_is_termios (SCM x)
{
  if (SCM_SMOB_PREDICATE (termios_tag, x))
    {
      if (SCM_SMOB_DATA (x) == 0)
	return 0;
      else
	return 1;
    }
  else
    return 0;
}

struct termios *
_scm_to_termios (SCM x)
{
  struct termios *gp;

  scm_assert_smob_type (termios_tag, x);

  gp = (struct termios *) SCM_SMOB_DATA (x);

  return gp;
}

SCM
_scm_from_termios (struct termios *x)
{
  SCM s_termios;

  assert (x != NULL);

  SCM_NEWSMOB (s_termios, termios_tag, x);

  assert (x == (struct termios *) SCM_SMOB_DATA (s_termios));

#if 0
  if (0)
    {
      fprintf (stderr, gettext ("Making smob from termios based on *%p\n"),
	       x);
    }
#endif

  return (s_termios);
}

// Termioss are equal if they point to the same C structure
SCM
equalp_termios (SCM x1, SCM x2)
{
  struct termios *termios1 = _scm_to_termios (x1);
  struct termios *termios2 = _scm_to_termios (x2);

  if ((termios1 == NULL) || (termios2 == NULL))
    return SCM_BOOL_F;
  else if ((termios1 != termios2))
    return SCM_BOOL_F;
  else
    return SCM_BOOL_T;
}

SCM
mark_termios (SCM x)
{
  // No SCMs in the window type: nothing to do here.
  return (SCM_BOOL_F);
}

size_t
gc_free_termios (SCM x)
{
  struct termios *gp;
  int retval;

  scm_assert_smob_type (termios_tag, x);

  gp = (struct termios *) SCM_SMOB_DATA (x);

  assert (gp != NULL);
  if (1)
    {
      fprintf (stderr, "Freeing termios at %p\n", gp);
      fprintf (stderr, "Flags: I %u O %u C %u L %u\n", gp->c_iflag,
               gp->c_oflag, gp->c_cflag, gp->c_lflag);
      fprintf (stderr, "Speed: O %u I %u\n", cfgetospeed(gp),
               cfgetispeed(gp));
      fflush (stderr);
      sleep (1);
    }

  scm_gc_free (gp, sizeof (struct termios), "termios");

  SCM_SET_SMOB_DATA (x, NULL);

  return 0;
}

int
print_termios (SCM x, SCM port, scm_print_state * pstate UNUSED)
{
  struct termios *pnl = _scm_to_termios (x);
  char *str;

  scm_puts ("#<termios ", port);

  if (pnl == NULL)
    scm_puts ( gettext ("(freed)"), port);
  else
    {
      if (asprintf (&str, "%p", (void *) pnl) < 0)
	scm_puts ("???", port);
      else
	scm_puts (str, port);
    }

  scm_puts (">", port);

  // non-zero means success
  return 1;
}

SCM
gucu_is_termios_p (SCM x)
{
  return scm_from_bool (_scm_is_termios (x));
}


SCM
gucu_new_termios (void)
{
  struct termios *gp;
  SCM smob;

  /* Step 1: Allocate memory */
  gp = scm_gc_malloc (sizeof (struct termios), "termios");

  /* Step 2: initialize it with C code */
  memset (gp, 0, sizeof(struct termios));

  /* Step 3: create the smob */
  SCM_NEWSMOB (smob, termios_tag, gp);

  /* Step 4: finish the initialization */
  return smob;
}


void
gucu_extra_init_type ()
{
  termios_tag = scm_make_smob_type ("termios", sizeof (struct termios *));
  scm_set_smob_mark (termios_tag, mark_termios);
  scm_set_smob_free (termios_tag, gc_free_termios);
  scm_set_smob_print (termios_tag, print_termios);
  scm_set_smob_equalp (termios_tag, equalp_termios);
  scm_c_define_gsubr ("termios?", 1, 0, 0, gucu_is_termios_p);

  scm_c_define_gsubr ("new-termios", 0, 0, 0, gucu_new_termios);
}
