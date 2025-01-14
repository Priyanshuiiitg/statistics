## Copyright (C) 2012 Rik Wehbring
## Copyright (C) 1995-2016 Kurt Hornik
## Copyright (C) 2022-2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
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
## @deftypefn  {statistics} {@var{x} =} gaminv (@var{p}, @var{a}, @var{b})
##
## Inverse of the Gamma cumulative distribution function (iCDF).
##
## For each element of @var{p}, compute the quantile (the inverse of the CDF)
## at @var{p} of the Gamma distribution with shape parameter @var{a} and
## scale @var{b}.  The size of @var{x} is the common size of @var{p}, @var{a},
## and @var{b}.  A scalar input functions as a constant matrix of the same size
## as the other inputs.
##
## @seealso{gamcdf, gampdf, gamrnd, gamfit, gamlike, gamstat}
## @end deftypefn

function x = gaminv (p, a, b)

  if (nargin != 3)
    print_usage ();
  endif

  if (! isscalar (a) || ! isscalar (b))
    [retval, p, a, b] = common_size (p, a, b);
    if (retval > 0)
      error ("gaminv: P, A, and B must be of common size or scalars.");
    endif
  endif

  if (iscomplex (p) || iscomplex (a) || iscomplex (b))
    error ("gaminv: P, A, and B must not be complex.");
  endif

  if (isa (p, "single") || isa (a, "single") || isa (b, "single"))
    x = zeros (size (p), "single");
  else
    x = zeros (size (p));
  endif

  k = ((p < 0) | (p > 1) | isnan (p) ...
       | !(a > 0) | !(a < Inf) | !(b > 0) | !(b < Inf));
  x(k) = NaN;

  k = (p == 1) & (a > 0) & (a < Inf) & (b > 0) & (b < Inf);
  x(k) = Inf;

  k = find ((p > 0) & (p < 1) & (a > 0) & (a < Inf) & (b > 0) & (b < Inf));
  if (! isempty (k))
    if (! isscalar (a) || ! isscalar (b))
      a = a(k);
      b = b(k);
      y = a .* b;
    else
      y = a * b * ones (size (k));
    endif
    p = p(k);

    ## Call GAMMAINCINV to find a root of GAMMAINC
    q = gammaincinv (p, a);
    tol = sqrt (eps (ones (1, 1, class(q))));
    check_cdf = ((abs (gammainc (q, a) - p) ./ p) > tol);
    ## Check for any cdf being far off from tolerance
    if (any (check_cdf(:)))
      warning ("gaminv: calculation failed to converge for some values.");
    endif
    x(k) = q .* b;
  endif
endfunction

%!shared p
%! p = [-1 0 0.63212055882855778 1 2];
%!assert (gaminv (p, ones (1,5), ones (1,5)), [NaN 0 1 Inf NaN], eps)
%!assert (gaminv (p, 1, ones (1,5)), [NaN 0 1 Inf NaN], eps)
%!assert (gaminv (p, ones (1,5), 1), [NaN 0 1 Inf NaN], eps)
%!assert (gaminv (p, [1 -Inf NaN Inf 1], 1), [NaN NaN NaN NaN NaN])
%!assert (gaminv (p, 1, [1 -Inf NaN Inf 1]), [NaN NaN NaN NaN NaN])
%!assert (gaminv ([p(1:2) NaN p(4:5)], 1, 1), [NaN 0 NaN Inf NaN])
%!assert (gaminv ([p(1:2) NaN p(4:5)], 1, 1), [NaN 0 NaN Inf NaN])

## Test for accuracy when p is small. Results compared to Matlab
%!assert (gaminv (1e-16, 1, 1), 1e-16, eps)
%!assert (gaminv (1e-16, 1, 2), 2e-16, eps)
%!assert (gaminv (1e-20, 3, 5), 1.957434012161815e-06, eps)
%!assert (gaminv (1e-15, 1, 1), 1e-15, eps)
%!assert (gaminv (1e-35, 1, 1), 1e-35, eps)

## Test class of input preserved
%!assert (gaminv ([p, NaN], 1, 1), [NaN 0 1 Inf NaN NaN], eps)
%!assert (gaminv (single ([p, NaN]), 1, 1), single ([NaN 0 1 Inf NaN NaN]), ...
%! eps ("single"))
%!assert (gaminv ([p, NaN], single (1), 1), single ([NaN 0 1 Inf NaN NaN]), ...
%! eps ("single"))
%!assert (gaminv ([p, NaN], 1, single (1)), single ([NaN 0 1 Inf NaN NaN]), ...
%! eps ("single"))

## Test input validation
%!error gaminv ()
%!error gaminv (1)
%!error gaminv (1,2)
%!error gaminv (1,2,3,4)
%!error gaminv (ones (3), ones (2), ones (2))
%!error gaminv (ones (2), ones (3), ones (2))
%!error gaminv (ones (2), ones (2), ones (3))
%!error gaminv (i, 2, 2)
%!error gaminv (2, i, 2)
%!error gaminv (2, 2, i)
