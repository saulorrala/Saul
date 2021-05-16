clc
close all
clear all

myFolder = 'C:\Users\saul_\Downloads\Biohack\CovidCoughDataSet pre\Negative'; 

filePattern = fullfile(myFolder, '*.wav');
matFiles = dir(filePattern);

fs =  16000;
numBands = 64;
frequencyRange = [125 7500];
windowLength = 0.025*fs;
overlapLength = 0.0102*fs;
FFTLength = 512;

for k = 1:length(matFiles)
    baseFileName = matFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);

    [y,fs] = audioread(fullFileName);
     y = y(:,1);
%     y = resample(y,fs,16000);
   
    

    melSpectrogram(y,fs, ...
    'Window',hann(round(windowLength),'periodic'), ...
    'OverlapLength',round(overlapLength), ...
    'FFTLength',FFTLength, ...
    'FrequencyRange',frequencyRange, ...
    'NumBands',numBands, ...
    'FilterBankNormalization','none', ...
    'WindowNormalization',false, ...
    'SpectrumType','magnitude', ...
    'FilterBankDesignDomain','warped');



set(gca, 'Visible', 'off');
    colorbar('off');
    
%     audiowrite(x,['C:\Users\saul_\Downloads\Senior Design\EmergencyVehicles1\AudioDatabase\Ambulance\a', num2str(k), '.wav']);
    saveas(gcf,['C:\Users\saul_\Downloads\Biohack\CovidCoughDataSet\Negative images\g', num2str(k), '.png']);

   
end