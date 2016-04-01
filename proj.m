%% Load the model file into a Matlab object

model = load_model();

%% Read low resolution starting image

im = imread('tiny_karin.png');
im = rgb2ycbcr(im);

im_scaled = im2double(imresize(im, 2.0, 'Nearest'));

layers = length(model);
im_pad = padarray(im_scaled(:,:,1), [layers, layers]);

%% Initialize cell of planes
% This will increase as the layers of the network are applied, then
% decrease as the final image is reconstructed by combining planes

planes = cell(1,1);
planes{1} = im_pad;

iter = 0; % 31904 iterations

%% Iterate through layers of model
% Each has number of input and output planes of the image starting and ending with 1 plane.
for la = 1:layers
    net = model{la};

    biases = net.bias;
    weights = net.weight;
    ninput = net.nInputPlane;
    noutput = net.nOutputPlane;
    len = noutput;
    oplanes = cell(1,noutput);
    
    for j = 1:len
        
        partial = 0;
        ps = length(planes);
        weight = weights{1,j};
        bias = biases{1,j};
        
        for k = 1:ps
            % Create the 3x3 matrix and convolve with the image plane
            w = weight{1,k};
            w = [cell2mat(w{1,1}); cell2mat(w{1,2}); cell2mat(w{1,3})];
            ip = planes{1,k};
            p = convnfft(ip, w,'valid',(1:max(ndims(ip),ndims(w))),1);
            partial = partial + p;  
            iter = iter + 1;
            disp(iter);
        end
        
        partial = partial + bias;
        plane = max(partial(:,:),0) + 0.1 * min(partial(:,:),0);
        oplanes{1,j} = plane;
    end
       
    planes = oplanes;
      
end

im = planes{1,1};

rsize = size(im_scaled);
isize = size(im);
offset = 2*layers;

% Fix clipping that seems to occur with some image sizes
if (rsize(1) ~= isize(1) || rsize(1) ~= isize(1))
    im_scaled(:,:,1) = im(offset+1:rsize(1)+offset,offset+1:rsize(2)+offset);
else
    im_scaled(:,:,1) = im;
end
    
im_scaled = uint8(255 * im_scaled);
final = ycbcr2rgb(im_scaled);
imwrite(final, 'final.png');

figure(1), imshow(final);




