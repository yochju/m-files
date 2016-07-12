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

module test_laplace
        use :: fruit
        use :: laplace
        use :: stencil
        use :: iso_fortran_env
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_laplace
        end subroutine setup_test_laplace

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_laplace
        end subroutine teardown_test_laplace

        subroutine check_stencil_laplace_5p
                implicit none

                call assertEquals(real([1, -2, 1], REAL64), stencil_laplace_5p (1), 3)
                call assertEquals(real([0, 1, 0, 1, -4, 1, 0, 1, 0], REAL64), stencil_laplace_5p (2), 9)
                call assertEquals( &
                        real([0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, -6, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], REAL64), &
                        stencil_laplace_5p (3), 27)
        end subroutine check_stencil_laplace_5p

        subroutine check_laplace_5p_sparse_coo
                implicit none

                integer(INT32), dimension(13) :: ir, jc
                real(REAL64),   dimension(13) :: a

                call laplace_5p_sparse_coo([5], ir, jc, a, .true.)
                call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
                call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
                call assertEquals(real([-1, 1, 1, -2, 1, 1, -2, 1, 1, -2, 1, 1, -1], REAL64), a, 13)
        end subroutine check_laplace_5p_sparse_coo

        subroutine check_apply_laplace_5p
                implicit none

                call assertEquals (real([0, 0, 0, 0, -6], REAL64), apply_laplace_5p([5], real([1, 2, 3, 4, 5], REAL64)), 5)
                call assertEquals (real([-1, 1, 0, 0, 0, -1, -5], REAL64), &
                        apply_laplace_5p([7], real([1, 1, 2, 3, 4, 5, 5], REAL64)), 7)

                call assertEquals (real([0, 0, 0, 0, -6], REAL64), apply_laplace_5p([5], real([1, 2, 3, 4, 5], REAL64), .false.), 5)
                call assertEquals (real([-1, 1, 0, 0, 0, -1, -5], REAL64), &
                        apply_laplace_5p([7], real([1, 1, 2, 3, 4, 5, 5], REAL64), .false.), 7)

                call assertEquals (real([1, 0, 0, 0, -1], REAL64), apply_laplace_5p([5], real([1, 2, 3, 4, 5], REAL64), .true.), 5)
                call assertEquals (real([0, 1, 0, 0, 0, -1, 0], REAL64), &
                        apply_laplace_5p([7], real([1, 1, 2, 3, 4, 5, 5], REAL64), .true.), 7)

                call assertEquals (real([0, 1, -2, 1, 0], REAL64), apply_laplace_5p([5], real([0, 0, 1, 0, 0], REAL64)), 5)
                call assertEquals (real([-2, 1, 0, 0, 0], REAL64), apply_laplace_5p([5], real([1, 0, 0, 0, 0], REAL64)), 5)
                call assertEquals (real([0, 0, 0, 1, -2], REAL64), apply_laplace_5p([5], real([0, 0, 0, 0, 1], REAL64)), 5)

                call assertEquals (real([0,1,0,1,-4,1,0,1,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,0,1,0,0,0,0], REAL64)), 9)
                call assertEquals (real([-4,1,0,1,0,0,0,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([1,0,0,0,0,0,0,0,0], REAL64)), 9)
                call assertEquals (real([0,1,-4,0,0,1,0,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,1,0,0,0,0,0,0], REAL64)), 9)
                call assertEquals (real([0,0,0,1,0,0,-4,1,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,0,0,0,1,0,0], REAL64)), 9)
                call assertEquals (real([0,0,0,0,0,1,0,1,-4], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,0,0,0,0,0,1], REAL64)), 9)

                call assertEquals (real([-2,1,0,1,0,0,0,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([1,0,0,0,0,0,0,0,0], REAL64), .true.), 9)
                call assertEquals (real([1,-3,1,0,1,0,0,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,1,0,0,0,0,0,0,0], REAL64), .true.), 9)
                call assertEquals (real([0,1,-2,0,0,1,0,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,1,0,0,0,0,0,0], REAL64), .true.), 9)
                call assertEquals (real([1,0,0,-3,1,0,1,0,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,1,0,0,0,0,0], REAL64), .true.), 9)
                call assertEquals (real([0,0,0,1,0,0,-2,1,0], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,0,0,0,1,0,0], REAL64), .true.), 9)
                call assertEquals (real([0,0,0,0,0,1,0,1,-2], REAL64), &
                        apply_laplace_5p([3, 3], real([0,0,0,0,0,0,0,0,1], REAL64), .true.), 9)
        end subroutine check_apply_laplace_5p

end module test_laplace
