## Copyright (C) 2013-2019 Fernando Damian Nieuwveldt <fdnieuwveldt@gmail.com>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{COEFF} =} pcacov(@var{X})
## @deftypefnx {statistics} {[@var{COEFF}, @var{latent}] =} pcacov(@var{X})
## @deftypefnx {statistics} {[@var{COEFF}, @var{latent}, @var{explained}] =} pcacov(@var{X})
##
## Perform principal component analysis on the NxN covariance matrix X.
##
## @itemize @bullet
## @item
## @var{COEFF} : a NxN matrix with columns containing the principal component coefficients
## @item
## @var{latent} : a vector containing the principal component variances
## @item
## @var{explained} : a vector containing the percentage of the total variance explained by each principal component
##
## @end itemize
##
## @subheading References
##
## @enumerate
## @item
## Jolliffe, I. T., Principal Component Analysis, 2nd Edition, Springer, 2002
##
## @end enumerate
## @end deftypefn

function [COEFF, latent, explained] = pcacov(X)

  [U,S,V] = svd(X);

  if nargout == 1
    COEFF     = U;
  elseif nargout == 2
    COEFF     = U;
    latent    = diag(S);
  else
    COEFF     = U;
    latent    = diag(S);
    explained = 100*latent./sum(latent);
  end
endfunction

%!demo
%! X = [ 7    26     6    60;
%!       1    29    15    52;
%!      11    56     8    20;
%!      11    31     8    47;
%!       7    52     6    33;
%!      11    55     9    22;
%!       3    71    17     6;
%!       1    31    22    44;
%!       2    54    18    22;
%!      21    47     4    26;
%!       1    40    23    34;
%!      11    66     9    12;
%!      10    68     8    12
%!     ];
%! covx = cov(X);
%! [COEFF,latent,explained] = pcacov(covx)

