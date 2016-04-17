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

module gvo
        use :: iso_fortran_env
        implicit none

        private :: TOL
        REAL(REAL64), parameter :: TOL = 1.0D-10

contains

        pure subroutine apply_gvo(dims, its, c, f, u, method)
                use :: iso_fortran_env
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                integer(INT32),                           intent(in) :: its
                real(REAL64),   dimension(product(dims)), intent(in) :: c
                real(REAL64),   dimension(product(dims)), intent(in) :: f
                integer(INT32),                           intent(in) :: method

                real(REAL64), dimension(product(dims)), intent(out) :: u

                integer(INT32)                                      :: itnlim

                itnlim = -1
                select case (method)
                        case (1)
                                call lsqr (dims, c, f,  u, its, itnlim)
                        case (2)
                                call apply_gvo_pdhg (dims, its, c, f, u)
                        case default
                                call lsqr (dims, c, f,  u, its, itnlim)
                end select
        end subroutine apply_gvo

        pure subroutine apply_gvo_pdhg(dims, its, c, f, x)
                use :: inpainting, only: apply_inpainting_5p, apply_inpainting_T_5p
                use :: iso_fortran_env
                implicit none

                integer(INT32), dimension(:), intent(in) :: dims
                integer(INT32),               intent(in) :: its

                real(REAL64), dimension(product(dims)), intent(in)  :: c
                real(REAL64), dimension(product(dims)), intent(in)  :: f
                real(REAL64), dimension(product(dims)), intent(out) :: x

                integer(INT32)                          :: ii
                real(REAL64)                            :: sigma, tau, theta, L
                real(REAL64), dimension(:), allocatable :: y
                real(REAL64), dimension(:), allocatable :: Ax
                real(REAL64), dimension(:), allocatable :: xbar
                real(REAL64), dimension(:), allocatable :: xold
                real(REAL64), dimension(:), allocatable :: d
                real(REAL64), dimension(:), allocatable :: dold
                real(REAL64), dimension(:), allocatable :: dbar

                allocate(y(product(dims)), Ax(product(dims)), xbar(product(dims)), xold(product(dims)), &
                        d(product(dims)), dold(product(dims)), dbar(product(dims)))

                x    = c*f
                xold = 0.0D0
                xbar = c*f
                d    = 0.0D0
                dbar = 0.0D0
                y    = 0.0D0

                L = 64.0D0 + maxval(c**2)

                tau   = 1.0D0
                sigma = 1.0D0/(tau*L+0.1D0)
                theta = 1.0D0

                do ii = 1, its
                        xold = x
                        dold = d

                        Ax = apply_inpainting_5p (dims, dbar, c, .true.)
                        y = y + sigma*(Ax-c*xbar)

                        Ax = apply_inpainting_T_5p(dims, y, c, .true.)
                        d = (d - tau*(Ax-f))/(1.0D0+tau)

                        x = x + tau*(c*y)

                        xbar = x + theta*(x-xold)
                        dbar = d + theta*(d-dold)

                        !! TODO: implement stopping criteria
                end do

                deallocate(y, Ax, xbar, xold, d, dold, dbar)
        end subroutine apply_gvo_pdhg

        pure subroutine lsqr (dims, cM, b, x, itnlim, itn)
                use :: inpainting, only: solve_inpainting
                implicit none

                integer(INT32), dimension( :),            intent(in) :: dims
                real(REAL64),   dimension(product(dims)), intent(in) :: cM
                real(REAL64),   dimension(product(dims)), intent(in) :: b
                integer(INT32),                           intent(in) :: itnlim

                integer(INT32),                           intent(out) :: itn
                real(REAL64),   dimension(product(dims)), intent(out) :: x

                real(REAL64),               dimension(:), allocatable :: u
                real(REAL64),               dimension(:), allocatable :: v
                real(REAL64),               dimension(:), allocatable :: w
                real(REAL64),               dimension(:), allocatable :: tmp
                integer(INT32)                                        :: ii
                integer(INT32)                                        :: n
                real(REAL64) :: alpha, beta, cs, phi, phibar, rho, rhobar, sn, theta

                interface
                        pure subroutine dscal (n, alpha, x, incx)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in)    :: n
                                real(REAL64),                 intent(in)    :: alpha
                                real(REAL64),   dimension(n), intent(inout) :: x
                                integer(INT32),               intent(in)    :: incx
                        end subroutine dscal

                        pure subroutine daxpy (n, alpha, x, incx, y, incy)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in)    :: n
                                real(REAL64),                 intent(in)    :: alpha
                                real(REAL64),   dimension(n), intent(in)    :: x
                                integer(INT32),               intent(in)    :: incx
                                real(REAL64),   dimension(n), intent(inout) :: y
                                integer(INT32),               intent(in)    :: incy
                        end subroutine daxpy

                        pure function dnrm2(n, x, incx) result (nrm)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in) :: n
                                real(REAL64),   dimension(n), intent(in) :: x
                                integer(INT32),               intent(in) :: incx

                                real(REAL64) :: nrm
                        end
                end interface

                n = product(dims)

                allocate(u(n), v(n), w(n), tmp(n))

                u = b
                v = 0.0D0
                x = 0.0D0

                cs = 0.0D0
                sn = 0.0D0

                alpha  = 0.0D0
                beta   = dnrm2(n, u, 1)

                call solve_inpainting (dims, cM, u, .true., v, 1)

                if (beta > 0.0D0) then
                        call dscal(n, 1.0D0/beta, u, 1)
                        call solve_inpainting (dims, cM, u, .true., v, 0)
                        alpha = dnrm2(n, v, 1)
                end if

                if (alpha > 0.0D0) then
                        call dscal(n, 1.0D0/alpha, v, 1)
                        w = v
                end if

                rhobar = alpha
                phibar = beta

                itn = 0
                do ii = 1, itnlim
                        itn = itn + 1

                        call solve_inpainting (dims, cM, v, .false., tmp, 0)
                        u = tmp - alpha * u
                        beta = dnrm2(n, u, 1)

                        if (beta > 0.0D0) then
                                call dscal(n, 1.0/beta, u, 1)
                                call solve_inpainting (dims, cM, u, .true., tmp, 0)
                                v = tmp - beta*v
                                alpha  = dnrm2(n, v, 1)
                                if (alpha > 0.0D0) then
                                        call dscal(n, 1.0D0/alpha, v, 1)
                                end if
                        end if

                        rho    =   hypot(rhobar, beta)
                        cs     =   rhobar/rho
                        sn     =   beta/rho
                        theta  =   sn*alpha
                        rhobar = -1.0D0*cs*alpha
                        phi    =   cs*phibar
                        phibar =   sn*phibar

                        x = (phi/rho)*w + x

                        if ( dnrm2(n, (phi/rho)*w, 1) < TOL ) then
                                exit
                        end if

                        w = v - (theta/rho)*w

                        if (abs(phibar) < TOL) then
                                !! Norm of the residual is small.
                                exit
                        end if

                        if (abs(phibar*alpha*cs) < TOL) then
                                !! Norm of A^T (Ax-b) is small.
                                exit
                        end if

                end do

                call solve_inpainting (dims, cM, u, .true., tmp, -1)
                deallocate(u, v, w, tmp)
        end subroutine lsqr
end module
