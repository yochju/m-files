!****h* modules/stencil
!
! NAME
!
! stencil: Provides helper functions for manipulating stencils.
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

module stencil
        use :: iso_fortran_env
        implicit none
        private

        public :: stencillocs

        public :: stencilmask

        public :: create_5p_stencil

        public :: stencil2sparse_size

        public :: const_stencil2sparse

        public :: stencil2sparse

        public :: convolve

contains

        !****f* modules/stencil/stencillocs
        !
        ! NAME
        !
        ! stencillocs
        !
        ! DESCRIPTION
        !
        ! Returns an array containing the linearly labeled positions in a stenci of size siz on a grid of size dims.
        !
        ! EXAMPLE
        !
        ! stencillocs([3, 5], [10, 12]) returns [-11, -10, -9, -6, -5, -4, -1, 0, 1, 4, 5, 6, 9, 10, 11]
        !
        ! ARGUMENTS
        !
        ! siz:  size of the stencil
        ! dims: size of the grid
        !
        ! RESULT
        !
        ! y: sorted linearly indexed positions
        !
        ! NOTES
        !
        ! siz may only contain odd integer entries whereas the entries in dims can be arbitrary integers. No error checking is done
        ! to verify that the obtained positions are not out of bounds.
        ! The algorithm works by splitting the result recursively for each considered dimension and finally applying the trivial 1D
        ! case.
        !
        !****
        pure recursive function stencillocs (siz, dims) result(y)
                use :: miscfun, only : cumprod
                implicit none

                integer(INT32), dimension(:),         intent(in) :: siz  ! size of the stencil
                integer(INT32), dimension(size(siz)), intent(in) :: dims ! size of the grid

                integer(INT32), dimension(product(siz)) :: y

                integer(INT32)                       :: ii, tmp
                integer(INT32), dimension(size(siz)) :: cumdim
                integer(INT32), dimension(size(siz)) :: cumsiz

                cumsiz = cumprod (siz)
                cumdim = cumprod (dims)

                if (size(dims) == 1) then
                        y = [(ii, ii = -floor(siz(1)/2.0, INT32), floor(siz(1)/2.0, INT32))]
                else
                        tmp = ubound(cumsiz,1)
                        forall (ii=1:siz(tmp))
                                y( (ii-1)*cumsiz(tmp-1) + 1:cumsiz(tmp-1) ) = cumdim(tmp-1) * ( (ii-1) - floor(siz(tmp)/2.0) ) + &
                                        stencillocs(siz(1:(tmp-1)), dims(1:(tmp-1)))
                        end forall
                end if
        end function stencillocs

        !****f* modules/stencil/stencilmask
        !
        ! NAME
        !
        ! stencilmask
        !
        ! DESCRIPTION
        !
        ! Indicates out-of-bounds references for a given stencil on a specified position in an arbitrary grid.
        !
        !****
        pure function stencilmask (siz, dims, x) result(y)
                use :: array, only : ind2sub
                use :: miscfun, only : cumprod, repelem
                implicit none

                integer(INT32), dimension(:),         intent(in) :: siz  ! size of the stencil
                integer(INT32), dimension(size(siz)), intent(in) :: dims ! size of the grid
                integer(INT32),                       intent(in) :: x    ! current position (linear index)

                logical, dimension(product(siz)) :: y

                integer(INT32), dimension(product(siz), size(siz)) :: tmp
                integer(INT32), dimension(size(siz)+2)             :: csiz
                integer(INT32), dimension(size(siz)+2)             :: cumsiz
                integer(INT32), dimension(size(siz))               :: sub
                integer(INT32)                                     :: ii, jj

                csiz = [1, siz, 1]
                cumsiz = cumprod(csiz)

                forall (ii=1:size(siz))
                        tmp(1:product(siz), ii) = reshape(spread( &
                                repelem([(jj, jj = -floor(siz(ii)/2.0, INT32), floor(siz(ii)/2.0, INT32))], cumsiz(ii)), &
                                2, product(csiz((ii+2):ubound(csiz, 1))) ), [product(siz)] )
                end forall

                sub = ind2sub(dims, 1, 1, x)

                forall (ii=1:product(siz))
                        y(ii) = (.not. (any( tmp(ii, 1:size(siz)) + sub < 1 ) .or. any( tmp(ii, 1:size(siz)) + sub > dims )))
                end forall

        end function stencilmask

        !****f* modules/stencil/create_5p_stencil
        !
        ! NAME
        !
        ! create_5p_stencil
        !
        ! DESCRIPTION
        !
        ! create a "5-point" stencil for arbitrary dimensions. Does not check for bounds!
        !
        !****
        pure function create_5p_stencil (dims) result(sten)
                use :: array, only : ind2sub
                use :: miscfun, only : cumprod, repelem
                implicit none

                integer(INT32), intent(in) :: dims ! size of the grid

                logical, dimension(3**dims) :: sten

                integer(INT32), dimension(3**dims, dims) :: tmp
                integer(INT32)                           :: ii

                forall (ii=1:dims)
                        tmp(1:(3**dims), ii) = reshape (spread ( &
                                repelem([-1, 0, 1], 3**(ii-1)), 2, 3**(dims-ii) ), [3**dims] )
                end forall

                sten = .false.
                where (sum(abs(tmp), 2) <= 1) sten = .true.
        end function create_5p_stencil

        !****f* modules/stencil/stencil2sparse_size
        !
        ! NAME
        !
        ! stencil2sparse_size
        !
        ! DESCRIPTION
        !
        ! Compute size of the coo sparse matrix arrays required to store the stencil in matrix form
        !
        !****
        pure function stencil2sparse_size (siz, dims, mask) result (numel)
                implicit none

                integer(INT32), dimension(:),            intent(in) :: siz  ! size of the stencil
                integer(INT32), dimension(size(siz)),    intent(in) :: dims ! size of the grid
                logical(INT32), dimension(product(siz)), intent(in) :: mask ! indicator for the relevant stencil entries

                integer(INT32) :: numel

                integer :: ii

                numel = 0
                do ii = 1, product(dims)
                        numel = numel + count(stencilmask(siz, dims, ii) .and. mask)
                end do
        end function stencil2sparse_size

        !****f* modules/stencil/const_stencil2sparse
        !
        ! NAME
        !
        ! const_stencil2sparse
        !
        ! DESCRIPTION
        !
        ! Convert a constant stencil into a sparse matrix representation in coo format.
        !
        !****
        pure subroutine const_stencil2sparse (siz, dims, mask, sten, ir, jc, a)
                implicit none

                integer(INT32), dimension(:),            intent(in) :: siz  ! size of the stencil
                integer(INT32), dimension(size(siz)),    intent(in) :: dims ! size of the grid
                logical(INT32), dimension(product(siz)), intent(in) :: mask ! indicator for the relevant stencil entries
                real(real64),   dimension(product(siz)), intent(in) :: sten ! stencil entries

                integer(INT32), dimension(count(mask)*product(dims)), intent(out) :: ir
                integer(INT32), dimension(count(mask)*product(dims)), intent(out) :: jc
                real(REAL64),   dimension(count(mask)*product(dims)), intent(out) :: a

                integer(INT32), dimension(product(siz)) :: unused
                logical,        dimension(product(siz)) :: tmp_mask
                integer(INT32)                          :: tmp_cnt
                integer(INT32)                          :: counter
                integer(INT32), dimension(product(siz)) :: const_stl
                integer(INT32)                          :: ii, jj

                unused = -1
                counter = 1
                const_stl = stencillocs(siz, dims)

                do ii = 1, product(dims)
                        tmp_mask                        = stencilmask(siz, dims, ii) .and. mask
                        tmp_cnt                         = count(tmp_mask)
                        ir(counter:(counter+tmp_cnt-1)) = [(ii, jj=1,tmp_cnt)]
                        jc(counter:(counter+tmp_cnt-1)) = pack(ii + const_stl, tmp_mask)
                        a(counter:(counter+tmp_cnt-1))  = pack(sten, tmp_mask)
                        counter                         = counter + tmp_cnt
                end do
        end subroutine const_stencil2sparse

        !****f* modules/stencil/stencil2sparse
        !
        ! NAME
        !
        ! stencil2sparse
        !
        ! DESCRIPTION
        !
        ! Convert an locally varying stencil into a sparse matrix representation in coo format.
        !
        ! NOTES
        !
        ! The argument sten should contain the entries of the stencil for each grid point. The first index runs over the linearly
        ! indexed data points and the second index on the linearly indexed entries of the stencil.
        !
        ! SEE ALSO
        !
        ! const_stencil2sparse
        !
        !****
        pure subroutine stencil2sparse (siz, dims, mask, sten, ir, jc, a)
                implicit none

                integer(INT32), dimension(:),                           intent(in) :: siz  ! size of the stencil
                integer(INT32), dimension(size(siz)),                   intent(in) :: dims ! size of the grid
                logical(INT32), dimension(product(siz)),                intent(in) :: mask ! indicator for the stencil entries
                real(real64),   dimension(product(dims), product(siz)), intent(in) :: sten ! stencil entries

                integer(INT32), dimension(count(mask)*product(dims)), intent(out) :: ir
                integer(INT32), dimension(count(mask)*product(dims)), intent(out) :: jc
                real(REAL64),   dimension(count(mask)*product(dims)), intent(out) :: a

                integer(INT32), dimension(product(siz)) :: unused
                logical,        dimension(product(siz)) :: tmp_mask
                integer(INT32)                          :: tmp_cnt
                integer(INT32)                          :: counter
                integer(INT32), dimension(product(siz)) :: const_stl
                integer(INT32)                          :: ii, jj

                unused = -1
                counter = 1
                const_stl = stencillocs(siz, dims)

                do ii = 1, product(dims)
                        tmp_mask                        = stencilmask(siz, dims, ii) .and. mask
                        tmp_cnt                         = count(tmp_mask)
                        ir(counter:(counter+tmp_cnt-1)) = [(ii, jj=1,tmp_cnt)]
                        jc(counter:(counter+tmp_cnt-1)) = pack(ii + const_stl, tmp_mask)
                        a(counter:(counter+tmp_cnt-1))  = pack(sten(ii,:), tmp_mask)
                        counter                         = counter + tmp_cnt
                end do
        end subroutine stencil2sparse

        pure function convolve (dims, siz, arr, ker, mask) result(res)
                implicit none

                integer(INT32), intent(in), dimension(:)             :: dims
                integer(INT32), intent(in), dimension(size(dims))    :: siz
                real(REAL64),   intent(in), dimension(product(dims)) :: arr
                real(REAL64),   intent(in), dimension(product(siz))  :: ker
                logical,        intent(in), dimension(product(siz))  :: mask

                real(REAL64), dimension(product(dims)) :: res

                integer(INT32) :: ii

                res = 0.0D0

                forall (ii = lbound(arr,1):ubound(arr,1))
                        res(ii) = sum(arr(ii + stencillocs (siz, dims))*ker(ubound(ker,1):lbound(ker,1):-1), 1, &
                                mask .and. stencilmask (siz, dims, ii))
                end forall
        end function convolve

end module
