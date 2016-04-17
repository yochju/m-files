! Compile on windows (ifort) with
! ifort /extfor:f03 /free /c mod_cmexinterface.F08
! https://software.intel.com/en-us/articles/
!   intel-fortran-compiler-effect-of-file-extensions-on-source-form
! https://software.intel.com/en-us/forums/
!   intel-fortran-compiler-for-linux-and-mac-os-x/topic/328744
module cmexinterface
    use :: iso_fortran_env
    use :: iso_c_binding
    use :: miscfun
    implicit none
    
contains

    pure subroutine mexcumsum (siz, arrIn, arrOut) bind(C, name="mexcumsum")
        integer(c_long), value,                 intent(in)  :: siz
        real(c_double),         dimension(siz), intent(in)  :: arrIn
        real(c_double),         dimension(siz), intent(out) :: arrOut
        arrOUt = cumsum(arrIn)
    end subroutine mexcumsum

end module cmexinterface
