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

module test_array
    use :: fruit
    use :: array
    use :: iso_fortran_env
    implicit none
    public

contains

    ! setup_before_all
    ! setup = setup_before_each
    subroutine setup_test_array
    end subroutine setup_test_array

    ! teardown_before_all
    ! teardown = teardown_before_each
    subroutine teardown_test_array
    end subroutine teardown_test_array

    subroutine check_add0padding
        implicit none

        call assertEquals ([0, 2, 0], add0padding([1], [1], [2]), 3)
        call assertEquals ([0, 2, 5, 0], add0padding([2], [1], [2, 5]), 4)
        call assertEquals ([0, 0, 2, 5, 8, 0, 0], add0padding([3], [2], [2, 5, 8]), 7)
        call assertEquals ([0, 0, 0, 0, 0, 1, 2, 0, 0, 3, 4, 0, 0, 0, 0, 0], &
                add0padding([2, 2], [1, 1], [1, 2, 3, 4]), 16)
    end subroutine check_add0padding

    subroutine check_ind2sub
        implicit none

        integer(INT32) :: ii, jj, kk

        call assertEquals ([1], ind2sub ([7], 1, 1, 1), 1)
        call assertEquals ([4], ind2sub ([7], 0, 1, 3), 1)
        call assertEquals ([6], ind2sub ([7], 1, 0, 7), 1)

        call assertEquals ([2,  1], ind2sub ([4, 5], -1, 1, 0), 2)
        call assertEquals ([0, -1], ind2sub ([4, 5], 1, -1, 2), 2)

        kk = 0
        do jj = 0, 6
            do ii = 0, 4
                call assertEquals([ii, jj], ind2sub([5, 7], 0, 0, kk), 2)
                kk = kk + 1
            end do
        end do

        kk = 1
        do jj = 1, 7
            do ii = 1, 5
                call assertEquals([ii, jj], ind2sub([5, 7], 1, 1, kk), 2)
                kk = kk + 1
            end do
        end do

        kk = -2
        do jj = -2, 4
            do ii = -2, 2
                call assertEquals([ii, jj], ind2sub([5, 7], -2, -2, kk), 2)
                kk = kk + 1
            end do
        end do

        kk = 2
        do jj = -2, 4
            do ii = -2, 2
                call assertEquals([ii, jj], ind2sub([5, 7], 2, -2, kk), 2)
                kk = kk + 1
            end do
        end do
    end subroutine check_ind2sub

    subroutine check_sub2ind
        implicit none

        integer(INT32) :: ii, jj, kk

        call assertEquals (1, sub2ind([7], 1, 1, [1]))
        call assertEquals (5, sub2ind([7], 0, 1, [4]))
        call assertEquals (3, sub2ind([7], 1, 0, [4]))

        call assertEquals (0, sub2ind([4, 5], 1, -1, [2, 1]))
        call assertEquals (2, sub2ind([4, 5], -1, 1, [0,-1]))

        kk = 0
        do jj = 0, 6
            do ii = 0, 4
                call assertEquals(kk, sub2ind([5, 7], 0, 0, [ii, jj]))
                kk = kk + 1
            end do
        end do

        kk = 1
        do jj = 1, 7
            do ii = 1, 5
                call assertEquals(kk, sub2ind([5, 7], 1, 1, [ii, jj]))
                kk = kk + 1
            end do
        end do

        kk = -2
        do jj = -2, 4
            do ii = -2, 2
                call assertEquals(kk, sub2ind([5, 7], -2, -2, [ii, jj]))
                kk = kk + 1
            end do
        end do

        kk = 2
        do jj = -2, 4
            do ii = -2, 2
                call assertEquals(kk, sub2ind([5, 7], -2, 2, [ii, jj]))
                kk = kk + 1
            end do
        end do
    end subroutine check_sub2ind

    subroutine check_mirror
        implicit none

        real, dimension(3)     :: y1
        real, dimension(3,3)   :: y2
        real, dimension(3,3,3) :: y3

        call mirror (1, [1.0], y1)
        call assertEquals ([1.0, 1.0, 1.0], y1, 3)

        call mirror (1, 1, reshape([1.0], [1, 1]), y2)
        call assertEquals (reshape([1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,&
                & 1.0], [3, 3]), y2, 3, 3)

        call mirror (1, 1, 1, reshape([1.0], [1, 1, 1]), y3)
        call assertEquals ( [ &
                1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,  &
                1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,  &
                1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], &
                reshape(y3, [27]), 27)

    end subroutine check_mirror

end module test_array
