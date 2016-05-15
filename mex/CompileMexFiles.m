if ismac
    % Code to run on Mac plaform
elseif isunix
    % Code to run on Linux plaform
elseif ispc
    % Code to run on Windows platform
    mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcmtd.lib" -v -largeArrayDims mexcumsum.c mod_cmexinterface.obj mod_miscfun.obj mod_stencil.obj mod_array.obj mod_laplace.obj mod_sparse.obj
    mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcmtd.lib" -v -largeArrayDims mexstencillocs.c mod_cmexinterface.obj mod_miscfun.obj mod_stencil.obj mod_array.obj mod_laplace.obj mod_sparse.obj
else
    disp('Platform not supported')
end