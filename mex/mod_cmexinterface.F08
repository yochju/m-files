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
        integer(C_INT64_T), value,                 intent(in)  :: siz
        real(c_double),         dimension(siz), intent(in)  :: arrIn
        real(c_double),         dimension(siz), intent(out) :: arrOut

        arrOUt = cumsum(arrIn)
    end subroutine mexcumsum

    !! stencil *****************************************************************
    
    subroutine mexstencillocs (lenIn, lenOut, siz, dims, arrOut) bind(C, name="mexstencillocs")
        integer(C_INT64_T), value,                    intent(in)  :: lenIn
        integer(C_INT64_T), value,                    intent(in)  :: lenOut
        integer(C_INT64_T),        dimension(lenIn),  intent(in)  :: siz
        integer(C_INT64_T),        dimension(lenIn),  intent(in)  :: dims
        integer(C_INT64_T),        dimension(lenOut), intent(out) :: arrOut
                
        arrOut = stencillocs(siz, dims)
    end subroutine mexstencillocs

    subroutine mexstencilmask (lenIn, lenOut, siz, dims, pos, arrOut) bind(C, name="mexstencilmask")
        integer(C_INT64_T), value,                    intent(in)  :: lenIn
        integer(C_INT64_T), value,                    intent(in)  :: lenOut
        integer(C_INT64_T),        dimension(lenIn),  intent(in)  :: siz
        integer(C_INT64_T),        dimension(lenIn),  intent(in)  :: dims
        integer(C_INT64_T), value,                    intent(in)  :: pos
        integer(C_INT64_T),        dimension(lenOut), intent(out) :: arrOut

        logical, dimension(lenOut) :: mask
        
        mask = stencilmask(siz, dims, pos)
        arrOut = 0
        where(mask) arrOut = 1

    end subroutine mexstencilmask

    subroutine mexcreate_5p_stencil (dims, arrOut) bind(C, name="mexcreate_5p_stencil")
        integer(C_INT64_T), value,                     intent(in)  :: dims
        integer(C_INT64_T),        dimension(3**dims), intent(out) :: arrOut

        logical, dimension(3**dims) :: stencil

        stencil = create_5p_stencil(dims)
        arrOut = 0
        where(stencil) arrOut = 1
    end subroutine mexcreate_5p_stencil

end module cmexinterface
