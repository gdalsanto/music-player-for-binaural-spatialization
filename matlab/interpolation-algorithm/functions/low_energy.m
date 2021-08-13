function [indx, mu, sgm] = low_energy(ir, pk_loc, dir)
% ---------------------------------------------------- %
% [indx, mu, sgm] = low_energy(ir, pk_loc, dir)
% This fucntion is part of the semester project "Design of an Externalized 
% Music Player" at EPFL
% find the block with lowest energy in the impulse response
% ---------------------------------------------------- %
%   ir:         impulse response
%   pk_loc:    	location of the peak
%   dir:        direction wrt to the peak where the streatching will be
%               applied {0, 1} = {R, L}
%   indx:       starting sample of the block with lowest enery
%   mu, sgm:    mean and standard deviation of the block values
% ---------------------------------------------------- %
    blck = 5;       % number of samples of which the energy will be computed
    n_smp = 48;     % length of the block
    engr = inf;     % lowest energy
    for i = 0 : ceil(n_smp/blck)
        if dir == 0 
            blck_indx = pk_loc+i*blck:pk_loc+(i+1)*blck;
            if blck_indx(end) >= length(ir)
                continue
            end
            temp = sum(abs(ir(blck_indx).^2));
            if temp < engr
                engr = temp;    % update
                indx = pk_loc + (-1)^dir*i*blck;      
                mu = mean(ir(blck_indx));
                sgm = std(ir(blck_indx));
            end
        else 
            if pk_loc-(ceil(n_smp/blck)-i)*blck <= 0 
                continue
            end
            blck_indx = pk_loc-(ceil(n_smp/blck)-i)*blck:pk_loc-(ceil(n_smp/blck)-i-1)*blck;
            if blck_indx(end) > pk_loc
                continue
            end
            temp = sum(abs(ir(blck_indx).^2));   
            if temp < engr
                engr = temp;
                indx = pk_loc-(ceil(n_smp/blck)-i)*blck;      
                mu = mean(ir(blck_indx));
                sgm = std(ir(blck_indx));
            end
        end
    end
end