% clear the previous work space's directory 
clear all;
% close all of the figures of previous program / reset figures
close all;

%
%----------------------------------------------------------------------------------------------------------%
% Section 1 ACCESSING IMAGE ACQUISITION DEVICE AND STORING THE SNAPSHOTS 
%----------------------------------------------------------------------------------------------------------%
%
% This section deals with accessing the Video input i.e Camera attached to the Laptop / Desktop
% Access the WINVIDEO object which represents the connection between MATLAB and an image acquisition device
CameraInput = videoinput('winvideo',1);

% Create the video feed from image acquistion devide
preview(CameraInput);

% Start image acquisition
start(CameraInput);

% Set the colorspace / Color bound of incoming video feed to RGB color bound 
set(CameraInput, 'ReturnedColorSpace', 'RGB');

% Stop the execution for 2 seconds to warm the acquistion device 
pause(2);

% Get the snapshot from the device and store it in the variable for further processing
snapShotImage = getsnapshot(CameraInput);

% Show the snapShotImage taken into another pop up with magnification of 60% 
%figure,imshow(snapShotImage , 'InitialMagnification', 60); 
% Also try with this :__
figure,imshow(snapShotImage ,'Border','tight');

% Represent the taken snapshot as the matrix of numbers
image(snapShotImage);

%store the temporary matrix numbers to variable
temporary_matrixNumber = snapShotImage;

%----------------------------------------------------------------------------------------------------------%
% Section 2 HSV COLOR SPACE SEGMENTATION 
%----------------------------------------------------------------------------------------------------------%
%
% This section uses Hue Saturated Value method to eliminate the " NON SKIN " Pixels in the image matrix 
% Copy the image matrix snapShotImage to image matrix used for HSV conversion
imageforHSV = snapShotImage;

% Convert the RGB color space image matrix to HSV color space image matrix using inbuilt converter
HSVImage = rgb2hsv(imageforHSV);

% Saperate the HUE color plane from the image
hueOfImage = HSVImage(:,:,1);
% Saperate the Saturation color plane from the image
saturationOfImage = HSVImage(:,:,2);
% Saperate the Value color plane from the image
valueOfImage = HSVImage(:,:,3);

% USE THIS BLOCK TO SHOW THE SUBPLOTS OF HSV SAPERATION
% START OF TEST BLOCK FOR HSV SAPERATION
% Show the image of HUE for comparision
subplot(2,2,1), imshow(hueOfImage)
% Show the image of SATURATION comparision
subplot(2,2,2), imshow(saturationOfImage)
% Show the image of VALUE comaprision
subplot(2,2,3), imshow(valueOfImage)
% END FOR THE TEST BLOCK OF HSV SAPERATION

% Find / Search the linear indices / nonZero elements in the image matrix 
% Put the thresholding value and update the matrix and violate the pixles of the NON SKIN type
[linearIndices, arrayNumber] = find( hueOfImage > 0.25 | saturationOfImage <= 0.15 | saturationOfImage > 0.9); 

% Update the found pixels to the matrix of type linear indices
totalPixelstoUpdate = size(linearIndices,1);

% Update all of the pixels to the img matrix for previewing   
for imageIndex = 1:totalPixelstoUpdate
  HSVImage(linearIndices(imageIndex),arrayNumber(imageIndex),:) = 0;
end

% Start the figure popUp procedure    
figure
% Attach the updated image MATRIX for viewing  
imshow(HSVImage);

% Delay for few seconds to update the image matrix
pause(3);

%
%----------------------------------------------------------------------------------------------------------%
% Section 3 YCBCR COLOR SPACE SEGMENTATION FOR SKIN TYPE DETECTION 
%----------------------------------------------------------------------------------------------------------%
%    
% This section uses YCbCr color space for detection of skin tone from the previous image. 
% Copy the image matrix img to image matrix generated from HSV conversion   
imageForYCBCR = HSVImage; 

% Convert the preiously converted HSV image to YCbCR color space as still it contains RGB components
% because of thresholding 
imageOfYCbCr = rgb2ycbcr(imageForYCBCR);

% Saperate the Cb color plane from the image
cbColorSpaceComponent = imageOfYCbCr(:,:,2);
% Saperate the Cr color plane from the image
crColorSpaceComponent = imageOfYCbCr(:,:,3);

% This is a routine for thresholding the detection of SKIN from the img Matrix 
% Find / Search the linear indices / nonZero elements in the image matrix 
% Put the thresholding value and update the matrix and violate the pixles of the NON SKIN type
%[linearIndices, arrayNumber, directionSearch] = find(cbColorSpaceComponent >= 77 & cbColorSpaceComponent <= 127 & crColorSpaceComponent >= 133 & crColorSpaceComponent <= 173); 
% You can try this statement also by making the above statement in comments
[linearIndices, arrayNumber, directionSearch] = find(cbColorSpaceComponent >= 77 | cbColorSpaceComponent <= 127 | crColorSpaceComponent >= 133 | crColorSpaceComponent <= 173); 
% Update the found pixels to the matrix of type linear indices
totalPixelstoUpdate = size(linearIndices,1);
 
 % Mark the SKIN pixels in the image matrix 
 for imageIndex = 1:totalPixelstoUpdate
     imageOfYCbCr(linearIndices(imageIndex),arrayNumber(imageIndex),:) = 0;
     bin(linearIndices(imageIndex),arrayNumber(imageIndex)) = 1;
 end
 
% Start the figure popUp procedure    
figure
% Attach the updated image MATRIX for viewing  
imshow(imageOfYCbCr);

% Delay for few seconds to update the image matrix
pause(3);
   
%
%----------------------------------------------------------------------------------------------------------%
% Section 4 RGB COLOR SPACE SEGMENTATION FOR SKIN TYPE DETECTION 
%----------------------------------------------------------------------------------------------------------%
%    
% This section uses YCbCr color space for detection of skin tone from the previous image. 
% Copy the image matrix img to image matrix generated from HSV conversion   
imageOfRGB = imageOfYCbCr;

% Saperate the RED color plane from the image
redImageComponent   = imageOfRGB(:,:,1);
% Saperate the GREEN color plane from the image
greenImageComponent = imageOfRGB(:,:,2);
% Saperate the BLUE color plane from the image
blueImageComponent  = imageOfRGB(:,:,3);

% This is a routine for thresholding the detection of SKIN from the img Matrix 
% Find / Search the linear indices / nonZero elements in the image matrix 
% Put the thresholding value and update the matrix and violate the pixles of the NON SKIN type
[imageRow, imageColumn, imageDirection]= find( blueImageComponent > 0.79 * greenImageComponent - 67 & blueImageComponent < 0.78 * greenImageComponent + 42 & blueImageComponent > 0.836 * greenImageComponent - 14 & blueImageComponent < 0.836 * greenImageComponent + 44 ); 
totalRGBtoUpdate=size(imageRow,1);

% Mark the SKIN pixels in the image matrix  
for imageIndex = 1:totalRGBtoUpdate
    imageOfRGB(imageRow(imageIndex) , imageColumn(imageIndex) , :) = 0;
end

% Start the figure popUp procedure    
figure
% Attach the updated image MATRIX for viewing  
imshow(imageOfRGB);

% Delay for few seconds to update the image matrix
pause(3);
   
 
imageForRGBmap = snapShotImage;
[imageForRGBmapRows,imageForRGBmapColumn,imageForRGBmapColormap] = size(imageForRGBmap);
 
% Check the snap shot image is there in the RGB colorspace MAP 
if imageForRGBmapColormap == 3
  % If yes saperate the color spaces according for Red , Green and Blue
  redColorComponent   = imageForRGBmap(:,:,1);
  greenColorComponent = imageForRGBmap(:,:,2);
  blueColorComponent  = imageForRGBmap(:,:,3);
end

%
%----------------------------------------------------------------------------------------------------------%
% Section 4 DATABASE CREATION AND UPDATION
%----------------------------------------------------------------------------------------------------------%
%
% This section deals with creating the database ( Microsoft Databse ) for the storing the images of skin types
% this is a generic database containing SKIN tone images from all over the world
% Upload the images as individual to avoid the skipping for images 
ImageDB{1} = imread('OBESITY_FOR_SKIN_TYPE_1.jpg');
ImageDB{2} = imread('OBESITY_FOR_SKIN_TYPE_2.jpg');
ImageDB{3} = imread('OBESITY_FOR_SKIN_TYPE_3.jpg');
imageDB{4} = imread('OBESITY_FOR_SKIN_TYPE_4.jpg');
ImageDB{5} = imread('OBESITY_FOR_SKIN_TYPE_5.jpg');
ImageDB{6} = imread('OBESITY_FOR_SKIN_TYPE_6.jpg');
ImageDB{7} = imread('OBESITY_FOR_SKIN_TYPE_7.jpg');
ImageDB{8} = imread('OBESITY_FOR_SKIN_TYPE_8.jpg');
ImageDB{9} = imread('OBESITY_FOR_SKIN_TYPE_9.jpg');
dataBase=cell(9,1);
%Upload the images to the database
for databaseIndex = 1:9
    % Change the location or address of the folder when running
  dataBase{databaseIndex} = imread (['D:\Shaveer_Proj\OBESITY_FOR_SKIN_TYPE_' int2str(databaseIndex) '.jpg ']);
end
% Save the database at the end of Update
save dataBase dataBase

%
%----------------------------------------------------------------------------------------------------------%
% Section 4 DATABASE CREATION AND UPDATION
%----------------------------------------------------------------------------------------------------------%
%
% This section deals with creating the database ( Microsoft Databse ) for the storing the images of skin types
% this is a generic database containing SKIN tone images from all over the world
% Upload the images as individual to avoid the skipping for images 
% to compare euclidian distance of 9 images.
% Load all of the database images 9.
for totalImagesinDatabase = 1:9
  % Copy the Image Matrix of Database of SKIN TYPE 1 
  temporaryImageMatrix = imread('OBESITY_FOR_SKIN_TYPE_1.jpg');
  % Copy the image of YCbCr matrix into the algorithm input matrix
  euclidianInputImage = imageOfYCbCr;
  % Define the euclidian minimum distance
  euclidianMinimumDistance = 588;   
  % Copy the image matrix from the temp image matrix
  [imageRow, imageColumn] = size(temporaryImageMatrix(:,:,1));
  % make the null matrix for the euclidian distance ( i.e fill with 0's) 
  euclidianDistanceMatrix = zeros(imageRow , imageColumn);
  for xAxis = 1 : imageRow          
      for yAxis = 1 : imageColumn
        % Calculate the euclidian image matrix
        distance(xAxis, yAxis) = sqrt(double(euclidianInputImage(xAxis, 1) - temporaryImageMatrix(1, yAxis)).^ 2);
        distance(xAxis, yAxis) = sqrt(double(euclidianInputImage(xAxis, 2) - temporaryImageMatrix(2, yAxis)).^ 2);
     end
  end
end

% Show the pop Up image of the result
if distance < euclidianMinimumDistance
  uiwait(msgbox('PERSON IS :- OBESE','Status','modal'));
else 
   uiwait(msgbox('PERSON IS :- NOT OBESE','Status','modal'));
end
