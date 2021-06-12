%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFAR detector on Range-Velocity to detect targets 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Resl_indx] = cfar_RV(Dopdata_sum, fft_Rang, num_crop, Pfa)

x_dop = []; % temp storage
Resl_indx = []; % store CFAR detections

for rani = num_crop+1:fft_Rang-num_crop
    % from range num_crop+1(because the DC components in range index 
    % < num_crop have been canceled)
    x_detected = cfar_ca1D_square(Dopdata_sum(rani,:), 4, 7, Pfa, 0, 0.7);
    x_dop = [x_dop, x_detected];
end

% make unique
[C,~,~] = unique(x_dop(1,:));

% CFAR for each specific doppler bin
for dopi = 1:size(C,2)
    y_detected = cfar_ca1D_square(Dopdata_sum(:, C(1,dopi)), ...
        4, 8, Pfa, 0, 0.7);
    if isempty(y_detected) == 1
        continue
    end
    for yi = 1:size(y_detected, 2)
        % saving format: 1st doppler index, 2st range index ...
        % (start from index 1), 3rd cell power
        Resl_indx = [Resl_indx, [C(1,dopi); y_detected(1, yi); ...
            y_detected(2, yi)]];
    end
end

end