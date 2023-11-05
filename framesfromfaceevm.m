
vid=VideoReader('evm_face_cropped.avi');
numFrames=vid.FrameRate*vid.Duration;

for i=1:numFrames
    img=readFrame(vid);
    imwrite(img,strcat('frame_',int2str(i),'.png'));
end
