% read multiple-frame uwcr raw data and convert them to the format for this
% repo

clc
clear

% update the directory for the uwcr dataset and the folder you want to read
folder_location = 'D:\Automotive\2019_04_09_bms1000\radar_raw_frame';
files = dir(folder_location);
data_frames = [];
start_idx = 3;  % the first frame has index 3 in files
num_frames_select = 30;
end_idx = start_idx + num_frames_select - 1;
for i = start_idx:end_idx
    file_dir = strcat(folder_location, '/', files(i).name);
    load(file_dir);
    data = permute(adcData, [2, 4, 1, 3]);
    shape = size(data);
    new_shape = [shape(1)*shape(2)*shape(3), shape(4)];
    data_seq = reshape_C_order(data, new_shape);
    data_seq = permute(data_seq, [2, 1]);
    data_frames = cat(2, data_frames, data_seq);
end

% save read data .mat
save("tmp_uwcr_read_data.mat","data_frames")