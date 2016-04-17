!****h* modules/laplace
!
! NAME
!
! laplace: functions for working with discrete laplacians
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

module laplace
        use :: iso_fortran_env
        use :: array
        use :: sparse
        implicit none

contains

        ! Computes standard 5 point stencil for the Laplacian in a dim dimensional setting. Grid size is assumed to be 1.0
        pure recursive function stencil_laplace_5p (dim) result(y)
                use :: iso_fortran_env
                implicit none

                integer(INT32), intent(in) :: dim

                real(REAL64), dimension(3**dim) :: y

                real(REAL64),  dimension(3**(dim-1)) :: tmp

                if (dim == 1) then
                        y = [1.0D0, -2.0D0, 1.0D0]
                else
                        tmp = 0.0D0
                        tmp(ceiling(3**(dim-1)/2.0D0)) = 1.0D0
                        y = [tmp,  stencil_laplace_5p (dim-1) - 2.0D0*tmp, tmp]
                end if
        end function stencil_laplace_5p

        ! Computes sparse matrix COO representation of a standard 5-point stencil in arbitrary dimensional setting.
        pure subroutine laplace_5p_sparse_coo(dims, ir, jc, a, neumann)
                use :: stencil
                implicit none

                integer(INT32), dimension(:),           intent(in) :: dims ! grid dimensions
                logical,                      optional, intent(in) :: neumann

                integer(INT32), dimension(:), intent(out) :: ir
                integer(INT32), dimension(:), intent(out) :: jc
                real(REAL64),   dimension(:), intent(out) :: a

                integer(INT32)                        :: ii
                real(REAL64), dimension(3**size(dims)) :: sten
                logical,      dimension(3**size(dims)) :: mask
                integer(INT32)                        :: numel

                sten = stencil_laplace_5p(size(dims))
                mask = (abs(sten) > epsilon(1.0D0))
                numel = stencil2sparse_size ([(3, ii=1, size(dims))], dims, mask)

                ! Get COO representation of Laplacian
                call const_stencil2sparse ([(3, ii=1, size(dims))], dims, mask, sten, ir, jc, a)

                if (present(neumann)) then
                        if (neumann) then
                                do ii = 1, numel
                                        if (ir(ii) == jc(ii)) then
                                                a(ii) = a(ii) + real(count(mask) - count(ir == ir(ii)), REAL64)
                                        end if
                                end do
                        end if
                end if
        end subroutine laplace_5p_sparse_coo

        pure function apply_laplace_5p (dims, sig, neumann) result(res)
                use :: stencil, only: convolve, create_5p_stencil, stencilmask
                implicit none

                integer(INT32), dimension(:),                       intent(in) :: dims ! grid dimensions
                real(REAL64),   dimension(product(dims)),           intent(in) :: sig  ! input signal
                logical,                                  optional, intent(in) :: neumann

                real(REAL64),   dimension(product(dims)) :: res

                integer(INT32), dimension(size(dims)) :: stl_5p
                integer(INT32) :: ii

                stl_5p = [(3, ii=1,size(dims))]

                res = convolve( dims, stl_5p, sig, stencil_laplace_5p(size(dims)), create_5p_stencil(size(dims)))

                if (present(neumann)) then
                        if (neumann) then
                                !! Handle Neumann conditions
                                forall (ii = 1:product(dims))
                                        res(ii) = res(ii) + (real(2**size(dims) - count( create_5p_stencil (size(dims)) .and. &
                                                stencilmask (stl_5p, dims, ii))+1, REAL64)) * sig(ii)
                                end forall
                        end if
                end if
        end function apply_laplace_5p

end module
