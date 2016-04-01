function [ model ] = load_model( )
% Loads and interprets the raw JSON neural network file into data readable by matlab

%     fname = 'scale2.0x_model.json';
%     dat = loadjson(fname,'ShowProgress',1,'FastArrayParser',3);
%     model = dat;

mat = matfile('model.mat');
model = mat.dat;
    
    % Takes EXTREMELY long to parse this JSON because of the nested arrays
    % (around 20 minutes) so I saved it to a matfile and load it directly.

end

