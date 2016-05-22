if ismac
    % Code to run on Mac plaform
    mex -v -largeArrayDims mexcumsum.c /opt/local/lib/libgcc/libgfortran.3.dylib libffiles.a
    mex -v -largeArrayDims mexstencillocs.c /opt/local/lib/libgcc/libgfortran.3.dylib libffiles.a
    mex -v -largeArrayDims mexstencilmask.c /opt/local/lib/libgcc/libgfortran.3.dylib libffiles.a
    mex -v -largeArrayDims mexcreate_5p_stencil.c /opt/local/lib/libgcc/libgfortran.3.dylib libffiles.a
elseif isunix
    % Code to run on Linux plaform
    mex -v -largeArrayDims mexcumsum.c -lffiles -lgfortran
    mex -v -largeArrayDims mexstencillocs.c -lffiles -lgfortran
    mex -v -largeArrayDims mexstencilmask.c -lffiles -lgfortran
    mex -v -largeArrayDims mexcreate_5p_stencil.c -lffiles -lgfortran
elseif ispc
    % Code to run on Windows platform
    mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcmtd.lib" -v -largeArrayDims mexcumsum.c mod_cmexinterface.obj mod_miscfun.obj mod_stencil.obj mod_array.obj mod_laplace.obj mod_sparse.obj
    mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcmtd.lib" -v -largeArrayDims mexstencillocs.c mod_cmexinterface.obj mod_miscfun.obj mod_stencil.obj mod_array.obj mod_laplace.obj mod_sparse.obj
else
    disp('Platform not supported')
end