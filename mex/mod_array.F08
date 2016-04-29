!****h* modules/array
!
! NAME
!
! array: provides useful functions for operating on arbitrary shaped arrays
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

module array
        use iso_fortran_env
        implicit none
        private

        public :: ind2sub
        interface ind2sub
            module procedure ind2sub_i, ind2sub_l
        end interface ind2sub

        public :: sub2ind
        interface sub2ind
            module procedure sub2ind_i, sub2ind_l
        end interface sub2ind

        public :: add0padding
        interface add0padding
                module procedure add0padding_i, add0padding_r
        end interface

        public :: mirror
        interface mirror
            module procedure mirror_1, mirror_2, mirror_3
        end interface mirror

contains

        !! Convert single integer index into subscript array
        !! rnk       Size of dims array
        !! dims      Extend of the array along each dimension from 1 to rnk.
        !! offsetIn  Offset of the input index.
        !! offsetOut Offset of the output subscripts
        !! ind       Index to be converted to a subscript
        !! sub       Corresponding subscript
        pure recursive function ind2sub_i (dims, offsetIn, offsetOut, ind) result(sub)
                implicit none

                integer(INT32), intent(in), dimension(:) :: dims
                integer(INT32), intent(in)               :: offsetIn
                integer(INT32), intent(in)               :: offsetOut
                integer(INT32), intent(in)               :: ind

                integer(INT32), dimension(size(dims)) :: sub

                integer(INT32) :: siz ! helper variable
                integer(INT32) :: rnk

                rnk = size(dims)

                ! The algorithm works recusively. Along each dimension it places as
                ! much as possible into the current subscript position. The remaining
                ! indices are passed to the next subscript position.
                if (1 < rnk) then
                        siz = product (dims(1:(rnk-1)))
                        sub(rnk) = int ((ind-offsetIn)/siz) + offsetOut
                        sub(1:(rnk-1)) =  ind2sub_i (dims(1:(rnk-1)), offsetIn, offsetOut, ind - siz * int ((ind-offsetIn)/siz))
                else
                        sub(rnk) = ind - offsetIn + offsetOut
                endif
        end function ind2sub_i

        pure recursive function ind2sub_l (dims, offsetIn, offsetOut, ind) result(sub)
                implicit none

                integer(INT64), intent(in), dimension(:) :: dims
                integer(INT64), intent(in)               :: offsetIn
                integer(INT64), intent(in)               :: offsetOut
                integer(INT64), intent(in)               :: ind

                integer(INT64), dimension(size(dims)) :: sub

                integer(INT64) :: siz ! helper variable
                integer(INT64) :: rnk

                rnk = size(dims)

                ! The algorithm works recusively. Along each dimension it places as
                ! much as possible into the current subscript position. The remaining
                ! indices are passed to the next subscript position.
                if (1 < rnk) then
                        siz = product (dims(1:(rnk-1)))
                        sub(rnk) = int ((ind-offsetIn)/siz, INT64) + offsetOut
                        sub(1:(rnk-1)) =  ind2sub_l (dims(1:(rnk-1)), offsetIn,&
                                & offsetOut, ind - siz * int ((ind-offsetIn)&
                                &/siz, INT64))
                else
                        sub(rnk) = ind - offsetIn + offsetOut
                endif
        end function ind2sub_l

        !! Converts subscript array into single index
        !! rnk       Size of dims array
        !! dims      Extend of the array along each dimension from 1 to rnk.
        !! offsetIn  Offset of the input index.
        !! offsetOut Offset of the output subscripts
        !! sub       subscript array to be convert into single index
        !! ind       Corresponding index
        pure recursive function sub2ind_i (dims, offsetIn, offsetOut, sub) result(ind)
                implicit none

                integer(INT32), intent(in), dimension(:)          :: dims
                integer(INT32), intent(in)                        :: offsetIn
                integer(INT32), intent(in)                        :: offsetOut
                integer(INT32), intent(in), dimension(size(dims)) :: sub

                integer(INT32) :: ind

                integer(INT32) :: rnk

                rnk = size(dims)

                ! The algorithm works recursively. For each subscript we compute the
                ! size of the corresponding dimension and add everything up.
                ind = 0
                if (1 < rnk) then
                        ind =  sub2ind_i (dims(1:(rnk-1)), offsetIn, offsetOut, sub(1:(rnk-1)))
                        ind = ind + (sub(rnk) - offsetIn) * product (dims(1:(rnk-1)))
                else
                        ind = sub(1) - offsetIn + offsetOut
                endif
        end function sub2ind_i

        pure recursive function sub2ind_l (dims, offsetIn, offsetOut, sub) result(ind)
                implicit none

                integer(INT64), intent(in), dimension(:)          :: dims
                integer(INT64), intent(in)                        :: offsetIn
                integer(INT64), intent(in)                        :: offsetOut
                integer(INT64), intent(in), dimension(size(dims)) :: sub

                integer(INT64) :: ind

                integer(INT64) :: rnk

                rnk = size(dims)

                ! The algorithm works recursively. For each subscript we compute the
                ! size of the corresponding dimension and add everything up.
                ind = 0
                if (1 < rnk) then
                        ind =  sub2ind_l (dims(1:(rnk-1)), offsetIn, offsetOut, sub(1:(rnk-1)))
                        ind = ind + (sub(rnk) - offsetIn) * product (dims(1:(rnk-1)))
                else
                        ind = sub(1) - offsetIn + offsetOut
                endif
        end function sub2ind_l


        ! if I enable bounds checking in gfortran, then this function fails. It seems that product(siz+2*padding)
        ! cannot be determined correctly. This appears to be bug in gfortran.
        pure recursive function add0padding_i (siz, padding, sig) result(y)
                use miscfun, only: cumprod
                implicit none

                integer(INT32), dimension(:),            intent(in) :: siz
                integer(INT32), dimension(size(siz)),    intent(in) :: padding
                integer(INT32), dimension(product(siz)), intent(in) :: sig

                integer(INT32), dimension(product(siz+2*padding)) :: y

                integer(INT32), dimension(size(siz)) :: csp, csz
                integer(INT32)                       :: ii, last

                y(1:product(siz+2*padding)) = 0

                if (size(siz) == 1) then
                        y((padding(1) + 1):(padding(1) + siz(1))) = sig
                else
                        csp = cumprod(siz + 2*padding)
                        csz = cumprod(siz)

                        last = ubound(siz,1)
                        forall (ii=1:siz(last))
                                y( (csp(last-1)*padding(last)+(ii-1)*csp(last-1)+1): &
                                        (csp(last-1)*padding(last)+(ii-1)*csp(last-1)+csp(last-1)) ) = &
                                                add0padding_i( siz(1:last-1), padding(1:last-1), &
                                                sig( ((ii-1)*csz(last-1) + 1):((ii-1)*csz(last-1) + csz(last-1)) ))
                        end forall
                end if
        end function add0padding_i

        pure recursive function add0padding_r (siz, padding, sig) result(y)
                use miscfun, only: cumprod
                implicit none

                integer(INT32), dimension(:),            intent(in) :: siz
                integer(INT32), dimension(size(siz)),    intent(in) :: padding
                real(REAL64),   dimension(product(siz)), intent(in) :: sig

                real(REAL64), dimension(product(siz+2*padding)) :: y

                integer(INT32), dimension(size(siz)) :: csp, csz
                integer(INT32)                       :: ii, last

                y(1:product(siz+2*padding)) = 0.0D0

                if (size(siz) == 1) then
                        y((padding(1) + 1):(padding(1) + siz(1))) = sig
                else
                        csp = cumprod(siz + 2*padding)
                        csz = cumprod(siz)

                        last = ubound(siz,1)
                        forall (ii=1:siz(last))
                                y( (csp(last-1)*padding(last)+(ii-1)*csp(last-1)+1): &
                                        (csp(last-1)*padding(last)+(ii-1)*csp(last-1)+csp(last-1)) ) = &
                                                add0padding_r( siz(1:last-1), padding(1:last-1), &
                                                sig( ((ii-1)*csz(last-1) + 1):((ii-1)*csz(last-1) + csz(last-1)) ))
                        end forall
                end if
        end function add0padding_r

        pure subroutine mirror_1(n, x, y)
                implicit none

                integer(INT32), intent(in)                  :: n
                real(REAL64),  intent(in),  dimension(n)   :: x
                real(REAL64),  intent(out), dimension(n+2) :: y

                y = 0.0D0

                y(2:(n+1)) = x

                y(  1) = x(1)
                y(n+2) = x(n)
        end subroutine mirror_1

        pure subroutine mirror_2(nr, nc, x, y)
                implicit none

                integer(INT32), intent(in)                        :: nr
                integer(INT32), intent(in)                        :: nc
                real(REAL64),  intent(in),  dimension(nr,  nc)   :: x
                real(REAL64),  intent(out), dimension(nr+2,nc+2) :: y

                y = 0.0D0

                y(2:(nr+1),2:(nc+1)) = x

                y(2:(nr+1), 1   ) = x(1:nr,  1)
                y(2:(nr+1), nc+2) = x(1:nr, nc)

                y(1,    2:(nc+1)) = x(1 , 1:nc)
                y(nr+2, 2:(nc+1)) = x(nr, 1:nc)

                y(1,       1) = x(1,   1)
                y(1,    nc+2) = x(1,  nc)
                y(nr+2,    1) = x(nr,  1)
                y(nr+2, nc+2) = x(nr, nc)
        end subroutine mirror_2

        pure subroutine mirror_3(nr, nc, nd, x, y)
                implicit none

                integer(INT32), intent(in)                             :: nr
                integer(INT32), intent(in)                             :: nc
                integer(INT32), intent(in)                             :: nd
                real(REAL64),  intent(in),  dimension(nr,  nc,  nd)   :: x
                real(REAL64),  intent(out), dimension(nr+2,nc+2,nd+2) :: y

                integer(INT32) :: ii

                y = 0.0D0

                !! Mirror all interior frames.
                do ii = 1, nd
                        call mirror_2(nr, nc, x(1:nr, 1:nc, ii), y(1:(nr+2), 1:(nc+2), ii+1))
                end do

                !! Mirror 1st and last frame.
                y(1:(nr+2), 1:(nc+2),    1) = y(1:(nr+2), 1:(nc+2),    2)
                y(1:(nr+2), 1:(nc+2), nd+2) = y(1:(nr+2), 1:(nc+2), nd+1)
        end subroutine mirror_3

end module array
