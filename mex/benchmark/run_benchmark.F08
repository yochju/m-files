program benchmark
    use :: iso_fortran_env
    use :: omp_lib
    use :: miscfun
    implicit none

    integer(INT64), parameter :: nruns = 10
    integer(INT64), parameter :: msize = 14
    integer(INT64)            :: ii, jj
    character(len=100)           :: buffer
    
    integer(INT64)            :: start, finish, rate
    real(REAL64), dimension(msize,nruns) :: runtime

    real(REAL64), dimension(:), allocatable :: data, dummy

    call omp_set_num_threads( 4 )

    write (OUTPUT_UNIT, *) "      --- softshrinkage ---"

    call system_clock(count_rate=rate)
    
    do jj = 1, msize

        allocate(data(2**jj), dummy(2**jj))
        call random_number(data)

        do ii = 1, nruns
            dummy = softshrinkage (2**jj, data, 0.5_REAL64)
            write (ERROR_UNIT, *) sum(dummy)
            
            call system_clock(count=start)
            dummy = softshrinkage (2**jj, data, 0.5_REAL64)
            call system_clock(count=finish)

            runtime(jj, ii) = real(finish-start)/real(rate)

            write (ERROR_UNIT, *) sum(dummy)
        end do

        deallocate(data, dummy)

    end do

    write(buffer, '(A1,I2.2,A11)') "(", nruns, "(E12.5),1X)"
    do jj = 1, msize
        write (OUTPUT_UNIT, '(I3.2,3X)', advance='no') jj
        write (OUTPUT_UNIT, trim(buffer), advance='no') runtime(jj, 1:nruns)
        write (OUTPUT_UNIT, '(4X,ES12.5)') sum(runtime(jj, 1:nruns))/real(nruns)
    end do

    !! ------------------------------------------------------------------------- !!
    
    write (OUTPUT_UNIT, *) "      --- huberloss ---"

    call system_clock(count_rate=rate)
    
    do jj = 1, msize

        allocate(data(2**jj), dummy(2**jj))
        call random_number(data)

        do ii = 1, nruns
            dummy = softshrinkage (2**jj, data, 0.5_REAL64)
            write (ERROR_UNIT, *) sum(dummy)
            
            call system_clock(count=start)
            dummy = softshrinkage (2**jj, data, 0.5_REAL64)
            call system_clock(count=finish)

            runtime(jj, ii) = real(finish-start)/real(rate)

            write (ERROR_UNIT, *) sum(dummy)
        end do

        deallocate(data, dummy)

    end do

    write(buffer, '(A1,I2.2,A11)') "(", nruns, "(E12.5),1X)"
    do jj = 1, msize
        write (OUTPUT_UNIT, '(I3.2,3X)', advance='no') jj
        write (OUTPUT_UNIT, trim(buffer), advance='no') runtime(jj, 1:nruns)
        write (OUTPUT_UNIT, '(4X,ES12.5)') sum(runtime(jj, 1:nruns))/real(nruns)
    end do
        
end program benchmark
