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

module test_stencil
        use :: fruit
        use :: stencil
        use :: iso_fortran_env
        implicit none
        public

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_stencil
        end subroutine setup_test_stencil

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_stencil
        end subroutine teardown_test_stencil

        !        subroutine check_get_neighbour_mask_1
        !                implicit none
        !
        !                logical, dimension(3) :: mask
        !
        !                mask = get_neighbour_mask ( 1, [5], [1], [1])
        !                call assertEquals (mask, [.false., .true., .true.], 3)
        !
        !                mask = get_neighbour_mask ( 1, [5], [1], [2])
        !                call assertEquals (mask, [.true., .true., .true.], 3)
        !
        !                mask = get_neighbour_mask ( 1, [5], [1], [3])
        !                call assertEquals (mask, [.true., .true., .true.], 3)
        !
        !                mask = get_neighbour_mask ( 1, [5], [1], [4])
        !                call assertEquals (mask, [.true., .true., .true.], 3)
        !
        !                mask = get_neighbour_mask ( 1, [5], [1], [5])
        !                call assertEquals (mask, [.false., .true., .false.], 3)
        !
        !        end subroutine check_get_neighbour_mask_1
        !
        !        subroutine check_get_neighbour_mask_2
        !                use :: iso_fortran_env
        !                implicit none
        !
        !                logical, dimension(9) :: mask
        !
        !                mask = get_neighbour_mask ( 2, [3, 5], [1, 1], [1, 1])
        !                call assertEquals (mask, [.false., .false., .false., &
                !                .false., .true., .true., .false., .true., .true.], 9)
        !
        !        end subroutine check_get_neighbour_mask_2
        !
        !        subroutine check_stencilcoo_1
        !                implicit none
        !
        !                integer(INT32), dimension(3,1) :: coo
        !
        !                call stencilcoo (1, [3], [1], coo)
        !                call assertEquals (reshape([0, 1, 2], [3, 1]), coo, 3, 1)
        !
        !                call stencilcoo (1, [3], [4], coo)
        !                call assertEquals (reshape([3, 4, 5], [3, 1]), coo, 3, 1)
        !        end subroutine check_stencilcoo_1
        !
        !        subroutine check_stencilcoo_2
        !                implicit none
        !
        !                integer(INT32), dimension(9,2) :: coo
        !
        !                call stencilcoo (2, [3, 3], [4, 5], coo)
        !                call assertEquals (reshape([3, 4, 5, 3, 4, 5, 3, 4, 5, 4, 4, 4, 5, 5, 5, 6, 6, 6], [6, 1]), coo, 9, 2)
        !
        !        end subroutine check_stencilcoo_2

        subroutine check_stencillocs
                implicit none

                call assertEquals([-3, -2, -1, 0, 1, 2, 3], stencillocs([7], [99]), 7)
                call assertEquals([-21, -20, -19, -11, -10, -9, -1, 0, 1, 9, 10, 11, 19, 20, 21], &
                        stencillocs([3, 5], [10, 12]), 15)
                call assertEquals([-100, -99, -98, -91, -90, -89, -82, -81, -80, &
                        -10, -9, -8, -1, 0, 1, 8, 9, 10, &
                        80, 81, 82, 89, 90, 91, 98, 99, 100], stencillocs([3, 3, 3], [9, 10, 11]), 27)
        end subroutine check_stencillocs

        subroutine check_stencilmask
                implicit none

                ! 1D
                call assertEquals([.false., .true., .false.], stencilmask ([3], [1], 1), 3)
                call assertEquals([.false., .true., .true.], stencilmask ([3], [2], 1), 3)
                call assertEquals([.true., .true., .false.], stencilmask ([3], [2], 2), 3)

                call assertEquals([.false., .false., .false., .true., .true., .true., .true.], stencilmask ([7], [99], 1), 7)
                call assertEquals([.false.,  .true.,  .true., .true., .true., .true., .true.], stencilmask ([7], [99], 3), 7)

                ! 2D
                call assertEquals([.false., .false., .false., .false., .true., .true., .false., .true., .true.], &
                        stencilmask([3, 3], [2, 2], 1), 9)
                call assertEquals([.false., .false., .false., .true., .true., .false., .true., .true., .false.], &
                        stencilmask([3, 3], [2, 2], 2), 9)
                call assertEquals([.false., .true., .true., .false., .true., .true., .false., .false., .false.], &
                        stencilmask([3, 3], [2, 2], 3), 9)
                call assertEquals([.true., .true., .false., .true., .true., .false., .false., .false., .false.], &
                        stencilmask([3, 3], [2, 2], 4), 9)

                call assertEquals([.false., .false., .false., .false., .false., .false., .true., .true., .true., .true., &
                        .true., .true., .true., .true., .true.], stencilmask([3, 5], [10, 12], 4), 15)

                call assertEquals([.false., .false., .false., .false., .true., .true., .false., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 1), 9)
                call assertEquals([.false., .false., .false., .true., .true., .true., .true., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 2), 9)
                call assertEquals([.false., .false., .false., .true., .true., .false., .true., .true., .false.], &
                        stencilmask([3, 3], [3, 4], 3), 9)

                call assertEquals([.false., .true., .true., .false., .true., .true., .false., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 4), 9)
                call assertEquals([.true., .true., .true., .true., .true., .true., .true., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 5), 9)
                call assertEquals([.true., .true., .false., .true., .true., .false., .true., .true., .false.], &
                        stencilmask([3, 3], [3, 4], 6), 9)

                call assertEquals([.false., .true., .true., .false., .true., .true., .false., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 7), 9)
                call assertEquals([.true., .true., .true., .true., .true., .true., .true., .true., .true.], &
                        stencilmask([3, 3], [3, 4], 8), 9)
                call assertEquals([.true., .true., .false., .true., .true., .false., .true., .true., .false.], &
                        stencilmask([3, 3], [3, 4], 9), 9)

                call assertEquals([.false., .true., .true., .false., .true., .true., .false., .false., .false.], &
                        stencilmask([3, 3], [3, 4], 10), 9)
                call assertEquals([.true., .true., .true., .true., .true., .true., .false., .false., .false.], &
                        stencilmask([3, 3], [3, 4], 11), 9)
                call assertEquals([.true., .true., .false., .true., .true., .false., .false., .false., .false.], &
                        stencilmask([3, 3], [3, 4], 12), 9)

                ! 3D

        end subroutine check_stencilmask

        subroutine check_stencil2sparse_size
                implicit none

                ! 1D
                call assertEquals(19, stencil2sparse_size ([3], [7], [.true., .true., .true.]))
                call assertEquals(44, stencil2sparse_size ([5], [10], [.true., .true., .true., .true., .true.]))

                ! 2D
                call assertEquals(460, stencil2sparse_size ([3, 3], [10, 10], &
                        [.false., .true., .false., .true., .true., .true., .false., .true., .false.]))
                call assertEquals(12, stencil2sparse_size ([3, 3], [2, 2], &
                        [.false., .true., .false., .true., .true., .true., .false., .true., .false.]))

                ! 3D
                call assertEquals(32, stencil2sparse_size ([3, 3, 3], [2, 2, 2], &
                        [.false., .false., .false., .false., .true., .false., .false., .false., .false., &
                        .false., .true., .false., .true., .true., .true., .false., .true., .false., &
                        .false., .false., .false., .false., .true., .false., .false., .false., .false.]))

        end subroutine check_stencil2sparse_size

        subroutine check_const_stencil2sparse
                implicit none

                integer(INT32), dimension(13) :: ir, jc
                real(REAL64),   dimension(13) :: a

                integer(INT32), dimension(12) :: ir2, jc2
                real(REAL64),   dimension(12) :: a2


                integer(INT32), dimension(32) :: ir3, jc3
                real(REAL64),   dimension(32) :: a3

                ! 1D
                call const_stencil2sparse ([3], [5], [.true., .true., .true.], real([1, -2, 1], REAL64), ir, jc, a)
                call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
                call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
                call assertEquals(real([-2, 1, 1, -2, 1, 1, -2, 1, 1, -2, 1, 1, -2], REAL64), a, 13)

                ! 2D
                call const_stencil2sparse ([3, 3], [2, 2], &
                        [.false., .true., .false., .true., .true., .true., .false., .true., .false.], &
                        real([0, 1, 0, 1, -4, 1, 0, 1, 0], REAL64), ir2, jc2, a2)
                call assertEquals([1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4], ir2, 12)
                call assertEquals([1, 2, 3, 1, 2, 4, 1, 3, 4, 2, 3, 4], jc2, 12)
                call assertEquals(real([-4, 1, 1, 1, -4, 1, 1, -4, 1, 1, 1, -4], REAL64), a2, 12)

                ! 3D
                call const_stencil2sparse ([3, 3, 3], [2, 2, 2], &
                        [.false., .false., .false., .false., .true., .false., .false., .false., .false., &
                                .false., .true., .false., .true., .true., .true., .false., .true., .false., &
                                .false., .false., .false., .false., .true., .false., .false., .false., .false.], &
                        real([0, 0, 0, 0, 1, 0, 0, 0, 0, &
                                0, 1, 0, 1, -6, 1, 0, 1, 0, &
                                0, 0, 0, 0, 1, 0, 0, 0, 0], REAL64), ir3, jc3, a3)
                call assertEquals([1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, &
                     5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8], ir3, 32)
                call assertEquals([1, 2, 3, 5, 1, 2, 4, 6, 1, 3, 4, 7, 2, 3, 4, 8, &
                     1, 5, 6, 7, 2, 5, 6, 8, 3, 5, 7, 8, 4, 6, 7, 8], jc3, 32)
                call assertEquals(real([-6, 1, 1, 1, 1, -6, 1, 1, 1, -6, 1, 1, 1, 1, &
                     -6, 1, 1, -6, 1, 1, 1, 1, -6, 1, 1, 1, -6, 1, 1, 1, 1,-6], REAL64), a3, 32)
        end subroutine check_const_stencil2sparse

        subroutine check_stencil2sparse
                implicit none

                integer(INT32), dimension(13) :: ir, jc
                real(REAL64),   dimension(13) :: a

                integer(INT32), dimension(12) :: ir2, jc2
                real(REAL64),   dimension(12) :: a2


                integer(INT32), dimension(32) :: ir3, jc3
                real(REAL64),   dimension(32) :: a3

                ! 1D
                ! call const_stencil2sparse ([3], [5], [.true., .true., .true.], spread(real([1, -2, 1], REAL64), 2, 5), ir, jc, a)
                ! call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
                ! call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
                ! call assertEquals(real([-2, 1, 1, -2, 1, 1, -2, 1, 1, -2, 1, 1, -2], REAL64), a, 13)

                ! 2D
                ! call const_stencil2sparse ([3, 3], [2, 2], &
                !         [.false., .true., .false., .true., .true., .true., .false., .true., .false.], &
                !         spread(real([0, 1, 0, 1, -4, 1, 0, 1, 0], REAL64), 2, 4), ir2, jc2, a2)
                ! call assertEquals([1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4], ir2, 12)
                ! call assertEquals([1, 2, 3, 1, 2, 4, 1, 3, 4, 2, 3, 4], jc2, 12)
                ! call assertEquals(real([-4, 1, 1, 1, -4, 1, 1, -4, 1, 1, 1, -4], REAL64), a2, 12)

                ! 3D
                ! call const_stencil2sparse ([3, 3, 3], [2, 2, 2], &
                !         [.false., .false., .false., .false., .true., .false., .false., .false., .false., &
                !                 .false., .true., .false., .true., .true., .true., .false., .true., .false., &
                !                 .false., .false., .false., .false., .true., .false., .false., .false., .false.], &
                !         spread(real([0, 0, 0, 0, 1, 0, 0, 0, 0, &
                !                 0, 1, 0, 1, -6, 1, 0, 1, 0, &
                !                 0, 0, 0, 0, 1, 0, 0, 0, 0], REAL64), 2, 8), ir3, jc3, a3)
                ! call assertEquals([1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, &
                !      5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8], ir3, 32)
                ! call assertEquals([1, 2, 3, 5, 1, 2, 4, 6, 1, 3, 4, 7, 2, 3, 4, 8, &
                !      1, 5, 6, 7, 2, 5, 6, 8, 3, 5, 7, 8, 4, 6, 7, 8], jc3, 32)
                ! call assertEquals(real([-6, 1, 1, 1, 1, -6, 1, 1, 1, -6, 1, 1, 1, 1, &
                !      -6, 1, 1, -6, 1, 1, 1, 1, -6, 1, 1, 1, -6, 1, 1, 1, 1,-6], REAL64), a3, 32)
        end subroutine check_stencil2sparse

        subroutine check_convolve
                implicit none

                call assertEquals (real([1, 2, 3, 4, 5], REAL64), &
                        convolve ([5], [3], real([1, 2, 3, 4, 5], REAL64), real([0, 1, 0], REAL64), [.true., .true., .true.]), 5)
                call assertEquals (real([3, 6, 9, 12, 9], REAL64), &
                        convolve ([5], [3], real([1, 2, 3, 4, 5], REAL64), real([1, 1, 1], REAL64), [.true., .true., .true.]), 5)
                call assertEquals (real([1, 2, 3, 4, 5], REAL64), &
                        convolve ([5], [3], real([1, 2, 3, 4, 5], REAL64), real([1, 1, 1], REAL64), [.false., .true., .false.]), 5)

                call assertEquals (real([4, 8, 8, 5, 10, 11, 5, 10, 11, 4, 8, 8], REAL64), &
                        convolve ([3, 4], [3, 3], real([1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3], REAL64), &
                        real([1, 1, 1, 1, 1, 1, 1, 1, 1], REAL64), &
                        [.false., .true., .false., .true., .true., .true., .false., .true., .false.]), 12)
        end subroutine check_convolve

        subroutine check_create_5p_stencil
                implicit none

                call assertEquals ([.true., .true., .true.], create_5p_stencil(1), 1)
                call assertEquals ([.false., .true., .false., .true., .true., .true., .false., .true., .false.], &
                        create_5p_stencil(2), 9)
                call assertEquals ([.false., .false., .false., .false., .true., .false., .false., .false., .false., &
                                .false., .true., .false., .true., .true., .true., .false., .true., .false., &
                                .false., .false., .false., .false., .true., .false., .false., .false., .false.], &
                        create_5p_stencil(3), 27)
        end subroutine check_create_5p_stencil

end module test_stencil
