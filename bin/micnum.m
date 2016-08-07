function varargout = micnum(varargin)
    % MICNUM MATLAB code for micnum.fig
    %      MICNUM, by itself, creates a new MICNUM or raises the existing
    %      singleton*.
    %
    %      H = MICNUM returns the handle to a new MICNUM or the handle to
    %      the existing singleton*.
    %
    %      MICNUM('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MICNUM.M with the given input arguments.
    %
    %      MICNUM('Property','Value',...) creates a new MICNUM or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before micnum_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to micnum_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help micnum
    
    % Last Modified by GUIDE v2.5 26-Jul-2016 23:19:17
    % Zernikes modes generations: function from Remy
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @micnum_OpeningFcn, ...
        'gui_OutputFcn',  @micnum_OutputFcn, ...
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
    
end
%%    % --- Executes just before micnum is made visible.
function micnum_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to micnum (see VARARGIN)
    
    % Choose default command line output for micnum
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using micnum.
    % if strcmp(get(hObject,'Visible'),'off')
    %     plot(rand(5));
    % end
    
    set(handles.displace,'Value',1)
    handles.vars.colors=[0 0.447 0.741;0.85  0.3250    0.0980;0.9290    0.6940    0.1250; 0.4940    0.1840    0.5560; 0.4660    0.6740    0.1880;0.3010    0.7450    0.9330; 0.6350    0.0780    0.1840];
    handles.vars.marc = {'o-','*--','+:','^:','d:'};
    handles=path_eta_Callback(hObject, eventdata, handles);
    path=handles.path_eta.String;
    if exist(path,'file')==2
        tmp=load(path,'-mat');
        object=tmp.object;
        handles.vars.object=object;
        
        set(handles.info_eta,'String',['Object info:'...
            num2str(size(object,1)) ' x '...
            num2str(size(object,2)) ' x ' ...
            num2str(size(object,3)) ' pixels'])
        
        set(handles.n_z,'String',num2str(size(object,3)))
        set(handles.n_pts,'String',num2str(size(object,1)/2))
        handles=update_params(hObject, eventdata, handles);
        
        set(handles.slider_z, 'Min', 1);
        set(handles.slider_z, 'Max', size(object,3));
        set(handles.slider_z, 'Value', size(object,3)/2);
        set(handles.slider_z, 'SliderStep', [1/size(object,3) , 10/size(object,3) ]);
        
        set(handles.slider_x, 'Min', 1);
        set(handles.slider_x, 'Max', size(object,1));
        set(handles.slider_x, 'Value', size(object,1)/2);
        set(handles.slider_x, 'SliderStep', [1/size(object,1) , 10/size(object,1) ]);
        
        set(handles.slider_y, 'Min', 1);
        set(handles.slider_y, 'Max', size(object,1));
        set(handles.slider_y, 'Value', size(object,1)/2);
        set(handles.slider_y, 'SliderStep', [1/size(object,1) , 10/size(object,1) ]);
        
        handles=refresh_object(hObject, eventdata, handles);
    else
        load gong;
        sound(y,Fs);
        m=msgbox('File does not exist', ' ','error');
        set(m,'WindowStyle','modal');
        uiwait(m);
        return
    end
    
    guidata(hObject, handles);
    clc
    
end
% UIWAIT makes micnum wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%%
% --- Outputs from this function are returned to the command line.
function varargout = micnum_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end
%%
% --- Executes on button press in imager.
function handles=imager_Callback(hObject, eventdata, handles)
    % hObject    handle to imager (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles.vars,'object')
        load gong;
        sound(y,Fs);
        m=msgbox('Object not loaded', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
    
    disp('---------------------------------')
    handles.aberr.ai=str2double(get(handles.ai, 'String'));
    handles.aberr.zi=str2double(get(handles.zi, 'String'));
    [handles,psf3d]=calc_psf(hObject, eventdata, handles);
    [handles,z_stack]=convol_eta_psf3D(psf3d,hObject, eventdata, handles);
    
    handles.vars.z_stack=z_stack;
    handles.vars.psf3d=psf3d;
    handles.slider_z.Value=round(handles.vars.n_z/2);
    
    handles.slider_x.Value=handles.vars.n_pts;
    handles.slider_y.Value=handles.vars.n_pts;
    
    handles=filtering(hObject, eventdata, handles);
    [m1,m2,m3,eta_bar]=calcul_metrics(hObject, eventdata, handles);
    handles.vars.m1=normalize(m1);
    handles.vars.m2=normalize(m2);
    handles.vars.m3=normalize(m3);
    handles.vars.eta_bar=eta_bar;
    
    handles=refresh_imgs(hObject, eventdata, handles);
    
    handles=update_infos(hObject, eventdata, handles);
    guidata(hObject, handles);
end

%%    % --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
    % hObject    handle to FileMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
end
%%    % --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to OpenMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    file = uigetfile('*.fig');
    if ~isequal(file, 0)
        open(file);
    end
end
%% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to PrintMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    printdlg(handles.figure1)
end
%%    % --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
    % hObject    handle to CloseMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
        ['Close ' get(handles.figure1,'Name') '...'],...
        'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    
    delete(handles.figure1)
    
    
end
%%
function zlim1_Callback(hObject, eventdata, handles)
    % hObject    handle to zlim1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of zlim1 as text
    %        str2double(get(hObject,'String')) returns contents of zlim1 as a double
end

%%    % --- Executes during object creation, after setting all properties.
function zlim1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to zlim1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%%
function zlim2_Callback(hObject, eventdata, handles)
    % hObject    handle to zlim2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of zlim2 as text
    %        str2double(get(hObject,'String')) returns contents of zlim2 as a double
end

%%    % --- Executes during object creation, after setting all properties.
function zlim2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to zlim2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%%
function handles=n_z_Callback(hObject, eventdata, handles)
    % hObject    handle to n_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of n_z as text
    %        str2double(get(hObject,'String')) returns contents of n_z as a double
    handles=update_params(hObject, eventdata, handles);
end
%%    % --- Executes during object creation, after setting all properties.
function handles=n_z_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to n_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %     handles=update_params(hObject, eventdata, handles);
    
end
%%    % --- Executes on slider movement.
function handles=slider_x_Callback(hObject, eventdata, handles)
    % hObject    handle to slider_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    
    handles=update_params(hObject, eventdata, handles);
    xy_tab=handles.vars.xy_tab;
    xloc=round(int32(get(hObject, 'Value')));
    set(handles.xloc,'String',['x = ' num2str(xy_tab(xloc)) 'micron'])
    if handles.graph_obj.Value==1
        handles=refresh_object(hObject, eventdata, handles);
    elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
        handles=refresh_imgs(hObject, eventdata, handles);
    elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
        handles=refresh_filter(hObject, eventdata, handles);
    elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
        handles=refresh_psf(hObject, eventdata, handles);
    end
    
    
    guidata(hObject, handles);
end
%%
% --- Executes during object creation, after setting all properties.
function slider_x_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider_x (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
end
%%
% --- Executes on slider movement.
function handles=slider_y_Callback(hObject, eventdata, handles)
    % hObject    handle to slider_y (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles=update_params(hObject, eventdata, handles);
    xy_tab=handles.vars.xy_tab;
    yloc=round(int32(get(hObject, 'Value')));
    set(handles.yloc,'String',['y = ' num2str(xy_tab(yloc)) 'micron'])
    if handles.graph_obj.Value==1
        handles=refresh_object(hObject, eventdata, handles);
    elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
        handles=refresh_imgs(hObject, eventdata, handles);
    elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
        handles=refresh_filter(hObject, eventdata, handles);
    elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
        handles=refresh_psf(hObject, eventdata, handles);
    end
    
    
    guidata(hObject, handles);
end
%%
% --- Executes during object creation, after setting all properties.
function slider_y_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider_y (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

%%
% --- Executes on slider movement.
function handles=slider_z_Callback(hObject, eventdata, handles)
    % hObject    handle to slider_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    
    handles=update_params(hObject, eventdata, handles);
    z_tab=(handles.vars.z_tab);
    zloc=round(int32(get(hObject, 'Value')));
    set(handles.zloc,'String',['z = ' num2str(z_tab(zloc)) 'micron'])
    if handles.graph_obj.Value==1
        handles=refresh_object(hObject, eventdata, handles);
    elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
        handles=refresh_imgs(hObject, eventdata, handles);
    elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
        handles=refresh_filter(hObject, eventdata, handles);
    elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
        handles=refresh_psf(hObject, eventdata, handles);
    end
    
    
    guidata(hObject, handles);
end
%%
% --- Executes during object creation, after setting all properties.
function slider_z_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
end

%%
function handles=n_pts_Callback(hObject, eventdata, handles)
    % hObject    handle to n_pts (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of n_pts as text
    %        str2double(get(hObject,'String')) returns contents of n_pts as a double
    handles=update_params(hObject, eventdata, handles);
end
%%
% --- Executes during object creation, after setting all properties.
function handles=n_pts_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to n_pts (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %     handles=update_params(hObject, eventdata, handles);
end
%%
% --- Executes on button press in loopx.
function handles=loopx_Callback(hObject, eventdata, handles)
    % hObject    handle to loopx (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles=update_params(hObject, eventdata, handles);
    xy_tab=handles.vars.xy_tab;
    for xi=1:length(xy_tab)
        handles.slider_x.Value=xi;
        set(handles.xloc,'String',['x = ' num2str(xy_tab(xi)) 'micron'])
        if handles.graph_obj.Value==1
            handles=refresh_object(hObject, eventdata, handles);
        elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
            handles=refresh_imgs(hObject, eventdata, handles);
        elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
            handles=refresh_filter(hObject, eventdata, handles);
        elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
            handles=refresh_psf(hObject, eventdata, handles);
        end
    end
    
end
%%
% --- Executes on button press in loopy.
function handles=loopy_Callback(hObject, eventdata, handles)
    % hObject    handle to loopy (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles=update_params(hObject, eventdata, handles);
    xy_tab=handles.vars.xy_tab;
    for yi=1:length(xy_tab)
        handles.slider_y.Value=yi;
        set(handles.yloc,'String',['y = ' num2str(xy_tab(yi)) 'micron'])
        if handles.graph_obj.Value==1
            handles=refresh_object(hObject, eventdata, handles);
        elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
            handles=refresh_imgs(hObject, eventdata, handles);
        elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
            handles=refresh_filter(hObject, eventdata, handles);
        elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
            handles=refresh_psf(hObject, eventdata, handles);
        end
    end
end
%%
% --- Executes on button press in loopz.
function handles=loopz_Callback(hObject, eventdata, handles)
    % hObject    handle to loopz (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles=update_params(hObject, eventdata, handles);
    z_tab=(handles.vars.z_tab);
    for zi=1:length(z_tab)
        handles.slider_z.Value=zi;
        set(handles.zloc,'String',['z = ' num2str(z_tab(zi)) 'micron'])
        if handles.graph_obj.Value==1
            handles=refresh_object(hObject, eventdata, handles);
        elseif handles.graph_img.Value==1 && isfield(handles.vars,'z_stack')
            handles=refresh_imgs(hObject, eventdata, handles);
        elseif handles.graph_filter.Value==1 && isfield(handles.vars,'z_stack_w')
            handles=refresh_filter(hObject, eventdata, handles);
        elseif handles.graph_psf.Value==1 && isfield(handles.vars,'psf3d')
            handles=refresh_psf(hObject, eventdata, handles);
        end
    end
    
    guidata(hObject, handles);
end
%%
% --- Executes on button press in graph_obj.
function handles=graph_obj_Callback(hObject, eventdata, handles)
    % hObject    handle to graph_obj (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of graph_obj
    
    if isfield(handles.vars,'object')
        handles=refresh_object(hObject, eventdata, handles);
    else
        return
    end
end
%%
function handles=n_ph_Callback(hObject, eventdata, handles)
    % hObject    handle to n_ph_tx (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of n_ph_tx as text
    %        str2double(get(hObject,'String')) returns contents of n_ph_tx as a double
    handles=update_params(hObject, eventdata, handles);
end
%%
function handles=n_ph_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to zlim2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %     handles=update_params(hObject, eventdata, handles);
end
%%    % --- Executes during object creation, after setting all properties.
function n_ph_tx_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to n_ph_tx (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%%
function handles=path_eta_Callback(hObject, eventdata, handles)
    % hObject    handle to path_eta (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of path_eta as text
    %        str2double(get(hObject,'String')) returns contents of path_eta as a double
    guidata(hObject, handles);
end
%%        % --- Executes during object creation, after setting all properties.
function path_eta_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to path_eta (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
%%        % --- Executes on button press in open_eta.
function handles=open_eta_Callback(hObject, eventdata, handles)
    % hObject    handle to open_eta (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [filename, pathname] = uigetfile('*.mat', 'Pick a MATLAB file');
    handles.path_eta.String=[pathname filename];
    path=handles.path_eta.String;
    tmp=load(path,'-mat');
    object=tmp.object;
    handles.vars.object=object;
    
    set(handles.info_eta,'String',['Object info:'...
        num2str(size(object,1)) ' x '...
        num2str(size(object,2)) ' x ' ...
        num2str(size(object,3)) ' pixels'])
    set(handles.n_z,'String',num2str(size(object,3)))
    
    set(handles.n_pts,'String',num2str(size(object,1)/2))
    handles=update_params(hObject, eventdata, handles);
    
    set(handles.slider_z, 'Min', 1);
    set(handles.slider_z, 'Max', size(object,3));
    set(handles.slider_z, 'Value', size(object,3)/2);
    set(handles.slider_z, 'SliderStep', [1/size(object,3) , 10/size(object,3) ]);
    
    set(handles.slider_x, 'Min', 1);
    set(handles.slider_x, 'Max', size(object,1));
    set(handles.slider_x, 'Value', size(object,1)/2+1);
    set(handles.slider_x, 'SliderStep', [1/size(object,1) , 10/size(object,1) ]);
    
    set(handles.slider_y, 'Min', 1);
    set(handles.slider_y, 'Max', size(object,1));
    set(handles.slider_y, 'Value', size(object,1)/2+1);
    set(handles.slider_y, 'SliderStep', [1/size(object,1) , 10/size(object,1) ]);
    
    handles=refresh_object(hObject, eventdata, handles);
    guidata(hObject, handles);
end
%% % --- Executes on button press in metrics_z.
function metrics_z_Callback(hObject, eventdata, handles)
    % hObject    handle to metrics_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles.vars,'z_stack')
        load gong;
        sound(y,Fs);
        m=msgbox('Execute MicNum before!', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
    dz=(handles.vars.z_tab);
    colors = handles.vars.colors;
    marc=handles.vars.marc;
    m1=handles.vars.m1;
    m2=handles.vars.m2;
    m3=handles.vars.m3;
    axial_distr=handles.vars.eta_bar;
    
    
    figure
    plot(dz,(m1),'-','Color',colors(2,:),'linewidth',2)
    hold on
    % plot(dz,normalize(imgsh1(1,:)),marc{1},'Color',colors(1,:),'linewidth',linew)
    % plot(dz,normalize(imgsh2(1,:)),marc{3},'Color',colors(3,:),'linewidth',linew)
    plot(dz,(m2),'-.','Color',colors(3,:),'linewidth',2)
    plot(dz,(m3),'--','Color',colors(5,:),'linewidth',2)
    plot(dz,axial_distr,':k','linewidth',2)
    hold off
    grid on
    set(gca,'xlim',[min(dz),max(dz)])
    ylabel('Metric value','fontweight','bold')
    title(['Metrics as function of depth focalisation for ' ...
        num2str(handles.aberr.ai) ' rad of Z' num2str(handles.aberr.zi+1)])
    set(gca,'ylim',[0,1.1])
    legend('Total Image Intensity','Variance',...
        'Pre-filtered image variance','Object axial distribution',...
        'location','best')
    legend boxoff
    xlabel('z [\mum]','fontweight','bold')
    % print(1,'-dtiff','metric_neur_z_all_withfiltered_normalize.tif')
    % savefig('metric_neur_z_all_withfiltered_normalize.fig')
end
%%
function r0_Callback(hObject, eventdata, handles)
    % hObject    handle to r0 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of r0 as text
    %        str2double(get(hObject,'String')) returns contents of r0 as a double
end

%% % --- Executes during object creation, after setting all properties.
function r0_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to r0 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%%
function sigma_Callback(hObject, eventdata, handles)
    % hObject    handle to sigma (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of sigma as text
    %        str2double(get(hObject,'String')) returns contents of sigma as a double
    
end
%% % --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to sigma (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% % --- Executes on button press in graph_filter.
function handles=graph_filter_Callback(hObject, eventdata, handles)
    % hObject    handle to graph_filter (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of graph_filter
    if isfield(handles.vars,'z_stack')
        handles=refresh_filter(hObject, eventdata, handles);
    else
        load gong;
        sound(y,Fs);
        m=msgbox('Z-stack inexistent! Press MicNum button', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
end

%% % --- Executes on button press in metric_a.
function metric_a_Callback(hObject, eventdata, handles)
    % hObject    handle to metric_a (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    dpix_xy=0.5*(0.92*1.33/(2*0.8));
    dpix_z = dpix_xy;
    n_z = str2double(get(handles.n_z, 'String'));
    if rem(n_z,2)==2
        tmp=floor(-n_z/2):floor(n_z/2)-1;
        z_tab=tmp.*dpix_z;
    else
        tmp=floor(-n_z/2)+1:floor(n_z/2);
        z_tab=tmp.*dpix_z;
    end
    handles.vars.z_tab=z_tab;
    handles.vars.n_z=n_z;
    handles.vars.dpix_z=dpix_z;
    
    
    handles=refresh_acoefs(hObject, eventdata, handles);
    pause(0.05)
    % tic
    handles=metrics_a_z0(hObject, eventdata, handles); %if metrics selected
    %     handles=metrics_vs_a_z(hObject, eventdata, handles);
    % t2=toc;
    % disp(['Elapsed time: ' num2str(t2) ' seconds'])
    guidata(hObject, handles);
    
end

%%
function amin_Callback(hObject, eventdata, handles)
    % hObject    handle to amin (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of amin as text
    %        str2double(get(hObject,'String')) returns contents of amin as a double
    handles=refresh_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function amin_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to amin (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%%
function astep_Callback(hObject, eventdata, handles)
    % hObject    handle to astep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of astep as text
    %        str2double(get(hObject,'String')) returns contents of astep as a double
    handles=refresh_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function astep_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to astep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%%
function amax_Callback(hObject, eventdata, handles)
    % hObject    handle to amax (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of amax as text
    %        str2double(get(hObject,'String')) returns contents of amax as a double
    handles=refresh_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function amax_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to amax (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%%
function z0_a_Callback(hObject, eventdata, handles)
    % hObject    handle to z0_a (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of z0_a as text
    %        str2double(get(hObject,'String')) returns contents of z0_a as a double
end

%% % --- Executes during object creation, after setting all properties.
function z0_a_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to z0_a (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%%
function handles=zi_Callback(hObject, eventdata, handles)
    % hObject    handle to zi (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of zi as text
    %        str2double(get(hObject,'String')) returns contents of zi as a double
    handles=update_params(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function zi_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to zi (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    % handles=update_params(hObject, eventdata, handles);
end

%%
function handles=ai_Callback(hObject, eventdata, handles)
    % hObject    handle to ai (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ai as text
    %        str2double(get(hObject,'String')) returns contents of ai as a double
    handles=update_params(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function ai_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ai (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% 
function zi_a_Callback(hObject, eventdata, handles)
    % hObject    handle to zi_a (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of zi_a as text
    %        str2double(get(hObject,'String')) returns contents of zi_a as a double
end

%% % --- Executes during object creation, after setting all properties.
function zi_a_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to zi_a (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% % --- Executes on button press in metr_a_z0_figure.
function metr_a_z0_figure_Callback(hObject, eventdata, handles)
    % hObject    handle to metr_a_z0_figure (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if isfield(handles,'metric_a_z0_graph')
        figure
        plot_metric_a_z0_graph(handles)
    end
end

%% % --- Executes on button press in graph_img.
function handles=graph_img_Callback(hObject, eventdata, handles)
    % hObject    handle to graph_img (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of graph_img
    if isfield(handles.vars,'z_stack')
        handles=refresh_imgs(hObject, eventdata, handles);
    else
        load gong;
        sound(y,Fs);
        m=msgbox('Z-stack inexistent! Press MicNum button', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
end

%% % --- Executes on button press in graph_psf.
function handles=graph_psf_Callback(hObject, eventdata, handles)
    % hObject    handle to graph_psf (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of graph_psf
    
    if isfield(handles.vars,'z_stack')
        handles=refresh_psf(hObject, eventdata, handles);
    else
        load gong;
        sound(y,Fs);
        m=msgbox('3D PSF inexistent! Press MicNum button', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
    
end

function handles=res_amin_Callback(hObject, eventdata, handles)
    % hObject    handle to res_amin (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of res_amin as text
    %        str2double(get(hObject,'String')) returns contents of res_amin as a double
    handles=refresh_res_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function res_amin_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to res_amin (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
end

%%
function handles=res_astep_Callback(hObject, eventdata, handles)
    % hObject    handle to res_astep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of res_astep as text
    %        str2double(get(hObject,'String')) returns contents of res_astep as a double
    handles=refresh_res_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function res_astep_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to res_astep (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end


function handles=res_amax_Callback(hObject, eventdata, handles)
    % hObject    handle to res_amax (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of res_amax as text
    %        str2double(get(hObject,'String')) returns contents of res_amax as a double
    handles=refresh_res_acoefs(hObject, eventdata, handles);
end

%% % --- Executes during object creation, after setting all properties.
function res_amax_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to res_amax (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
end

function res_zi_Callback(hObject, eventdata, handles)
    % hObject    handle to res_zi (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of res_zi as text
    %        str2double(get(hObject,'String')) returns contents of res_zi as a double
end

%% % --- Executes during object creation, after setting all properties.
function res_zi_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to res_zi (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

%% % --- Executes on button press in psf_resolution.
function handles=psf_resolution_Callback(hObject, eventdata, handles)
    % hObject    handle to psf_resolution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles=refresh_res_acoefs(hObject, eventdata, handles);
    z_tab=handles.vars.z_tab;
    xy_tab=handles.vars.xy_tab;
    a_coefs=handles.vars.res_acoefs;
    percent=round(100*normalize(1:length(a_coefs)));
    handles.aberr.res_zi=str2double(get(handles.res_zi, 'String'));
    ares1_tab=zeros(1,length(a_coefs));
    ares2_tab=ares1_tab;
    ares3_tab=ares1_tab;
    lres1_tab=ares1_tab;
    lres2_tab=ares1_tab;
    lres3_tab=ares1_tab;
    dispx_tab=ares1_tab;
    dispy_tab=ares1_tab;
    dispz_tab=ares1_tab;
    bari_tab=ares1_tab;
    t_gl=tic;
    for ai_iter=1:length(a_coefs)
        disp('---------------------------------')
        tst=tic;
        handles_parfor=handles;
        handles_parfor.aberr.ai=a_coefs(ai_iter);
        
        handles_parfor.aberr.phase=a_coefs(ai_iter)*handles_parfor.vars.modes_zern(:,:,handles_parfor.aberr.res_zi);
        
        [handles_parfor,psf3d]=calc_psf(hObject, eventdata, handles_parfor);
        
        
        if handles.res_image.Value==1
            [handles_parfor,z_stack]=convol_eta_psf3D(psf3d,hObject, eventdata, handles_parfor);
            handles_parfor.vars.z_stack=z_stack;
            psf3d=z_stack;
            z_stack=[];
            
        end
        [handles_parfor]=calcul_axial_res(psf3d,hObject, eventdata, handles_parfor);
        %         ares1_tab(ai_iter)=handles_parfor.ares1;
        %         ares2_tab(ai_iter)=handles_parfor.ares2;
        %         ares3_tab(ai_iter)=handles_parfor.ares3;
        [handles_parfor]=calcul_long_res(psf3d,hObject, eventdata, handles_parfor);
        %         lres1_tab(ai_iter)=handles_parfor.lres1;
        %         lres2_tab(ai_iter)=handles_parfor.lres2;
        %         lres3_tab(ai_iter)=handles_parfor.lres3;
        [handles_parfor]=calcul_displ(psf3d,hObject, eventdata, handles_parfor);
        dispx_tab(ai_iter)=xy_tab(handles_parfor.ix);
        dispy_tab(ai_iter)=xy_tab(handles_parfor.iy);
        dispz_tab(ai_iter)=z_tab(handles_parfor.iz);
        
        handles_parfor=[];
        tend=toc(tst);
        disp([num2str(percent(ai_iter)) '% - ' num2str(tend) ' seconds'])
        
    end
    
    %     handles.res_graph.ares1_tab=(ares1_tab);
    %     handles.res_graph.ares2_tab=(ares2_tab);
    %     handles.res_graph.ares3_tab=(ares3_tab);
    %
    %     handles.res_graph.lres1_tab=(lres1_tab);
    %     handles.res_graph.lres2_tab=(lres2_tab);
    %     handles.res_graph.lres3_tab=(lres3_tab);
    %
    handles.res_graph.dispx=dispx_tab;
    handles.res_graph.dispy=dispy_tab;
    handles.res_graph.dispz=dispz_tab;
    
    handles.res_graph.a_coefs=a_coefs;
    
    t_gl2=toc(t_gl);
    disp(['Total elapsed time: ' num2str(t_gl2) ' seconds'])
    figure
    plot_resolution_graph(handles);
    guidata(hObject, handles);
    
end

%% % --- Executes on button press in resolution_psf_figure.
function handles=resolution_psf_figure_Callback(hObject, eventdata, handles)
    % hObject    handle to resolution_psf_figure (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if isfield(handles,'res_graph')
        figure
        plot_resolution_graph(handles);
    end
end

%% % --- Executes on button press in axial_res.
function axial_res_Callback(hObject, eventdata, handles)
    % hObject    handle to axial_res (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of axial_res
    if hObject.Value==1
        handles.displace.Value=0;
        handles.long_res.Value=0;
    end
    if isfield(handles,'res_graph')
        figure
        plot_resolution_graph(handles);
    end
    
end
%% % --- Executes on button press in displace.
function displace_Callback(hObject, eventdata, handles)
    % hObject    handle to displace (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of displace
    if hObject.Value==1
        handles.axial_res.Value=0;
        handles.long_res.Value=0;
    end
    if isfield(handles,'res_graph')
        figure;
        plot_resolution_graph(handles);
    end
end
%% % --- Executes on button press in long_res.
function long_res_Callback(hObject, eventdata, handles)
    % hObject    handle to long_res (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of long_res
    if hObject.Value==1
        handles.displace.Value=0;
        handles.axial_res.Value=0;
    end
    if isfield(handles,'res_graph')
        figure
        plot_resolution_graph(handles)
    end
end
%%

% --- Executes on button press in res_image.
function res_image_Callback(hObject, eventdata, handles)
    % hObject    handle to res_image (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of res_image
end


%% --- Executes on button press in aberr_vs_z.
function aberr_vs_z_Callback(hObject, eventdata, handles)
    % hObject    handle to aberr_vs_z (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    dpix_xy=0.5*(0.92*1.33/(2*0.8));
    dpix_z = dpix_xy;
    n_z = str2double(get(handles.n_z, 'String'));
    if rem(n_z,2)==2
        tmp=floor(-n_z/2):floor(n_z/2)-1;
        z_tab=tmp.*dpix_z;
    else
        tmp=floor(-n_z/2)+1:floor(n_z/2);
        z_tab=tmp.*dpix_z;
    end
    handles.vars.z_tab=z_tab;
    handles.vars.n_z=n_z;
    handles.vars.dpix_z=dpix_z;
    
    
    handles=refresh_acoefs(hObject, eventdata, handles);
    pause(0.05)
    % tic
    %     handles=metrics_a_z0(hObject, eventdata, handles); %if metrics selected
    handles=metrics_vs_a_z(hObject, eventdata, handles);
    % t2=toc;
    % disp(['Elapsed time: ' num2str(t2) ' seconds'])
    guidata(hObject, handles);
    
end


%% --- Executes on button press in figure_scan.
function figure_scan_Callback(hObject, eventdata, handles)
% hObject    handle to figure_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if isfield(handles,'metric_scan_graph')
        figure
        plot_scan(handles)
 end
    
end

%%
function handles=update_infos(hObject, eventdata, handles);
    
    xy_tab=handles.vars.xy_tab;
    dpix_xy=handles.vars.dpix_xy;
    z_tab=handles.vars.z_tab;
    dpix_z=handles.vars.dpix_z;
    
    larg_xy=round(max(xy_tab)-min(xy_tab)+dpix_xy);
    larg_z=round(max(z_tab)-min(z_tab)+dpix_z);
    set(handles.info,'String',['z-stack: '...
        num2str(larg_xy) ' x ' num2str(larg_xy) ...
        ' x '  num2str(larg_z) ' micron'])
    set(handles.info2,'String',['              '...
        num2str(length(xy_tab)) ' x ' num2str(length(xy_tab)) ...
        ' x '  num2str(length(z_tab)) ' pixels'])
    guidata(hObject, handles);
end

%%
function handles=update_params(hObject, eventdata, handles)
    n_pts=str2double(get(handles.n_pts, 'String'));
    [modes_zern,msk]=Base_Zernike(4,2,n_pts);
    handles.vars.modes_zern=modes_zern;
    handles.vars.mask=msk;
    handles.aberr.ai=str2double(get(handles.ai, 'String'));
    handles.aberr.zi=str2double(get(handles.zi, 'String'));
    ai=handles.aberr.ai;
    zi=handles.aberr.zi;
    aberr=ai*modes_zern(:,:,zi);
    handles.aberr.phase=aberr;
    handles.vars.n_ph=str2double(get(handles.n_ph, 'String'));
    
    
    dpix_xy=0.5*(0.92*1.33/(2*0.8));
    xy_tab = linspace(-n_pts,n_pts-1,2*n_pts)*dpix_xy;
    handles.vars.xy_tab=xy_tab;
    handles.vars.dpix_xy=dpix_xy;
    handles.vars.n_pts=n_pts;
    
    dpix_xy=0.5*(0.92*1.33/(2*0.8));
    dpix_z = dpix_xy;
    n_z = str2double(get(handles.n_z, 'String'));
    if rem(n_z,2)==2
        tmp=floor(-n_z/2):floor(n_z/2)-1;
        z_tab=tmp.*dpix_z;
    else
        tmp=floor(-n_z/2)+1:floor(n_z/2);
        z_tab=tmp.*dpix_z;
    end
    handles.vars.z_tab=(z_tab);
    handles.vars.n_z=n_z;
    handles.vars.dpix_z=dpix_z;
    guidata(hObject, handles);
end
%%
function [handles,psf3d]=calc_psf(hObject, eventdata, handles) 
    
    %handles=update_params(hObject, eventdata, handles);
    n_pts=handles.vars.n_pts;
    z_tab=handles.vars.z_tab;
    dpix_xy=handles.vars.dpix_xy;
    a4_tab = z_tab.*((pi*0.8^2)./(2.*sqrt(3.0).*1.33.*0.92));
    aberr=handles.aberr.phase;
    n_ph=handles.vars.n_ph;
    
    tic
    disp('3DPSF calculation...')
    psf3d=calcul_psf3d(aberr,1,n_pts,a4_tab);
    normenergie=1/(dpix_xy^2);
    psf3d=(psf3d.*normenergie).^n_ph;
    %     psf3d=psf3d(:,:,end:-1:1);
    disp('Done')
    t=toc;
    disp(['Elapsed time: ' num2str(t) ' seconds'])
    guidata(hObject, handles);
end
%%
function [handles,z_stack]=convol_eta_psf3D(psf3d,hObject, eventdata, handles)
    
    
    object=handles.vars.object;
    
    n_pts=handles.vars.n_pts;
    n_z=handles.vars.n_z;
    im=zeros(2*n_pts,2*n_pts,n_z*2);
    kernel=im;
    
    for zi=1:n_z
        im(:,:,round(n_z/2)+zi)=object(:,:,zi);
        kernel(:,:,round(n_z/2)+zi) = psf3d(:,:,zi);
    end
    tic
    disp('3D convolution...')
    
    % tmp = zeros(size(im)); % create a zero volume of the same size as input image
    % sK=round(size(im)*0.5);
    % s=((size(kernel)-1)*0.5);
    % tmp(sK(1)-s(1)+1:sK(1)+s(1)+1,sK(2)-s(2)+1:sK(2)+s(2)+1,sK(3)-s(3)+1:sK(3)+s(3)+1)=-kernel; % center the kernel in the new image
    % tmp(sK(1)-s(1)+1:sK(1)+s(1),sK(2)-s(2)+1:sK(2)+s(2),sK(3)-s(3)+1:sK(3)+s(3))=-kernel; % center the kernel in the new image
    tmp=kernel;
    im_f = fftn(im);
    ddg_f = fftn(tmp);
    response=real(fftshift(ifftn(ddg_f.*im_f)));
    z_stack = response(:,:,round(n_z/2)+1:round(n_z/2)+n_z);
    
    disp('Done')
    t=toc;
    disp(['Elapsed time: ' num2str(t) ' seconds'])
end
%%
function handles=refresh_object(hObject, eventdata, handles)
    handles=update_params(hObject, eventdata, handles);
    
    z_tab=handles.vars.z_tab;
    n_z=length(z_tab);
    xy_tab=handles.vars.xy_tab;
    object=handles.vars.object;
    xloc=round(handles.slider_x.Value);
    yloc=round(handles.slider_y.Value);
    zloc=round(handles.slider_z.Value);
    
    n_pts=handles.vars.n_pts;
    
    handles.vars.toshow = object;
    
    toshow=handles.vars.toshow;
    guidata(hObject, handles);
    
    axes(handles.xzcut);
    % cla;
    img=rot90(reshape(toshow(:,yloc,:),2*n_pts,n_z),1);
    
    handles.metric_xzcut_graph.img=img;
    handles.metric_xzcut_graph.z_tab=z_tab;
    handles.metric_xzcut_graph.xy_tab=xy_tab;
    handles.metric_xzcut_graph.xloc=xloc;
%     handles.metric_xzcut_graph.yloc=yloc;
    handles.metric_xzcut_graph.zloc=zloc;
    
     plot_xzcut(handles)
%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(xloc) xy_tab(xloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
    
    
    axes(handles.yzcut);
    % cla;
    img=rot90(reshape(toshow(xloc,:,:),2*n_pts,n_z),1);
     handles.metric_yzcut_graph.img=img;
    handles.metric_yzcut_graph.z_tab=z_tab;
    handles.metric_yzcut_graph.xy_tab=xy_tab;
%     handles.metric_yzcut_graph.xloc=xloc;
    handles.metric_yzcut_graph.yloc=yloc;
    handles.metric_yzcut_graph.zloc=zloc;
    
         plot_yzcut(handles)

%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(yloc) xy_tab(yloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('y [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
    
    axes(handles.scan);
    % cla;
        handles.metric_scan_graph.xy_tab=xy_tab;
    handles.metric_scan_graph.toshow=toshow;
    handles.metric_scan_graph.xloc=xloc;
    handles.metric_scan_graph.yloc=yloc;
    handles.metric_scan_graph.zloc=zloc;
    handles.metric_scan_graph.zloc=zloc;

    plot_scan(handles)
% 
%     imagesc(xy_tab,xy_tab,rot90(toshow(:,:,zloc)',0))
%     line([xy_tab(xloc) xy_tab(xloc)],[min(xy_tab) max(xy_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([min(xy_tab) max(xy_tab)],[xy_tab(yloc) xy_tab(yloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('y [\mum]','Fontweight','bold','FontSize',8)
%     axis equal
%     axis tight
    %colormap('jet')
    
    drawnow
    set(handles.yloc,'String',['y = ' num2str(xy_tab(yloc)) 'micron'])
    set(handles.xloc,'String',['x = ' num2str(xy_tab(xloc)) 'micron'])
    set(handles.zloc,'String',['z = ' num2str(z_tab(zloc)) 'micron'])
    %     set(hObject,'toolbar','figure')
    %     set(handles.xzcut,'toolbar','figure')
    %     set(handles.yzcut,'toolbar','figure')
    if handles.graph_obj.Value==0 && isfield(handles.vars,'m1')
        set(handles.info_scan,'String',{'Scan info:',...
            ['M1 = ' num2str(handles.vars.m1(zloc))],...
            ['M2 = ' num2str(handles.vars.m2(zloc))],...
            ['M3 = ' num2str(handles.vars.m3(zloc))]});
    end
    guidata(hObject, handles);
    handles.graph_obj.Value=1;
end
%%
function handles=refresh_psf(hObject, eventdata, handles)
    handles=update_params(hObject, eventdata, handles);
    
    z_tab=handles.vars.z_tab;
    n_z=length(z_tab);
    xy_tab=handles.vars.xy_tab;
    psf3d=handles.vars.psf3d;
    xloc=round(handles.slider_x.Value);
    yloc=round(handles.slider_y.Value);
    zloc=round(handles.slider_z.Value);
    
    n_pts=handles.vars.n_pts;
    
    handles.vars.toshow = psf3d;
    
    toshow=handles.vars.toshow;
    guidata(hObject, handles);
    
    axes(handles.xzcut);
    % cla;
    img=rot90(reshape(toshow(:,yloc,:),2*n_pts,n_z),1);
    
    handles.metric_xzcut_graph.img=img;
    handles.metric_xzcut_graph.z_tab=z_tab;
    handles.metric_xzcut_graph.xy_tab=xy_tab;
    handles.metric_xzcut_graph.xloc=xloc;
%     handles.metric_xzcut_graph.yloc=yloc;
    handles.metric_xzcut_graph.zloc=zloc;
    
    plot_xzcut(handles)
%     imagesc(xy_tab,(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     line([xy_tab(xloc) xy_tab(xloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
%     
    
    axes(handles.yzcut);
    % cla;
    img=rot90(reshape(toshow(xloc,:,:),2*n_pts,n_z),1);
    
     handles.metric_yzcut_graph.img=img;
    handles.metric_yzcut_graph.z_tab=z_tab;
    handles.metric_yzcut_graph.xy_tab=xy_tab;
%     handles.metric_yzcut_graph.xloc=xloc;
    handles.metric_yzcut_graph.yloc=yloc;
    handles.metric_yzcut_graph.zloc=zloc;
   
    plot_yzcut(handles)
%     imagesc(xy_tab,(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     line([xy_tab(yloc) xy_tab(yloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     xlabel('y [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
    
    axes(handles.scan);
    % cla;
        toshow=toshow(:,:,end:-1:1);

    handles.metric_scan_graph.xy_tab=xy_tab;
    handles.metric_scan_graph.toshow=toshow;
    handles.metric_scan_graph.xloc=xloc;
    handles.metric_scan_graph.yloc=yloc;
    handles.metric_scan_graph.zloc=zloc;
    handles.metric_scan_graph.zloc=zloc;

    plot_scan(handles)
%     imagesc(xy_tab,xy_tab,rot90(toshow(:,:,zloc)',0))
%     line([xy_tab(xloc) xy_tab(xloc)],[min(xy_tab) max(xy_tab)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     line([min(xy_tab) max(xy_tab)],[xy_tab(yloc) xy_tab(yloc)],'Color','r','linewidth',0.5,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('y [\mum]','Fontweight','bold','FontSize',8)
%     axis equal
%     axis tight
    %colormap('jet')
    
    drawnow
    set(handles.yloc,'String',['y = ' num2str(xy_tab(yloc)) 'micron'])
    set(handles.xloc,'String',['x = ' num2str(xy_tab(xloc)) 'micron'])
    set(handles.zloc,'String',['z = ' num2str(z_tab(zloc)) 'micron'])
    %     set(hObject,'toolbar','figure')
    %     set(handles.xzcut,'toolbar','figure')
    %     set(handles.yzcut,'toolbar','figure')
    if handles.graph_obj.Value==0 && isfield(handles.vars,'m1')
        set(handles.info_scan,'String',{'Scan info:',...
            ['M1 = ' num2str(handles.vars.m1(zloc))],...
            ['M2 = ' num2str(handles.vars.m2(zloc))],...
            ['M3 = ' num2str(handles.vars.m3(zloc))]});
    end
    handles.graph_psf.Value=1;
    guidata(hObject, handles);
end
%%
function handles=refresh_imgs(hObject, eventdata, handles)
    handles=update_params(hObject, eventdata, handles);
    
    z_tab=handles.vars.z_tab;
    n_z=length(z_tab);
    xy_tab=handles.vars.xy_tab;
    z_stack=handles.vars.z_stack;
    xloc=round(handles.slider_x.Value);
    yloc=round(handles.slider_y.Value);
    zloc=round(handles.slider_z.Value);
    
    n_pts=handles.vars.n_pts;
    
    handles.vars.toshow = z_stack;
    
    toshow=handles.vars.toshow;
    guidata(hObject, handles);
    
    axes(handles.xzcut);
    % cla;
    img=rot90(reshape(toshow(:,yloc,:),2*n_pts,n_z),1);
    
    handles.metric_xzcut_graph.img=img;
    handles.metric_xzcut_graph.z_tab=z_tab;
    handles.metric_xzcut_graph.xy_tab=xy_tab;
    handles.metric_xzcut_graph.xloc=xloc;
%     handles.metric_xzcut_graph.yloc=yloc;
    handles.metric_xzcut_graph.zloc=zloc;
    
    plot_xzcut(handles)
%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(xloc) xy_tab(xloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
%     
    
    axes(handles.yzcut);
    % cla;
    img=rot90(reshape(toshow(xloc,:,:),2*n_pts,n_z),1);
    
 handles.metric_yzcut_graph.img=img;
    handles.metric_yzcut_graph.z_tab=z_tab;
    handles.metric_yzcut_graph.xy_tab=xy_tab;
%     handles.metric_yzcut_graph.xloc=xloc;
    handles.metric_yzcut_graph.yloc=yloc;
    handles.metric_yzcut_graph.zloc=zloc;
    
    plot_yzcut(handles)    
%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(yloc) xy_tab(yloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('y [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
%     
    axes(handles.scan);
    % cla;
    handles.metric_scan_graph.xy_tab=xy_tab;
    handles.metric_scan_graph.toshow=toshow;
    handles.metric_scan_graph.xloc=xloc;
    handles.metric_scan_graph.yloc=yloc;
    handles.metric_scan_graph.zloc=zloc;
    handles.metric_scan_graph.zloc=zloc;

    plot_scan(handles)
%     imagesc(xy_tab,xy_tab,rot90(toshow(:,:,zloc)',0))
%     line([xy_tab(xloc) xy_tab(xloc)],[min(xy_tab) max(xy_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([min(xy_tab) max(xy_tab)],[xy_tab(yloc) xy_tab(yloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('y [\mum]','Fontweight','bold','FontSize',8)
%     axis equal
%     axis tight
    %colormap('jet')
    
    drawnow
    set(handles.yloc,'String',['y = ' num2str(xy_tab(yloc)) 'micron'])
    set(handles.xloc,'String',['x = ' num2str(xy_tab(xloc)) 'micron'])
    set(handles.zloc,'String',['z = ' num2str(z_tab(zloc)) 'micron'])
    %     set(hObject,'toolbar','figure')
    %     set(handles.xzcut,'toolbar','figure')
    %     set(handles.yzcut,'toolbar','figure')
    if handles.graph_obj.Value==0
        set(handles.info_scan,'String',{'Scan info:',...
            ['M1 = ' num2str(handles.vars.m1(zloc))],...
            ['M2 = ' num2str(handles.vars.m2(zloc))],...
            ['M3 = ' num2str(handles.vars.m3(zloc))]});
    else
        set(handles.info_scan,'String','Scan info:')
    end
    handles.graph_img.Value=1;
    guidata(hObject, handles);
end

%%
function handles=refresh_filter(hObject, eventdata, handles)
    handles=update_params(hObject, eventdata, handles);
    
    z_tab=handles.vars.z_tab;
    n_z=length(z_tab);
    xy_tab=handles.vars.xy_tab;
    z_stack_w=handles.vars.z_stack_w;
    xloc=round(handles.slider_x.Value);
    yloc=round(handles.slider_y.Value);
    zloc=round(handles.slider_z.Value);
    
    n_pts=handles.vars.n_pts;
    
    handles.vars.toshow = z_stack_w;
    
    toshow=handles.vars.toshow;
    guidata(hObject, handles);
    
    axes(handles.xzcut);
    % cla;
    img=rot90(reshape(toshow(:,yloc,:),2*n_pts,n_z),1);
        
    handles.metric_xzcut_graph.img=img;
    handles.metric_xzcut_graph.z_tab=z_tab;
    handles.metric_xzcut_graph.xy_tab=xy_tab;
    handles.metric_xzcut_graph.xloc=xloc;
%     handles.metric_xzcut_graph.yloc=yloc;
    handles.metric_xzcut_graph.zloc=zloc;
    
    plot_xzcut(handles)
% 
%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(xloc) xy_tab(xloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
%     %     axis tight
%     %colormap('jet')
    
    
    axes(handles.yzcut);
    % cla;
    img=rot90(reshape(toshow(xloc,:,:),2*n_pts,n_z),1);
    
    handles.metric_yzcut_graph.img=img;
    handles.metric_yzcut_graph.z_tab=z_tab;
    handles.metric_yzcut_graph.xy_tab=xy_tab;
%     handles.metric_yzcut_graph.xloc=xloc;
    handles.metric_yzcut_graph.yloc=yloc;
    handles.metric_yzcut_graph.zloc=zloc;
    
    plot_yzcut(handles)
%     imagesc(xy_tab,fliplr(z_tab),img)
%     line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([xy_tab(yloc) xy_tab(yloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('y [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('z [\mum]','Fontweight','bold','FontSize',8)
%     %     axis equal
    %     axis tight
    %colormap('jet')
    
    axes(handles.scan);
    % cla;
    handles.metric_scan_graph.xy_tab=xy_tab;
    handles.metric_scan_graph.toshow=toshow;
    handles.metric_scan_graph.xloc=xloc;
    handles.metric_scan_graph.yloc=yloc;
    handles.metric_scan_graph.zloc=zloc;
    handles.metric_scan_graph.zloc=zloc;

    plot_scan(handles)
% 
%     imagesc(xy_tab,xy_tab,rot90(toshow(:,:,zloc)',0))
%     line([xy_tab(xloc) xy_tab(xloc)],[min(xy_tab) max(xy_tab)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     line([min(xy_tab) max(xy_tab)],[xy_tab(yloc) xy_tab(yloc)],'Color','r','linewidth',1,...
%         'linestyle',':')
%     xlabel('x [\mum]','Fontweight','bold','FontSize',8)
%     ylabel('y [\mum]','Fontweight','bold','FontSize',8)
%     axis equal
%     axis tight
    %colormap('jet')
    
    drawnow
    set(handles.yloc,'String',['y = ' num2str(xy_tab(yloc)) 'micron'])
    set(handles.xloc,'String',['x = ' num2str(xy_tab(xloc)) 'micron'])
    set(handles.zloc,'String',['z = ' num2str(z_tab(zloc)) 'micron'])
    %     set(hObject,'toolbar','figure')
    %     set(handles.xzcut,'toolbar','figure')
    %     set(handles.yzcut,'toolbar','figure')
    if handles.graph_obj.Value==0
        set(handles.info_scan,'String',{'Scan info:',...
            ['M1 = ' num2str(handles.vars.m1(zloc))],...
            ['M2 = ' num2str(handles.vars.m2(zloc))],...
            ['M3 = ' num2str(handles.vars.m3(zloc))]});
    else
        set(handles.info_scan,'String','Scan info:')
    end
    handles.graph_filter.Value=1;
    guidata(hObject, handles);
end
%%
function [m1,m2,m3,eta_bar]=calcul_metrics(hObject, eventdata, handles)
    n_z=str2double(handles.n_z.String);
    zloc=round(handles.slider_z.Value);
    m1=reshape(mean(mean(handles.vars.z_stack,1),2),n_z,1);
    m2=reshape(var(var(handles.vars.z_stack,0,1),0,2),n_z,1);
    var(handles.vars.z_stack,0,3);
    m3=reshape(var(var(handles.vars.z_stack_w,0,1),0,2),n_z,1);
    eta_bar=normalize(reshape(sum(sum(handles.vars.object,1),2),n_z,1));
    
    %     m1=normalize(m1);
    %     m2=normalize(m2);
    %     m3=normalize(m3);
    
    handles.vars.m1=m1;
    handles.vars.m2=m2;
    handles.vars.m3=m3;
    handles.vars.etabar=eta_bar;
    guidata(hObject, handles);
end
%%
function handles=filtering(hObject, eventdata, handles)
    r0=str2double(get(handles.r0, 'String'));
    sigma=str2double(get(handles.sigma, 'String'));
    z_stack=handles.vars.z_stack;
    n_pts=str2double(get(handles.n_pts, 'String'));
    dpix_xy=handles.vars.dpix_xy;
    n_z=str2double(get(handles.n_z, 'String'));
    z_stack_w=0*z_stack;
    tmp=-n_pts:n_pts-1;
    [X,Y]=meshgrid(tmp,tmp);
    rho=sqrt(X.^2+Y.^2);
    rho0=2*n_pts/(r0/dpix_xy);
    ftW=normalize(exp((-(rho-rho0).^2)./sigma^2));
    tic
    disp('Filtering...')
    for zi=1:n_z
        img=z_stack(:,:,zi);
        ftI=fftshift(fft2(img));
        ftIw=fftshift(ftI.*ftW);
        z_stack_w(:,:,zi)=(ifft2(ftIw));
    end
    disp('Done')
    t=toc;
    disp(['Elapsed time: ' num2str(t) ' seconds'])
    handles.vars.z_stack_w=z_stack_w;
    guidata(hObject, handles);
end

%%
function plot_scan(handles)
    
    xy_tab = handles.metric_scan_graph.xy_tab;
    toshow = handles.metric_scan_graph.toshow;
    xloc = handles.metric_scan_graph.xloc;
    yloc = handles.metric_scan_graph.yloc;
    zloc = handles.metric_scan_graph.zloc;
    
        imagesc(xy_tab,xy_tab,rot90(toshow(:,:,zloc)',0))
    line([xy_tab(xloc) xy_tab(xloc)],[min(xy_tab) max(xy_tab)],'Color','r','linewidth',1,...
        'linestyle',':')
    line([min(xy_tab) max(xy_tab)],[xy_tab(yloc) xy_tab(yloc)],'Color','r','linewidth',1,...
        'linestyle',':')
    xlabel('x [\mum]','Fontweight','bold','FontSize',8)
    ylabel('y [\mum]','Fontweight','bold','FontSize',8)
    axis equal
    axis tight
    
end

%%
function plot_xzcut(handles)
    
    img = handles.metric_xzcut_graph.img;
    z_tab = handles.metric_xzcut_graph.z_tab;
    xy_tab = handles.metric_xzcut_graph.xy_tab;
    xloc = handles.metric_xzcut_graph.xloc;
%     yloc = handles.metric_xzcut_graph.yloc;
    zloc = handles.metric_xzcut_graph.zloc;
    
    imagesc(xy_tab,fliplr(z_tab),img)
    line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
        'linestyle',':')
    line([xy_tab(xloc) xy_tab(xloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
        'linestyle',':')
    xlabel('x [\mum]','Fontweight','bold','FontSize',8)
    ylabel('z [\mum]','Fontweight','bold','FontSize',8)
    %     axis equal
    %     axis tight
    %colormap('jet')
    
end

%%
function plot_yzcut(handles)
    img = handles.metric_yzcut_graph.img;
    z_tab = handles.metric_yzcut_graph.z_tab;
    xy_tab = handles.metric_yzcut_graph.xy_tab;
    %     xloc = handles.metric_yzcut_graph.xloc;
    yloc = handles.metric_yzcut_graph.yloc;
    zloc = handles.metric_yzcut_graph.zloc;
    
    imagesc(xy_tab,fliplr(z_tab),img)
    line([min(xy_tab) max(xy_tab)],[z_tab(zloc),z_tab(zloc)],'Color','r','linewidth',1,...
        'linestyle',':')
    line([xy_tab(yloc) xy_tab(yloc)],[min(z_tab) max(z_tab)],'Color','r','linewidth',1,...
        'linestyle',':')
    xlabel('y [\mum]','Fontweight','bold','FontSize',8)
    ylabel('z [\mum]','Fontweight','bold','FontSize',8)
    %     axis equal
    %     axis tight
    
end
%%
function handles=refresh_res_acoefs(hObject, eventdata, handles);
    
    
    amin=str2double(get(handles.res_amin, 'String'));
    astep=str2double(get(handles.res_astep, 'String'));
    amax=str2double(get(handles.res_amax, 'String'));
    if amin>=amax
        load gong;
        sound(y,Fs);
        m=msgbox('min(coefs) must be lower than max(coefs)', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
    a_coefs=amin:astep:amax;
    handles.vars.res_acoefs=a_coefs;
    handles.res_ncoefs.String=['n_coefs = ' num2str(length(a_coefs))];
    guidata(hObject, handles);
end

%%
function [handles]=calcul_long_res(psf3d,hObject, eventdata, handles)
    
    %locate maximum
    [m,ind]=max(psf3d(:));
    [ix,iy,iz]=ind2sub(size(psf3d),ind)
    
    %store indices
    
    %
end

%%
function [handles]=calcul_axial_res(psf3d,hObject, eventdata, handles)
    
    %locate maximum
    [m,ind]=max(psf3d(:));
    [ix,iy,iz]=ind2sub(size(psf3d),ind)
    
    %store indices
    
    %
end

%%
function [handles]=calcul_displ(psf3d,hObject, eventdata, handles)
    
    %locate maximum
    [m,ind]=max(psf3d(:));
    [ix,iy,iz]=ind2sub(size(psf3d),ind)
    
    %store indices
    handles.ix=ix;
    handles.iy=iy;
    handles.iz=iz;
    %
end

%%
function plot_resolution_graph(handles)
    colors = handles.vars.colors;
    marc=handles.vars.marc;
    a_coefs=handles.res_graph.a_coefs;
    
    
    if handles.axial_res.Value==1
        %     dispx_tab=handles.vars.dispx;
        %     dispy_tab=handles.vars.dispy;
        %     dispz_tab=handles.vars.dispz;
        %     plot(a_coefs,(dispx_tab),'-','Color',colors(2,:),'linewidth',2)
        %     hold on
        %     plot(a_coefs,(dispy_tab),'-.','Color',colors(3,:),'linewidth',2)
        %     plot(a_coefs,(dispz_tab),'--','Color',colors(5,:),'linewidth',2)
        %     hold off
        %     grid on
        %     set(gca,'xlim',[min(a_coefs),max(a_coefs)])
        %     ylabel('Displacement value [\mum]','fontweight','bold')
        %     title(['Maximum displacement as function of Z' ...
        %         num2str(handles.aberr.zi+1)])
        %     legend('x displacement','y displacement',...
        %         'z displacement','location','best')
        %     xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    end
    
    
    if handles.long_res.Value==1
        %     dispx_tab=handles.vars.dispx;
        %     dispy_tab=handles.vars.dispy;
        %     dispz_tab=handles.vars.dispz;
        %     plot(a_coefs,(dispx_tab),'-','Color',colors(2,:),'linewidth',2)
        %     hold on
        %     plot(a_coefs,(dispy_tab),'-.','Color',colors(3,:),'linewidth',2)
        %     plot(a_coefs,(dispz_tab),'--','Color',colors(5,:),'linewidth',2)
        %     hold off
        %     grid on
        %     set(gca,'xlim',[min(a_coefs),max(a_coefs)])
        %     ylabel('Displacement value [\mum]','fontweight','bold')
        %     title(['Maximum displacement as function of Z' ...
        %         num2str(handles.aberr.zi+1)])
        %     legend('x displacement','y displacement',...
        %         'z displacement','location','best')
        %     xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    end
    
    if handles.displace.Value==1
        dispx_tab=handles.res_graph.dispx;
        dispy_tab=handles.res_graph.dispy;
        dispz_tab=handles.res_graph.dispz;
        plot(a_coefs,(dispx_tab),'-','Color',colors(1,:),'linewidth',2)
        hold on
        plot(a_coefs,(dispy_tab),'-.','Color',colors(2,:),'linewidth',2)
        plot(a_coefs,(dispz_tab),'--','Color',colors(3,:),'linewidth',2)
        hold off
        grid on
        set(gca,'xlim',[min(a_coefs),max(a_coefs)])
        ylabel('Displacement value [\mum]','fontweight','bold')
        title(['Maximum displacement as function of Z' ...
            num2str(handles.aberr.zi+1)])
        legend('x displacement','y displacement',...
            'z displacement','location','best')
        xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    end
end

%%
function handles=refresh_acoefs(hObject, eventdata, handles)
    
    amin=str2double(get(handles.amin, 'String'));
    astep=str2double(get(handles.astep, 'String'));
    amax=str2double(get(handles.amax, 'String'));
    z0_a=str2double(get(handles.z0_a, 'String'));
    if amin>=amax
        load gong;
        sound(y,Fs);
        m=msgbox('min(coefs) must be lower than max(coefs)', ' ','error');
        set(m,'WindowStyle','modal');
        return
    end
    a_coefs=amin:astep:amax;
    handles.vars.a_coefs=a_coefs;
    handles.vars.z0_a=z0_a;
    handles.n_coefs.String=['n_coefs = ' num2str(length(a_coefs))];
    guidata(hObject, handles);
    
end
%%
function [handles]=metrics_a_z0(hObject, eventdata, handles)
    z0=handles.vars.z0_a;
    z_tab=handles.vars.z_tab;
    [~,z0_plan]=min(abs(z_tab-z0));
    a_coefs=handles.vars.a_coefs;
    percent=round(100*normalize(1:length(a_coefs)),2);
    handles.aberr.zi=str2double(get(handles.zi_a, 'String'));
    m1_tab=zeros(1,length(a_coefs));
    m2_tab=m1_tab;
    m3_tab=m1_tab;
    t_gl=tic;
    for ai_iter=1:length(a_coefs)
        disp('   ')
        disp('---------------------------------')
        tst=tic;
        handles_parfor=handles;
        handles_parfor.aberr.ai=a_coefs(ai_iter);
        
        handles_parfor.aberr.phase=a_coefs(ai_iter)*handles_parfor.vars.modes_zern(:,:,handles_parfor.aberr.zi);
        
        [handles_parfor,psf3d]=calc_psf(hObject, eventdata, handles_parfor);
        [handles_parfor,z_stack]=convol_eta_psf3D(psf3d,hObject, eventdata, handles_parfor);
        psf3d=[];
        handles_parfor.vars.z_stack=z_stack;
        z_stack=[];
        handles_parfor=filtering(hObject, eventdata, handles_parfor);
        
        [m1,m2,m3]=calcul_metrics(hObject, eventdata, handles_parfor);
        handles_parfor=[];
        m1_tab(ai_iter)=m1(z0_plan);
        m2_tab(ai_iter)=m2(z0_plan);
        m3_tab(ai_iter)=m3(z0_plan);
        tend=toc(tst);
        disp(['Iteration ' num2str(ai_iter) ' in ' num2str(length(a_coefs)*length(z_tab))])
        disp(['-- ' num2str(percent(ai_iter)) '%'])
        %             currentdate=clock;
        %             time_to_end=datevec(tend./(60*60*24));
        %             endtime=currentdate+datevec;
        t=tend*(length(percent)-ai_iter);
        t_hms = datevec(t./(60*60*24));
        
        disp(['-- Estimated time remaining: '...
            num2str(t_hms(4)) ' hours, ' ...
            num2str(t_hms(5)) ' minutes and '...
            num2str(t_hms(6)) ' seconds'])
        
        disp(['Iteration elapsed time - ' num2str(tend) ' seconds'])
    end
    t_gl2=toc(t_gl);
    disp(['Total elapsed time: ' num2str(t_gl2) ' seconds'])
    handles.metric_a_z0_graph.m1_tab=(m1_tab);
    handles.metric_a_z0_graph.m2_tab=(m2_tab);
    handles.metric_a_z0_graph.m3_tab=(m3_tab);
    handles.metric_a_z0_graph.a_coefs=a_coefs;
    
    figure
    plot_metric_a_z0_graph(handles);
end

%%
function [handles]=metrics_vs_a_z(hObject, eventdata, handles)
    z0=handles.vars.z0_a;
    z_tab=handles.vars.z_tab;
    %     [~,z0_plan]=min(abs(z_tab-z0));
    a_coefs=handles.vars.a_coefs;
    percent=round(100*normalize(1:length(a_coefs)*length(z_tab)),2);
    handles.aberr.zi=str2double(get(handles.zi_a, 'String'));
    m1_tab=zeros(length(a_coefs),length(z_tab));
    m2_tab=m1_tab;
    m3_tab=m1_tab;
    t_gl=tic;
    it_tt=0;
    for z_iter=1:length(z_tab)
        
        z0=z_tab(z_iter);
        [~,z0_plan]=min(abs(z_tab-z0));
        
        for ai_iter=1:length(a_coefs)
            it_tt=it_tt+1;
            disp('      ')
            disp('---------------------------------')
            tst=tic;
            handles_parfor=handles;
            handles_parfor.aberr.ai=a_coefs(ai_iter);
            
            handles_parfor.aberr.phase=a_coefs(ai_iter)*handles_parfor.vars.modes_zern(:,:,handles_parfor.aberr.zi);
            
            [handles_parfor,psf3d]=calc_psf(hObject, eventdata, handles_parfor);
            [handles_parfor,z_stack]=convol_eta_psf3D(psf3d,hObject, eventdata, handles_parfor);
            psf3d=[];
            handles_parfor.vars.z_stack=z_stack;
            z_stack=[];
            handles_parfor=filtering(hObject, eventdata, handles_parfor);
            
            [m1,m2,m3]=calcul_metrics(hObject, eventdata, handles_parfor);
            handles_parfor=[];
            m1_tab(ai_iter,z_iter)=m1(z0_plan);
            m2_tab(ai_iter,z_iter)=m2(z0_plan);
            m3_tab(ai_iter,z_iter)=m3(z0_plan);
            tend=toc(tst);
            disp(['Iteration ' num2str(it_tt) ' in ' num2str(length(a_coefs)*length(z_tab))])
            disp(['-- ' num2str(percent(it_tt)) '%'])
            %             currentdate=clock;
            %             time_to_end=datevec(tend./(60*60*24));
            %             endtime=currentdate+datevec;
            t=tend*(length(percent)-it_tt);
            t_hms = datevec(t./(60*60*24));
            
            disp(['-- Estimated time remaining: '...
                num2str(t_hms(4)) ' hours, ' ...
                num2str(t_hms(5)) ' minutes and '...
                num2str(t_hms(6)) ' seconds'])
            
            disp(['Iteration elapsed time - ' num2str(tend) ' seconds'])
        end
    end
    
    t_gl2=toc(t_gl);
    disp(['Total elapsed time: ' num2str(t_gl2) ' seconds'])
    handles.metric_a_z0_graph.m1_tab=(m1_tab);
    handles.metric_a_z0_graph.m2_tab=(m2_tab);
    handles.metric_a_z0_graph.m3_tab=(m3_tab);
    handles.metric_a_z0_graph.a_coefs=a_coefs;
    
    figure
    plot_metric_vs_a_z_graph(handles);
end

%%
function plot_metric_a_z0_graph(handles)
    colors = handles.vars.colors;
    marc=handles.vars.marc;
    m1_tab=handles.metric_a_z0_graph.m1_tab;
    m2_tab=handles.metric_a_z0_graph.m2_tab;
    m3_tab=handles.metric_a_z0_graph.m3_tab;
    a_coefs=handles.metric_a_z0_graph.a_coefs;
    % figure
    plot(a_coefs,normalize(m1_tab),'-','Color',colors(2,:),'linewidth',2)
    hold on
    % plot(dz,normalize(imgsh1(1,:)),marc{1},'Color',colors(1,:),'linewidth',linew)
    % plot(dz,normalize(imgsh2(1,:)),marc{3},'Color',colors(3,:),'linewidth',linew)
    plot(a_coefs,normalize(m2_tab),'-.','Color',colors(3,:),'linewidth',2)
    plot(a_coefs,normalize(m3_tab),'--','Color',colors(5,:),'linewidth',2)
    hold off
    grid on
    set(gca,'xlim',[min(a_coefs),max(a_coefs)])
    ylabel('Metric value','fontweight','bold')
    title(['Metrics as function of Z' num2str(handles.aberr.zi+1) ' at z0 = ' num2str(handles.vars.z0_a) ' \mum'])
    legend('Total Image Intensity','Variance',...
        'Pre-filtered image variance','location','best')
    xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
end

%%
function plot_metric_vs_a_z_graph(handles)
    colors = handles.vars.colors;
    marc=handles.vars.marc;
    m1_tab=handles.metric_a_z0_graph.m1_tab';
    m2_tab=handles.metric_a_z0_graph.m2_tab';
    m3_tab=handles.metric_a_z0_graph.m3_tab';
    a_coefs=handles.metric_a_z0_graph.a_coefs;
    [~,ind_m1]=max(m1_tab,[],2);
    [~,ind_m2]=max(m2_tab,[],2);
    [~,ind_m3]=max(m3_tab,[],2);
    z_tab=handles.vars.z_tab;
    figure
    subplot(2,2,1)
    imagesc(a_coefs,z_tab,(m1_tab))
    ylabel('z_0 [\mum]','fontweight','bold')
    title(['M1 as function of Z' num2str(handles.aberr.zi+1) ' and imaging depth z_0'])
    xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    
    subplot(2,2,2)
    imagesc(a_coefs,z_tab,(m2_tab))
    ylabel('z_0 [\mum]','fontweight','bold')
    title(['M2 as function of Z' num2str(handles.aberr.zi+1) ' and imaging depth z_0'])
    xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    
    subplot(2,2,3)
    imagesc(a_coefs,z_tab,(m3_tab))
    ylabel('z_0 [\mum]','fontweight','bold')
    title(['M3 as function of Z' num2str(handles.aberr.zi+1) ' and imaging depth z_0'])
    xlabel(['a' num2str(handles.aberr.zi+1) ' [rad]'],'fontweight','bold')
    
    subplot(2,2,4)
    plot(z_tab,a_coefs(ind_m1),'-','Color',colors(2,:),'linewidth',2)
    hold on
    plot(z_tab,a_coefs(ind_m2),'-.','Color',colors(3,:),'linewidth',2)
    plot(z_tab,a_coefs(ind_m3),'--','Color',colors(5,:),'linewidth',2)
    hold off
    grid on
    xlabel(['z [\mum]'],'fontweight','bold')
    ylabel(['a_{max} [rad]'],'fontweight','bold')
    legend('m1','m2','m3')
end


% --- Executes on button press in figure_yzcut.
function figure_yzcut_Callback(hObject, eventdata, handles)
% hObject    handle to figure_yzcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if isfield(handles,'metric_yzcut_graph')
        figure
        plot_yzcut(handles)
 end
    
end

% --- Executes on button press in figure_xzcut.
function figure_xzcut_Callback(hObject, eventdata, handles)
% hObject    handle to figure_xzcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if isfield(handles,'metric_xzcut_graph')
        figure
        plot_xzcut(handles)
 end
    
end