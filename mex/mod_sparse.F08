!****h* modules/sparse
!
! NAME
!
! sparse: Provides functionality for sparse matrix handling
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

module sparse
        use iso_fortran_env
        implicit none

        !! Sparse matrix in Compressed Sparse Row Format
        !! Stores a matrix in sparse CSR format.
        type, public :: csr_matrix
                integer(INT32)                            :: nr    ! Number of rows in the matrix.
                integer(INT32)                            :: nc    ! Number of columns in the matrix.
                integer(INT32)                            :: nnz   ! Number of non-zero entries in the matrix.
                integer(INT32)                            :: nzmax ! Maximal number of possible non-zero entries.
                integer(INT32), dimension(:), allocatable :: ir    ! Row index pointer. Size (nr+1)
                integer(INT32), dimension(:), allocatable :: jc    ! Column index pointer. Size nnz
                real(REAL64),   dimension(:), allocatable :: a     ! Pointer with values. Size nnz
        end type csr_matrix

        !! Sparse matrix in Coordinate Triplet Format
        !! Stores a matrix in sparse COO format.
        type, public :: coo_matrix
                integer(INT32)                            :: nr  ! Number of rows in the matrix.
                integer(INT32)                            :: nc  ! Number of columns in the matrix.
                integer(INT32)                            :: nnz ! Number of non-zero entries in the matrix.
                integer(INT32), dimension(:), allocatable :: ir  ! Row index pointer. Size nnz
                integer(INT32), dimension(:), allocatable :: jc  ! Column index pointer. Size nnz
                real(REAL64),   dimension(:), allocatable :: a   ! Pointer with values. Size nnz
        end type coo_matrix

contains

        pure function fullnnz(nr, nc, mat) result(nnz)
                implicit none

                integer(INT32), intent(in)                   :: nr
                integer(INT32), intent(in)                   :: nc
                real(REAL64),   intent(in), dimension(nr,nc) :: mat

                integer(INT32) :: nnz

                integer(INT32) :: ii, jj

                nnz = 0
                do jj = 1, nc
                        do ii = 1, nr
                                if (abs(mat(ii,jj)) > 0.0D0) nnz = nnz + 1
                        end do
                end do
        end function fullnnz

        pure subroutine dnscoo(nr, nc, nnz, mat, ir, jc, a)
                implicit none

                integer(INT32), intent(in)                    :: nr
                integer(INT32), intent(in)                    :: nc
                integer(INT32), intent(in)                    :: nnz
                real(REAL64),   intent(in),  dimension(nr,nc) :: mat

                integer(INT32), intent(out), dimension(nnz)   :: ir
                integer(INT32), intent(out), dimension(nnz)   :: jc
                real(REAL64),   intent(out), dimension(nnz)   :: a

                integer(INT32) :: ii, jj, kk

                kk = 1
                do jj = 1, nc
                        do ii = 1, nr
                                if (abs(mat(ii,jj)) > 0.0D0) then
                                        ir(kk) = ii
                                        jc(kk) = jj
                                        a(kk)  = mat(ii,jj)
                                        kk     = kk + 1
                                end if
                        end do
                end do
        end subroutine dnscoo

        pure subroutine coodns(nr, nc, nnz, ir, jc, a, mat)
                implicit none

                integer(INT32), intent(in)                    :: nr
                integer(INT32), intent(in)                    :: nc
                integer(INT32), intent(in)                    :: nnz
                integer(INT32), intent(in),  dimension(nnz)   :: ir
                integer(INT32), intent(in),  dimension(nnz)   :: jc
                real(REAL64),   intent(in),  dimension(nnz)   :: a

                real(REAL64),  intent(out), dimension(nr,nc)  :: mat

                integer(INT32) :: kk

                mat = 0.0d0

                forall(kk = 1:nnz)
                        mat(ir(kk),jc(kk)) = a(kk)
                end forall
        end subroutine coodns

        pure subroutine coocsr(nrow, nnz, ir, jc, a, iro, jco, ao)
                implicit none

                integer(INT32), intent(in)                     :: nrow
                integer(INT32), intent(in)                     :: nnz
                integer(INT32), intent(in),  dimension(nnz)    :: ir
                integer(INT32), intent(in),  dimension(nnz)    :: jc
                real(REAL64),   intent(in),  dimension(nnz)    :: a

                integer(INT32), intent(out), dimension(nrow+1) :: iro
                integer(INT32), intent(out), dimension(nnz)    :: jco
                real(REAL64),   intent(out), dimension(nnz)    :: ao

                integer(INT32) :: i, j, iad, k, k0
                real(REAL64)   :: x

                do k = 1, nrow+1
                        iro(k) = 0
                end do

                ! determine row-lengths.
                do k = 1, nnz
                        iro(ir(k)) = iro(ir(k))+1
                end do

                ! starting position of each row.
                k = 1
                do j = 1, nrow+1
                        k0 = iro(j)
                        iro(j) = k
                        k = k+k0
                end do

                ! go through the structure  once more. Fill in output matrix.
                do k = 1, nnz
                        i = ir(k)
                        j = jc(k)
                        x = a(k)
                        iad = iro(i)
                        ao(iad) = x
                        jco(iad) = j
                        iro(i) = iad+1
                end do

                ! shift back iao
                do j = nrow, 1, -1
                        iro(j+1) = iro(j)
                end do
                iro(1) = 1
        end subroutine coocsr

        pure subroutine csrcoo ( nr, nnz, ia, ja, a, ir, jc, ao )
                use :: iso_c_binding
                implicit none

                integer(INT32), intent(in)                  :: nr
                integer(INT32), intent(in)                  :: nnz
                integer(INT32), intent(in), dimension(nr+1) :: ia
                integer(INT32), intent(in), dimension(nnz)  :: ja
                real(REAL64),   intent(in), dimension(nnz)  :: a

                integer(INT32), intent(out), dimension(nnz) :: ir
                integer(INT32), intent(out), dimension(nnz) :: jc
                real(REAL64),   intent(out), dimension(nnz) :: ao

                integer(INT32)                              :: i, k, k1, k2

                ao(1:nnz) = a(1:nnz)
                jc(1:nnz) = ja(1:nnz)
                do i = nr, 1, -1
                        k1 = ia(i+1) - 1
                        k2 = ia(i)
                        do k = k1, k2, -1
                                ir(k) = i
                        end do
                end do
        end subroutine csrcoo

        pure subroutine csrdns ( nr, nc, nnz, ir, jc, a, dns)
                implicit none

                integer(INT32), intent(in)                   :: nc
                integer(INT32), intent(in)                   :: nr
                integer(INT32), intent(in)                   :: nnz
                real(REAL64),   intent(in), dimension(nnz)   :: a
                integer(INT32), intent(in), dimension(nr+1)  :: ir
                integer(INT32), intent(in), dimension(nnz)   :: jc

                real(REAL64), intent(out), dimension(nr,nc)  :: dns

                integer(INT32)                               :: i, j, k

                dns(1:nr,1:nc) = 0.0D+00

                do i = 1, nr
                        do k = ir(i), ir(i+1)-1
                                j = jc(k)
                                dns(i,j) = a(k)
                        end do
                end do
        end subroutine csrdns

        pure subroutine dnscsr ( nr, nc, dns, nnz, ir, jc, a )
                implicit none

                integer(INT32), intent(in)                    :: nr
                integer(INT32), intent(in)                    :: nc
                real(REAL64),   intent(in),  dimension(nr,nc) :: dns
                integer(INT32), intent(in)                    :: nnz

                integer(INT32), intent(out), dimension(nr+1)  :: ir
                integer(INT32), intent(out), dimension(nnz)   :: jc
                real(REAL64),   intent(out), dimension(nnz)   :: a

                integer(INT32) :: i, j, next

                next = 1
                ir(1) = 1

                do i = 1, nr
                        do j = 1, nc
                                if ( abs(dns(i,j)) > 100.0D0*EPSILON(1.0D+00) ) then
                                        jc(next) = j
                                        a(next) = dns(i,j)
                                        next = next + 1
                                end if
                        end do
                        ir(i+1) = next
                end do
        end subroutine dnscsr

        !*****************************************************************************80
        !
        !! DIAMUA performs the matrix by matrix product B = Diag * A.
        !
        !
        !  Parameters:
        !
        !    Input, integer(INT32) :: NR, the row dimension of the matrix.
        !
        !    Input, real A(*), integer(INT32) :: JA(*), IA(NR+1), the matrix in CSR
        !    Compressed Sparse Row format.
        !
        !    Input, real DIAG(N), a diagonal matrix stored as a vector.
        !
        !    Output, real B(*), integer(INT32) :: JB(*),
        !    integer(INT32) :: IB(NR+1), the resulting
        !    matrix B in compressed sparse row sparse format.
        !
        pure subroutine diamua ( nr, nnz, diag, ia, ja, a, ib, jb, b )
                implicit none

                integer(INT32), intent(in)                  :: nr
                integer(INT32), intent(in)                  :: nnz
                real(REAL64),   intent(in), dimension(nr)   :: diag
                integer(INT32), intent(in), dimension(nr+1) :: ia
                integer(INT32), intent(in), dimension(nnz)  :: ja
                real(REAL64),   intent(in), dimension(nnz)  :: a

                integer(INT32), intent(out), dimension(nr+1) :: ib
                integer(INT32), intent(out), dimension(nnz)  :: jb
                real(REAL64),   intent(out), dimension(nnz)  :: b

                integer(INT32) :: ii, k, k1, k2
                real(REAL64)   :: scal

                do ii = 1, nr
                        !
                        !  Normalize each row.
                        !
                        k1 = ia(ii)
                        k2 = ia(ii+1) - 1
                        scal = diag(ii)
                        b(k1:k2) = a(k1:k2) * scal
                end do

                ib(1) = ia(1)

                do ii = 1, nr
                        ib(ii) = ia(ii)
                        do k = ia(ii), ia(ii+1)-1
                                jb(k) = ja(k)
                        end do
                end do
        end subroutine diamua

        ! c-----------------------------------------------------------------------
        ! c Rectangular version.  n is number of rows of CSR matrix,
        ! c                       n2 (input) is number of columns of CSC matrix.
        ! c-----------------------------------------------------------------------
        ! c----------
        ! c n	= number of rows of CSR matrix.
        ! c n2    = number of columns of CSC matrix.
        ! c a	= real array of length nnz (nnz=number of nonzero elements in input
        ! c         matrix) containing the nonzero elements.
        ! c ja	= integer array of length nnz containing the column positions
        ! c 	  of the corresponding elements in a.
        ! c ia	= integer of size n+1. ia(k) contains the position in a, ja of
        ! c	  the beginning of the k-th row.
        ! c
        ! c on return:
        ! c ----------
        ! c output arguments:
        ! c ao	= real array of size nzz containing the "a" part of the transpose
        ! c jao	= integer array of size nnz containing the column indices.
        ! c iao	= integer array of size n+1 containing the "ia" index array of
        ! c	  the transpose.
        ! c
        pure subroutine csrtranspose (nrow, ncol, nnz, ia, ja, a, iao, jao, ao)
                implicit none

                integer(INT32), intent(in)                     :: nrow
                integer(INT32), intent(in)                     :: ncol
                integer(INT32), intent(in)                     :: nnz
                integer(INT32), intent(in),  dimension(nrow+1) :: ia
                integer(INT32), intent(in),  dimension(nnz)    :: ja
                real(REAL64),   intent(in),  dimension(nnz)    :: a

                integer(INT32), intent(out), dimension(ncol+1) :: iao
                integer(INT32), intent(out), dimension(nnz)    :: jao
                real(REAL64),   intent(out), dimension(nnz)    :: ao

                integer(INT32) :: i, j, k, next

                do i=1, ncol+1
                        iao(i) = 0
                end do

                do i=1, nrow
                        do k= ia(i), ia(i+1)-1
                                j = ja(k)+1
                                iao(j) = iao(j)+1
                        end do
                end do

                iao(1) = 1

                do i=1,ncol
                        iao(i+1) = iao(i) + iao(i+1)
                end do

                do i=1,nrow
                        do k=ia(i),ia(i+1)-1
                                j = ja(k)
                                next = iao(j)
                                ao(next) = a(k)
                                jao(next) = i
                                iao(j) = next+1
                        end do
                end do

                do i=ncol,1,-1
                        iao(i+1) = iao(i)
                end do
                iao(1) = 1
        end subroutine csrtranspose

        !> @brief Computes y = A*x, sparse matrix, full vector product.
        !!
        !! A is a sparse matrix in CSR format.
        !
        !    Y = A*X, sparse matrix vector product
        pure subroutine amux ( nrow, ncol, nnz, ia, ja, a, x, y )
                implicit none

                integer(INT32), intent(in)                    :: nrow
                integer(INT32), intent(in)                    :: ncol
                integer(INT32), intent(in)                    :: nnz
                integer(INT32), intent(in), dimension(nrow+1) :: ia
                integer(INT32), intent(in), dimension(nnz)    :: ja
                real(REAL64),   intent(in), dimension(nnz)    :: a
                real(REAL64),   intent(in), dimension(ncol)   :: x

                real(REAL64),  intent(out), dimension(nrow)   :: y

                integer(INT32) :: i, k
                real(REAL64)  :: t

                do i = 1, nrow
                        t = 0.0D+00
                        do k = ia(i), ia(i+1)-1
                                t = t + a(k) * x(ja(k))
                        end do
                        y(i) = t
                end do
        end subroutine amux

        !*****************************************************************************80
        !
        !! APLB performs the CSR matrix sum C = A + B.
        !
        !  Parameters:
        !
        !    Input, integer(INT32) NROW, the row dimension of A and B.
        !
        !    Input, integer(INT32) NCOL, the column dimension of A and B.
        !
        !    Input, integer(INT32) JOB.  When JOB = 0, only the structure
        !    (i.e. the arrays jc, ic) is computed and the
        !    real values are ignored.
        !
        !    Input, real A(*), integer(INT32) JA(*), IA(NROW+1), the matrix in CSR
        !    Compressed Sparse Row format.
        !
        ! b,
        ! jb,
        ! ib      =  Matrix B in compressed sparse row format.
        !
        ! on return:
        !
        ! c,
        ! jc,
        ! ic      = resulting matrix C in compressed sparse row sparse format.
        !
        ! ierr      = integer(INT32). serving as error message.
        !         ierr = 0 means normal return,
        !         ierr > 0 means that amub stopped while computing the
        !         i-th row  of C with i = ierr, because the number
        !         of elements in C exceeds nzmax.
        !
        subroutine aplb ( nrow, ncol, nnz, job, ia, ja, a, ib, jb, b, ic, jc, c, ierr )
                implicit none

                integer(INT32), intent(in)                    :: ncol
                integer(INT32), intent(in)                    :: nrow
                integer(INT32), intent(in)                    :: nnz
                logical,        intent(in)                    :: job
                integer(INT32), intent(in), dimension(nrow+1) :: ia
                integer(INT32), intent(in), dimension(nnz)    :: ja
                real(REAL64),   intent(in), dimension(nnz)    :: a
                integer(INT32), intent(in), dimension(nrow+1) :: ib
                integer(INT32), intent(in), dimension(nnz)    :: jb
                real(REAL64),   intent(in), dimension(nnz)    :: b

                integer(INT32), intent(out), dimension(nrow+1) :: ic
                integer(INT32), intent(out), dimension(nnz)    :: jc
                real(REAL64),   intent(out), dimension(nnz)    :: c
                integer(INT32), intent(out)                    :: ierr

                integer(INT32)                            :: ii, jcol, jpos, k, ka, kb, length
                integer(INT32), dimension(:), allocatable :: iw

                allocate(iw(ncol))

                ierr = 0
                length = 0
                ic(1) = 1
                iw(1:ncol) = 0

                do ii = 1, nrow
                        !  Row I.
                        do ka = ia(ii), ia(ii+1)-1

                                length = length + 1
                                jcol = ja(ka)

                                if ( nnz < length ) then
                                        ierr = ii
                                        return
                                end if

                                jc(length) = jcol
                                if ( job ) then
                                        c(length) = a(ka)
                                end if
                                iw(jcol) = length
                        end do

                        do kb = ib(ii), ib(ii+1)-1

                                jcol = jb(kb)
                                jpos = iw(jcol)

                                if ( jpos == 0 ) then

                                        length = length + 1

                                        if ( nnz < length ) then
                                                ierr = ii
                                                return
                                        end if

                                        jc(length) = jcol
                                        if ( job ) then
                                                c(length) = b(kb)
                                        end if
                                        iw(jcol)= length
                                else
                                        if ( job ) then
                                                c(jpos) = c(jpos) + b(kb)
                                        end if
                                end if
                        end do

                        do k = ic(ii), length
                                iw(jc(k)) = 0
                        end do

                        ic(ii+1) = length+1
                end do
                deallocate(iw)
        end subroutine aplb

        !*****************************************************************************80
        !
        !! APLB1 performs the sum C = A + B for sorted CSR matrices.
        !
        !  Discussion:
        !
        !    The difference between this routine and APLB is that here the
        !    resulting matrix is such that the elements of each row are sorted,
        !    with increasing column indices in each row, provided the original
        !    matrices are sorted in the same way.
        !
        !    This routine will not work if either of the two input matrices is
        !    not sorted.
        !
        subroutine aplb1 ( nrow, ncol, nnz, job, ia, ja, a, ib, jb, b, ic, jc, c, ierr )
                implicit none

                integer(INT32), intent(in)                    :: ncol
                integer(INT32), intent(in)                    :: nrow
                integer(INT32), intent(in)                    :: nnz
                logical,        intent(in)                    :: job
                integer(INT32), intent(in), dimension(nrow+1) :: ia
                integer(INT32), intent(in), dimension(nnz)    :: ja
                real(REAL64),   intent(in), dimension(nnz)    :: a
                integer(INT32), intent(in), dimension(nrow+1) :: ib
                integer(INT32), intent(in), dimension(nnz)    :: jb
                real(REAL64),   intent(in), dimension(nnz)    :: b

                integer(INT32), intent(out), dimension(nrow+1) :: ic
                integer(INT32), intent(out), dimension(nnz)    :: jc
                real(REAL64),   intent(out), dimension(nnz)    :: c
                integer(INT32), intent(out)                    :: ierr

                integer(INT32) :: i, j1, j2, ka, kamax, kb, kbmax, kc

                ierr = 0
                kc = 1
                ic(1) = kc

                do i = 1, nrow
                        ka = ia(i)
                        kb = ib(i)
                        kamax = ia(i+1) - 1
                        kbmax = ib(i+1) - 1

                        do
                                if ( ka <= kamax ) then
                                        j1 = ja(ka)
                                else
                                        j1 = ncol + 1
                                end if

                                if ( kb <= kbmax ) then
                                        j2 = jb(kb)
                                else
                                        j2 = ncol + 1
                                end if

                                if ( j1 == j2 ) then
                                        if ( job ) then
                                                c(kc) = a(ka) + b(kb)
                                        end if
                                        jc(kc) = j1
                                        ka = ka + 1
                                        kb = kb + 1
                                        kc = kc + 1
                                else if ( j1 < j2 ) then
                                        jc(kc) = j1
                                        if ( job ) then
                                                c(kc) = a(ka)
                                        end if
                                        ka = ka + 1
                                        kc = kc + 1
                                else if ( j2 < j1 ) then
                                        jc(kc) = j2
                                        if ( job ) then
                                                c(kc) = b(kb)
                                        end if
                                        kb = kb + 1
                                        kc = kc + 1
                                end if

                                if ( nnz < kc ) then
                                        ierr = i
                                        return
                                end if

                                if ( kamax < ka .and. kbmax < kb ) then
                                        exit
                                end if
                        end do
                        ic(i+1) = kc
                end do
        end subroutine aplb1

end module
