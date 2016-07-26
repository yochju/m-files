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

module test_inpainting
        use :: fruit
!        use :: inpainting
        use :: iso_fortran_env
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_inpainting
        end subroutine setup_test_inpainting

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_inpainting
        end subroutine teardown_test_inpainting

        ! subroutine check_apply_inpainting_5p
        !         implicit none

        !         call assertEquals (real(-1*[0, 0, 0, 0, -6], REAL64), apply_inpainting_5p([5], real([1, 2, 3, 4, 5], REAL64), &
        !                 real([0, 0, 0, 0, 0], REAL64)), 5)
        !         call assertEquals (real(-1*[-1, 1, 0, 0, 0, -1, -5], REAL64), &
        !                 apply_inpainting_5p([7], real([1, 1, 2, 3, 4, 5, 5], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0], REAL64)), 7)

        !         call assertEquals (real([1, 2, 0, 0, 1], REAL64), apply_inpainting_5p([5], real([1, 2, 3, 4, 5], REAL64), &
        !                 real([1, 1, 0, 0, 0], REAL64), .true.), 5)
        !         call assertEquals (real([-1, 0, 0, 0, 5], REAL64), apply_inpainting_5p([5], real([1, 2, 3, 4, 5], REAL64), &
        !                 real([0, 0, 0, 0, 1], REAL64), .true.), 5)

        !         call assertEquals (real(-1*[0, 1, -2, 1, 0], REAL64), apply_inpainting_5p([5], real([0, 0, 1, 0, 0], REAL64), &
        !                 real([0, 0, 0, 0, 0], REAL64)), 5)
        !         call assertEquals (real(-1*[-2, 1, 0, 0, 0], REAL64), apply_inpainting_5p([5], real([1, 0, 0, 0, 0], REAL64), &
        !                 real([0, 0, 0, 0, 0], REAL64)), 5)
        !         call assertEquals (real(-1*[0, 0, 0, 1, -2], REAL64), apply_inpainting_5p([5], real([0, 0, 0, 0, 1], REAL64), &
        !                 real([0, 0, 0, 0, 0], REAL64)), 5)

        !         call assertEquals (real(-1*[0,1,0,1,-4,1,0,1,0], REAL64), &
        !                 apply_inpainting_5p([3, 3], real([0,0,0,0,1,0,0,0,0], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0], REAL64)), 9)
        !         call assertEquals (real(-1*[-4,1,0,1,0,0,0,0,0], REAL64), &
        !                 apply_inpainting_5p([3, 3], real([1,0,0,0,0,0,0,0,0], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0], REAL64)), 9)
        !         call assertEquals (real(-1*[0,1,-4,0,0,1,0,0,0], REAL64), &
        !                 apply_inpainting_5p([3, 3], real([0,0,1,0,0,0,0,0,0], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0], REAL64)), 9)
        !         call assertEquals (real(-1*[0,0,0,1,0,0,-4,1,0], REAL64), &
        !                 apply_inpainting_5p([3, 3], real([0,0,0,0,0,0,1,0,0], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0], REAL64)), 9)
        !         call assertEquals (real(-1*[0,0,0,0,0,1,0,1,-4], REAL64), &
        !                 apply_inpainting_5p([3, 3], real([0,0,0,0,0,0,0,0,1], REAL64), &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0], REAL64)), 9)
        ! end subroutine check_apply_inpainting_5p

        ! subroutine check_apply_inpainting_T_5p
        !         implicit none

        !         call assertEquals (real([1, -1, 2, 0, 1], REAL64), apply_inpainting_T_5p([5], real([1, 2, 3, 4, 5], REAL64), &
        !                 real([1, 1, 0, 0, 0], REAL64), .true.), 5)
        !         call assertEquals (real([-1, 0, 0, 5, 1], REAL64), apply_inpainting_T_5p([5], real([1, 2, 3, 4, 5], REAL64), &
        !                 real([0, 0, 0, 0, 1], REAL64), .true.), 5)

        !         call assertEquals (real([1, 2, 3, 4, 5], REAL64), apply_inpainting_T_5p([5], &
        !                 real([1, 2, 3, 4, 5], REAL64), real([1, 1, 1, 1, 1], REAL64)), 5)

        !         call assertEquals (real([ &
        !                 0.219791666666667D0, -0.1156250D0, 4.3750D-002, -0.213541666666667D0, &
        !                 0.186458333333333D0, -9.374999999999994D-003, 0.132291666666667D0, &
        !                 -0.108333333333333D0, -0.239583333333333D0, 0.1656250D0, &
        !                 7.604166666666673D-002, 1.3156250D0, 0.308333333333333D0, &
        !                 1.018750D0, 3.333333333333338D-002], REAL64), apply_inpainting_T_5p([3, 5], &
        !                 real([9, 3, 4, 1, 6, 3, 7, 2, 0, 13, 15, 63, 25, 64, 19], REAL64)/64.0D0, &
        !                 real([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], REAL64)/15.0D0, .true.), 15, 1.0D-8)

        ! end subroutine check_apply_inpainting_T_5p

        ! subroutine check_power_iteration_inpainting
        !         implicit none

        !         call assertEquals(1.0D0, power_iteration_inpainting([5], real([1, 1, 1, 1, 1], REAL64), 500, &
        !                 real([0, 0, 0, 0, 0], REAL64)), 1.0D-6)
        !         call assertEquals(1.0D0, power_iteration_inpainting([5], real([1, 1, 1, 1, 1], REAL64), 500, &
        !                 real([1, 1, 1, 1, 1], REAL64)), 1.0D-6)

        !         call assertEquals(3.4142135623730950488D0, power_iteration_inpainting([5], real([1, 0, 0, 0, 1], REAL64), 500, &
        !                 real([0, 0, 0, 0, 0], REAL64)), 1.0D-6)
        !         call assertEquals(3.4142135623730950488D0, power_iteration_inpainting([5], real([1, 0, 0, 0, 1], REAL64), 500, &
        !                 real([1, 1, 1, 1, 1], REAL64)), 1.0D-6)

        !         call assertEquals(3.0D0, power_iteration_inpainting([5], real([1, 1, 0, 0, 1], REAL64), 500, &
        !                 real([0, 0, 0, 0, 0], REAL64)), 1.0D-6) !! Problably failing due to 0 initialisation.
        !         call assertEquals(3.0D0, power_iteration_inpainting([5], real([1, 1, 0, 0, 1], REAL64), 500, &
        !                 real([1, 1, 1, 1, 1], REAL64)), 1.0D-6)

        !         call assertEquals(3.2469796037174670611D0, power_iteration_inpainting([5], real([1, 1, 0, 0, 0], REAL64), 500, &
        !                 real([0, 0, 0, 0, 0], REAL64)), 1.0D-6) !! Problably failing due to 0 initialisation.
        !         call assertEquals(3.2469796037174670611D0, power_iteration_inpainting([5], real([1, 1, 0, 0, 0], REAL64), 500, &
        !                 real([1, 1, 1, 1, 1], REAL64)), 1.0D-6)

        !         call assertEquals(4.518781989175074D0, power_iteration_inpainting([3, 5], &
        !                 real([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], REAL64)/15.0D0, 500, &
        !                 real([0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0], REAL64)), 1.0D-6)
        !         call assertEquals(4.518781989175074D0, power_iteration_inpainting([3, 5], &
        !                 real([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], REAL64)/15.0D0, 500, &
        !                 real([1, 1, 1, 1, 1, 1, 1, 1, 1,  1,  1,  1,  1,  1,  1], REAL64)), 1.0D-6)
        ! end subroutine check_power_iteration_inpainting

        ! subroutine check_inpainting_5p_sparse_coo
        !         implicit none

        !         integer(INT32), dimension(13) :: ir, jc
        !         real(REAL64),   dimension(13) :: a

        !         call inpainting_5p_sparse_coo([5], real([0, 0, 0, 0, 0], REAL64), ir, jc, a, .true.)
        !         call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
        !         call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
        !         call assertEquals(real([1, -1, -1, 2, -1, -1, 2, -1, -1, 2, -1, -1, 1], REAL64), a, 13)

        !         call inpainting_5p_sparse_coo([5], real([1, 1, 1, 1, 1], REAL64), ir, jc, a, .true.)
        !         call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
        !         call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
        !         call assertEquals(real([1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1], REAL64), a, 13)

        !         call inpainting_5p_sparse_coo([5], real([0, 1, 0, 1, 0], REAL64), ir, jc, a, .true.)
        !         call assertEquals([1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5], ir, 13)
        !         call assertEquals([1, 2, 1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5], jc, 13)
        !         call assertEquals(real([1, -1, 0, 1, 0, -1, 2, -1, 0, 1, 0, -1, 1], REAL64), a, 13)
        ! end subroutine check_inpainting_5p_sparse_coo

        ! subroutine check_solve_inpainting
        !         implicit none
        !         real(REAL64), dimension(5) :: u1D, c1D, f1D, v1D
        !         real(REAL64), dimension(5) :: c, u, f, solgvo, solinp

        !         c1D = real([1, 0, 1, 0, 1], REAL64)
        !         f1D = real([1, 2, 3, 4, 5], REAL64)
        !         v1D = real([1, 2, 3, 4, 5], REAL64)

        !         call solve_inpainting ([5], c1D, f1D, .false., u1D, 2)
        !         call assertEquals(real([1, 2, 3, 4, 5], REAL64), u1D, 5, 1D-8)

        !         v1D = real([2, 0, 6, 0, 7], REAL64)

        !         call solve_inpainting([5], c1D, f1D, .true., u1D, 2)
        !         call assertEquals(real([2, 0, 6, 0, 7], REAL64), u1D, 5, 1D-8)

        !         c1D = real([0.1D0, 0.0D0, 0.1D0, 0.0D0, 1.0D0], REAL64)
        !         f1D = real([1, 2, 3, 4, 5], REAL64)
        !         v1D = real([3.5899280575539568345D0, 3.8776978417266187050D0, 4.1654676258992805755D0, &
        !                 4.5827338129496402878D0, 5.0D0], REAL64)

        !         call solve_inpainting([5], c1D, f1D, .false., u1D, 2)
        !         call assertEquals(v1D, u1D, 5, 1D-8)

        !         v1D = real([1.3525179856115107914D0, 0.0D0, 1.2086330935251798561D0, 0.0D0, &
        !                 12.438848920863309353D0], REAL64)

        !         call solve_inpainting([5], c1D, f1D, .true., u1D, 2)
        !         call assertEquals(v1D, u1D, 5, 1D-8)

        !         c = [0.0D0, 1.0D0, 0.0D0, 0.0D0, 1.0D0]
        !         solgvo = [0.0D0, 0.46764705882352941176D0, 0.0D0, 0.0D0, 0.68602941176470588235D0]
        !         solinp = [0.46764705882352941176D0, 0.46764705882352941176D0, 0.54044117647058823529D0, 0.61323529411764705882D0, &
        !                 0.68602941176470588235D0]

        !         call solve_inpainting([5], c, solgvo, .false., u, 2)
        !         call assertEquals(solinp, u, 5, 1D-8)

        !         c = [0.0D0, 0.0D0, 1.0D0, 0.0D0, 1.0D0]
        !         solgvo = [0.0D0, 0.0D0, 0.4453125D0, 0.0D0, 0.8109375D0]
        !         solinp = [0.4453125D0, 0.4453125D0, 0.4453125D0, 0.628125D0, 0.8109375D0]

        !         call solve_inpainting([5], c, solgvo, .false., u, 2)
        !         call assertEquals(solinp, u, 5, 1D-8)

        !         c = [1.0D0, 1.0D0, 0.0D0, 0.0D0, 0.0D0]
        !         solgvo = [0.3D0, 0.61875D0, 0.0D0, 0.0D0, 0.0D0]
        !         solinp = [0.3D0, 0.61875D0, 0.61875D0, 0.61875D0, 0.61875D0]

        !         call solve_inpainting([5], c, solgvo, .false., u, 2)
        !         call assertEquals(solinp, u, 5, 1D-8)
        ! end subroutine check_solve_inpainting
end module test_inpainting
