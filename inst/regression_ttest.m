## Copyright (C) 1995-2017 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} [@var{pval}, @var{t}, @var{df}] = regression_ttest (@var{y}, @var{x}, @var{rr}, @var{r}, @var{alt})
##
## Perform a linear regression t-test for the null hypothesis
## @nospell{@code{@var{rr} * @var{b} = @var{r}}} in a classical normal
## regression model @code{@var{y} = @var{x} * @var{b} + @var{e}}.
##
## Under the null, the test statistic @var{t} follows a @var{t} distribution
## with @var{df} degrees of freedom.
##
## If @var{r} is omitted, a value of 0 is assumed.
##
## With the optional argument string @var{alt}, the alternative of interest
## can be selected.  If @var{alt} is @qcode{"!="} or @qcode{"<>"}, the null
## is tested against the two-sided alternative @nospell{@code{@var{rr} *
## @var{b} != @var{r}}}.  If @var{alt} is @qcode{">"}, the one-sided
## alternative @nospell{@code{@var{rr} * @var{b} > @var{r}}} is used.
## Similarly for @var{"<"}, the one-sided alternative @nospell{@code{@var{rr}
## * @var{b} < @var{r}}} is used.  The default is the two-sided case.
##
## The p-value of the test is returned in @var{pval}.
##
## If no output argument is given, the p-value of the test is displayed.
## @end deftypefn

function [pval, t, df] = regression_ttest (y, x, rr, r, alt)

  if (nargin == 3)
    r   = 0;
    alt = "!=";
  elseif (nargin == 4)
    if (ischar (r))
      alt = r;
      r   = 0;
    else
      alt = "!=";
    endif
  elseif (! (nargin == 5))
    print_usage ();
  endif

  if (! isscalar (r))
    error ("regression_ttest: R must be a scalar");
  elseif (! ischar (alt))
    error ("regression_ttest: ALT must be a string");
  endif

  [T, k] = size (x);
  if (! (isvector (y) && (length (y) == T)))
    error ("regression_ttest: Y must be a vector of length rows (X)");
  endif
  s = size (rr);
  if (! ((max (s) == k) && (min (s) == 1)))
    error ("regression_ttest: RR must be a vector of length columns (X)");
  endif

  rr     = reshape (rr, 1, k);
  y      = reshape (y, T, 1);
  [b, v] = ols (y, x);
  df     = T - k;
  t      = (rr * b - r) / sqrt (v * rr * inv (x' * x) * rr');
  cdf    = tcdf (t, df);

  if (strcmp (alt, "!=") || strcmp (alt, "<>"))
    pval = 2 * min (cdf, 1 - cdf);
  elseif (strcmp (alt, ">"))
    pval = 1 - cdf;
  elseif (strcmp (alt, "<"))
    pval = cdf;
  else
    error ("regression_ttest: the value '%s' for ALT is not possible", alt);
  endif

  if (nargout == 0)
    printf ("pval: %g\n", pval);
  endif

endfunction