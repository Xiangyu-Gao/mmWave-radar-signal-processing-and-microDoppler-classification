function [dets_cluster] = clustering(dets,N_vfft,veloc_bin_norm,dis_thrs,rng_grid,agl_grid)

dets_cluster = [];
dets_num = size(dets, 1);
flag = zeros(1, dets_num); % for clusterng
[~, I] = sort(dets(:,4), 'descend');

for idx = 1:dets_num
    % check the flag of current elemnt, if 1, skip comparing
    if flag(I(idx))
        continue
    end
    range_bin = dets(I(idx), 1);
    veloc_bin = dets(I(idx), 2);
    angle_bin = dets(I(idx), 3);
    cur_det = dets(I(idx),:);
    n_incluster = 1;
    % check if the near point is within certain distance threshold of
    % current element
    for idx_nxt = idx+1:dets_num
        if flag(I(idx_nxt))
            continue
        end
        
        range_bin_diff = dets(I(idx_nxt), 1) - range_bin;
        veloc_bin_diff = dets(I(idx_nxt), 2) - veloc_bin;
        angle_bin_diff = dets(I(idx_nxt), 3) - angle_bin;
	
        % wrap veloc_bin_diff around half Velocity FFT poiints
        if abs(veloc_bin_diff) > N_vfft/2
            veloc_bin_diff = N_vfft - abs(veloc_bin_diff);
        end
        
        if abs(range_bin_diff)<=dis_thrs(1) && abs(veloc_bin_diff/veloc_bin_norm)<=dis_thrs(2) ...
                && abs(angle_bin_diff)<=dis_thrs(3)
            flag(I(idx_nxt)) = 1;
            % update the location (range+angle) of center point
            cur_det(1) = cur_det(1) + dets(I(idx_nxt), 1);
            cur_det(3) = cur_det(3) + dets(I(idx_nxt), 3);
            n_incluster = n_incluster + 1;
        end
    end
    
    % update the flag of current element, and add it to the det_clustering
    flag(I(idx)) = 1;
    cur_det(1) = round(cur_det(1)/n_incluster);
    cur_det(3) = round(cur_det(3)/n_incluster);
    cur_det(5) = rng_grid(cur_det(1));
    cur_det(7) = agl_grid(cur_det(3));
    
    dets_cluster = [dets_cluster; cur_det]; 
    
end
