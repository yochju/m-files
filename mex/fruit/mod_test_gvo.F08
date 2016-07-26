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

module test_gvo
        use :: fruit
!        use :: gvo
        use :: iso_fortran_env
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_gvo
        end subroutine setup_test_gvo

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_gvo
        end subroutine teardown_test_gvo

        ! subroutine check_gvo
        !         implicit none
        !         real(REAL64), dimension(5) :: c, u, v, f, solgvo, solinp
        !         real(REAL64), dimension(15) :: c2, u2, v2, f2, solgvo2, solinp2

        !         f = [0.3D0, 0.9D0, 0.2D0, 0.5D0, 0.875D0]
        !         c = [0.0D0, 1.0D0, 0.0D0, 0.0D0, 1.0D0]
        !         solgvo = [0.0D0, 0.46764705882352941176D0, 0.0D0, 0.0D0, 0.68602941176470588235D0]

        !         call apply_gvo([5], 20000, c, f, u, 1)
        !         call assertEquals(solgvo, u, 5, 1D-8)

        !         u = 0.0D0
        !         call apply_gvo([5], 20000, c, f, u, 2)
        !         call assertEquals(solgvo, u, 5, 1D-8)

        !         c = [0.0D0, 0.0D0, 1.0D0, 0.0D0, 1.0D0]
        !         solgvo = [0.0D0, 0.0D0, 0.4453125D0, 0.0D0, 0.8109375D0]
        !         !
        !         u = 0.0D0
        !         call apply_gvo([5], 20000, c, f, u, 1)
        !         call assertEquals(solgvo, u, 5, 1D-8)
        !         !
        !         u = 0.0D0
        !         call apply_gvo([5], 20000, c, f, u, 2)
        !         call assertEquals(solgvo, u, 5, 1D-8)
        !         !
        !         c = [1.0D0, 1.0D0, 0.0D0, 0.0D0, 0.0D0]
        !         solgvo = [0.3D0, 0.61875D0, 0.0D0, 0.0D0, 0.0D0]
        !         solinp = [0.3D0, 0.61875D0, 0.61875D0, 0.61875D0, 0.61875D0]
        !         !
        !         u = 0.0D0
        !         call apply_gvo([5], 20000, c, f, u, 1)
        !         call assertEquals(solgvo, u, 5, 1D-8)
        !         !
        !         u = 0.0D0
        !         call apply_gvo([5], 20000, c, f, u, 2)
        !         call assertEquals(solgvo, u, 5, 1D-8)
        !         !
        !         c2 = 0.0D0
        !         f2 = 0.0D0

        !         f2 = real([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], REAL64)/15.0D0
        !         c2(1)  = 0.75D0
        !         c2(3)  = 1.0D0
        !         c2(13) = 0.3D0
        !         c2(15) = 0.6D0

        !         u2 = 0.0D0
        !         call apply_gvo([3, 5], 20000, c2, f2, u2, 1)
        !         call assertEquals([ &
        !                 -0.119589292262560D+000,  0.000000000000000D+000, 0.195621562156215D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 1.252335900256695D+000,  0.000000000000000D+000,  1.330355702236890D+000 ], u2, 15, 1.0D-10)
        !         !
        !         u2 = 0.0D0
        !         call apply_gvo([3, 5], 20000, c2, f2, u2, 2)
        !         call assertEquals([ &
        !                 -0.119589292262560D+000,  0.000000000000000D+000, 0.195621562156215D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 0.000000000000000D+000,  0.000000000000000D+000,  0.000000000000000D+000, &
        !                 1.252335900256695D+000,  0.000000000000000D+000,  1.330355702236890D+000 ], u2, 15, 1.0D-10)
        ! end subroutine check_gvo

end module test_gvo
