! Copyright (C) 2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
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

module test_finitedifference
    use :: fruit
    use :: finitedifference
    use :: iso_fortran_env
    implicit none
    public

contains

    ! setup_before_all
    ! setup = setup_before_each
    subroutine setup_test_finitedifference
    end subroutine setup_test_finitedifference

    ! teardown_before_all
    ! teardown = teardown_before_each
    subroutine teardown_test_finitedifference
    end subroutine teardown_test_finitedifference

    subroutine check_fd_filter_1D
        implicit none

        integer(INT32) :: siz
        real(REAL32), dimension(:), allocatable :: knots
        integer(INT32) :: order
        real(REAL32) :: grid_size
        real(REAL32) :: tolerance
        real(REAL32), dimension(:), allocatable :: coeffs
        integer(INT32) :: consistency

        tolerance = 0.0001
        
        siz = 2
        
        allocate(knots(siz))
        allocate(coeffs(siz))

        ! Forward differences
        
        order = 1
        grid_size = 1.0
        knots = [0.0, 1.0]

        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [-1.0, 1.0], coeffs, 2 )
        call assertEquals ( 1, consistency )

        grid_size = 0.5
        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [-2.0, 2.0], coeffs, 2 )
        call assertEquals ( 1, consistency )

        grid_size = 2.0
        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [-0.5, 0.5], coeffs, 2 )
        call assertEquals ( 1, consistency )

        ! Backward differences
        
        order = 1
        grid_size = 1.0
        knots = [-1.0, 0.0]

        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [-1.0, 1.0], coeffs, 2 )
        call assertEquals ( 1, consistency )

        deallocate(knots)
        deallocate(coeffs)

        siz = 3
        
        allocate(knots(siz))
        allocate(coeffs(siz))

        ! Central differences

        order = 1
        grid_size = 1.0
        knots = [-1.0, 0.0, 1.0]

        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [-0.5, 0.0, 0.5], coeffs, 3 )
        call assertEquals ( 2, consistency )

        ! Standard scheme 2nd derivative

        order = 2
        grid_size = 1.0
        knots = [-1.0, 0.0, 1.0]

        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [1.0, -2.0, 1.0], coeffs, 3 )
        call assertEquals ( 2, consistency )

        grid_size = 2.0

        call fd_filter_1D (siz, knots, order, grid_size, tolerance, coeffs, consistency)
        call assertEquals ( [1.0, -2.0, 1.0]/4.0, coeffs, 3 )
        call assertEquals ( 2, consistency )
        
        deallocate(knots)
        deallocate(coeffs)
        
    end subroutine check_fd_filter_1D


end module test_finitedifference
