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

module test_sparse
        use :: fruit
        use :: sparse
        use :: iso_fortran_env
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_sparse
        end subroutine setup_test_sparse

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_sparse
        end subroutine teardown_test_sparse

        subroutine check_coocsr_ops
                use :: iso_c_binding
                implicit none

                real(REAL64),  dimension(3,5) :: mat, mat2, mat3
                real(REAL64),  dimension(5,3) :: matT
                integer(INT32), dimension(4)   :: ir, irT, ir2
                integer(INT32), dimension(9)   :: jc, jcT, icoo, jcoo, icoo2, jcoo2, jc2
                real(REAL64),  dimension(9)   :: a, aT, acoo, acoo2, a2

                !! 1 0 3 0 7
                !! 2 0 4 0 8
                !! 0 0 5 6 9
                mat = reshape(real([1, 2, 0, 0, 0, 0, 3, 4, 5, 0, 0, 6, 7, 8, 9], REAL64), [3, 5])

                call dnscsr( int(3, INT32), int(5, INT32), mat, int(9, INT32), ir, jc, a )
                call csrtranspose( int(3, INT32), int(5, INT32), int(9, INT32), ir, jc, a, irT, jcT, aT)
                call csrdns(int(5, INT32), int(3, INT32), int(9, INT32), irT, jcT, aT, matT)
                call csrcoo( int(3, INT32), int(9, INT32), ir, jc, a, icoo, jcoo, acoo)
                call dnscoo( int(3, INT32), int(5, INT32), int(9, INT32), mat, icoo2, jcoo2, acoo2)
                call coocsr( int(3, INT32), int(9, INT32), icoo2, jcoo2, acoo2, ir2, jc2, a2)
                call coodns(int(3, INT32), int(5, INT32), int(9, INT32), icoo, jcoo, acoo, mat2)
                call coodns(int(3, INT32), int(5, INT32), int(9, INT32), icoo2, jcoo2, acoo2, mat3)
                call assertEquals(matT, transpose(mat), 5, 3)
                call assertEquals(mat2, mat, 3, 5)
                call assertEquals(mat3, mat, 3, 5)
                call assertEquals(int(ir), int(ir2), 4)
                call assertEquals(int(jc), int(jc2), 9)
                call assertEquals(a, a2, 9)
        end subroutine check_coocsr_ops

        subroutine check_fullnnz
                implicit none

                real(REAL64), dimension(3,5) :: mat

                !! 1 0 3 0 7
                !! 2 0 4 0 8
                !! 0 0 5 6 9
                mat = reshape(real([1, 2, 0, 0, 0, 0, 3, 4, 5, 0, 0, 6, 7, 8, 9], REAL64), [3, 5])
                call assertEquals(9, int(fullnnz(int(3, INT32), int(5, INT32), mat)))
        end subroutine check_fullnnz

        subroutine check_full2coo
                implicit none

                real(REAL64),  dimension(6,6) :: mat
                integer(INT32), dimension(19)  :: ir
                integer(INT32), dimension(19)  :: jc
                real(REAL64),  dimension(19)  :: a

                mat = reshape( &
                        real([10, 3, 0, 3, 0, 0, 0, 9, 7, 0, 8, 4, 0, 0, 8, 8, 0, 0, &
                        0, 0, 7, 7, 9, 0, -2, 0, 0, 5, 9, 2, 0, 3, 0, 0, 13, -1], REAL64), [6, 6])

                call assertEquals(int(fullnnz(int(6, INT32), int(6, INT32), mat)), 19)
                call dnscoo(int(6, INT32), int(6, INT32), int(19, INT32), mat, ir, jc, a)
                call assertEquals([1, 2, 4, 2, 3, 5, 6, 3, 4, 3, 4, 5, 1, 4, 5, 6, 2, 5, 6], int(ir), 19)
                call assertEquals([1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6], int(jc), 19)
                call assertEquals(real([10, 3, 3, 9, 7, 8, 4, 8, 8, 7, 7, 9, -2, 5, 9, 2, 3, 13, -1], REAL64), a, 19)
        end subroutine check_full2coo

        subroutine check_amux
                implicit none

        end subroutine check_amux


end module test_sparse
