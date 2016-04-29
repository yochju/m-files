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
    use :: stencil
    implicit none
    
contains

    !! miscfun *****************************************************************

    pure subroutine mexcumsum (siz, arrIn, arrOut) bind(C, name="mexcumsum")
        integer(c_long), value,                 intent(in)  :: siz
        real(c_double),         dimension(siz), intent(in)  :: arrIn
        real(c_double),         dimension(siz), intent(out) :: arrOut
        arrOUt = cumsum(arrIn)
    end subroutine mexcumsum

    !! stencil *****************************************************************
    
    subroutine mexstencillocs (lenIn, lenOut, siz, dims, arrOut) bind(C, name="mexstencillocs")
        integer(c_long), value,                    intent(in)  :: lenIn
        integer(c_long), value,                    intent(in)  :: lenOut
        integer(c_long),        dimension(lenIn),  intent(in)  :: siz
        integer(c_long),        dimension(lenIn),  intent(in)  :: dims
        integer(c_long),        dimension(lenOut), intent(out) :: arrOut
                
        arrOut = stencillocs(siz, dims)
    end subroutine mexstencillocs
end module cmexinterface
