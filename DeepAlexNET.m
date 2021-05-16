clc
clear
close all

imds = imageDatastore('C:\Users\saul_\Downloads\Biohack\CovidCoughDataSet','FileExtensions','.png', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

[imdsTrain,imdsValidation] = splitEachLabel(imds,0.8,'randomized');
augimdsTrain = augmentedImageDatastore([227 227],imdsTrain);
augimdsValidation = augmentedImageDatastore([227 227],imdsValidation);

net = alexnet;

layersTransfer = net.Layers(1:end-3);

numClasses = numel(categories(imdsTrain.Labels));

layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

miniBatchSize = 4;
valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);

options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',8, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',valFrequency, ...
    'Verbose',false, ...
    'Plots','training-progress');


Cnet = trainNetwork(augimdsTrain,layers,options);

[YPred,scores] = classify(Cnet,augimdsValidation);

YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

figure('Units','normalized','Position',[0.2 0.2 0.4 0.4]);
cm = confusionchart(YValidation,YPred);

cm.Title = sprintf('Confusion Matrix for Validation Data \nAccuracy = %0.2f %%',mean(YPred==YValidation)*100);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
