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

module test_miscfun
    use :: fruit
    use :: miscfun
    use :: iso_fortran_env
    implicit none
    public

contains

    ! setup_before_all
    ! setup = setup_before_each
    subroutine setup_test_miscfun
    end subroutine setup_test_miscfun

    ! teardown_before_all
    ! teardown = teardown_before_each
    subroutine teardown_test_miscfun
    end subroutine teardown_test_miscfun

    subroutine check_cumsum
        implicit none

        call assertEquals([3, 7, 12, 18, 25, 26, 28, 31, 35], &
                cumsum([3, 4, 5, 6, 7, 1, 2, 3, 4]), 9)
        call assertEquals(real([3, 7, 12, 18, 25, 26, 28, 31, 35], REAL64), &
                cumsum(real([3, 4, 5, 6, 7, 1, 2, 3, 4], REAL64)), 9)
    end subroutine check_cumsum

    subroutine check_cumprod
        implicit none

        call assertEquals([1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800], &
                cumprod([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]), 11)
        call assertEquals(real([1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800], REAL64), &
                cumprod(real([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], REAL64)), 11)
    end subroutine check_cumprod

    subroutine check_outerproduct
        implicit none

        call assertEquals (reshape([4, 8, 12, 5, 10, 15, 6, 12, 18], [3, 3]), &
                outerproduct([1, 2, 3], [4, 5, 6]), 3, 3)

        call assertEquals (reshape(real([4, 8, 12, 5, 10, 15, 6, 12, 18], REAL64), [3, 3]), &
                outerproduct(real([1, 2, 3], REAL64), real([4, 5, 6], REAL64)), 3, 3)
    end subroutine check_outerproduct

    subroutine check_scatter_add
        implicit none

        integer(INT32), dimension(4) :: src, dst
        integer(INT32), dimension(3) :: ind
        real(REAL64),   dimension(3) :: src2, dst2

        src = [10, 20, 30, 0]
        ind = [3, 2, 1]
        dst = [30, 20, 10, 7]

        src2 = [4.0D0, -9.0D0, 23.0D0]
        dst2 = [0.0D0, 0.0D0, 0.0D0]

        call scatter_add (src, ind, dst)
        call assertEquals ([60, 40, 20, 7], dst, 3)

        call scatter_add (src2, ind, dst2)
        call assertEquals ([23.0D0, -9.0D0, 4.0D0], dst2, 3)
    end subroutine check_scatter_add

    subroutine check_repelem
        implicit none

        call assertEquals([1, 1, 1], repelem([1], 3), 3)
        call assertEquals([1, 1, 2, 2, 3, 3], repelem([1, 2, 3], 2), 6)
        call assertEquals([1, 1, 1, 6, 6, 6], repelem([1, 6], 3), 6)
    end subroutine check_repelem

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

end module test_miscfun
