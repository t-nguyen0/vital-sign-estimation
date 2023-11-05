%% Face recognition

%addpath(fullfile(pwd, 'matlabPyrTools'));

vid = VideoReader('facevid.mp4')
%vid_write = VideoWriter('newvideo');
vid_write = VideoWriter('face_cropped');
fr = vid.FrameRate;
vid_write.FrameRate=fr;
vidHeight = vid.Height;
vidWidth = vid.Width;
numFrames = vid.FrameRate*vid.Duration;

faceDetector = vision.CascadeObjectDetector();
depVideoPlayer = vision.DeployableVideoPlayer;
open(vid_write);

while hasFrame(vid)
	vidFrame = readFrame(vid);
    bbox = faceDetector(vidFrame);
    %vidFrame = insertShape(vidFrame, 'Rectangle', bbox); %insert rectangle around  face    
    
    %height_start = bbox(2); height_end = (bbox(2)+bbox(4))/3  
    %vidFrame = vidFrame(80:(80+391)/3,:,:); 
    %vidFrame = vidFrame(70:((80+391)/3+25),95:400,:);
    %vidFrame = vidFrame(200:300,320:740,:);
    vidFrame = vidFrame(90:970,70:vid.Width-150,:);
    
	depVideoPlayer(vidFrame);
	writeVideo(vid_write, vidFrame);
	%pause(1/vid.FrameRate);
end


close(vid_write)


