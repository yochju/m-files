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
        integer(c_int64_t), value,                 intent(in)  :: siz
        real(c_double),         dimension(siz), intent(in)  :: arrIn
        real(c_double),         dimension(siz), intent(out) :: arrOut

        arrOUt = cumsum(arrIn)
    end subroutine mexcumsum

    !! stencil *****************************************************************
    
    subroutine mexstencillocs (lenIn, lenOut, siz, dims, arrOut) bind(C, name="mexstencillocs")
        integer(c_int64_t), value,                    intent(in)  :: lenIn
        integer(c_int64_t), value,                    intent(in)  :: lenOut
        integer(c_int64_t),        dimension(lenIn),  intent(in)  :: siz
        integer(c_int64_t),        dimension(lenIn),  intent(in)  :: dims
        integer(c_int64_t),        dimension(lenOut), intent(out) :: arrOut
                
        arrOut = stencillocs(siz, dims)
    end subroutine mexstencillocs

    subroutine mexstencilmask (lenIn, lenOut, siz, dims, pos, arrOut) bind(C, name="mexstencilmask")
        integer(c_int64_t), value,                    intent(in)  :: lenIn
        integer(c_int64_t), value,                    intent(in)  :: lenOut
        integer(c_int64_t),        dimension(lenIn),  intent(in)  :: siz
        integer(c_int64_t),        dimension(lenIn),  intent(in)  :: dims
        integer(c_int64_t), value,                    intent(in)  :: pos
        integer(c_int64_t),        dimension(lenOut), intent(out) :: arrOut

        logical, dimension(:), allocatable :: mask

        allocate(mask(lenOut))
        
        mask = stencilmask(siz, dims, pos)
        arrOut = 0
        where(mask) arrOut = 1

        deallocate(mask)

    end subroutine mexstencilmask

    subroutine mexcreate_5p_stencil (dims, arrOut) bind(C, name="mexcreate_5p_stencil")
        integer(c_int64_t), value,                     intent(in)  :: dims
        integer(c_int64_t),        dimension(3**dims), intent(out) :: arrOut

        logical, dimension(:), allocatable :: stencil

        allocate(stencil(3**dims))
        
        stencil = create_5p_stencil(dims)
        arrOut = 0
        where(stencil) arrOut = 1

        deallocate(stencil)
    end subroutine mexcreate_5p_stencil

    subroutine mexstencil2sparse_size (lenIn, siz, dims, mask, numel) bind(C, name="mexstencil2sparse_size")
        implicit none

        integer(c_int64_t), value,                          intent(in) :: lenIn
        integer(c_int64_t),        dimension(lenIn),        intent(in) :: siz
        integer(c_int64_t),        dimension(size(siz)),    intent(in) :: dims
        integer(c_int64_t),        dimension(product(siz)), intent(in) :: mask

        integer(c_int64_t), intent(out) :: numel
        
        logical, dimension(:), allocatable :: tmp_mask

        allocate(tmp_mask(product(siz)))

        tmp_mask = .false.
        where(.not. (mask == 0)) tmp_mask = .true.

        numel = stencil2sparse_size(siz, dims, tmp_mask)

        deallocate(tmp_mask)

    end subroutine mexstencil2sparse_size

    subroutine mexconst_stencil2sparse (lenIn, lenOut, siz, dims, mask, sten, ir, jc, a) bind(C, name="mexconst_stencil2sparse")
        implicit none
        
        integer(c_int64_t), value,                          intent(in) :: lenIn
        integer(c_int64_t), value,                          intent(in) :: lenOut
        integer(c_int64_t),        dimension(lenIn),        intent(in) :: siz
        integer(c_int64_t),        dimension(size(siz)),    intent(in) :: dims
        integer(c_int64_t),        dimension(product(siz)), intent(in) :: mask
        real(c_double),            dimension(product(siz)), intent(in) :: sten

        integer(c_int64_t), dimension(lenOut), intent(out) :: ir
        integer(c_int64_t), dimension(lenOut), intent(out) :: jc
        real(c_double),     dimension(lenOut), intent(out) :: a

        logical, dimension(:), allocatable :: tmp_mask

        allocate(tmp_mask(product(siz))) ! does this fail?
        tmp_mask = .false.
        ! where(.not. (mask == 0)) tmp_mask = .true. ! is this correct?

        call const_stencil2sparse(siz, dims, tmp_mask, sten, ir, jc, a)

        deallocate(tmp_mask)

    end subroutine mexconst_stencil2sparse

    subroutine mexstencil2sparse (lenIn, siz, dims, mask, sten, ir, jc, a) bind(C, name="mexstencil2sparse")
        implicit none
        
        integer(c_int64_t), value,                                        intent(in) :: lenIn
        integer(c_int64_t),        dimension(lenIn),                      intent(in) :: siz
        integer(c_int64_t),        dimension(size(siz)),                  intent(in) :: dims
        integer(c_int64_t),        dimension(product(siz)),               intent(in) :: mask
        real(c_double),            dimension(product(dims)*product(siz)), intent(in) :: sten

        integer(c_int64_t), dimension(count(mask > 0)*product(dims)), intent(out) :: ir
        integer(c_int64_t), dimension(count(mask > 0)*product(dims)), intent(out) :: jc
        real(c_double),     dimension(count(mask > 0)*product(dims)), intent(out) :: a

        real(c_double), dimension(:,:), allocatable :: buffer
        logical, dimension(:), allocatable :: tmp_mask

        allocate(tmp_mask(product(siz)))
        allocate(buffer(product(dims), product(siz)))

        tmp_mask = .false.
        where(.not. (mask == 0)) tmp_mask = .true.

        buffer = reshape(sten, [product(dims), product(siz)])
        call stencil2sparse(siz, dims, tmp_mask, buffer, ir, jc, a)

        deallocate(tmp_mask)
        deallocate(buffer)
    end subroutine mexstencil2sparse

end module cmexinterface

