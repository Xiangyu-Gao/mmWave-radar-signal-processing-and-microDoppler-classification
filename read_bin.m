% Put te unziped binary file under the folder as './template data/bin_data/adc_data_0.bin'
clc
clear all
close all

samples = 128; % num of samples per chirp
loop = 255;
Tx = 2;

folder_location = './template data/bin_data/';
data = readDCA1000(folder_location, samples);
data_length = length(data);
data_each_frame = samples*loop*Tx;
Frame_num = data_length/data_each_frame;
