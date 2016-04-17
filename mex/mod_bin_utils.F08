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

module bin_utils
        use :: iso_fortran_env
        implicit none
        save

        character(len=*), parameter :: author = "Laurent Hoeltgen"
        character(len=*), parameter :: email  = "<hoeltgen@b-tu.de>"
        character(len=*), parameter :: years  = "2013-2015"

contains

        subroutine print_license()
                write (OUTPUT_UNIT,*) "Copyright (C) ", years, " ", author, " ", email
                write (OUTPUT_UNIT,*) ""
                write (OUTPUT_UNIT,*) "This program is free software: you can redistribute it and/or modify"
                write (OUTPUT_UNIT,*) "it under the terms of the GNU General Public License as published by"
                write (OUTPUT_UNIT,*) "the Free Software Foundation, either version 3 of the License, or"
                write (OUTPUT_UNIT,*) "(at your option) any later version."
                write (OUTPUT_UNIT,*) ""
                write (OUTPUT_UNIT,*) "This program is distributed in the hope that it will be useful,"
                write (OUTPUT_UNIT,*) "but WITHOUT ANY WARRANTY; without even the implied warranty of"
                write (OUTPUT_UNIT,*) "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
                write (OUTPUT_UNIT,*) "GNU General Public License for more details."
                write (OUTPUT_UNIT,*) ""
                write (OUTPUT_UNIT,*) "You should have received a copy of the GNU General Public License"
                write (OUTPUT_UNIT,*) "along with this program.  If not, see <http://www.gnu.org/licenses/>."
                write (OUTPUT_UNIT,*) ""
                write (OUTPUT_UNIT,*) ""
        end subroutine print_license

end module bin_utils
