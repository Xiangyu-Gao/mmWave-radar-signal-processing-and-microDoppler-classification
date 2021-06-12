function [objOut] = peakGrouping(detMat)

numDetectedObjects = size(detMat,2);
objOut = [];

% sort the detMat matrix according to the cell power
[~, order] = sort(detMat(3,:), 'descend');
detMat = detMat(:,order);

for ni = 1:numDetectedObjects
    detectedObjFlag = 1;
    rangeIdx = detMat(2,ni);
    dopplerIdx = detMat(1,ni);
    peakVal = detMat(3,ni);
    kernal = zeros(3,3);
    
    %% fill the middle column of the  kernel
    kernal(2,2) = peakVal;
    
    need_index = find(detMat(1,:) == dopplerIdx & detMat(2,:) == rangeIdx+1);
    if ~isempty(need_index)
        kernal(1,2) = detMat(3,need_index(1));
    end
    
    need_index = find(detMat(1,:) == dopplerIdx & detMat(2,:) == rangeIdx-1);
    if ~isempty(need_index)
        kernal(3,2) = detMat(3,need_index(1));
    end

    % fill the left column of the kernal
    need_index = find(detMat(1,:) == dopplerIdx-1 & detMat(2,:) == rangeIdx+1);
    if ~isempty(need_index)
        kernal(1,1) = detMat(3,need_index(1));
    end
    
    need_index = find(detMat(1,:) == dopplerIdx-1 & detMat(2,:) == rangeIdx);
    if ~isempty(need_index)
        kernal(2,1) = detMat(3,need_index(1));
    end
    
    need_index = find(detMat(1,:) == dopplerIdx-1 & detMat(2,:) == rangeIdx-1);
    if ~isempty(need_index)
        kernal(3,1) = detMat(3,need_index(1));
    end
    
    % Fill the right column of the kernel
    need_index = find(detMat(1,:) == dopplerIdx+1 & detMat(2,:) == rangeIdx+1);
    if ~isempty(need_index)
        kernal(1,3) = detMat(3,need_index(1));
    end
    
    need_index = find(detMat(1,:) == dopplerIdx+1 & detMat(2,:) == rangeIdx);
    if ~isempty(need_index)
        kernal(2,3) = detMat(3,need_index(1));
    end
    
    need_index = find(detMat(1,:) == dopplerIdx+1 & detMat(2,:) == rangeIdx-1);
    if ~isempty(need_index)
        kernal(3,3) = detMat(3,need_index(1));
    end
    
    % Compare the detected object to its neighbors.Detected object is
    % at index [2,2]
    if kernal(2,2) ~= max(max(kernal))
        detectedObjFlag = 0;
    end
    
    if detectedObjFlag == 1
        objOut = [objOut, detMat(:,ni)];
    end
end
end