% This script is used for processing the raw data collectd by TI awr1843
% radar
% Author : Xiangyu Gao (xygao@uw.edu), University of Washingyton
% Input: raw I-Q radar data
% Output: micro-Doppler image for cropped region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clearvars
close all

% parameter setting
params = get_params_value();
% constant parameters
c = params.c; % Speed of light in air (m/s)
fc = params.fc; % Center frequency (Hz)
lambda = params.lambda;
Rx = params.Rx;
Tx = params.Tx;

% configuration parameters
Fs = params.Fs;
sweepSlope = params.sweepSlope;
samples = params.samples;
loop = params.loop;

Tc = params.Tc; % us 
fft_Rang = params.fft_Rang;
fft_Vel = params.fft_Vel;
fft_Ang = params.fft_Ang;
num_crop = params.num_crop;
max_value = params.max_value; % normalization the maximum of data WITH 1843

% Creat grid table
rng_grid = params.rng_grid;
agl_grid = params.agl_grid;
vel_grid = params.vel_grid;

% Algorithm parameters
data_each_frame = samples*loop*Tx;
set_frame_number = 30;
frame_start = 1;
frame_end = set_frame_number;
Is_Windowed = 1;% 1==> Windowing before doing range and angle fft
M = 16; % number of frames for generating micro-Doppler image
Lr = 11; % length of cropped region along range
La = 5; % length of cropped region along angle
Ang_seq = [2,5,8,11,14]; % dialated angle bin index for cropping
veloc_bin_norm = 2; % velocity normaliztion term for DBSCAN
dis_thrs = [20, 16, 20]; % range_thrs, veloc_thrs, angle_thrs for DBSCAN
WINDOW =  255; % STFT parameters
NOVEPLAP = 240; % STFT parameters

% specify data name and load data as variable data_frames
seq_name = 'pms1000_30fs.mat';
seq_dir = strcat('.\template data\', seq_name);
load(seq_dir); % load data as variable data_frames

%% generating Range-angle image, and crop radar cube from it
radarcube_crop = [];
for i = frame_start:frame_start+M-1
    % read the data of each frame, and then arrange for each chirps
    data_frame = data_frames(:, (i-1)*data_each_frame+1:i*data_each_frame);
    data_chirp = [];
    for cj = 1:Tx*loop
        temp_data = data_frame(:, (cj-1)*samples+1:cj*samples);
        data_chirp(:,:,cj) = temp_data;
    end
    
    % separate the odd-index chirps and even-index chirps for TDM-MIMO with 2 TXs
    chirp_odd = data_chirp(:,:,1:2:end);
    chirp_even = data_chirp(:,:,2:2:end);
    
    % permutation with the format [samples, Rx, chirp]
    chirp_odd = permute(chirp_odd, [2,1,3]);
    chirp_even = permute(chirp_even, [2,1,3]);

    % Range FFT for odd chirps
    [Rangedata_odd] = fft_range(chirp_odd,fft_Rang,Is_Windowed);

    % Range FFT for even chirps
    [Rangedata_even] = fft_range(chirp_even,fft_Rang,Is_Windowed);

    % Doppler FFT
    Dopplerdata_odd = fft_doppler(Rangedata_odd, fft_Vel, 0);
    Dopplerdata_even = fft_doppler(Rangedata_even, fft_Vel, 0);
    Dopdata_sum = squeeze(mean(abs(Dopplerdata_odd), 2));
    
    % CFAR detector on Range-Velocity to detect targets 
    % Output format: [doppler index, range index(start from index 1), ...
    % cell power]
    Pfa = 1e-4; % probability of false alarm
    [Resl_indx] = cfar_RV(Dopdata_sum, fft_Rang, num_crop, Pfa);
    detout = peakGrouping(Resl_indx);
    
    % doppler compensation on Rangedata_even using the max-intensity peak
    % on each range bin
    for ri = num_crop+1:fft_Rang-num_crop
        find_idx = find(detout(2, :) == ri);
        if isempty(find_idx)
            continue
        else
            % pick the first larger velocity
            pick_idx = find_idx(1);
            % phase compensation for virtual elements
            pha_comp_term = exp(-1i * pi * (detout(1,pick_idx)-fft_Vel/2-1) / fft_Vel);
            Rangedata_even(ri, :, :) = Rangedata_even(ri, :, :) * pha_comp_term;
        end
    end
    
    Rangedata_merge = [Rangedata_odd, Rangedata_even];
    
    % Angle FFT
    Angdata = fft_angle(Rangedata_merge,fft_Ang,Is_Windowed);
    Angdata_crop = Angdata(num_crop + 1:fft_Rang - num_crop, :, :);
    [Angdata_crop] = Normalize(Angdata_crop, max_value);
    
    % for the first frame, determine the center location of croped region
    if i == frame_start
        % Angle estimation for detected point clouds
        Dopplerdata_merge = permute([Dopplerdata_odd, Dopplerdata_even], [2, 1, 3]);
        [Resel_agl, ~, rng_excd_list] = angle_estim_dets(detout, Dopplerdata_merge, fft_Vel, ...
            fft_Ang, Rx, Tx, num_crop);

        % Transform bin index to range/velocity/angle
        Resel_agl_deg = agl_grid(1, Resel_agl)';
        Resel_vel = vel_grid(detout(1,:), 1);
        Resel_rng = rng_grid(detout(2,:), 1);

        % save_det data format below
        % [range bin, velocity bin, angle bin, power, range(m), velocity (m/s), angle(degree)]
        save_det_data = [detout(2,:)', detout(1,:)', Resel_agl', detout(3,:)', ...
            Resel_rng, Resel_vel, Resel_agl_deg];

        % filter out the points with range_bin within the crop region
        if ~isempty(rng_excd_list)
            save_det_data(rng_excd_list, :) = [];
        end
        
        % DBSCAN clustering
        if ~isempty(rng_excd_list)
            dets_cluster = clustering(save_det_data, fft_Vel, veloc_bin_norm, ...
                dis_thrs, rng_grid, agl_grid);
        end
        
        % determine the center for cropping region
        center_r = dets_cluster(1, 1); % range center for cropped region
        center_a = dets_cluster(1, 3); % angle center for cropped region
    end
    
    radarcube_crop = cat(3, radarcube_crop, Angdata_crop(center_r-(Lr-1)/2:center_r+(Lr-1)/2, ...
        center_a-(max(Ang_seq)/2+1)+Ang_seq, :));
end

%% STFT processing for generating microDoppler map
data_conca = [];
STFT_data = [];

% reshae data to the formta [rangebin*anglebin, frames]
for j = 1:Lr
    for i = 1:La
        data_conca = [data_conca; squeeze(radarcube_crop(j,i,:))'];
    end
end

% STFT operation
for h = 1:Lr*La
    [S,F,T] = spectrogram(data_conca(h,:), WINDOW, NOVEPLAP, 256, 1/Tc,'centered');
    v_grid_new = F*lambda/2;
    STFT_data = cat(3, STFT_data, S);
end

% plot figure
figure('visible','on')
axh = mesh(T-T(1), v_grid_new, abs(STFT_data(:,:,(1+Lr*La)/2)));
view(0,90)
axis([0, 0.45, -8, 8])
xlabel('time (s)')
ylabel('velocity (m/s)')
title('micro-Doppler map')
colorbar
