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

module test_array_ops
        use :: fruit
        use :: array_ops
        use :: iso_fortran_env
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_array_ops
        end subroutine setup_test_array_ops

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_array_ops
        end subroutine teardown_test_array_ops

        subroutine check_softshrinkage
                implicit none

                call assertEquals (real([0.0, 0.5, 1.5, 2.5], REAL64), softshrinkage(real([1, 2, 3, 4], REAL64), 1.5D0), 4)

                call assertEquals (reshape(real([0.0, 0.5, 1.5, 2.5], REAL64), [2, 2]), &
                        reshape(softshrinkage(real([1, 2, 3, 4], REAL64), 1.5D0), [2, 2]), 2, 2)

                call assertEquals(softshrinkage([-3.0D0, -2.0D0, -1.0D0, 0.0D0, 1.0D0, 2.0D0, 3.0D0], 2.0D0), &
             [-1.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0, 1.0D0], 7)
        call assertEquals(softshrinkage([-3.0D0, -2.0D0, -1.0D0, 0.0D0, 1.0D0, 2.0D0, 3.0D0], -2.0D0), &
             [-1.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0, 1.0D0], 7)


        end subroutine check_softshrinkage

        subroutine check_huberloss
                implicit none
        call assertEquals(huberloss([-2.0D0, -1.0D0, 0.0D0, 1.0D0, 2.0D0], 2.0D0), &
             [2.0D0, 0.5D0, 0.0D0, 0.5D0, 2.0D0], 5)
        call assertEquals(huberloss([-2.0D0, -1.0D0, 0.0D0, 1.0D0, 2.0D0], -2.0D0), &
             [2.0D0, 0.5D0, 0.0D0, 0.5D0, 2.0D0], 5)
        call assertEquals(huberloss([-4.0D0, -3.0D0, 3.0D0, 4.0D0], 2.0D0), &
             [6.0D0, 4.0D0, 4.0D0, 6.0D0], 4)
        call assertEquals(huberloss([-4.0D0, -3.0D0, 3.0D0, 4.0D0], -2.0D0), &
             [6.0D0, 4.0D0, 4.0D0, 6.0D0], 4)

        end subroutine check_huberloss

end module test_array_ops
