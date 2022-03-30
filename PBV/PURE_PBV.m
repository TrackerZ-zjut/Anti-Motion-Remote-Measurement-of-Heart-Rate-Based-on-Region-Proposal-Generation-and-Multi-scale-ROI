clear;
workDir = 'G:\ZMH\Multi-scale rPPG';
addpath([NEWworkDir '\utils']);

nSub = 10;
nVersion = 6;
PUREfps = 30;
winLength = 150;
stepSize = winLength/2;
hannW = hann(winLength);
load('uspeusig.mat');
u_sig = u(:,2);

for  iSub = 1:nSub
    for iVersion = 1:nVersion
        subID = [num2str(iSub,'%02d') '-' num2str(iVersion,'%02d')];
        disp(['processing ' subID ]);
        vidDir = [ 'E:\PURE\Data\' subID];
        roi_File = [workDir '\Result\PURE\' subID '\roi_facedetector.mat']; %  ROI coordinates tracked by KLT
        ResultDir = [NEWworkDir '\Result\PURE\' subID ];
        file2Save = [ResultDir '\new_single_PBV_1220.mat'];
        
        if ~exist(vidDir,'dir')
            disp([ subID 'does not exist'])
            continue;
        end
        
        if ~exist(ResultDir,'dir')
            mkdir(ResultDir);
        end
        
        imageList = dir(vidDir);
        nImages = length(imageList)-2;
        Num_k = floor( nImages/stepSize );
        nImages = Num_k * stepSize;
        traces = zeros(3,nImages);
        
        for iImage =1:nImages
            imageName = imageList(iImage+2).name;
            imagePath = [vidDir '\' imageName];
            currImage = imread(imagePath);
            load(roi_File); % rect_klt
            bbox0 = rect_klt(iImage,:);
            imgcrop = imcrop ( currImage, bbox0 );  % ROI coordinates
            traces(:,iImage)  =  mean(mean(imgcrop),2);     % get RGB trace
        end
        traceLength = size(traces,2);
        win_pulseEst = zeros( 1, winLength );
        PulseEst = zeros(1, traceLength);
        
        for n = winLength:stepSize:traceLength
            % PBV algorithm
            raw_trace = traces( : , n-winLength+1:n);
            mean_trace = mean(raw_trace,2);
            ntraces = raw_trace./repmat(mean_trace,[1,size(raw_trace,2)]);
            ntraces = ntraces - ones(3,winLength);
            p = u_sig'*((ntraces*ntraces')\ntraces);
            p = p - mean(p);
            p = p/std(p);
            win_pulseEst = p;%  windows signal extracted by PBV
            win_fusion_pulseEst = win_pulseEst.*(hannW)';
            % Overlap and add to complete signal
            PulseEst(n-winLength+1:n) = PulseEst(n-winLength+1:n) + win_fusion_pulseEst;
        end
        save( file2Save, 'PulseEst');
    end
end
disp( 'PluseEst complete');
