function params = get_params_value()
% constant parameters
params.c = physconst('LightSpeed');% Speed of light in air (m/s)
params.fc = 77e9; % Center frequency (Hz)
params.lambda = params.c/params.fc;
params.Rx = 4;
params.Tx = 2;

% configuration parameters
params.Fs = 4*10^6;
params.sweepSlope = 21.0017e12;
params.samples = 128;
params.loop = 255;

params.Tc = 120e-6; % us
params.fft_Rang = 134; % 134=>128
params.fft_Vel = 256;
params.fft_Ang = 128;
params.num_crop = 3;
params.max_value = 1e+04; % data WITH 1843

% Creat grid table
freq_res = params.Fs/params.fft_Rang; % range_grid
freq_grid = (0:params.fft_Rang-1).'*freq_res;
params.rng_grid = freq_grid*params.c/params.sweepSlope/2; % d=frediff_grid*c/sweepSlope/2;

w = linspace(-1,1,params.fft_Ang); % angle_grid
params.agl_grid = asin(w)*180/pi; % [-1,1]->[-pi/2,pi/2]

% velocity_grid
dop_grid = fftshiftfreqgrid(params.fft_Vel,1/params.Tc); % now fs is equal to 1/Tc
params.vel_grid = dop_grid*params.lambda/2;   % unit: m/s, v = lamda/4*[-fs,fs], dopgrid = [-fs/2,fs/2]

end