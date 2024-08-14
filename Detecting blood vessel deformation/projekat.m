function varargout = projekat(varargin)
    % PROJEKAT MATLAB code for projekat.fig
    %      PROJEKAT, by itself, creates a new PROJEKAT or raises the existing
    %      singleton*.
    %
    %      H = PROJEKAT returns the handle to a new PROJEKAT or the handle to
    %      the existing singleton*.
    %
    %      PROJEKAT('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in PROJEKAT.M with the given input arguments.
    %
    %      PROJEKAT('Property','Value',...) creates a new PROJEKAT or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before projekat_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to projekat_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help projekat

    % Last Modified by GUIDE v2.5 30-May-2024 19:56:00

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @projekat_OpeningFcn, ...
                       'gui_OutputFcn',  @projekat_OutputFcn, ...
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

    % --- Executes just before projekat is made visible.
    function projekat_OpeningFcn(hObject, eventdata, handles, varargin)
        handles.output = hObject;
        
        
        handles.axesVideo = findobj(hObject, 'Tag', 'axesVideo');
        handles.axesStartFrame = findobj(hObject, 'Tag', 'axesStartFrame');
        handles.axesEndFrame = findobj(hObject, 'Tag', 'axesEndFrame');
        handles.axesResults = findobj(hObject, 'Tag', 'axesResults'); % rezultati
        handles.axesDilation = findobj(hObject, 'Tag', 'axesDilation'); % r
        handles.axesFirstFrameDilation = findobj(hObject, 'Tag', 'axesFirstFrameDilation'); % prvi frem 
        handles.axesLastFrameDilation = findobj(hObject, 'Tag', 'axesLastFrameDilation'); % poslednji frejm
        handles.textTotalFrames = findobj(hObject, 'Tag', 'textTotalFrames'); % total text
        
        % Posto je prvo bilo problema sa kodom, ubacujem validaciju koja
        % proverava da li su sve axes komponente pronadjene i ispisuje to u
        % komandni prozor
        if isempty(handles.axesVideo) || ~ishandle(handles.axesVideo)
            disp('Axes component for video not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for video found.');
        end
        if isempty(handles.axesStartFrame) || ~ishandle(handles.axesStartFrame)
            disp('Axes component for start frame not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for start frame found.');
        end
        if isempty(handles.axesEndFrame) || ~ishandle(handles.axesEndFrame)
            disp('Axes component for end frame not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for end frame found.');
        end
        if isempty(handles.axesResults) || ~ishandle(handles.axesResults)
            disp('Axes component for results not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for results found.');
        end
        if isempty(handles.axesDilation) || ~ishandle(handles.axesDilation)
            disp('Axes component for dilation not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for dilation found.');
        end
        if isempty(handles.axesFirstFrameDilation) || ~ishandle(handles.axesFirstFrameDilation)
            disp('Axes component for first frame dilation not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for first frame dilation found.');
        end
        if isempty(handles.axesLastFrameDilation) || ~ishandle(handles.axesLastFrameDilation)
            disp('Axes component for last frame dilation not found or invalid. Please check the Tag property.');
        else
            disp('Axes component for last frame dilation found.');
        end
        if isempty(handles.textTotalFrames) || ~ishandle(handles.textTotalFrames)
            disp('Text component for total frames not found or invalid. Please check the Tag property.');
        else
            disp('Text component for total frames found.');
        end
        
        % Inicijalizacija tajmera
        if all([ishandle(handles.axesVideo), ishandle(handles.axesStartFrame), ...
                ishandle(handles.axesEndFrame), ishandle(handles.axesResults), ...
                ishandle(handles.axesDilation), ishandle(handles.axesFirstFrameDilation), ...
                ishandle(handles.axesLastFrameDilation), ishandle(handles.textTotalFrames)])
            handles.timer = timer('ExecutionMode', 'fixedRate', ...
                                  'Period', 1/30, ... % Set period to 1/30 for 30 FPS
                                  'TimerFcn', @(~,~)timerCallback(hObject, handles));
            handles.currentFrame = 1;
            handles.selectingStartFrame = false;
            handles.selectingEndFrame = false;
            handles.startFrame = 1;
            handles.endFrame = 1;
            disp('Timer initialized successfully.');
        else
            error('One or more GUI components were not found or are invalid.');
        end
        
        guidata(hObject, handles);

    % --- Outputs from this function are returned to the command line.
    function varargout = projekat_OutputFcn(hObject, eventdata, handles) 
        varargout{1} = handles.output;

    % --- Executes on button press in loadButton.
    function loadButton_Callback(hObject, eventdata, handles)
        [file, path] = uigetfile('*.avi', 'Select a video file');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            handles.videoFile = fullfile(path, file);
            handles.vidObj = VideoReader(handles.videoFile);
            handles.totalFrames = handles.vidObj.NumFrames;
            handles.currentFrame = 1;
            % Prikazujemo ukupan broj frejmova
            set(handles.textTotalFrames, 'String', ['Total Frames: ', num2str(handles.totalFrames)]);
            disp(['Video loaded: ', handles.videoFile]);
            guidata(hObject, handles);
        end

    % --- Executes on button press in startButton.
    function startButton_Callback(hObject, eventdata, handles)
        
        if ~isfield(handles, 'vidObj') || isempty(handles.vidObj)
            errordlg('Video not loaded. Please load a video file first.');
            return;
        end

        % Prikazivanje prvog i poslednjeg frejma pri pokretanju
        startFrame = read(handles.vidObj, 1);
        imshow(startFrame, 'Parent', handles.axesStartFrame);
        disp('Start frame displayed.');
        
        endFrame = read(handles.vidObj, handles.totalFrames);
        imshow(endFrame, 'Parent', handles.axesEndFrame);
        disp('End frame displayed.');
        
        % Start tajemra
        start(handles.timer);
        disp('Video playback started.');

    % --- Executes on button press in stopButton.
    function stopButton_Callback(hObject, eventdata, handles)
        stop(handles.timer);
        disp('Video playback stopped.');

    % --- Executes on button press in selectFramesButton.
    function selectFramesButton_Callback(hObject, eventdata, handles)
        % postavljaju se flegovi na true da bi se omogucilo selektovanje
        handles.selectingStartFrame = true;
        handles.selectingEndFrame = true;
        guidata(hObject, handles);
        uiwait(msgbox('Click "Start Frame" button to select the start frame, then "End Frame" button to select the end frame.'));

    % --- Executes on button press in startFrameButton.
    function startFrameButton_Callback(hObject, eventdata, handles)
        if handles.selectingStartFrame
            handles.startFrame = handles.currentFrame;
            imshow(read(handles.vidObj, handles.startFrame), 'Parent', handles.axesStartFrame);
            disp(['Start frame selected: ', num2str(handles.startFrame)]);
            handles.selectingStartFrame = false;
            guidata(hObject, handles);
        end

    % --- Executes on button press in endFrameButton.
    function endFrameButton_Callback(hObject, eventdata, handles)
        if handles.selectingEndFrame
            handles.endFrame = handles.currentFrame;
            imshow(read(handles.vidObj, handles.endFrame), 'Parent', handles.axesEndFrame);
            disp(['End frame selected: ', num2str(handles.endFrame)]);
            handles.selectingEndFrame = false;

            % Stop videa
            stop(handles.timer);
            disp('Video playback stopped.');

            % analiziranje i prikazivanje rezultata
            startFrame = handles.startFrame;
            endFrame = handles.endFrame;
            
            if isnan(startFrame) || isnan(endFrame) || startFrame < 1 || endFrame > handles.totalFrames || startFrame > endFrame
                errordlg('Invalid frame numbers. Please try again.');
                return;
            end
            
            disp(['Selected frames from ', num2str(startFrame), ' to ', num2str(endFrame)]);
            
            % Prikazivanje promena uselektovanim frejmovima
            numFrames = endFrame - startFrame + 1;
            frameChanges = zeros(numFrames, 1);
            
            for k = startFrame:endFrame
                frame = read(handles.vidObj, k);
                grayFrame = rgb2gray(frame); % Konvertovanje u gray skalu
                frameChanges(k - startFrame + 1) = sum(grayFrame(:)); % Suma svih piksela
            end
            
            % Prikazivanje promena u selektovanim frejmovima, obican plot
            axes(handles.axesResults);
            cla(handles.axesResults, 'reset'); % Clear previous plot
            plot(handles.axesResults, startFrame:endFrame, frameChanges, '-o');
            xlabel(handles.axesResults, 'Frame Number');
            ylabel(handles.axesResults, 'Sum of Pixel Intensities');
            title(handles.axesResults, 'Changes in selected frames');
            
            guidata(hObject, handles);
        end

    % --- Executes on button press in analyzeDilationButton.
    function analyzeDilationButton_Callback(hObject, eventdata, handles)
        % Prvo provra da li su start i end frejm selektovani
        startFrame = handles.startFrame;
        endFrame = handles.endFrame;
        
        if isnan(startFrame) || isnan(endFrame) || startFrame < 1 || endFrame > handles.totalFrames || startFrame > endFrame
            errordlg('Invalid frame numbers. Please try again.');
            return;
        end
        
        disp(['Analyzing dilation from frame ', num2str(startFrame), ' to ', num2str(endFrame)]);
        
        
        numFrames = endFrame - startFrame + 1;
        allDilationProfiles = zeros(numFrames, size(read(handles.vidObj, startFrame), 1));
        diameters = cell(numFrames, 1); % cuvamo r za svaki frejm
        upperEdges = cell(numFrames, 1); % poziciju gornje ivice
        lowerEdges = cell(numFrames, 1); % poziciju donje ivice
        normalDiameters = cell(numFrames, 1); % r preko normale
        
        for k = startFrame:endFrame
            frame = read(handles.vidObj, k);
            grayFrame = rgb2gray(frame); % opat grayscale konverzija
            edges = edge(grayFrame, 'Canny'); % Detektovanje ivica ptrko Canny algoritma
            
            % Racunanje r celom duzinom krvnog suda
            dilationProfile = zeros(1, size(grayFrame, 1));
            frameDiameters = zeros(size(grayFrame, 1), 1); % cuvanje r za ovaj frejm
            frameNormalDiameters = zeros(size(grayFrame, 1), 1);
            upperEdgePos = zeros(size(grayFrame, 1), 1); 
            lowerEdgePos = zeros(size(grayFrame, 1), 1); 
            
            for row = 1:size(grayFrame, 1)
                edgeCols = find(edges(row, :));
                if length(edgeCols) >= 2
                    % Izracunavanje r izmenju dve tacke
                    upperEdgePos(row) = min(edgeCols);
                    lowerEdgePos(row) = max(edgeCols);
                    frameDiameters(row) = lowerEdgePos(row) - upperEdgePos(row);
                    
                    % Tangenta i normala
                    edgePos = [edgeCols', row * ones(length(edgeCols), 1)];
                    if length(edgePos) > 1
                        % Fja diff za tangentu
                        tangents = diff(edgePos);
                        % normala
                        normals = [-tangents(:, 2), tangents(:, 1)];
                        % normalizacija normale
                        normLengths = sqrt(normals(:, 1).^2 + normals(:, 2).^2);
                        normals = normals ./ normLengths;
                        %distanca izmedju normala
                        normalDistances = vecnorm(normals, 2, 2);
                        frameNormalDiameters(row) = mean(normalDistances); % Example aggregation
                    else
                        frameNormalDiameters(row) = NaN;
                    end
                else
                    % ako nisu detektovane ivice
                    upperEdgePos(row) = NaN;
                    lowerEdgePos(row) = NaN;
                    frameDiameters(row) = NaN;
                    frameNormalDiameters(row) = NaN;
                end
            end
            allDilationProfiles(k - startFrame + 1, :) = frameDiameters;
            diameters{k - startFrame + 1} = frameDiameters;
            upperEdges{k - startFrame + 1} = upperEdgePos;
            lowerEdges{k - startFrame + 1} = lowerEdgePos;
            normalDiameters{k - startFrame + 1} = frameNormalDiameters;
        end
        
        % Cuvanje rez u fajl
        save('dilation_data.mat', 'allDilationProfiles', 'diameters', 'upperEdges', 'lowerEdges', 'normalDiameters', 'startFrame', 'endFrame');
        disp('Dilation data saved to dilation_data.mat');
        
        % Plot
        axes(handles.axesDilation);
        cla(handles.axesDilation, 'reset'); 
        hold on;
        
        % Plot 
        n = 5; % Podesavamo koliko ce se frejmova plotovati
        cmap = lines(numFrames); 
        for k = 1:n:numFrames
            plot(handles.axesDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(k, :), 'Color', cmap(k, :), 'LineWidth', 1.5, 'DisplayName', sprintf('Frame %d', startFrame + k - 1));
        end
        hold off;
        xlabel(handles.axesDilation, 'Position in Blood Vessel');
        ylabel(handles.axesDilation, 'Dilation (pixels)');
        title(handles.axesDilation, 'Vessel Dilation Across Frames');
        
        % legenda
        legend(handles.axesDilation);
        
        % Plot za prvi frejm
        axes(handles.axesFirstFrameDilation);
        cla(handles.axesFirstFrameDilation, 'reset'); % Clear previous plot
        plot(handles.axesFirstFrameDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(1, :), 'LineWidth', 1.5);
        xlabel(handles.axesFirstFrameDilation, 'Position in Blood Vessel');
        ylabel(handles.axesFirstFrameDilation, 'Dilation (pixels)');
        title(handles.axesFirstFrameDilation, sprintf('Dilation Profile for Frame %d', startFrame));
        
        % Plot za poslednji selektovan frejm
        axes(handles.axesLastFrameDilation);
        cla(handles.axesLastFrameDilation, 'reset'); 
        plot(handles.axesLastFrameDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(end, :), 'LineWidth', 1.5);
        xlabel(handles.axesLastFrameDilation, 'Position in Blood Vessel');
        ylabel(handles.axesLastFrameDilation, 'Dilation (pixels)');
        title(handles.axesLastFrameDilation, sprintf('Dilation Profile for Frame %d', endFrame));
        
        guidata(hObject, handles);

    % --- Executes on button press in loadDilationDataButton.
    function loadDilationDataButton_Callback(hObject, eventdata, handles)
        % Load the saved dilation data
        if exist('dilation_data.mat', 'file')
            load('dilation_data.mat', 'allDilationProfiles', 'diameters', 'upperEdges', 'lowerEdges', 'normalDiameters', 'startFrame', 'endFrame');
            disp('Dilation data loaded from dilation_data.mat');
            
            %sve isto 
            % Plot 
            axes(handles.axesDilation);
            cla(handles.axesDilation, 'reset');
            hold on;
            
            % Plot 
            numFrames = endFrame - startFrame + 1;
            n = 5; 
            cmap = lines(numFrames); 
            for k = 1:n:numFrames
                plot(handles.axesDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(k, :), 'Color', cmap(k, :), 'LineWidth', 1.5, 'DisplayName', sprintf('Frame %d', startFrame + k - 1));
            end
            hold off;
            xlabel(handles.axesDilation, 'Position in Blood Vessel');
            ylabel(handles.axesDilation, 'Dilation (pixels)');
            title(handles.axesDilation, 'Vessel Dilation Across Frames');
            
           
            legend(handles.axesDilation);
            
           
            axes(handles.axesFirstFrameDilation);
            cla(handles.axesFirstFrameDilation, 'reset'); 
            plot(handles.axesFirstFrameDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(1, :), 'LineWidth', 1.5);
            xlabel(handles.axesFirstFrameDilation, 'Position in Blood Vessel');
            ylabel(handles.axesFirstFrameDilation, 'Dilation (pixels)');
            title(handles.axesFirstFrameDilation, sprintf('Dilation Profile for Frame %d', startFrame));
            
            
            axes(handles.axesLastFrameDilation);
            cla(handles.axesLastFrameDilation, 'reset'); 
            plot(handles.axesLastFrameDilation, 1:size(allDilationProfiles, 2), allDilationProfiles(end, :), 'LineWidth', 1.5);
            xlabel(handles.axesLastFrameDilation, 'Position in Blood Vessel');
            ylabel(handles.axesLastFrameDilation, 'Dilation (pixels)');
            title(handles.axesLastFrameDilation, sprintf('Dilation Profile for Frame %d', endFrame));
        else
            errordlg('Dilation data file not found. Please analyze dilation first.');
        end

    % Timer callback function for video playback
    function timerCallback(hObject, handles)
        handles = guidata(hObject);
        if handles.currentFrame <= handles.totalFrames
            frame = read(handles.vidObj, handles.currentFrame);
            imshow(frame, 'Parent', handles.axesVideo);
            handles.currentFrame = handles.currentFrame + 1;
            guidata(hObject, handles);
        else
            stop(handles.timer);
            disp('End of video reached.');
        end
