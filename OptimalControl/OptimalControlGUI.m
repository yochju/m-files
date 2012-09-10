function varargout = OptimalControlGUI(varargin)
    % OPTIMALCONTROLGUI MATLAB code for OptimalControlGUI.fig
    %      OPTIMALCONTROLGUI, by itself, creates a new OPTIMALCONTROLGUI or raises the existing
    %      singleton*.
    %
    %      H = OPTIMALCONTROLGUI returns the handle to a new OPTIMALCONTROLGUI or the handle to
    %      the existing singleton*.
    %
    %      OPTIMALCONTROLGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in OPTIMALCONTROLGUI.M with the given input arguments.
    %
    %      OPTIMALCONTROLGUI('Property','Value',...) creates a new OPTIMALCONTROLGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before OptimalControlGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to OptimalControlGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help OptimalControlGUI
    
    % Last Modified by GUIDE v2.5 16-Aug-2012 11:50:19
    
    % Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
    %
    % This program is free software; you can redistribute it and/or modify it
    % under the terms of the GNU General Public License as published by the Free
    % Software Foundation; either version 3 of the License, or (at your option)
    % any later version.
    %
    % This program is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    % for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc., 51
    % Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
    
    % Last revision on: 16.08.2012 17:30
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @OptimalControlGUI_OpeningFcn, ...
        'gui_OutputFcn',  @OptimalControlGUI_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
    
    
    % --- Executes just before OptimalControlGUI is made visible.
function OptimalControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to OptimalControlGUI (see VARARGIN)
    
    % Choose default command line output for OptimalControlGUI
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes OptimalControlGUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = OptimalControlGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
    % hObject    handle to RunButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    fprintf(1,'Starting Computation.\n');
    
    if ~isfield(handles.data,'N') || ...
            ~isfield(handles.data,'lambda') || ...
            ~isfield(handles.data,'ItK') || ...
            ~isfield(handles.data,'ItI') || ...
            ~isfield(handles.data,'TolK') || ...
            ~isfield(handles.data,'TolI') || ...
            ~isfield(handles.data,'uStep') || ...
            ~isfield(handles.data,'cStep') || ...
            ~isfield(handles.data,'theta')
        errordlg('Not all Fields have been filled out.','Error');
    else
        N      = handles.data.N;
        lambda = handles.data.lambda;
        itK    = handles.data.ItK;
        itI    = handles.data.ItI;
        TolK   = handles.data.TolK;
        TolI   = handles.data.TolI;
        uStep  = handles.data.uStep;
        cStep  = handles.data.cStep;
        theta  = handles.data.theta;
    end
    
    popup_sel_index = get(handles.SelectSignal, 'Value');
    switch popup_sel_index
        case 1
            Sig = MakeSignal('Piece-Polynomial',N);
        case 2
            Sig = MakeSignal('Piece-Regular',N);
        case 3
            Sig = linspace(-1,1,N).^2;
        case 4
            Sig = -reallog(linspace(1/10,10,N));
    end
    Sig = Sig - min(Sig(:));
    Sig = Sig/max(Sig(:));
    
    axes(handles.Results);
    cla;
    plot( ...
        1:length(Sig(:)), Sig(:), '-k', ...
        'LineWidth', 1, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'b', ...
        'MarkerSize', 4 ...
        );
    title('Signal');
    legend('Signal');
    xlabel('Position');
    ylabel('Value');
    
    tic();
    % TODO: Replace this with multiscale algorithm and add remaining parameters
    % to gui.
    [u c ItIn ItOut EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
        Sig(:), ...
        'MaxOuter', itK, ...
        'MaxInner', itI, ...
        'TolOuter', TolK, ...
        'TolInner', TolI, ...
        'uInit', [], ...
        'cInit', [], ...
        'lambda', lambda, ...
        'penPDE', theta, ...
        'penPDE', 10, ...
        'penu', 1e-3, ...
        'penc', 1e-3, ...
        'uStep', uStep, ...
        'cStep', cStep, ...
        'PDEstep', 2.0, ...
        'thresh', -1 ...
    );
    runtime = toc();
    
    NumIter = ItIn;
    Ener = Energy(u,c,Sig(:),lambda);
    Resi = Residual(u,c,Sig(:));
    
    axes(handles.EvoEne);
    cla;
    plot(1:NumIter,EnerVal,'-k',IncPEN,EnerVal(IncPEN),'or', ...
        'LineWidth', 1, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'r', ...
        'MarkerSize', 4 );
    %title('Evolution of the Energy functional');
    legend('Energy','Increasing Penalization');
    %xlabel('Iteration');
    %ylabel('Energy Value');
    
    axes(handles.EvoResi);
    cla;
    plot(1:NumIter,ResiVal,'-k',IncPEN,ResiVal(IncPEN),'or', ...
        'LineWidth', 1, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'r', ...
        'MarkerSize', 4 );
    %title('Evolution of the Residual of the PDE');
    legend('Residual','Increasing Penalization');
    %xlabel('Iteration');
    %ylabel('Residual Value');
    
    axes(handles.Results);
    cla;
    plot( ...
        1:length(Sig(:)), Sig(:), '-k', ...
        1:length(Sig(:)), u, '--r', ...
        1:length(Sig(:)), c, 'ob', ...
        'LineWidth', 1, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'b', ...
        'MarkerSize', 4 ...
        );
    %title('Results from the optimization strategy');
    legend('Signal','Reconstruction','Mask');
    %xlabel('Position');
    %ylabel('Value');
    
    set(handles.NumIts, 'String', NumIter);
    set(handles.runtime, 'String', runtime);
    set(handles.EneVal, 'String', Ener);
    set(handles.ResiVal, 'String', Resi);
    
    fprintf(1,'Computation finished.\n');
    
    
function SigN_Callback(hObject, eventdata, handles)
    % hObject    handle to SigN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of SigN as text
    %        str2double(get(hObject,'String')) returns contents of SigN as a double
    N = str2double(get(hObject, 'String'));
    if isnan(N)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.N = N;
    fprintf(1,'Set signal length to: %d.\n',N);
    guidata(hObject,handles)
    
    
    % --- Executes during object creation, after setting all properties.
function SigN_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to SigN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function TolK_Callback(hObject, eventdata, handles)
    % hObject    handle to TolK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of TolK as text
    %        str2double(get(hObject,'String')) returns contents of TolK as a double
    TolK = str2double(get(hObject, 'String'));
    if isnan(TolK)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.TolK = TolK;
    fprintf(1,'Set outer tolerance to: %d.\n',TolK);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function TolK_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to TolK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function ItK_Callback(hObject, eventdata, handles)
    % hObject    handle to ItK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ItK as text
    %        str2double(get(hObject,'String')) returns contents of ItK as a double
    ItK = str2double(get(hObject, 'String'));
    if isnan(ItK)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.ItK = ItK;
    fprintf(1,'Set outer iterations to: %d.\n',ItK);
    guidata(hObject,handles)
    
    
    % --- Executes during object creation, after setting all properties.
function ItK_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ItK (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function TolI_Callback(hObject, eventdata, handles)
    % hObject    handle to TolI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of TolI as text
    %        str2double(get(hObject,'String')) returns contents of TolI as a double
    TolI = str2double(get(hObject, 'String'));
    if isnan(TolI)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.TolI = TolI;
    fprintf(1,'Set inner tolerance to: %d.\n',TolI);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function TolI_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to TolI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function ItI_Callback(hObject, eventdata, handles)
    % hObject    handle to ItI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ItI as text
    %        str2double(get(hObject,'String')) returns contents of ItI as a double
    ItI = str2double(get(hObject, 'String'));
    if isnan(ItI)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.ItI = ItI;
    fprintf(1,'Set inner iterations to: %d.\n',ItI);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function ItI_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ItI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function lambda_Callback(hObject, eventdata, handles)
    % hObject    handle to lambda (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of lambda as text
    %        str2double(get(hObject,'String')) returns contents of lambda as a double
    lambda = str2double(get(hObject, 'String'));
    if isnan(lambda)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.lambda = lambda;
    fprintf(1,'Set lambda to: %d.\n',lambda);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function lambda_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lambda (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function uStep_Callback(hObject, eventdata, handles)
    % hObject    handle to uStep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of uStep as text
    %        str2double(get(hObject,'String')) returns contents of uStep as a double
    uStep = str2double(get(hObject, 'String'));
    if isnan(uStep)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.uStep = uStep;
    fprintf(1,'Set proximal penalisation of solution to: %d.\n',uStep);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function uStep_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to uStep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function cStep_Callback(hObject, eventdata, handles)
    % hObject    handle to cStep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of cStep as text
    %        str2double(get(hObject,'String')) returns contents of cStep as a double
    cStep = str2double(get(hObject, 'String'));
    if isnan(cStep)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.cStep = cStep;
    fprintf(1,'Set proximal penalisation of mask to: %d.\n',cStep);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function cStep_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to cStep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function theta_Callback(hObject, eventdata, handles)
    % hObject    handle to theta (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of theta as text
    %        str2double(get(hObject,'String')) returns contents of theta as a double
    theta = str2double(get(hObject, 'String'));
    if isnan(theta)
        set(hObject, 'String', 0);
        errordlg('Input must be a number','Error');
    end
    % Save the new volume value
    handles.data.theta = theta;
    fprintf(1,'Set penalisation of PDE to: %d.\n',theta);
    guidata(hObject,handles)
    
    % --- Executes during object creation, after setting all properties.
function theta_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to theta (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    % --- Executes on selection change in SelectSignal.
function SelectSignal_Callback(hObject, eventdata, handles)
    % hObject    handle to SelectSignal (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns SelectSignal contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from SelectSignal
    
    
    % --- Executes during object creation, after setting all properties.
function SelectSignal_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to SelectSignal (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject, 'String', { ...
        'Piece-Polynomial', ...
        'Piece-Regular', ...
        'x^2', ...
        '-log(x)' ...
        });
