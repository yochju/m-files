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
    public

contains

    ! setup_before_all
    ! setup = setup_before_each
    subroutine setup_test_sparse
    end subroutine setup_test_sparse

    ! teardown_before_all
    ! teardown = teardown_before_each
    subroutine teardown_test_sparse
    end subroutine teardown_test_sparse

    subroutine check_fullnnz
        implicit none

        real(REAL64), dimension(3,5) :: mat1
        real(REAL64), dimension(6,6) :: mat2
        
        ! 1  0  3  0  7
        ! 2  0  4  0  8
        ! 0  0  5  6  9
        mat1 = reshape(real([1, 2, 0, 0, 0, 0, 3, 4, 5, 0, 0, 6, 7, 8, 9], REAL64), [3, 5])

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
        mat2 = reshape( &
                real([10, 3, 0, 3, 0, 0, 0, 9, 7, 0, 8, 4, 0, 0, 8, 8, 0, 0, &
                0, 0, 7, 7, 9, 0, -2, 0, 0, 5, 9, 2, 0, 3, 0, 0, 13, -1], REAL64), [6, 6])
        
        call assertEquals(9,  int(fullnnz(int(3, INT32), int(5, INT32), mat1)))
        call assertEquals(19, int(fullnnz(int(6, INT32), int(6, INT32), mat2)))
    end subroutine check_fullnnz
        
    subroutine check_dnscoo
        implicit none

        real(REAL64),   dimension(6,6) :: mat
        integer(INT32), dimension(19)  :: ir
        integer(INT32), dimension(19)  :: jc
        real(REAL64),   dimension(19)  :: a

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
        mat = reshape( &
                real([10, 3, 0, 3, 0, 0, 0, 9, 7, 0, 8, 4, 0, 0, 8, 8, 0, 0, &
                0, 0, 7, 7, 9, 0, -2, 0, 0, 5, 9, 2, 0, 3, 0, 0, 13, -1], REAL64), [6, 6])
        
        call dnscoo(int(6, INT32), int(6, INT32), int(19, INT32), mat, ir, jc, a)
        
        call assertEquals([1, 2, 4, 2, 3, 5, 6, 3, 4, 3, 4, 5, 1, 4, 5, 6, 2, 5, 6], int(ir), 19)
        call assertEquals([1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6], int(jc), 19)
        call assertEquals(real([10, 3, 3, 9, 7, 8, 4, 8, 8, 7, 7, 9, -2, 5, 9, 2, 3, 13, -1], REAL64), a, 19)
    end subroutine check_dnscoo

    subroutine check_coodns
        implicit none

        real(REAL64),   dimension(6,6) :: mat
        integer(INT32), dimension(19)  :: ir
        integer(INT32), dimension(19)  :: jc
        real(REAL64),   dimension(19)  :: a

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1

        ir = [1, 2, 4, 2, 3, 5, 6, 3, 4, 3, 4, 5, 1, 4, 5, 6, 2, 5, 6]
        jc = [1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6]
        a  = real([10, 3, 3, 9, 7, 8, 4, 8, 8, 7, 7, 9, -2, 5, 9, 2, 3, 13, -1], REAL64)
        call coodns(int(6, INT32), int(6, INT32), int(19, INT32), ir, jc, a, mat)

        call assertEquals( &
                real([10, 3, 0, 3, 0, 0, 0, 9, 7, 0, 8, 4, 0, 0, 8, 8, 0, 0, &
                0, 0, 7, 7, 9, 0, -2, 0, 0, 5, 9, 2, 0, 3, 0, 0, 13, -1], REAL64), &
                reshape (mat, [36]), 36)
    end subroutine check_coodns

    subroutine check_coocsr
        implicit none

        integer, dimension(7)   :: ir
        integer, dimension(19)  :: jc
        real,    dimension(19)  :: a

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1

        call coocsr(6, 19, &
                [1, 2, 4, 2, 3, 5, 6, 3, 4, 3, 4, 5, 1, 4, 5, 6, 2, 5, 6], &
                [1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6], &
                real([10, 3, 3, 9, 7, 8, 4, 8, 8, 7, 7, 9, -2, 5, 9, 2, 3, 13, -1]), &
                ir, jc, a)

        call assertEquals ([1, 3, 6, 9, 13, 17, 20],                                           ir,  7)
        call assertEquals ([1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6],          jc, 19)
        call assertEquals (real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), a, 19)
    end subroutine check_coocsr

    subroutine check_csrcoo
        implicit none

        integer, dimension(19)  :: ir
        integer, dimension(19)  :: jc
        real,    dimension(19)  :: a

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
                
        call csrcoo (6, 19, &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                ir, jc, a)

        call assertEquals(     [ 1,  1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6,  6,  6], ir, 19)
        call assertEquals(     [ 1,  5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2,  5,  6], jc, 19)
        call assertEquals(real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), a, 19)
    end subroutine check_csrcoo

    subroutine check_csrdns
        implicit none

        real, dimension(6,6) :: mat

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
        call csrdns (6, 6, 19, &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                mat)

        call assertEquals( &
                real([10, 3, 0, 3, 0, 0, 0, 9, 7, 0, 8, 4, 0, 0, 8, 8, 0, 0, &
                0, 0, 7, 7, 9, 0, -2, 0, 0, 5, 9, 2, 0, 3, 0, 0, 13, -1]), &
                reshape (mat, [36]), 36)
    end subroutine check_csrdns

    subroutine check_csrtranspose
        integer, dimension(7)   :: ir
        integer, dimension(19)  :: jc
        real,    dimension(19)  :: a

        call csrtranspose (6, 6, 19, &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                ir, jc, a)
        
        call assertEquals( &
                [1, 4, 8, 10, 13, 17, 20], &
                ir, 7)
        call assertEquals( &
                [1, 2, 4, 2, 3, 5, 6, 3, 4, 3, 4, 5, 1, 4, 5, 6, 2, 5, 6], &
                jc, 19)
        
        call assertEquals( &
                real([10, 3, 3, 9, 7, 8, 4, 8, 8, 7, 7, 9, -2, 5, 9, 2, 3, 13, -1]), &
                a, 19)

    end subroutine check_csrtranspose

    subroutine check_diamua
        integer, dimension(7) :: ir
        integer, dimension(19) :: jc
        real, dimension(19) :: a

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
        call diamua( 6, 19, &
                real([1, 2, 3, 4, 5, 6]), &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                ir, jc, a)

        call assertEquals( &
                [1, 3, 6, 9, 13, 17, 20], &
                ir, 7)
        call assertEquals( &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                jc, 19)
        
        call assertEquals( &
                real([ &
                10, -2, 6, 18, 6, 21, 24, 21, 12, 32, 28, 20, 40, 45, 45, 65, 24, 12, -6]), &
                a, 19)
    end subroutine check_diamua

    subroutine check_amux

        real, dimension(6) :: y

        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1

        call amux(6, 6, 19, &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                real([1, 2, 3, 4, 5, 6]), y)

        call assertEquals(real([0, 39, 66, 80, 175, 12]), y, 6)
        
    end subroutine check_amux

    subroutine check_aplb

        integer, dimension(7)  :: ir
        integer, dimension(19) :: jc
        real,    dimension(19) :: a

        ! integer, dimension(9) :: ir2
        ! integer, dimension(9) :: jc2
        ! real,    dimension(9) :: a2
        
        ! 10  0  0  0 -2   0
        !  3  9  0  0  0   3
        !  0  7  8  7  0   0 
        !  3  0  8  7  5   0
        !  0  8  0  9  9  13
        !  0  4  0  0  2  -1
        
        call aplb(6, 6, 19, .true., &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                [1, 3, 6, 9, 13, 17, 20], &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                real([10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                ir, jc, a)
        
        call assertEquals( &
                [1, 3, 6, 9, 13, 17, 20], &
                ir, 7)
        call assertEquals( &
                [1, 5, 1, 2, 6, 2, 3, 4, 1, 3, 4, 5, 2, 4, 5, 6, 2, 5, 6], &
                jc, 19)

        call assertEquals( &
                2*real([ &
                10, -2, 3, 9, 3, 7, 8, 7, 3, 8, 7, 5, 8, 9, 9, 13, 4, 2, -1]), &
                a, 19)

        !  1 -1  0     0  0  1
        !  0  0  2  +  1  1  0
        !  3  4  5     0  1  0

        ! call aplb(3, 3, 9, .true., &
        !         [1, 3, 4, 7], [1, 2, 3, 1, 2, 3], real([1, -1, 2, 3, 4, 5]), &
        !         [1, 2, 4, 7], [3, 1, 2, 1],       real([1,  1, 1, 1]), &
        !         ir2, jc2, a2
        !         )
    end subroutine check_aplb

end module test_sparse
