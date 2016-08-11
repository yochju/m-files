program fruit_driver
    use :: fruit
    use :: test_array
    ! use :: test_array_ops
    ! use :: test_gvo
    ! use :: test_img_fun
    ! use :: test_inpainting
    ! use :: test_laplace
    use :: test_miscfun
    use :: test_sparse
    use :: test_stencil
    implicit none

    call init_fruit

    !! array

    call setup_test_array
    write (*,*) ".. running test: check_add0padding"
    call set_unit_name('check_add0padding')
    call run_test_case(check_add0padding, "check_add0padding")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_array

    call setup_test_array
    write (*,*) ".. running test: check_ind2sub"
    call set_unit_name('check_ind2sub')
    call run_test_case(check_ind2sub, "check_ind2sub")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_array

    call setup_test_array
    write (*,*) ".. running test: check_sub2ind"
    call set_unit_name('check_sub2ind')
    call run_test_case(check_sub2ind, "check_sub2ind")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_array

    call setup_test_array
    write (*,*) ".. running test: check_mirror"
    call set_unit_name('check_mirror')
    call run_test_case(check_mirror, "check_mirror")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_array

    ! !! array_ops

    ! call setup_test_array_ops
    ! write (*,*) ".. running test: check_softshrinkage"
    ! call set_unit_name('check_softshrinkage')
    ! call run_test_case(check_softshrinkage, "check_softshrinkage")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_array_ops

    ! call setup_test_array_ops
    ! write (*,*) ".. running test: check_huberloss"
    ! call set_unit_name('check_huberloss')
    ! call run_test_case(check_softshrinkage, "check_huberloss")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_array_ops

    ! !! gvo

    ! call setup_test_gvo
    ! write (*,*) ".. running test: check_gvo"
    ! call set_unit_name('check_gvo')
    ! call run_test_case(check_gvo, "check_gvo")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_gvo

    ! !! img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_mse_error"
    ! call set_unit_name('check_mse_error')
    ! call run_test_case(check_mse_error, "check_mse_error")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_psnr_error"
    ! call set_unit_name('check_psnr_error')
    ! call run_test_case(check_psnr_error, "check_psnr_error")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_get_image_dimensions"
    ! call set_unit_name('check_get_image_dimensions')
    ! call run_test_case(check_get_image_dimensions, "check_get_image_dimensions")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_get_image_pbm"
    ! call set_unit_name('check_get_image_pbm')
    ! call run_test_case(check_get_image_pbm, "check_get_image_pbm")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_get_image_pgm"
    ! call set_unit_name('check_get_image_pgm')
    ! call run_test_case(check_get_image_pgm, "check_get_image_pgm")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_get_image_ppm"
    ! call set_unit_name('check_get_image_ppm')
    ! call run_test_case(check_get_image_ppm, "check_get_image_ppm")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! call setup_test_img_fun
    ! write (*,*) ".. running test: check_write_image"
    ! call set_unit_name('check_write_image')
    ! call run_test_case(check_write_image, "check_write_image")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_img_fun

    ! !! inpainting

    ! call setup_test_inpainting
    ! write (*,*) ".. running test: check_apply_inpainting_5p"
    ! call set_unit_name('check_apply_inpainting_5p')
    ! call run_test_case(check_apply_inpainting_5p, "check_apply_inpainting_5p")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_inpainting

    ! call setup_test_inpainting
    ! write (*,*) ".. running test: check_apply_inpainting_T_5p"
    ! call set_unit_name('check_apply_inpainting_T_5p')
    ! call run_test_case(check_apply_inpainting_T_5p, "check_apply_inpainting_T_5p")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_inpainting

    ! call setup_test_inpainting
    ! write (*,*) ".. running test: check_power_iteration_inpainting"
    ! call set_unit_name('check_power_iteration_inpainting')
    ! call run_test_case(check_power_iteration_inpainting, "check_power_iteration_inpainting")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_inpainting

    ! call setup_test_inpainting
    ! write (*,*) ".. running test: check_inpainting_5p_sparse_coo"
    ! call set_unit_name('check_inpainting_5p_sparse_coo')
    ! call run_test_case(check_inpainting_5p_sparse_coo, "check_inpainting_5p_sparse_coo")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_inpainting

    ! call setup_test_inpainting
    ! write (*,*) ".. running test: check_solve_inpainting"
    ! call set_unit_name('check_solve_inpainting')
    ! call run_test_case(check_solve_inpainting, "check_solve_inpainting")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_inpainting

    ! !! laplace

    ! call setup_test_laplace
    ! write (*,*) ".. running test: check_stencil_laplace_5p"
    ! call set_unit_name('check_stencil_laplace_5p')
    ! call run_test_case(check_stencil_laplace_5p, "check_stencil_laplace_5p")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_laplace

    ! call setup_test_laplace
    ! write (*,*) ".. running test: check_laplace_5p_sparse_coo"
    ! call set_unit_name('check_laplace_5p_sparse_coo')
    ! call run_test_case(check_laplace_5p_sparse_coo, "check_laplace_5p_sparse_coo")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_laplace

    ! call setup_test_laplace
    ! write (*,*) ".. running test: check_apply_laplace_5p"
    ! call set_unit_name('check_apply_laplace_5p')
    ! call run_test_case(check_apply_laplace_5p, "check_apply_laplace_5p")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_laplace

    ! !! miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_cumsum"
    call set_unit_name('check_cumsum')
    call run_test_case(check_cumsum, "check_cumsum")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_cumprod"
    call set_unit_name('check_cumprod')
    call run_test_case(check_cumprod, "check_cumprod")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_outerproduct"
    call set_unit_name('check_outerproduct')
    call run_test_case(check_outerproduct, "check_outerproduct")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_scatter_add"
    call set_unit_name('check_scatter_add')
    call run_test_case(check_scatter_add, "check_scatter_add")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_repelem"
    call set_unit_name('check_repelem')
    call run_test_case(check_repelem, "check_repelem")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun

    call setup_test_miscfun
    write (*,*) ".. running test: check_quicksort"
    call set_unit_name('check_quicksort')
    call run_test_case(check_quicksort, "check_quicksort")
    write (*,*)
    write (*,*) ".. done."
    write (*,*) ""
    call teardown_test_miscfun
    
    ! !! sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_fullnnz"
    call set_unit_name('check_fullnnz')
    call run_test_case(check_fullnnz, "check_fullnnz")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_dnscoo"
    call set_unit_name('check_dnscoo')
    call run_test_case(check_dnscoo, "check_dnscoo")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_dnscoo"
    call set_unit_name('check_dnscoo')
    call run_test_case(check_dnscoo, "check_dnscoo")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_coodns"
    call set_unit_name('check_coodns')
    call run_test_case(check_coodns, "check_coodns")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_coocsr"
    call set_unit_name('check_coocsr')
    call run_test_case(check_coocsr, "check_coocsr")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_csrcoo"
    call set_unit_name('check_csrcoo')
    call run_test_case(check_csrcoo, "check_csrcoo")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_csrtranspose"
    call set_unit_name('check_csrtranspose')
    call run_test_case(check_csrtranspose, "check_csrtranspose")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse
    
    call setup_test_sparse
    write(*,*) ".. running test: check_diamua"
    call set_unit_name('check_diamua')
    call run_test_case(check_diamua, "check_diamua")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse
    
    call setup_test_sparse
    write(*,*) ".. running test: check_amux"
    call set_unit_name('check_amux')
    call run_test_case(check_amux, "check_amux")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_aplb"
    call set_unit_name('check_aplb')
    call run_test_case(check_aplb, "check_aplb")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse

    call setup_test_sparse
    write(*,*) ".. running test: check_csrsort"
    call set_unit_name('check_csrsort')
    call run_test_case(check_csrsort, "check_csrsort")
    write(*,*) ""
    write(*,*) ".. done."
    write(*,*) ""
    call teardown_test_sparse
    
    
    ! !! stencil

    ! !        call setup_test_stencil
    ! !        write (*,*) ".. running test: check_get_neighbour_mask_1"
    ! !        call set_unit_name('check_get_neighbour_mask_1')
    ! !        call run_test_case(check_get_neighbour_mask_1, "check_get_neighbour_mask_1")
    ! !        write(*,*) ""
    ! !        write(*,*) ".. done."
    ! !        write(*,*) ""
    ! !        call teardown_test_stencil
    ! !
    ! !        call setup_test_stencil
    ! !        write (*,*) ".. running test: check_get_neighbour_mask_2"
    ! !        call set_unit_name('check_get_neighbour_mask_2')
    ! !        call run_test_case(check_get_neighbour_mask_2, "check_get_neighbour_mask_2")
    ! !        write(*,*) ""
    ! !        write(*,*) ".. done."
    ! !        write(*,*) ""
    ! !        call teardown_test_stencil
    ! !
    ! !        call setup_test_stencil
    ! !        write (*,*) ".. running test: check_stencilcoo_1"
    ! !        call set_unit_name('check_stencilcoo_1')
    ! !        call run_test_case(check_stencilcoo_1, "check_stencilcoo_1")
    ! !        write(*,*) ""
    ! !        write(*,*) ".. done."
    ! !        write(*,*) ""
    ! !        call teardown_test_stencil
    ! !
    ! !        call setup_test_stencil
    ! !        write (*,*) ".. running test: check_stencilcoo_2"
    ! !        call set_unit_name('check_stencilcoo_2')
    ! !        call run_test_case(check_stencilcoo_2, "check_stencilcoo_2")
    ! !        write(*,*) ""
    ! !        write(*,*) ".. done."
    ! !        write(*,*) ""
    ! !        call teardown_test_stencil
    ! !
    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_stencillocs"
    ! call set_unit_name('check_stencillocs')
    ! call run_test_case(check_stencillocs, "check_stencillocs")
    ! write(*,*) ""
    ! write(*,*) ".. done."
    ! write(*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_stencilmask"
    ! call set_unit_name('check_stencilmask')
    ! call run_test_case(check_stencilmask, "check_stencilmask")
    ! write(*,*) ""
    ! write(*,*) ".. done."
    ! write(*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_stencil2sparse_size"
    ! call set_unit_name('check_stencil2sparse_size')
    ! call run_test_case(check_stencil2sparse_size, "check_stencil2sparse_size")
    ! write(*,*) ""
    ! write(*,*) ".. done."
    ! write(*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_const_stencil2sparse"
    ! call set_unit_name('check_const_stencil2sparse')
    ! call run_test_case(check_const_stencil2sparse, "check_const_stencil2sparse")
    ! write(*,*) ""
    ! write(*,*) ".. done."
    ! write(*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_stencil2sparse"
    ! call set_unit_name('check_stencil2sparse')
    ! call run_test_case(check_stencil2sparse, "check_stencil2sparse")
    ! write(*,*) ""
    ! write(*,*) ".. done."
    ! write(*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_convolve"
    ! call set_unit_name('check_convolve')
    ! call run_test_case(check_convolve, "check_convolve")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_stencil

    ! call setup_test_stencil
    ! write (*,*) ".. running test: check_create_5p_stencil"
    ! call set_unit_name('check_create_5p_stencil')
    ! call run_test_case(check_create_5p_stencil, "check_create_5p_stencil")
    ! write (*,*)
    ! write (*,*) ".. done."
    ! write (*,*) ""
    ! call teardown_test_stencil

    call fruit_summary
    call fruit_finalize
end program fruit_driver
