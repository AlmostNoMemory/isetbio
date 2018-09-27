function sceneOpen(hObject,eventdata,handles)
% Initialize sceneWindow
% 
%    sceneOpen(hObject,eventdata,handles)
%
% Copyright ImagEval Consultants, LLC, 2005.

% Choose default command line output for microLensWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

vcSetFigureHandles('SCENE',hObject,eventdata,handles);

%  Check the preferences for ISET and adjust the font size.
ieFontInit(hObject);

end