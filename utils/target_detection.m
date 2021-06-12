clc
clear all
close all

%% Main function 
% file information
% date_list = ["2019_09_29"];
% date_list = ["2019_04_09", "2019_04_30", "2019_05_09", "2019_05_23", "2019_05_28", "2019_05_29"];

for ida = 1:length(date_list)
    date = date_list(ida);
    folder_location = strcat('/mnt/nas_crdataset/', date, '/');
    files = dir(folder_location); % find all the files under the folder
    n_files = length(files);
    processed_files = [3:n_files];
    
    date_split = split(date, '_');
    if str2num(date_split(2)) < 9
        % old data format
        IS_oldF = 1;
        store_folder = '/rad_reo_zerf/';
    else
        % new data format
        IS_oldF = 0;
        store_folder = '/rad_reo_zerf_h/';
    end
    
    for idx = 1:length(processed_files)
        inum = processed_files(idx);
        file_name = files(inum).name; 
        disp(file_name)
        folder_dir = strcat(folder_location, file_name, store_folder);
        run_detection(folder_dir, date, file_name, IS_oldF);
    end
end


%% Detection function
function [] = run_detection(folder_dir, date, file_name, IS_oldF)

IS_Save_dets = 1;
IS_Save_rawdata = 0;
IS_vel_disambg = 1;
IS_Disp_num = 1;
IS_Win_rngvel = 0;
max_det_len = 0;

%% FMCW waveform parameters
fc = 77e9; % Carrier frequency
c = physconst('LightSpeed');
lambda = c/fc;
Fs = 4*10^6; % Sampling frequency (complex)
S = 21.0017e12; % sweep slopes
samples = 128; % only use the first 64 points
loop = 255;
rx_d = lambda/2;
Tx = 2;
Rx = 4;

if IS_oldF
    Tc = 120e-6; % seconds; 
else
    Tc = 90e-6; % seconds;
end

%% System parameters
Pfa = 5e-5; % probability of false alarm
num_crop = 2; % crop the range bin near the self-reflection

fft_Rang = 128;
fft_Ang = 64; % This is for the ego-motion estimation
fft_Vel = 256;

freq_res = Fs/fft_Rang; % range_grid
freq_grid = (0:fft_Rang-1).'*freq_res;
rng_grid = freq_grid*c/S/2; % d=frediff_grid*c/sweepSlope/2;

w = linspace(-1, 1, fft_Ang+1); % angle_grid for ego-motion estimation
w(fft_Ang+1) = [];
agl_grid = asin(w)*180/pi; % [-1,1]->[-pi/2,pi/2]

dop_grid = fftshiftfreqgrid(fft_Vel, 1/Tc); % fs=1/Tc, dopgrid = [-fs/2,fs/2]
vel_grid = dop_grid*lambda/2;   % velocity_grid, v = lamda/4*[-fs,fs]

rng_grid = round(rng_grid, 4);
agl_grid = round(agl_grid, 4);
vel_grid = round(vel_grid, 4);
vmax = vel_grid(end, 1);

%% read raw data for whole sequence
data = readDCA1000(folder_dir, samples);
data_length = length(data);
data_each_frame = samples*loop*Tx;
Frame_num = data_length/data_each_frame;

% check if the frame numer of read data is an integar
if IS_oldF
    [data,Frame_num,frame_start,frame_end] = check_read_data(data,Frame_num, ...
        data_each_frame,data_length,Rx);
else
    frame_start = 1;
    frame_end = frame_start + Frame_num - 1; 
end

save_folder = "/mnt/sdb/ProcsData/cfar_dets/";
save_dir = strcat(save_folder, date, '/', file_name);
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
end

%% target detection loop for each frame
for i = frame_start:frame_end
    % reshape data of each frame to the format [Rx, samples, chirp]
    [raw_data_frame] = extract_framedata(data, i, data_each_frame, Rx, ...
    Tx, samples, loop);
    
    % save the raw data locally for selected frames
    if IS_Save_rawdata
        saved_file_name = strcat(save_file_dir, '/', num2str(i,'%04d'), '.mat');
        save(saved_file_name,'raw_data_frame','-v6');
    end
    
    % Range FFT, Velocity FFT (with hanning widnow) for points detection
    if IS_Win_rngvel
        rng_hann_wind = reshape(hanning(samples), [1,samples,1]);
        Range_FFT = fft(raw_data_frame.*rng_hann_wind, fft_Rang, 2);
        vel_hann_wind = reshape(hanning(loop), [1,1,loop]);
        Velocity_FFT = fftshift(fft(Range_FFT.*vel_hann_wind, fft_Vel, 3), 3);
    else
        Range_FFT = fft(raw_data_frame, fft_Rang, 2);
        Velocity_FFT = fftshift(fft(Range_FFT, fft_Vel, 3), 3);
    end
    Dopdata_sum = squeeze(mean(abs(Velocity_FFT), 1));
    
    % CFAR detector on Range-Velocity to detect targets 
    % Output format: [doppler index, range index(start from index 1), ...
    % cell power]
    [Resl_indx] = cfar_RV(Dopdata_sum, fft_Rang, num_crop, Pfa);
    if size(Resl_indx,2) > 0
        % Peak Grouping
        % Output format: [doppler index, range index(start from index 1), ...
        % cell power]
        detout = peakGrouping(Resl_indx);

        % Angle estimation for each peak in detout
        [Resel_agl, vel_ambg_list, rng_excd_list] = angle_estim_dets(detout, Velocity_FFT, ...
        fft_Vel, fft_Ang, Rx, Tx, num_crop);

        % Transform bin index to range/velocity/angle
        Resel_agl_deg = agl_grid(1, Resel_agl)';
        Resel_vel = vel_grid(detout(1,:), 1);
        Resel_rng = rng_grid(detout(2,:), 1);

        % Velocity disambiguation
        if IS_vel_disambg
            [Resel_vel] = vel_disambg(Resel_vel, vel_ambg_list, vmax);
        end

        % save_det data format: [range bin, velocity bin, angle bin, power, 
        % range(m), velocity (m/s), angle(degree)]
        save_det_data = [detout(2,:)', detout(1,:)', Resel_agl', detout(3,:)', ...
            Resel_rng, Resel_vel, Resel_agl_deg];
        
        % filter out the points with range_bin within the crop region
        if ~isempty(rng_excd_list)
            save_det_data(rng_excd_list, :) = [];
        end
        
    else
       save_det_data = []; 
    end
    
    % update max_clus_len
    if size(save_det_data, 1) > max_det_len
        max_det_len = size(save_det_data, 1);
    end
    
    % Save the detections to local
    if IS_Save_dets
        save_file_name = strcat(save_dir, '/', num2str(i, '%04d'), ".txt");
        writematrix(single(save_det_data), save_file_name, 'Delimiter','tab');
    end
    
end

if IS_Disp_num
    disp(max_det_len)
end

end

