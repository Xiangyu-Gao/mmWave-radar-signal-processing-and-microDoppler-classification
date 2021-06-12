%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Angle estimation for each peak in detout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Resel_agl, vel_ambg_list, rng_excd_list] = angle_estim_dets(detout, ...
    Velocity_FFT, fft_Vel, fft_Ang, Rx, Tx, num_crop)

Resel_agl = [];
vel_ambg_list = [];
rng_excd_list = [];
fft_Rang = size(Velocity_FFT, 2);

for ai = 1:size(detout, 2)
    rx_vect = squeeze(Velocity_FFT(:, detout(2,ai), detout(1,ai)));

    % Phase Compensation on the range-velocity bin for virtual elements
    pha_comp_term = exp(-1i * (pi * (detout(1,ai) - fft_Vel/2 - 1) / fft_Vel));
    rx_vect(Rx+1:Rx*Tx) = rx_vect(Rx+1:Rx*Tx) * pha_comp_term;

    % Estimate Angle on set1
    Angle_FFT1 = fftshift(fft(rx_vect, fft_Ang));
    [MM,II] = max(abs(Angle_FFT1));
    Resel_agl = [Resel_agl, II];

    % Velocity disambiguation on set2 -- flip the sign of the symbols 
    % corresponding to Tx2
    rx_vect(Rx+1:Rx*Tx) = - rx_vect(Rx+1:Rx*Tx);
    Angle_FFT1_flip = fftshift(fft(rx_vect, fft_Ang));
    [MM_flip,II_flip] = max(abs(Angle_FFT1_flip));

    if MM_flip > 1.2 * MM
        % now has velocity ambiguration, need to be corrected 
        vel_ambg_list = [vel_ambg_list, ai];
    end
    
    if detout(2,ai) <= num_crop || detout(2,ai) > fft_Rang - num_crop
        rng_excd_list = [rng_excd_list, ai];
    end
end

end