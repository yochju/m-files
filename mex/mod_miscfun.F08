!****h* modules/miscfun
!
! NAME
!
! miscfun: provides miscellaneous useful functions.
!
! AUTHOR
!
! Laurent Hoeltgen <hoeltgen@b-tu.de>
!*****

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

module miscfun
        use :: iso_fortran_env
        implicit none
        save

        integer(INT32), parameter, private :: NPAR = 8  ! Used for allowing parallelisation of certain routines.

        private :: cumsum_i
        private :: cumsum_r
        interface cumsum
                module procedure cumsum_i, cumsum_r
        end interface cumsum

        private :: cumprod_i
        private :: cumprod_r
        interface cumprod
                module procedure cumprod_i, cumprod_r
        end interface cumprod

        private :: outerproduct_i
        private :: outerproduct_r
        interface outerproduct
                module procedure outerproduct_i, outerproduct_r
        end interface outerproduct

        private :: scatter_add_i
        private :: scatter_add_r
        interface scatter_add
                module procedure scatter_add_i, scatter_add_r
        end interface scatter_add

        private :: repelem_i
        interface repelem
                module procedure repelem_i
        end interface repelem

contains

        !! INT32 code !!

        !! Cumulative sum of an array
        pure recursive function cumsum_i (arr) result(ans)

                integer(INT32), dimension(:), intent(in) :: arr

                integer(INT32), dimension(size(arr)) :: ans

                integer(INT32) :: n, j

                n = size(arr)

                ans(1) = arr(1)

                if (n < NPAR) then
                        do j = 2, n
                                ans(j) = ans(j-1) + arr(j)
                        end do
                else
                        ans(2:n:2) = cumsum_i (arr(2:n:2) + arr(1:n-1:2))
                        ans(3:n:2) = ans(2:n-1:2) + arr(3:n:2)
                end if
        end function cumsum_i

        !! Cumulative product of an array
        pure recursive function cumprod_i (arr) result(ans)

                integer(INT32), dimension(:), intent(in) :: arr

                integer(INT32), dimension(size(arr)) :: ans

                integer(INT32) :: n,j

                n = size(arr)

                ans(1) = arr(1)

                if (n < NPAR) then
                        do j = 2, n
                                ans(j) = ans(j-1) * arr(j)
                        end do
                else
                        ans(2:n:2) = cumprod_i (arr(2:n:2) * arr(1:n-1:2))
                        ans(3:n:2) = ans(2:n-1:2) * arr(3:n:2)
                end if
        end function cumprod_i

        !! Outer product
        pure function outerproduct_i (a, b) result(ans)

                integer(INT32), dimension(:), intent(in) :: a
                integer(INT32), dimension(:), intent(in) :: b

                integer(INT32), dimension(size(a),size(b)) :: ans

                ans = spread(a, dim=2, ncopies=size(b)) * spread(b, dim=1, ncopies=size(a))
        end function outerproduct_i

        !! Scatter Add
        pure subroutine scatter_add_i (source, dest_index, dest)

                integer(INT32), dimension(:),            intent(in) :: source
                integer(INT32), dimension(size(source)), intent(in) :: dest_index

                integer(INT32), dimension(:), intent(out) :: dest

                integer(INT32) :: m, n, j, i

                n=size(source)
                m=size(dest)
                do j=1, n
                        i=dest_index(j)
                        if (i > 0 .and. i <= m) dest(i) = dest(i) + source(j)
                end do
        end subroutine scatter_add_i

        pure function repelem_i (src, ncop) result(dest)
                implicit none

                integer(INT32), dimension(:), intent(in) :: src
                integer(INT32),               intent(in) :: ncop

                integer(INT32), dimension(ncop*size(src)) :: dest

                dest = reshape(spread(src, 1, ncop), [ncop*size(src)])

        end function repelem_i

        !! REAL64 code

        !! Cumulative sum of an array
        pure recursive function cumsum_r (arr) result(ans)

                real(REAL64), dimension(:), intent(in) :: arr

                real(REAL64), dimension(size(arr)) :: ans

                integer(INT32) :: n, j

                n = size(arr)

                ans(1) = arr(1)

                if (n < NPAR) then
                        do j = 2, n
                                ans(j) = ans(j-1) + arr(j)
                        end do
                else
                        ans(2:n:2) = cumsum_r (arr(2:n:2) + arr(1:n-1:2))
                        ans(3:n:2) = ans(2:n-1:2) + arr(3:n:2)
                end if
        end function cumsum_r

        !! Cumulative product of an array
        pure recursive function cumprod_r (arr) result(ans)

                real(REAL64), dimension(:), intent(in) :: arr

                real(REAL64), dimension(size(arr)) :: ans

                integer(INT32) :: n, j

                n = size(arr)

                ans(1) = arr(1)

                if (n < NPAR) then
                        do j = 2, n
                                ans(j) = ans(j-1) * arr(j)
                        end do
                else
                        ans(2:n:2) = cumprod_r (arr(2:n:2) * arr(1:n-1:2))
                        ans(3:n:2) = ans(2:n-1:2) * arr(3:n:2)
                end if
        end function cumprod_r

        !! Outer product
        pure function outerproduct_r (a, b) result(ans)

                real(REAL64), dimension(:), intent(in) :: a
                real(REAL64), dimension(:), intent(in) :: b

                real(REAL64), dimension(size(a),size(b)) :: ans

                ans = spread(a, dim=2, ncopies=size(b)) * spread(b, dim=1, ncopies=size(a))
        end function outerproduct_r

        !! Scatter Add
        pure subroutine scatter_add_r(source, dest_index, dest)

                real(REAL64),   dimension(:),            intent(in) :: source
                integer(INT32), dimension(size(source)), intent(in) :: dest_index

                real(REAL64), dimension(:), intent(out) :: dest

                integer(INT32) :: m, n, j, i

                n=size(source)
                m=size(dest)
                do j=1, n
                        i=dest_index(j)
                        if (i > 0 .and. i <= m) dest(i) = dest(i) + source(j)
                end do
        end subroutine scatter_add_r
end
