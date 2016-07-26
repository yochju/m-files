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

module test_img_fun
        use :: fruit
!        use :: img_fun
        use :: iso_fortran_env
        use :: iso_c_binding
        implicit none

contains

        ! setup_before_all
        ! setup = setup_before_each
        subroutine setup_test_img_fun
        end subroutine setup_test_img_fun

        ! teardown_before_all
        ! teardown = teardown_before_each
        subroutine teardown_test_img_fun
        end subroutine teardown_test_img_fun

        ! subroutine check_mse_error
        !         implicit none

        !         call assertEquals(5.0D0/4.0D0, &
        !                 mse_error(real([1, 0, 2, 0], REAL64), real([0, 0, 0, 0], REAL64), 1.0D0), 1.0D-10)

        !         call assertEquals(255.0D0**2/2.0D0, &
        !                 mse_error(real([0, 1, 0, 0], REAL64), real([0, 0, 1, 0], REAL64), 255.0D0), 1.0D-10)

        !         call assertEquals(0.0D0, &
        !                 mse_error(real([1, 2, 3, 4, 5, 6], REAL64), real([1, 2, 3, 4, 5, 6], REAL64), 2.0D0), 1.0D-10)

        !         call assertEquals(0.0D0, &
        !                 mse_error(real([1, 2, 3, 4, 5, 6], REAL64), real([1, 2, 3, 4, 5, 6], REAL64), 2.0D0), 1.0D-10)
        ! end subroutine check_mse_error

        ! subroutine check_psnr_error
        !         implicit none

        !         call assertEquals(-1.0D0, &
        !                 psnr_error(real([1, 2, 3, 4, 5, 6], REAL64), real([1, 2, 3, 4, 5, 6], REAL64), 2.0D0), 1.0D-10)
        ! end subroutine check_psnr_error

        ! subroutine check_get_image_dimensions
        !         implicit none

        !         integer(kind=c_long) :: nr
        !         integer(kind=c_long) :: nc
        !         integer(kind=c_long) :: nd

        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         call get_image_dimensions ("data/pgm255-5x2-raw.pgm", nr, nc, nd)
        !         call assertEquals(int(5, INT32), int(nr, INT32))
        !         call assertEquals(int(2, INT32), int(nc, INT32))
        !         call assertEquals(int(1, INT32), int(nd, INT32))


        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         call get_image_dimensions ("data/pgm255-2x5-raw.pgm", nr, nc, nd)
        !         call assertEquals(int(2, INT32), int(nr, INT32))
        !         call assertEquals(int(5, INT32), int(nc, INT32))
        !         call assertEquals(int(1, INT32), int(nd, INT32))

        ! end subroutine check_get_image_dimensions

        ! subroutine check_get_image_pbm
        !         implicit none

        !         integer(kind=c_long) :: nr
        !         integer(kind=c_long) :: nc
        !         integer(kind=c_long) :: nd

        !         real(REAL64), dimension(:), allocatable :: c1
        !         real(REAL64), dimension(:), allocatable :: c2
        !         real(REAL64), dimension(:), allocatable :: c3

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/test-ascii-65K.pbm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-65K.pbm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], REAL64), c1, 27)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         call get_image_dimensions("data/test-ascii-255.pbm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-255.pbm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], REAL64), c1, 27)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         call get_image_dimensions("data/test-raw-65K.pbm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-65K.pbm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], REAL64), c1, 27)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         call get_image_dimensions("data/test-raw-255.pbm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-255.pbm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], REAL64), c1, 27)
        !         deallocate(c1, c2, c3)

        ! end subroutine check_get_image_pbm

        ! subroutine check_get_image_pgm
        !         implicit none

        !         integer(kind=c_long) :: nr
        !         integer(kind=c_long) :: nc
        !         integer(kind=c_long) :: nd

        !         real(REAL64), dimension(:), allocatable :: c1
        !         real(REAL64), dimension(:), allocatable :: c2
        !         real(REAL64), dimension(:), allocatable :: c3

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/pgm255-5x2-raw.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))

        !         call get_image ("data/pgm255-5x2-raw.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals (real([79, 28, 223, 17, 6, 174, 9, 115, 103, 175], REAL64)/255.0D0, c1, 10, 1.0D-8)
        !         call assertEquals(int(5, INT32), int(nr, INT32))
        !         call assertEquals(int(2, INT32), int(nc, INT32))
        !         call assertEquals(int(1, INT32), int(nd, INT32))
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/pgm255-2x5-raw.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))

        !         call get_image ("data/pgm255-2x5-raw.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals(real([114, 141, 226, 53, 135, 175, 41, 107, 64, 0], REAL64)/255.0D0, c1, 10, 1.0D-8)
        !         call assertEquals(int(2, INT32), int(nr, INT32))
        !         call assertEquals(int(5, INT32), int(nc, INT32))
        !         call assertEquals(int(1, INT32), int(nd, INT32))
        !         deallocate(c1, c2, c3)


        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-ascii-65K.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-65K.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c1, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-raw-65K.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-65K.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c1, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-ascii-255.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-255.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c1, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-raw-255.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-255.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c1, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/matlab-pgm-ascii-255.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/matlab-pgm-ascii-255.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([1, 129, 2, 130, 3, 131, 4, 132, 5, 133], REAL64)/255.0D0, c1, 10, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-matlab.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-matlab.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([1, 129, 2, 130, 3, 131, 4, 132, 5, 133], REAL64)/255.0D0, c1, 10, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/matlab-pgm-raw-255.pgm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/matlab-pgm-raw-255.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([1, 129, 2, 130, 3, 131, 4, 132, 5, 133], REAL64)/255.0D0, c1, 10, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/matlab-pgm-ascii-65K.pgm", nr, nc, nd) !! FAILS
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/matlab-pgm-ascii-65K.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([256, 33024, 512, 33280, 768, 33536, 1024, 33792, 1280, 34048], REAL64)/65535.0D0, &
        !                 c1, 10, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/matlab-pgm-raw-65K.pgm", nr, nc, nd) !! FAILS
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/matlab-pgm-raw-65K.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([256, 33024, 512, 33280, 768, 33536, 1024, 33792, 1280, 34048], REAL64)/65535.0D0, &
        !                 c1, 10, 1.0D-8)
        !         deallocate(c1, c2, c3)

        ! end subroutine check_get_image_pgm

        ! subroutine check_get_image_ppm
        !         implicit none

        !         integer(kind=c_long) :: nr
        !         integer(kind=c_long) :: nc
        !         integer(kind=c_long) :: nd

        !         real(REAL64), dimension(:), allocatable :: c1
        !         real(REAL64), dimension(:), allocatable :: c2
        !         real(REAL64), dimension(:), allocatable :: c3

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-ascii-255.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-255.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c1, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c2, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c3, 36, 1.0D-8)

        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-raw-255.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-255.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c1, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c2, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([1, 11, 21, 2, 12, 22, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, &
        !                 17, 27, 8, 18, 28, 9, 19, 29, 10, 20, 30, 254, 252, 250, 255, 253, 251], REAL64)/255.0D0, c3, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-ascii-65K.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-ascii-65K.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c1, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c2, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c3, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions("data/test-raw-65K.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/test-raw-65K.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c1, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c2, 36, 1.0D-8)
        !         call assertEquals( &
        !                 real([257, 2827, 5397,  514, 3084, 5654,  771, 3341, 5911, 1028, 3598, 6168, &
        !                 1285, 3855, 6425, 1542, 4112, 6682, 1799, 4369, 6939, 2056, 4626, 7196, 2313, 4883, &
        !                 7453, 2570, 5140, 7710, 65278, 64764, 64250, 65535, 65021, 64507], REAL64)/65535.0D0, c3, 36, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/ppm255-3x5-raw.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/ppm255-3x5-raw.ppm", nr, nc, nd, c1, c2, c3)

        !         call assertEquals( &
        !                 real([255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 0], REAL64)/255.0D0, c1, 15, 1.0D-8)
        !         call assertEquals( &
        !                 real([0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 0], REAL64)/255.0D0, c2, 15, 1.0D-8)
        !         call assertEquals( &
        !                 real([0, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0], REAL64)/255.0D0, c3, 15, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/ppm255-3x5-asc.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/ppm255-3x5-asc.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([255, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 0], REAL64)/255.0D0, c1, 15, 1.0D-8)
        !         call assertEquals( &
        !                 real([0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 255, 0], REAL64)/255.0D0, c2, 15, 1.0D-8)
        !         call assertEquals( &
        !                 real([0, 255, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0], REAL64)/255.0D0, c3, 15, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/color-monotone-inc.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/color-monotone-inc.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([10, 40, 70, 100, 130, 160], REAL64)/255.0D0, c1, 6, 1.0D-8)
        !         call assertEquals( &
        !                 real([20, 50, 80, 110, 140, 170], REAL64)/255.0D0, c2, 6, 1.0D-8)
        !         call assertEquals( &
        !                 real([30, 60, 90, 120, 150, 180], REAL64)/255.0D0, c3, 6, 1.0D-8)
        !         deallocate(c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0

        !         call get_image_dimensions ("data/color-monotone-inc-asc.ppm", nr, nc, nd)
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         call get_image ("data/color-monotone-inc.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( &
        !                 real([10, 40, 70, 100, 130, 160], REAL64)/255.0D0, c1, 6, 1.0D-8)
        !         call assertEquals( &
        !                 real([20, 50, 80, 110, 140, 170], REAL64)/255.0D0, c2, 6, 1.0D-8)
        !         call assertEquals( &
        !                 real([30, 60, 90, 120, 150, 180], REAL64)/255.0D0, c3, 6, 1.0D-8)
        !         deallocate(c1, c2, c3)

        ! end subroutine check_get_image_ppm

        ! subroutine check_write_image
        !         implicit none

        !         integer(kind=c_long) :: nr
        !         integer(kind=c_long) :: nc
        !         integer(kind=c_long) :: nd
        !         integer              :: ii

        !         real(REAL64), dimension(:), allocatable :: c1
        !         real(REAL64), dimension(:), allocatable :: c2
        !         real(REAL64), dimension(:), allocatable :: c3

        !         nr = 3
        !         nc = 2
        !         nd = 1
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         c1 = real([1, 1, 1, 0, 0, 0], REAL64)
        !         c2 = real([1, 1, 1, 0, 0, 0], REAL64)
        !         c3 = real([1, 1, 1, 0, 0, 0], REAL64)
        !         call write_image("data/test.pbm", nr, nc, nd, c1, c2, c3)
        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         c1 = 0.0D0
        !         c2 = 0.0D0
        !         c3 = 0.0D0
        !         call get_image_dimensions ("data/test.pbm", nr, nc, nd)
        !         call get_image ("data/test.pbm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([1, 1, 1, 0, 0, 0], REAL64), c1, 6)
        !         deallocate(c1, c2, c3)

        !         nr = 3
        !         nc = 2
        !         nd = 1
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         c1 = real([255,   1,   1, 0, 0, 0], REAL64)/255.0D0
        !         c2 = real([1,   255,   1, 0, 0, 0], REAL64)/255.0D0
        !         c3 = real([1,     1, 255, 0, 0, 0], REAL64)/255.0D0
        !         call write_image("data/test.pgm", nr, nc, nd, c1, c2, c3)
        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         c1 = 0.0D0
        !         c2 = 0.0D0
        !         c3 = 0.0D0
        !         call get_image_dimensions ("data/test.pgm", nr, nc, nd)
        !         call get_image ("data/test.pgm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([255, 1, 1, 0, 0, 0], REAL64)/255.0D0, c1, 6)
        !         deallocate(c1, c2, c3)

        !         nr = 2
        !         nc = 3
        !         nd = 3
        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         c1 = real([255, 125,   1, 65, 32, 10], REAL64)/255.0D0
        !         c2 = real([1,   255,   1,  0,  0,  0], REAL64)/255.0D0
        !         c3 = real([1,     1, 255,  0,  0,  0], REAL64)/255.0D0
        !         call write_image("data/test.ppm", nr, nc, nd, c1, c2, c3)
        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         c1 = 0.0D0
        !         c2 = 0.0D0
        !         c3 = 0.0D0
        !         call get_image_dimensions ("data/test.ppm", nr, nc, nd)
        !         call get_image ("data/test.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals( real([255, 125,   1, 65, 32, 10], REAL64)/255.0D0, c1, 6)
        !         call assertEquals( real([1,   255,   1,  0,  0,  0], REAL64)/255.0D0, c2, 6)
        !         call assertEquals( real([1,     1, 255,  0,  0,  0], REAL64)/255.0D0, c3, 6)
        !         deallocate(c1, c2, c3)

        !         nr = 4096
        !         nc = 4096
        !         nd = 3

        !         allocate(c1(nr*nc), c2(nr*nc), c3(nr*nc))
        !         c1 = 1.0D0
        !         c2 = 0.0D0
        !         c3 = 0.0D0

        !         call write_image("data/test-xxl.ppm", nr, nc, nd, c1, c2, c3)

        !         nr = 0
        !         nc = 0
        !         nd = 0
        !         c1 = 0.0D0
        !         c2 = 0.0D0
        !         c3 = 0.0D0

        !         call get_image_dimensions ("data/test-xxl.ppm", nr, nc, nd)
        !         write (*,*) [nr, nc, nd]
        !         call assertEquals (int([4096, 4096, 3]), int([nr, nc, nd]), 3)

        !         call get_image ("data/test-xxl.ppm", nr, nc, nd, c1, c2, c3)
        !         call assertEquals ([(1.0D0, ii=1, 4096)], c1, 4096)
        !         call assertEquals ([(0.0D0, ii=1, 4096)], c2, 4096)
        !         call assertEquals ([(0.0D0, ii=1, 4096)], c3, 4096)

        !         deallocate(c1, c2, c3)
        ! end subroutine check_write_image

        ! !! -------------------------------------------------------------------------------------------------------------------------
        ! !        subroutine test_out_of_range_io ()
        ! !                use :: fruit
        ! !                use :: netpbm
        ! !                use :: iso_c_binding
        ! !                implicit none
        ! !
        ! !                integer(kind=c_long) :: nr
        ! !                integer(kind=c_long) :: nc
        ! !                integer(kind=c_long) :: nd
        ! !                integer(kind=c_long) :: mv
        ! !                real(kind=c_double), dimension(:,:), allocatable :: data, dump1, dump2
        ! !
        ! !                nr = 2
        ! !                nc = 3
        ! !
        ! !                allocate(data(nr, nc), dump1(nr, nc), dump2(nr, nc))
        ! !
        ! !                data = reshape(real([1, -3, 312, 1, 2, 3], c_double), [nr, nc])
        ! !
        ! !                nd = 1
        ! !                mv = 255
        ! !                call write_image ("test.pgm", nr, nc, nd, mv, data, dump1, dump2)
        ! !
        ! !                data = 0.0D0
        ! !                nd = 0
        ! !                mv = 0
        ! !                call get_image_data ("test.pgm", nr, nc, nd, mv, data, dump1, dump2)
        ! !
        ! !                call assertEquals (int([2, 3, 1, 255]), int([nr, nc, nd, mv]), 4)
        ! !                call assertEquals (reshape(real([1, 0, 255, 1, 2, 3], c_double), [nr, nc]), data, int(nr), int(nc))
        ! !
        ! !                data = reshape(real([1, -2, 70000, 1, 2, 3], c_double), [nr, nc])
        ! !
        ! !                nd = 1
        ! !                mv = 65535
        ! !                call write_image ("test.pgm", nr, nc, nd, mv, data, dump1, dump2)
        ! !
        ! !                data = 0.0D0
        ! !                nd = 0
        ! !                mv = 0
        ! !
        ! !                call get_image_data ("test.pgm", nr, nc, nd, mv, data, dump1, dump2)
        ! !
        ! !                call assertEquals (int([2, 3, 1, 65535]), int([nr, nc, nd, mv]), 4)
        ! !                call assertEquals (reshape(real([1, 0, 65535, 1, 2, 3], c_double), [nr, nc]), data, int(nr), int(nc))
        ! !
        ! !                deallocate(data, dump1, dump2)
        ! !
        ! !        end subroutine test_out_of_range_io
        ! !
        ! !        subroutine test_io_large_image()
        ! !                use :: fruit
        ! !                use :: netpbm
        ! !                use :: iso_c_binding
        ! !                implicit none
        ! !
        ! !                integer(kind=c_long) :: nr
        ! !                integer(kind=c_long) :: nc
        ! !                integer(kind=c_long) :: nd
        ! !                integer(kind=c_long) :: mv
        ! !
        ! !                real(kind=c_double), dimension(:,:), allocatable :: c1
        ! !                real(kind=c_double), dimension(:,:), allocatable :: c2
        ! !                real(kind=c_double), dimension(:,:), allocatable :: c3
        ! !
        ! !                nr = 512
        ! !                nc = 512
        ! !                nd = 3
        ! !                mv = 255
        ! !                allocate(c1(nr,nc), c2(nr,nc), c3(nr,nc))
        ! !                c1 = 255.0D0
        ! !                c2 = 0.0D0
        ! !                c3 = 0.0D0
        ! !                call write_image("test.pbm", nr, nc, nd, mv, c1, c2, c3)
        ! !
        ! !                deallocate(c1, c2, c3)
        ! !
        ! !        end subroutine test_io_large_image

end module test_img_fun
