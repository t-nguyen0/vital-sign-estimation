%% Post EVM
% The amplified video was converted to HSV color model. 
% FFT was performed on the time series signals for each pixel in the hue channel
% frequency component with highest magnitude recorded for each spectrogram
clearvars

vid = VideoReader('evm_20_1317.avi'); %load vid after EVM

fr = vid.FrameRate;
vidHeight = vid.Height;
vidWidth = vid.Width;
numFrames = vid.FrameRate*vid.Duration;

Htotal=zeros(vidHeight,vidWidth,numFrames);

% Convert to HSV
k=1;
while hasFrame(vid)
    img = readFrame(vid);
    [H S V] = rgb2hsv(img);
    r(:,:,k)=img(:,:,1);
    g(:,:,k)=img(:,:,2);
    b(:,:,k)=img(:,:,3);
    Htotal(:,:,k)=H;
    k = k+1;
end

freq=zeros(vidHeight,vidWidth);

for i=1:vidHeight
    for j=1:vidWidth
        sig=Htotal(i,j,:);
        sig1=reshape(sig,1,numFrames);
        sig1=detrend(sig1);
        sig1=fft(sig1);
        %figure, plot(abs(sig1))
        [argval, argmax]=max(abs(sig1));
        freq(i,j)=argmax*fr/numFrames;
        freq(i,j)=freq(i,j)*60;
    end
end

histogram(freq)

