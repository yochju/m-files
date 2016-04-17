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

module optmask
        use :: iso_fortran_env
        use :: inpainting
        implicit none
        save

        private :: TOL
        REAL(REAL64), parameter :: TOL = 1.0D0

contains

        pure function primal_energy (u, c, f, ubar, cbar, lambda, epsi, mu) result(energy)
                implicit none

                real(REAL64), dimension(:),       intent(in) :: u
                real(REAL64), dimension(size(u)), intent(in) :: c
                real(REAL64), dimension(size(u)), intent(in) :: f
                real(REAL64), dimension(size(u)), intent(in) :: ubar
                real(REAL64), dimension(size(u)), intent(in) :: cbar
                real(REAL64),                     intent(in) :: lambda
                real(REAL64),                     intent(in) :: epsi
                real(REAL64),                     intent(in) :: mu

                real(REAL64) :: energy

                energy = sum(0.5D0*((u-f)**2 + epsi*sum(c**2) + mu*((u-ubar)**2 + (c-cbar)**2)) + lambda*abs(c))
        end function primal_energy

        pure function dual_energy (dims, p, f, g, b, cbar, ubar, lambda, epsi, mu) result(energy)
                use :: inpainting, only: apply_inpainting_5p, apply_inpainting_T_5p
                use :: array_ops, only: huberloss
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                real(REAL64),   dimension(product(dims)), intent(in) :: p
                real(REAL64),   dimension(size(p)),       intent(in) :: f
                real(REAL64),   dimension(size(p)),       intent(in) :: g
                real(REAL64),   dimension(size(p)),       intent(in) :: b
                real(REAL64),   dimension(size(p)),       intent(in) :: cbar
                real(REAL64),   dimension(size(p)),       intent(in) :: ubar
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu

                real(REAL64) :: energy

                integer(INT32) :: n

                !! Interface to BLAS functions
                interface
                        pure function dnrm2(n, x, incx) result (nrm)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in) :: n
                                real(REAL64),   dimension(n), intent(in) :: x
                                integer(INT32),               intent(in) :: incx

                                real(REAL64) :: nrm
                        end

                        pure function ddot(n, x, incx, y, incy) result (dot)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in) :: n
                                real(REAL64),   dimension(n), intent(in) :: x
                                integer(INT32),               intent(in) :: incx
                                real(REAL64),   dimension(n), intent(in) :: y
                                integer(INT32),               intent(in) :: incy

                                real(REAL64) :: dot
                        end
                end interface

                n = size(cbar)

                energy = ddot(n, p, 1, g - apply_inpainting_5p (dims, (mu*ubar+f)/(1.0D0+mu), cbar, .true.), 1) + &
                        (dnrm2(n, apply_inpainting_T_5p (dims, p, cbar, .true.), 1)**2)/(2*(1+mu)) - &
                        (dnrm2(n, mu*cbar, 1)**2 + dnrm2(n, -b*p+mu*cbar, 1)**2)/(2*(epsi+mu)) - &
                        sum(huberloss(-b*p+mu*cbar, lambda))/(mu+epsi)
        end function dual_energy

        pure function grad_energy_dual (dims, p, f, g, b, cbar, ubar, lambda, epsi, mu) result(nabla)
                use :: inpainting, only: apply_inpainting_5p, apply_inpainting_T_5p
                use :: array_ops, only: softshrinkage
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                real(REAL64),   dimension(product(dims)), intent(in) :: p
                real(REAL64),   dimension(size(p)),       intent(in) :: f
                real(REAL64),   dimension(size(p)),       intent(in) :: g
                real(REAL64),   dimension(size(p)),       intent(in) :: b
                real(REAL64),   dimension(size(p)),       intent(in) :: cbar
                real(REAL64),   dimension(size(p)),       intent(in) :: ubar
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu

                real(REAL64), dimension(product(dims)) :: nabla

                nabla = g - apply_inpainting_5p (dims, (mu*ubar+f)/(1.0D0+mu), cbar, .true.) - mu*b*cbar/(epsi+mu) + &
                        apply_inpainting_5p(dims, apply_inpainting_T_5p(dims, p/(1.0D0+mu), cbar, .true.), cbar, .true.) + &
                        1.0D0/(epsi+mu)*(b**2)*p - b *(b*p+mu*cbar + softshrinkage(-b*p+mu*cbar, lambda))/(mu+epsi)
        end function grad_energy_dual

        pure subroutine grad_desc_dual(dims, p, f, g, b, cbar, ubar, lambda, epsi, mu, maxit, alpha, popt)
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                real(REAL64),   dimension(product(dims)), intent(in) :: p
                real(REAL64),   dimension(product(dims)), intent(in) :: f
                real(REAL64),   dimension(product(dims)), intent(in) :: g
                real(REAL64),   dimension(product(dims)), intent(in) :: b
                real(REAL64),   dimension(product(dims)), intent(in) :: cbar
                real(REAL64),   dimension(product(dims)), intent(in) :: ubar
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu
                integer(INT32),                           intent(in) :: maxit
                real(REAL64),                             intent(in) :: alpha

                real(REAL64),   intent(out), dimension(product(dims)) :: popt

                integer(INT32)                           :: ii
                real(REAL64),  dimension(:), allocatable :: tmp
                real(REAL64),  dimension(:), allocatable :: pOld

                allocate(tmp(product(dims)), pOld(product(dims)))
                popt = p

                do ii = 1, maxit

                        tmp = grad_energy_dual (dims, popt, f, g, b, cbar, ubar, lambda, epsi, mu)
                        popt = popt - alpha*tmp !! Perform gradient descent step.

                        !! TODO: Stopping criteria, check 0 gradient.
                end do
                deallocate(tmp, pOld)
        end subroutine grad_desc_dual

!        pure subroutine solveKKT (dims, p, f, b, cbar, ubar, lambda, epsi, mu, u, c)
!                use :: inpainting, only: apply_inpainting_T_5p
!                use :: array_ops, only: softshrinkage
!                implicit none
!
!                integer(INT32), dimension(:), intent(in) :: dims
!
!                real(REAL64), dimension(product(dims)), intent(in) :: p
!                real(REAL64), dimension(product(dims)), intent(in) :: f
!                real(REAL64), dimension(product(dims)), intent(in) :: b
!                real(REAL64), dimension(product(dims)), intent(in) :: cbar
!                real(REAL64), dimension(product(dims)), intent(in) :: ubar
!                real(REAL64),                           intent(in) :: lambda
!                real(REAL64),                           intent(in) :: epsi
!                real(REAL64),                           intent(in) :: mu
!
!                real(REAL64), dimension(product(dims)), intent(out) :: u
!                real(REAL64), dimension(product(dims)), intent(out) :: c
!
!                u = (mu*ubar + f - apply_inpainting_T_5p (dims, p, cbar, .true.))/(1.0D0 + mu)
!                c = softshrinkage((mu*cbar - b*p)/(epsi+mu), lambda/(epsi+mu))
!        end subroutine solveKKT

        pure subroutine solve_optmask_dual(dims, lambda, epsi, mu, f, maxitI, maxitO, uinit, cinit, alpha, u, c)
                use :: laplace, only: apply_laplace_5p
                use :: inpainting, only: apply_inpainting_T_5p
                use :: array_ops, only: softshrinkage
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu
                real(REAL64),   dimension(product(dims)), intent(in) :: f
                integer(INT32),                           intent(in) :: maxitI
                integer(INT32),                           intent(in) :: maxitO
                real(REAL64),   dimension(product(dims)), intent(in) :: uinit
                real(REAL64),   dimension(product(dims)), intent(in) :: cinit
                real(REAL64),                             intent(in) :: alpha

                real(REAL64),  dimension(product(dims)), intent(out) :: u
                real(REAL64),  dimension(product(dims)), intent(out) :: c

                real(REAL64),  dimension(:), allocatable :: ubar, cbar, b, g, p, popt
                integer(INT32)                           :: ii, itc

                allocate( ubar(product(dims)), cbar(product(dims)), b(product(dims)), &
                        g(product(dims)), p(product(dims)), popt(product(dims)))

                u = uinit
                c = cinit
                ubar = u
                cbar = c
                p = 0.0D0

                do ii = 1, maxitO
                        b = ubar - f + apply_laplace_5p(dims, ubar, .true.)
                        g = cbar*(ubar+apply_laplace_5p(dims, ubar, .true.))

                        call grad_desc_dual(dims, p, f, g, b, cbar, ubar, lambda, epsi, mu, maxitI, alpha, popt)

                        p = popt
                        !! call solveKKT (dims, popt, f, b, cbar, ubar, lambda, epsi, mu, u, c)
                        !! Solve KKT
                        u = (mu*ubar + f - apply_inpainting_T_5p (dims, popt, cbar, .true.))/(1.0D0 + mu)
                        c = softshrinkage((mu*cbar - b*popt)/(epsi+mu), lambda/(epsi+mu))

                        ! TODO: implement stopping criteria
                end do

                deallocate(ubar, cbar, b, g, p, popt)
        end subroutine solve_optmask_dual


        pure subroutine pdhg (dims, maxit, f, b, g, ubar, cbar, lambda, epsi, mu, u, c)
                use :: inpainting, only: apply_inpainting_5p, apply_inpainting_T_5p
                use :: array_ops, only: softshrinkage
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                integer(INT32),                           intent(in) :: maxit
                real(REAL64),   dimension(product(dims)), intent(in) :: f
                real(REAL64),   dimension(product(dims)), intent(in) :: b
                real(REAL64),   dimension(product(dims)), intent(in) :: g
                real(REAL64),   dimension(product(dims)), intent(in) :: ubar
                real(REAL64),   dimension(product(dims)), intent(in) :: cbar
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu

                real(REAL64), dimension(product(dims)), intent(out) :: u
                real(REAL64), dimension(product(dims)), intent(out) :: c

                real(REAL64),  parameter :: inp_op_nrm2 = 64.0D0 ! Rough estimate based on Gersgorin
                real(REAL64)             :: ev
                real(REAL64),  parameter :: tau = 0.25D0 ! TODO: Implement faster non-constant variant.
                real(REAL64)             :: sigma
                real(REAL64),  parameter :: theta = 1.0D0
                integer(INT32)           :: ii
                integer(INT32)           :: n

                interface
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

                        pure subroutine dscal (n, alpha, x, incx)
                                use :: iso_fortran_env
                                implicit none

                                integer(INT32),               intent(in)    :: n
                                real(REAL64),                 intent(in)    :: alpha
                                real(REAL64),   dimension(n), intent(inout) :: x
                                integer(INT32),               intent(in)    :: incx
                        end subroutine dscal
                end interface

                real(REAL64), allocatable, dimension(:) :: y, uold, cold ! TODO: use save attribute to save allocation.

                allocate(y(product(dims)), uold(product(dims)), cold(product(dims)))

                ev = inp_op_nrm2 + maxval(b**2)
                sigma = 1.0D0/(ev*tau)

                y = 0.0D0
                u = 0.0D0
                c = 0.0D0
                uold = u
                cold = c

                n = product(dims)

                do ii = 1, maxit
                        call daxpy(n, sigma, apply_inpainting_5p(dims, u, cbar, .true.) + b*c - g, 1, y, 1)
                        uold = u
                        cold = c

                        call daxpy(n, -1.0D0*tau, apply_inpainting_T_5p(dims, y, cbar, .true.) - f - mu*ubar, 1, u, 1)
                        call dscal(n, 1.0D0/(1.0D0+tau+mu*tau), u, 1)

                        c = softshrinkage((c - tau*b*y + tau*mu*cbar)/(1+tau*epsi+tau*mu), tau*lambda/(1+tau*epsi+tau*mu))

                        u = u + theta*(u-uold)
                        c = c + theta*(c-cold)

                        !! TODO: Implement stopping criteria.
                end do
                deallocate(y, uold, cold)
        end subroutine pdhg

        pure subroutine solve_optmask_primal (dims, lambda, epsi, mu, f, maxitI, maxitO, uinit, cinit, u, c)
                use :: laplace, only: apply_laplace_5p
                implicit none

                integer(INT32), dimension(:),             intent(in) :: dims
                real(REAL64),                             intent(in) :: lambda
                real(REAL64),                             intent(in) :: epsi
                real(REAL64),                             intent(in) :: mu
                real(REAL64),   dimension(product(dims)), intent(in) :: f
                integer(INT32),                           intent(in) :: maxitI
                integer(INT32),                           intent(in) :: maxitO
                real(REAL64),   dimension(product(dims)), intent(in) :: uinit
                real(REAL64),   dimension(product(dims)), intent(in) :: cinit

                real(REAL64),  dimension(product(dims)), intent(out) :: u
                real(REAL64),  dimension(product(dims)), intent(out) :: c


                real(REAL64), dimension(:), allocatable :: ubar, cbar, b, g
                integer(INT32)                          :: ii

                allocate(ubar(product(dims)), cbar(product(dims)), b(product(dims)), g(product(dims)))

                u = uinit
                c = cinit
                ubar = u
                cbar = c

                do ii = 1, maxitO
                        b = ubar - f + apply_laplace_5p(dims, ubar, .true.)
                        g = cbar*(ubar+apply_laplace_5p(dims, ubar, .true.))

                        call pdhg(dims, maxitI, f, b, g, ubar, cbar, lambda, epsi, mu, u, c)

                        ! TODO: implement stopping criteria
                end do

                deallocate(ubar, cbar, b, g)
        end subroutine solve_optmask_primal
end module
