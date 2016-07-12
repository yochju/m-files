!! mod_array_ops.F08
!! Provides helper functions for manipulating arrays.
!
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

module array_ops
        use :: iso_fortran_env
        implicit none

!        private :: dnrmf
!        private :: fnrmf
!
!        interface nrmf
!                module procedure dnrmf
!                module procedure fnrmf
!        end interface nrmf
!
!        private :: dnrmf2
!        private :: fnrmf2
!
!        interface nrmf2
!                module procedure dnrmf2
!                module procedure fnrmf2
!        end interface nrmf2
!
!        private :: dvec
!        private :: fvec
!
!        interface vec
!                module procedure dvec
!                module procedure fvec
!        end interface vec
!
!        private :: normalise1d
!        private :: normalise1f
!        private :: normalise2d
!        private :: normalise2f
!
!        interface normalise
!                module procedure normalise1d
!                module procedure normalise1f
!                module procedure normalise2d
!                module procedure normalise2f
!        end interface normalise
!
!        private :: relativeDistance1
!        private :: relativeDistance2
!
!        interface relativeDistance
!                module procedure relativeDistance1
!                module procedure relativeDistance2
!        end interface relativeDistance
!
!        private :: absoluteDistance1
!        private :: absoluteDistance2
!
!        interface absoluteDistance
!                module procedure absoluteDistance1
!                module procedure absoluteDistance2
!        end interface absoluteDistance
!
!        private :: normalfactorisation1
!        private :: normalfactorisation2
!
!        interface normalfactorisation
!                module procedure normalfactorisation1
!                module procedure normalfactorisation2
!        end interface normalfactorisation
!
!        interface
!                pure function ddot(n, x, incx, y, incy)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)             :: n
!                        real(REAL64), dimension(n), intent(in) :: x
!                        integer, intent(in)                          :: incx
!                        real(REAL64), dimension(n), intent(in) :: y
!                        integer, intent(in)                          :: incy
!
!                        real(REAL64)                          :: ddot
!                end function ddot
!
!                pure function snrm2(n, x, incx)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)             :: n
!                        real(REAL32), dimension(n), intent(in) :: x
!                        integer, intent(in)                          :: incx
!
!                        real(REAL32)                           :: snrm2
!                end function snrm2
!
!                pure function dnrm2(n, x, incx)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)              :: n
!                        real(REAL64), dimension(n), intent(in) :: x
!                        integer, intent(in)                           :: incx
!
!                        real(REAL64)                           :: dnrm2
!                end function dnrm2
!
!                pure subroutine dcopy(n, x, incx, y, incy)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)               :: n
!                        real(REAL64), dimension(n), intent(in)  :: x
!                        integer, intent(in)                            :: incx
!                        real(REAL64), dimension(n), intent(out) :: y
!                        integer, intent(in)                            :: incy
!                end subroutine dcopy
!
!                pure subroutine scopy(n, x, incx, y, incy)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)               :: n
!                        real(REAL32), dimension(n), intent(in)  :: x
!                        integer, intent(in)                            :: incx
!                        real(REAL32), dimension(n), intent(out) :: y
!                        integer, intent(in)                            :: incy
!                end subroutine scopy
!
!                pure subroutine dscal(n, alpha, x, incx)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)                 :: n
!                        real(REAL64),               intent(in)    :: alpha
!                        real(REAL64), dimension(n), intent(inout) :: x
!                        integer, intent(in)                              :: incx
!                end subroutine dscal
!
!                pure subroutine sscal(n, alpha, x, incx)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)                 :: n
!                        real(REAL32),               intent(in)    :: alpha
!                        real(REAL32), dimension(n), intent(inout) :: x
!                        integer, intent(in)                              :: incx
!                end subroutine sscal
!
!                pure subroutine daxpy(n, alpha, x, incx, y, incy)
!                        use :: iso_fortran_env
!                        implicit none
!                        integer(INT32), intent(in)                 :: n
!                        real(REAL64),               intent(in)    :: alpha
!                        real(REAL64), dimension(n), intent(in)    :: x
!                        integer, intent(in)                              :: incx
!                        real(REAL64), dimension(n), intent(inout) :: y
!                        integer, intent(in)                              :: incy
!                end subroutine daxpy
!        end interface

contains

        pure elemental function softshrinkage (x, lambda) result(y)
                implicit none

                real(REAL64), intent(in) :: x
                real(REAL64), intent(in) :: lambda

                real(REAL64)             :: y

                y = sign(dim(abs(x), abs(lambda)), x)
        end function softshrinkage

        pure elemental function huberloss (x, lambda) result(y)
                implicit none

                real(REAL64), intent(in) :: x
                real(REAL64), intent(in) :: lambda

                real(REAL64)             :: y
!
                if (abs(x)<=abs(lambda)) then
                        y = 0.50d0*x**2
                else
                        y = abs(lambda)*(abs(x)-0.50d0*abs(lambda))
                end if
        end function huberloss

        pure elemental function chop (x, min_val, max_val) result(y)
                implicit none

                real(REAL64),  intent(in) :: x
                real(REAL64),  intent(in) :: min_val
                real(REAL64),  intent(in) :: max_val

                real(REAL64) :: y

                y = min ( max (x, min_val), max_val)
        end function chop

        pure elemental function binarise (x, t) result(y)
                implicit none

                real(REAL64),  intent(in) :: x
                real(REAL64),  intent(in) :: t

                real(REAL64) :: y

                y = (sign(1.0D0, x-t) + 1.0D0)/2.0D0
        end function binarise
!
!        pure function dnrmf(x) result(y)
!                use :: iso_c_binding
!                implicit none
!
!                real(REAL64), dimension(:,:), intent(in) :: x
!                real(REAL64)                             :: y
!
!                y = dnrm2(int(size(x), INT32), reshape(x, [size(x)]), 1)
!        end function dnrmf
!
!        pure function d2nrmf(nr, nc, x) result(y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                   intent(in) :: nr
!                integer(INT32),                   intent(in) :: nc
!                real(REAL64),  dimension(nr*nc), intent(in) :: x
!                real(REAL64)                                :: y
!
!                y = dnrm2(nr*nc, reshape(x, [nr*nc]), 1)
!        end function d2nrmf
!
!        pure function fnrmf(x) result(y)
!                use :: iso_c_binding
!                implicit none
!
!                real(REAL32), dimension(:,:), intent(in) :: x
!                real(REAL32)                             :: y
!
!                y = snrm2(int(size(x), INT32), reshape(x, [size(x)]), 1)
!        end function fnrmf
!
!        pure function dnrmf2(x) result(y)
!                use :: iso_c_binding
!                implicit none
!
!                real(REAL64), dimension(:,:), intent(in) :: x
!                real(REAL64)                             :: y
!
!                y = dnrm2(int(size(x), INT32), reshape(x, [size(x)]), 1)**2
!        end function dnrmf2
!
!        pure function fnrmf2(x) result(y)
!                use :: iso_c_binding
!                implicit none
!
!                real(REAL32), dimension(:,:), intent(in) :: x
!                real(REAL32)                             :: y
!
!                y = snrm2(int(size(x), INT32), reshape(x, [size(x)]), 1)**2
!        end function fnrmf2
!
!        pure subroutine daxpby1(n, x, y, a, b) ! y = a*x + b*y
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                   intent(in)   :: n
!                real(REAL64), intent(in),    dimension(n) :: x
!                real(REAL64), intent(inout), dimension(n) :: y
!                real(REAL64), intent(in)                      :: a
!                real(REAL64), intent(in)                      :: b
!
!                call dscal(n, b, y, 1)                         ! tmp = b*tmp = b*y
!                call daxpy(n, a, x, 1, y, 1) ! tmp = a*x + tmp = a*x + b*y
!
!        end subroutine daxpby1
!
!        pure subroutine daxpby2(nr, nc, x, y, a, b) ! y = a*x + b*y
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                   intent(in)   :: nr
!                integer(INT32),                   intent(in)   :: nc
!                real(REAL64), intent(in),    dimension(nr,nc) :: x
!                real(REAL64), intent(inout), dimension(nr,nc) :: y
!                real(REAL64), intent(in)                      :: a
!                real(REAL64), intent(in)                      :: b
!
!                real(REAL64), dimension(:), allocatable       :: tmp
!
!                allocate(tmp(nr*nc))
!
!                call dcopy(nr*nc, reshape(y, [nr*nc]), 1, tmp, 1)    ! tmp = y
!                call dscal(nr*nc, b, tmp, 1)                         ! tmp = b*tmp = b*y
!                call daxpy(nr*nc, a, reshape(x, [nr*nc]), 1, tmp, 1) ! tmp = a*x + tmp = a*x + b*y
!                y = reshape(tmp, [nr, nc])
!
!                deallocate(tmp)
!        end subroutine daxpby2
!
!        pure subroutine scal2(nr, nc, x, a)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                   intent(in)   :: nr
!                integer(INT32),                   intent(in)   :: nc
!                real(REAL64), intent(inout), dimension(nr,nc) :: x
!                real(REAL64), intent(in)                      :: a
!                real(REAL64), dimension(:), allocatable       :: tmp
!
!                allocate(tmp(nr*nc))
!
!                call dcopy(nr*nc, reshape(x, [nr*nc]), 1, tmp, 1)   ! tmp = x
!                call dscal(nr*nc, a, tmp, 1)                        ! tmp = a*tmp = a*x
!                x = reshape(tmp, [nr, nc])
!
!                deallocate(tmp)
!        end subroutine scal2
!
!        pure subroutine dvec(nr, nc, x, order, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                  intent(in)  :: nr
!                integer(INT32),                  intent(in)  :: nc
!                real(REAL64), dimension(nr,nc), intent(in)  :: x
!                logical,                               intent(in)  :: order
!                real(REAL64), dimension(nr*nc), intent(out) :: y
!
!                if (order) then
!                        y = reshape(x, [nr*nc])
!                else
!                        y = reshape(transpose(x), [nr*nc])
!                end if
!        end subroutine dvec
!
!        pure subroutine fvec(nr, nc, x, order, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32),                  intent(in)  :: nr
!                integer(INT32),                  intent(in)  :: nc
!                real(REAL32), dimension(nr,nc), intent(in)  :: x
!                logical,                             intent(in)  :: order
!                real(REAL32), dimension(nr*nc),   intent(out) :: y
!
!                if (order) then
!                        y = reshape(x, [nr*nc])
!                else
!                        y = reshape(transpose(x), [nr*nc])
!                end if
!        end subroutine fvec
!
!        pure subroutine normalise1d(n, x, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32), intent(in)               :: n
!                real(REAL64),  intent(in), dimension(n) :: x
!
!                real(REAL64), intent(out), dimension(n) :: y
!
!                call dcopy(n, x, 1, y, 1)
!                if (dnrm2(n, x, 1) > epsilon(1.0)) then
!                        call dscal(n, 1.0D0/dnrm2(n, x, 1), y, 1)
!                end if
!        end subroutine normalise1d
!
!        pure subroutine normalise1f(n, x, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32), intent(in)              :: n
!                real(REAL32),  intent(in), dimension(n) :: x
!
!                real(REAL32), intent(out), dimension(n) :: y
!
!                call scopy(n, x, 1, y, 1)
!                call sscal(n, 1.0/snrm2(n, x, 1), y, 1)
!        end subroutine normalise1f
!
!        pure subroutine normalise2d(nr, nc, x, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32), intent(in)                   :: nr, nc
!                real(REAL64),  intent(in), dimension(nr,nc) :: x
!
!                real(REAL64), intent(out), dimension(nr,nc) :: y
!                real(REAL64),              dimension(nr*nc) :: tmp
!
!                tmp = reshape(x, [nr*nc])
!                call dscal(nr*nc, 1.0D0/dnrm2(nr*nc, tmp, 1), tmp, 1)
!                y = reshape(tmp, [nr, nc])
!        end subroutine normalise2d
!
!        pure subroutine normalise2f(nr, nc, x, y)
!                use :: iso_c_binding
!                implicit none
!
!                integer(INT32), intent(in)                  :: nr, nc
!                real(REAL32),  intent(in), dimension(nr,nc) :: x
!
!                real(REAL32), intent(out), dimension(nr,nc) :: y
!                real(REAL32),              dimension(nr*nc) :: tmp
!
!                tmp = reshape(x, [nr*nc])
!                call sscal(nr*nc, 1.0/snrm2(nr*nc, tmp, 1), tmp, 1)
!                y = reshape(tmp, [nr, nc])
!        end subroutine normalise2f
!
!        pure function relativeDistance1(n, x, y) result(z)
!                implicit none
!
!                integer(INT32), intent(in) :: n
!                real(REAL64), intent(in), dimension(n) :: x
!                real(REAL64), intent(in), dimension(n) :: y
!                real(REAL64) :: z
!
!                real(REAL64), dimension(:), allocatable :: tmp
!
!                if (dnrm2(n, y, 1) > 100.0D0*epsilon(1.0D0)) then
!                        allocate(tmp(n))
!                        call dcopy(n, y, 1, tmp, 1) ! tmp = y
!                        call daxpy(n, -1.0D0, x, 1, tmp, 1) ! tmp = -1.0D0*x + tmp = y - x
!                        z = dnrm2(n, tmp, 1)/dnrm2(n, y, 1) ! z = ||y-x||/||y||
!                        deallocate(tmp)
!                else
!                        z = dnrm2(n, x, 1) ! z = ||x-y||
!                end if
!        end function relativeDistance1
!
!        pure function relativeDistance2(nr, nc, x, y) result(z)
!
!                implicit none
!
!                integer(INT32), intent(in) :: nr
!                integer(INT32), intent(in) :: nc
!                real(REAL64), intent(in), dimension(nr,nc) :: x
!                real(REAL64), intent(in), dimension(nr,nc) :: y
!                real(REAL64) :: z
!
!                real(REAL64), dimension(:), allocatable :: tmp
!
!                if (dnrm2(nr*nc, reshape(y,[nr*nc]), 1) > 100.0D0*epsilon(1.0D0)) then
!                        allocate(tmp(nr*nc))
!                        call dcopy(nr*nc, reshape(y,[nr*nc]), 1, tmp, 1) ! tmp = y
!                        call daxpy(nr*nc, -1.0D0, reshape(x, [nr*nc]), 1, tmp, 1) ! tmp = -1.0D0*x + tmp = y - x
!                        z = dnrm2(nr*nc, tmp, 1)/dnrm2(nr*nc, reshape(y,[nr*nc]), 1) ! z = ||y-x||/||y||
!                        deallocate(tmp)
!                else
!                        z = dnrm2(nr*nc, reshape(x,[nr*nc]), 1) ! z = ||x-y||
!                end if
!        end function relativeDistance2
!
!        pure function absoluteDistance1(n, x, y) result(z)
!
!                implicit none
!
!                integer(INT32), intent(in) :: n
!                real(REAL64), intent(in), dimension(n) :: x
!                real(REAL64), intent(in), dimension(n) :: y
!                real(REAL64) :: z
!
!                real(REAL64), dimension(:), allocatable :: tmp
!
!                allocate(tmp(n))
!                call dcopy(n, y, 1, tmp, 1) ! tmp = y
!                call daxpy(n, -1.0D0, x, 1, tmp, 1) ! tmp = -1.0D0*x + tmp = y - x
!                z = dnrm2(n, tmp, 1) ! z = ||y-x||
!                deallocate(tmp)
!
!        end function absoluteDistance1
!
!        pure function absoluteDistance2(nr, nc, x, y) result(z)
!
!                implicit none
!
!                integer(INT32), intent(in) :: nr
!                integer(INT32), intent(in) :: nc
!                real(REAL64), intent(in), dimension(nr,nc) :: x
!                real(REAL64), intent(in), dimension(nr,nc) :: y
!                real(REAL64) :: z
!
!                real(REAL64), dimension(:), allocatable :: tmp
!
!                allocate(tmp(nr*nc))
!                call dcopy(nr*nc, reshape(y,[nr*nc]), 1, tmp, 1) ! tmp = y
!                call daxpy(nr*nc, -1.0D0, reshape(x, [nr*nc]), 1, tmp, 1) ! tmp = -1.0D0*x + tmp = y - x
!                z = dnrm2(nr*nc, tmp, 1) ! z = ||y-x||
!                deallocate(tmp)
!
!        end function absoluteDistance2
!
!        pure subroutine normalfactorisation1(n, x, alpha, y)
!
!                implicit none
!
!                integer(INT32), intent(in) :: n
!                real(REAL64), intent(in), dimension(n) :: x
!                real(REAL64), intent(out) :: alpha
!                real(REAL64), intent(out), dimension(n) :: y
!
!                alpha = dnrm2(n, x, 1)           ! alpha = ||x||
!                call dcopy(n, x, 1, y, 1)        ! y = x
!                call dscal(n, 1.0D0/alpha, y, 1) ! y = y/||y||
!        end subroutine normalfactorisation1
!
!        pure subroutine normalfactorisation2(nr, nc, x, alpha, y)
!
!                implicit none
!
!                integer(INT32), intent(in) :: nr
!                integer(INT32), intent(in) :: nc
!                real(REAL64), intent(in), dimension(nr, nc) :: x
!                real(REAL64), intent(out) :: alpha
!                real(REAL64), intent(out), dimension(nr, nc) :: y
!
!                real(REAL64), dimension(:), allocatable :: tmp
!
!                allocate(tmp(nr*nc))
!                alpha = dnrm2(nr*nc, reshape(x, [nr*nc]), 1)      ! alpha = ||x||
!                call dcopy(nr*nc, reshape(x, [nr*nc]), 1, tmp, 1) ! tmp = x
!                call dscal(nr*nc, 1.0D0/alpha, tmp, 1)            ! tmp = tmp/||tmp||
!
!                y = reshape(tmp, [nr, nc])
!                deallocate(tmp)
!        end subroutine normalfactorisation2
!
!        pure function ddot2(nr, nc, u, v) result(s)
!                use :: iso_c_binding
!                implicit none
!                integer(INT32), intent(in) :: nr
!                integer(INT32), intent(in) :: nc
!                real(REAL64), intent(in), dimension(nr, nc) :: u
!                real(REAL64), intent(in), dimension(nr, nc) :: v
!
!                real(REAL64) :: s
!
!                s = ddot(nr*nc, reshape(u, [nr*nc]), 1, reshape(v, [nr*nc]), 1)
!        end function ddot2
end module array_ops

