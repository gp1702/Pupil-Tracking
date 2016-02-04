% Show the preview of the cameras in a custom GUI
% Also save the timestamps of both.
% Also save the live video stream at the end
% If this is possible, then the whole thing should happen this way
global record;
global arduino;
record = 0;     % false

%% First get inputs from the examiner
% h = rapdi_gui;
% uiwait(h); 

%% Create the video object
video_filename = strcat(mr_no, '_left.avi');
v_left = VideoWriter(video_filename);
v_left.FrameRate = 30;
v_left.Quality = 100;

video_filename = strcat(mr_no, '_right.avi');
v_right = VideoWriter(video_filename);
v_right.FrameRate = 30;
v_right.Quality = 100;

%% Establish connection to the arduino
ports = instrhwinfo('serial');
ports_list = ports.AvailableSerialPorts;

for i = 1:size(ports_list, 1)
    if ~strcmp(ports_list(i), 'COM1')
        arduino_port = ports_list(2)    % TODO: establish comm to prove it is the arduino
        break
    end
end

arduino = serial(arduino_port{1});  % establish comm.
set(arduino,'BaudRate',9600);
fopen(arduino);

%% Establish connection to the cameras
if (~exist('w1'))
    w1 = webcam1;
    start(w1);
end

if (~exist('w2'))
    w2 = webcam2;
    start(w2);
end

vidRes = w1.VideoResolution;    % assume w1 and w2 same which we know
nBands = w1.NumberOfBands;

hImage1 = zeros(vidRes(2), vidRes(1), nBands);
hImage2 = hImage1;

% Create figure and use it to display previews of both cameras
f = figure('CloseRequestFcn',@cleanup);
subplot(1,2,1); h1 = subimage(hImage1);     % h1 and h2 are the handles to the subimages 
subplot(1,2,2); h2 = subimage(hImage2);

% Set the update function for preview.. pass arguments
setappdata(h1, 'UpdatePreviewWindowFcn', @(obj, evt, h1)process_videos_func(obj, evt, h1, v_left));
setappdata(h2, 'UpdatePreviewWindowFcn', @(obj, evt, h2)process_videos_func(obj, evt, h2, v_right));

preview(w1, h2); preview(w2, h1);           % display the images as subplots

start_button = uicontrol(f,'Style','pushbutton','String','START', 'Position',[50 20 60 40], 'Callback', {@do_record, '1'});
stop_button = uicontrol(f,'Style','pushbutton','String','STOP', 'Position',[450 20 60 40], 'Callback', {@do_record, '0'});