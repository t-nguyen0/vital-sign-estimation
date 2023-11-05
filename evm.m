%% EVM

addpath(fullfile(pwd, 'matlabPyrTools'));
%run(fullfile('matlabPyrTools', 'MEX', 'compilePyrTools.m'));

%% Load cropped video
vid = VideoReader('face_cropped.avi'); %keep same cropped.avi vid
vid_write = VideoWriter('evm_face_cropped_50');
fr = vid.FrameRate;
vid_write.FrameRate=fr;
vidHeight = vid.Height;
vidWidth = vid.Width;
numFrames = vid.FrameRate*vid.Duration;
numChan = 3;
level = 4;

%alpha = 20;
alpha = 50;

temp = struct('cdata', zeros(vidHeight, vidWidth, numChan, 'uint8'), 'colormap', []);

fl = 1.3;
fh = 1.7;

startId = 1;
endId = numFrames-10;

%% Gaussian pyramid decomposition (time, x, y, color chan)
temp.cdata = read(vid, startId);
[rgbframe, ~] = frame2im(temp);
rgbframe = im2double(rgbframe);
frame = rgb2ntsc(rgbframe);

blurred = blurDnClr(frame,level);

GDown_stack = zeros(endId - startId +1, size(blurred,1),size(blurred,2),size(blurred,3));
GDown_stack(1,:,:,:) = blurred;

k = 1;
for i=startId+1:endId
    k = k+1;
    temp.cdata = read(vid, i);
    [rgbframe,~] = frame2im(temp);

    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);

	blurred = blurDnClr(frame,level);
    GDown_stack(k,:,:,:) = blurred;
end

%% Temporal filtering

%sampRate = 30;
sampRate = fr;
atten = 1; % alpha when past cutoff freq
dim = 1;

input_shifted = shiftdim(GDown_stack,dim-1);
Dimensions = size(input_shifted);
    
n = Dimensions(1);
dn = size(Dimensions,2);
        
Freq = 1:n;
Freq = (Freq-1)/n*sampRate;
mask = Freq > fl & Freq < fh;
    
Dimensions(1) = 1;
mask = mask(:);
mask = repmat(mask, Dimensions);

F = fft(input_shifted,[],1);  
F(~mask) = 0;   
filtered = real(ifft(F,[],1));   
filtered = shiftdim(filtered,dn-(dim-1));

%% Amplify
filtered(:,:,:,1) = filtered(:,:,:,1) .* alpha;
filtered(:,:,:,2) = filtered(:,:,:,2) .* alpha .* atten;
filtered(:,:,:,3) = filtered(:,:,:,3) .* alpha .* atten;

%% Output rendering
k = 0;

open(vid_write)

for i=startId:endId
    k = k+1;
    temp.cdata = read(vid, i);
    [rgbframe,~] = frame2im(temp);
    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);

    filteredout = squeeze(filtered(k,:,:,:));
    filteredout = imresize(filteredout,[vidHeight vidWidth]);
    filteredout = filteredout+frame;
    
    frame = ntsc2rgb(filteredout);
    frame(frame > 1) = 1;
    frame(frame < 0) = 0;

    writeVideo(vid_write,im2uint8(frame));
end

close(vid_write);


  

%% functions
function out = blurDnClr(im, nlevs, filt)
if (exist('nlevs') ~= 1) 
  nlevs = 1;
end

if (exist('filt') ~= 1) 
  filt = 'binom5';
end

tmp = blurDn(im(:,:,1), nlevs, filt);
out = zeros(size(tmp,1), size(tmp,2), size(im,3));
out(:,:,1) = tmp;
for clr = 2:size(im,3)
  out(:,:,clr) = blurDn(im(:,:,clr), nlevs, filt);
end
end



