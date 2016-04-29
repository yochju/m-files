! Copyright (C) 2015 Laurent Hoeltgen <hoeltgen@b-tu.de>
!
! This program is free software: you can redistribute it and/or modify it under
! the terms of the GNU General Public License as published by the Free Software
! Foundation, either version 3 of the License, or (at your option) any later
! version.
!
! This program is distributed in the hope that it will be useful, but WITHOUT
! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
! FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along with
! this program. If not, see <http://www.gnu.org/licenses/>.
!

module colours
      use iso_fortran_env
      implicit none
      private

      public :: rgb2ycbcr
      
      public :: ycbcr2rgb

contains

      !! Requires data in the range [0, 255]
      !! Source: http://www.equasys.de/colorconversion.html
      pure subroutine rgb2ycbcr(nr, nc, r, g, b, y, cb, cr)
            implicit none

            integer(INT32), intent(in)                   :: nr
            integer(INT32), intent(in)                   :: nc
            real(REAL64), intent(in),  dimension(nr,nc) :: r
            real(REAL64), intent(in),  dimension(nr,nc) :: g
            real(REAL64), intent(in),  dimension(nr,nc) :: b
            real(REAL64), intent(out), dimension(nr,nc) :: y
            real(REAL64), intent(out), dimension(nr,nc) :: cb
            real(REAL64), intent(out), dimension(nr,nc) :: cr

            y  =   0.0D0 + 0.299D0*r + 0.587D0*g + 0.114D0*b
            cb = 128.0D0 - 0.169D0*r - 0.331D0*g + 0.500D0*b
            cr = 128.0D0 + 0.500D0*r - 0.419D0*g - 0.081D0*b
      end subroutine rgb2ycbcr

      !! Requires data in the range [0, 255].
      !! Source: http://www.equasys.de/colorconversion.html
      pure subroutine ycbcr2rgb(nr, nc, r, g, b, y, cb, cr)
            implicit none

            integer(INT32), intent(in)                   :: nr
            integer(INT32), intent(in)                   :: nc
            real(REAL64), intent(out), dimension(nr,nc) :: r
            real(REAL64), intent(out), dimension(nr,nc) :: g
            real(REAL64), intent(out), dimension(nr,nc) :: b
            real(REAL64), intent(in),  dimension(nr,nc) :: y
            real(REAL64), intent(in),  dimension(nr,nc) :: cb
            real(REAL64), intent(in),  dimension(nr,nc) :: cr

            r = 1.0D0 * y + 0.000D0 * (cb - 128.0D0) + 1.400D0 * (cr - 128.0D0)
            g = 1.0D0 * y - 0.343D0 * (cb - 128.0D0) - 0.711D0 * (cr - 128.0D0)
            b = 1.0D0 * y + 1.765D0 * (cb - 128.0D0) + 0.000D0 * (cr - 128.0D0)
      end subroutine ycbcr2rgb


end module
