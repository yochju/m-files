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

module img_fun
        use :: iso_fortran_env
        implicit none

contains

        pure function mse_error(u, f, mv) result(mse)
                implicit none

                real(REAL64),   dimension(:),       intent(in) :: u
                real(REAL64),   dimension(size(u)), intent(in) :: f
                real(REAL64),                       intent(in) :: mv

                real(REAL64) :: mse

                mse = sum((mv*(u-f))**2)/real (size(u), REAL64)
        end function mse_error

        pure function psnr_error(u, f, mv) result(psnr)
                implicit none

                real(REAL64), dimension(:),       intent(in) :: u
                real(REAL64), dimension(size(u)), intent(in) :: f
                real(REAL64),                     intent(in) :: mv

                real(REAL64) :: psnr

                if (mse_error(u, f, mv) > 0.0D0) then
                        psnr = 20.0D0 * log10(mv/sqrt(mse_error(u, f, 1.0D0)))
                else
                        psnr = -1.0D0
                end if
        end function psnr_error

        !> @brief Read image size for any pnm, pam file.
        !! @param [in]  name Name of the file to be read.
        !! @param [out] nr   Number of rows (1st dimension)
        !! @param [out] nc   Number of columns (2nd dimension)
        !! @param [out] nd   Number of samples in each pixel. (number of channels)
        subroutine get_image_dimensions (name, nr, nc, nd)
                use :: iso_c_binding
                implicit none

                character(len=*, kind=c_char), intent(in)  :: name

                integer(kind=c_long), intent(out) :: nr
                integer(kind=c_long), intent(out) :: nc
                integer(kind=c_long), intent(out) :: nd

                integer(INT32)                          :: erro
                character(len=len(name)+1, kind=c_char) :: fname

                interface
                        function pixfiles_read_size (height, width, depth, fname) bind(c)
                                use :: iso_c_binding
                                implicit none

                                integer(kind=c_long)                 :: height
                                integer(kind=c_long)                 :: width
                                integer(kind=c_long)                 :: depth
                                character(kind=c_char), dimension(*) :: fname

                                integer(kind=c_int)                  :: pixfiles_read_size
                        end function pixfiles_read_size
                end interface

                ! We are passing a string to a C-function, which expects it to be
                ! Null-terminated.
                fname = trim (name)//CHAR(0)
                erro = pixfiles_read_size (nr, nc, nd, fname)
                !> @todo Error checking
        end subroutine get_image_dimensions

        !> @brief Read image data
        !!
        !! @param [in]  name  Name of the file to be read. May not be longer than 128 chars.
        !! @param [in]  nr    Number of rows
        !! @param [in]  nc    Number of columns
        !! @param [out] pixel Array containing the image data.
        subroutine get_image (name, nr, nc, nd, c1, c2, c3)
                use :: iso_c_binding
                implicit none

                character(len=*, kind=c_char), intent(in) :: name
                integer(kind=c_long),          intent(in) :: nr
                integer(kind=c_long),          intent(in) :: nc
                integer(kind=c_long),          intent(in) :: nd

                real(kind=REAL64), dimension(nr*nc),           intent(out) :: c1
                real(kind=REAL64), dimension(nr*nc), optional, intent(out) :: c2
                real(kind=REAL64), dimension(nr*nc), optional, intent(out) :: c3

                real(kind=c_double), dimension(:), allocatable :: c1d
                real(kind=c_double), dimension(:), allocatable :: c2d
                real(kind=c_double), dimension(:), allocatable :: c3d

                integer(kind=c_int) :: erro
                character(len=len(name)+1, kind=c_char) :: fname

                interface
                        function pixfiles_read_image (nr, nc, nd, c1, c2, c3, fname) bind(c)
                                use :: iso_c_binding
                                implicit none

                                integer(kind=c_long)                     :: nr
                                integer(kind=c_long)                     :: nc
                                integer(kind=c_long)                     :: nd
                                real(kind=c_double),    dimension(nr*nc) :: c1
                                real(kind=c_double),    dimension(nr*nc) :: c2
                                real(kind=c_double),    dimension(nr*nc) :: c3
                                character(kind=c_char), dimension(*)     :: fname

                                integer(kind=c_int)                      :: pixfiles_read_image
                        end function pixfiles_read_image
                end interface

                allocate(c1d(nr*nc), c2d(nr*nc), c3d(nr*nc))

                ! We are passing a string to a C-function, which expects it to be
                ! Null-terminated.
                fname = trim(name)//CHAR(0)
                erro = pixfiles_read_image (nr, nc, nd, c1d, c2d, c3d, fname)

                !! TODO: There's a bug here, if called like get_image_data( ..., x, x, x)
                !! This returns wrong values. Having an interfaces would be a way to fix the problem.
                c1 = real(reshape(transpose(reshape(c1d, [nc, nr])), [nr*nc]), REAL64)

                if ((nd > 1) .and. present(c2)) then
                        c2 = real(reshape(transpose(reshape(c2d, [nc, nr])), [nr*nc]), REAL64)
                end if

                if ((nd > 2) .and. present(c3)) then
                        c3 = real(reshape(transpose(reshape(c3d, [nc, nr])), [nr*nc]), REAL64)
                end if

                deallocate(c1d, c2d, c3d)
        end subroutine get_image

        !> @brief Write image data to disk
        !!
        !! @param [in] name  Name of the file to be written. May not be longer than 128 chars.
        !! @param [in] nr    Number of rows
        !! @param [in] nc    Number of columns
        !! @param [in] pixel Array containing the image data.
        !!
        !! @todo Write interface for 1 and 3 channel images.
        subroutine write_image (name, nr, nc, nd, c1, c2, c3)
                use :: iso_c_binding
                implicit none

                character(len=*, kind=c_char),                             intent(in) :: name
                integer(kind=c_long),                                      intent(in) :: nr
                integer(kind=c_long),                                      intent(in) :: nc
                integer(kind=c_long),                                      intent(in) :: nd
                real(REAL64),                  dimension(nr*nc),           intent(in) :: c1
                real(REAL64),                  dimension(nr*nc), optional, intent(in) :: c2
                real(REAL64),                  dimension(nr*nc), optional, intent(in) :: c3

                real(kind=c_double), dimension(:), allocatable :: c1d, c2d, c3d
                integer(kind=c_int)                            :: erro
                character(len=len(name)+1, kind=c_char)        :: fname

                interface
                        function pixfiles_write_image (nr, nc, nd, r, g, b, fname) bind(c)
                                use :: iso_c_binding
                                implicit none

                                integer(kind=c_long)                     :: nr
                                integer(kind=c_long)                     :: nc
                                integer(kind=c_long)                     :: nd
                                real(kind=c_double),    dimension(nr*nc) :: r, g, b
                                character(kind=c_char), dimension(*)     :: fname
                                integer(kind=c_int)                      :: pixfiles_write_image
                        end function pixfiles_write_image
                end interface

                allocate(c1d(nr*nc), c2d(nr*nc), c3d(nr*nc))

                ! We are passing a string to a C-function, which expects it to be
                ! Null-terminated. We chop data outside of the admissible range to make
                ! the behavior more prdeictable.
                fname = trim(name)//CHAR(0)

                c1d = real(reshape(transpose(reshape(c1, [nr, nc])), [nr*nc]), c_double)

                if ((nd > 1) .and. present(c2)) then
                        c2d = real(reshape(transpose(reshape(c2, [nr, nc])), [nr*nc]), c_double)
                end if

                if (nd > 2) then
                        c3d = real(reshape(transpose(reshape(c3, [nr, nc])), [nr*nc]), c_double)
                end if

                erro = pixfiles_write_image (nr, nc, nd, c1d, c2d, c3d, fname)

                deallocate(c1d, c2d, c3d)
        end subroutine write_image
end module
