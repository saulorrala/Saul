function raspi_CovidDetect()
%#codegen

%Create raspi & webcam obj
r = raspi();
% cam      = webcam(raspiObj,1);
audioCapture= audiocapture(r,'plughw:2,0','SampleRate',48000,'SamplesPerFrame', 48000/20);%Initialize DNN and the input size
net        = coder.loadDeepLearningNetwork('CovidNet.mat');
inputSize  = [227, 227,3];% net.Layers(1).InputSize;

%Initialize text to display
textToDisplay = '......';
fs = 48000;
numBands = 64;
frequencyRange = [125 7500];
windowLength = 0.025*fs;
overlapLength = 0.0102*fs;
FFTLength = 1200;
% Main loop
start = tic;
fprintf('Entering into while loop.\n');
while true
    %Capture image from webcam
    x = capture(audioCapture);
    x1 = zeros(size(double(x)),'like',double(x)); %#ok<PREALL>
    [x1] = double(x);

    mel = melSpectrogram(x1,fs, ...
    'Window',hann(round(windowLength),'periodic'), ...
    'OverlapLength',round(overlapLength), ...
    'FFTLength',FFTLength, ...
    'FrequencyRange',frequencyRange, ...
    'NumBands',numBands, ...
    'FilterBankNormalization','none', ...
    'WindowNormalization',false, ...
    'SpectrumType','magnitude', ...
    'FilterBankDesignDomain','warped');
        mel = mel(1:227, 1:227, 1:3);

set(gca, 'Visible', 'off');
% colorbar('off');


    img = mel ;
    
    elapsedTime = toc(start);
    %Process frames at 1 per second
    if elapsedTime > 1
        %Resize the image
        imgSizeAdjusted = imresize(img,inputSize(1:2));
        
        %Classify the input image
        [label,score] = net.classify(imgSizeAdjusted);
        maxScore = max(score);
        
        labelStr = cellstr(label);
        textToDisplay = sprintf('Label : %s \nScore : %f',labelStr{:},maxScore);
        start = tic;
    end
    
    %Display the predicted label
    img_label = insertText(img,[0,0],textToDisplay);
    displayImage(r,img_label);
end