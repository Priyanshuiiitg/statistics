## Copyright (C) 2018 John Donoghue
## Copyright (C) 2016 Dag Lyberg
## Copyright (C) 1995-2015 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{r} =} bbsrnd (@var{shape}, @var{scale}, @var{location})
## @deftypefnx {statistics} {@var{r} =} bbsrnd (@var{shape}, @var{scale}, @var{location}, @var{rows})
## @deftypefnx {statistics} {@var{r} =} bbsrnd (@var{shape}, @var{scale}, @var{location}, @var{rows}, @var{cols}, @dots{})
## @deftypefnx {statistics} {@var{r} =} bbsrnd (@var{shape}, @var{scale}, @var{location}, [@var{sz}])
##
## Random arrays from the Birnbaum-Saunders distribution.
##
## @code{@var{r} = bbsrnd (@var{shape}, @var{scale}, @var{location})} returns an
## array of random numbers chosen from the Birnbaum-Saunders distribution with
## parameters @var{shape}, @var{scale}, and @var{location}.  The size of @var{r}
## is the common size of @var{shape}, @var{scale}, and @var{location}.  A scalar
## input functions as a constant matrix of the same size as the other inputs.
##
## When called with a single size argument, return a square matrix with
## the dimension specified.  When called with more than one scalar argument the
## first two arguments are taken as the number of rows and columns and any
## further arguments specify additional matrix dimensions.  The size may also
## be specified with a vector of dimensions @var{sz}.
##
## @seealso{bbscdf, bbsinv, bbspdf}
## @end deftypefn

function r = bbsrnd (shape, scale, location, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  if (! isscalar (shape) || ! isscalar (scale) || ! isscalar (location))
    [retval, shape, scale, location] = common_size (shape, scale, location);
    if (retval > 0)
      error (strcat (["bbsrnd: SHAPE, SCALE, and LOCATION must be of"], ...
                     [" common size or scalars."]));
    endif
  endif

  if (iscomplex (shape) || iscomplex (scale) || iscomplex (location))
    error ("bbsrnd: SHAPE, SCALE, and LOCATION must not be complex.");
  endif

  if (nargin == 3)
    sz = size (location);
  elseif (nargin == 4)
    if (isscalar (varargin{1}) && varargin{1} >= 0)
      sz = [varargin{1}, varargin{1}];
    elseif (isrow (varargin{1}) && all (varargin{1} >= 0))
      sz = varargin{1};
    else
      error (strcat (["bbsrnd: dimension vector must be row vector of"], ...
                     [" non-negative integers."]));
    endif
  elseif (nargin > 3)
    if (any (cellfun (@(x) (! isscalar (x) || x < 0), varargin)))
      error ("bbsrnd: dimensions must be non-negative integers.");
    endif
    sz = [varargin{:}];
  endif

  if (! isscalar (location) && ! isequal (size (location), sz))
    error ("bbsrnd: SHAPE, SCALE, and LOCATION must be scalar or of size SZ.");
  endif

  if (isa (location, "single") || isa (scale, "single") ...
                               || isa (shape, "single"))
    cls = "single";
  else
    cls = "double";
  endif

  if (isscalar (shape) && isscalar (scale) && isscalar (location))
    if ((-Inf < location) && (location < Inf) ...
        && (0 < scale) && (scale < Inf) ...
        && (0 < shape) && (shape < Inf))
      r = rand (sz, cls);
      y = shape * norminv (r);
      r = location + scale * (y + sqrt (4 + y.^2)).^2 / 4;
    else
      r = NaN (sz, cls);
    endif
  else
    r = NaN (sz, cls);

    k = (-Inf < location) & (location < Inf) ...
        & (0 < scale) & (scale < Inf) ...
        & (0 < shape) & (shape < Inf);
    r(k) = rand (sum (k(:)),1);
    y = shape(k) .* norminv (r(k));
    r(k) = location(k) + scale(k) .* (y + sqrt (4 + y.^2)).^2 / 4;
  endif
endfunction

## Test results
%!assert (size (bbsrnd (1, 1, 0)), [1 1])
%!assert (size (bbsrnd (1, 1, zeros (2,1))), [2, 1])
%!assert (size (bbsrnd (1, 1, zeros (2,2))), [2, 2])
%!assert (size (bbsrnd (1, ones (2,1), 0)), [2, 1])
%!assert (size (bbsrnd (1, ones (2,2), 0)), [2, 2])
%!assert (size (bbsrnd (ones (2,1), 1, 0)), [2, 1])
%!assert (size (bbsrnd (ones (2,2), 1, 0)), [2, 2])
%!assert (size (bbsrnd (1, 1, 0, 3)), [3, 3])
%!assert (size (bbsrnd (1, 1, 0, [4 1])), [4, 1])
%!assert (size (bbsrnd (1, 1, 0, 4, 1)), [4, 1])

## Test class of input preserved
%!assert (class (bbsrnd (1,1,0)), "double")
%!assert (class (bbsrnd (1, 1, single (0))), "single")
%!assert (class (bbsrnd (1, 1, single ([0 0]))), "single")
%!assert (class (bbsrnd (1, single (1), 0)), "single")
%!assert (class (bbsrnd (1, single ([1 1]), 0)), "single")
%!assert (class (bbsrnd (single (1), 1, 0)), "single")
%!assert (class (bbsrnd (single ([1 1]), 1, 0)), "single")

## Test input validation
%!error bbsrnd ()
%!error bbsrnd (1)
%!error bbsrnd (1,2)
%!error bbsrnd (ones (3), ones (2), ones (2), 2)
%!error bbsrnd (ones (2), ones (3), ones (2), 2)
%!error bbsrnd (ones (2), ones (2), ones (3), 2)
%!error bbsrnd (i, 2, 3)
%!error bbsrnd (1, i, 3)
%!error bbsrnd (1, 2, i)
%!error bbsrnd (1,2,3, -1)
%!error bbsrnd (1,2,3, ones (2))
%!error bbsrnd (1,2,3, [2 -1 2])
%!error bbsrnd (2, 1, ones (2), 3)
%!error bbsrnd (2, 1, ones (2), [3, 2])
%!error bbsrnd (2, 1, ones (2), 3, 2)

