function [pks, n_pks] = find_peaks(he1, he2, min_distance)
    % ---------------------------------------------------- %
    % [pks, n_pks] = find_peaks(he1, he2, min_distance)
    % This fucntion is part of the semester project "Design of an 
    % Externalized Music Player" at EPFL
    % find the highest peaks in "he1" and "he2" that are separated by at least "min_distance"
    % ---------------------------------------------------- %
    %   he1:    early reflection of the first impulse response
    %   he2:    early reflection of the second impulse response
    %   min_distance:   minimum distance between the peaks 
    %   pks:    structure containing the amplitude and location of the peaks
    %   n_pks:  number of peaks in each impulse response
    % ---------------------------------------------------- %
    pks = struct();
    n_pks = 10;
    
    % 1. find n_pks peaks
    [pks_1,locs_1] = findpeaks(he1,'Npeaks',n_pks,'MinPeakDistance',min_distance);
    [pks_2,locs_2] = findpeaks(he2,'Npeaks',n_pks,'MinPeakDistance',min_distance);
    % sort them in descending order
    [pks_1,locs_1_s] = sort(pks_1,'descend');
    [pks_2,locs_2_s] = sort(pks_2,'descend');
    locs_1 = locs_1(locs_1_s);
    locs_2 = locs_2(locs_2_s);

    % 2. peaks selection
    % C: distance matrix for peaks matching
    DeltaP = abs(repmat(pks_1,10,1)-repmat(pks_2',1,10));   % amplitude difference
    DeltaP/max(DeltaP,[],'all');                            % normalization
    DeltaS = abs(repmat(locs_1,10,1)-repmat(locs_2',1,10)); % time difference
    DeltaS/max(DeltaS,[],'all');                            % normalization
    C = 1./(1+DeltaS)./(1+DeltaP);                          % d istance matrix 
    % find the peaks that are most likely to be related
    [~, max_loc] = max(C,[],1);                 

    n_pks = 2; % smaller number of peaks (relevant peaks)
    % 3. save the location and amplitude of the most relevant peaks
    pks.h1.amp = pks_1(1:n_pks);
    pks.h2.amp = pks_2(max_loc(1:n_pks));
    pks.h1.loc = locs_1(1:n_pks);
    pks.h2.loc = locs_2(max_loc(1:n_pks));
end