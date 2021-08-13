% ------------- BRIR interpolation algorithm ----------------- %

% This code is part of the semester project "Design of an Externalized Music Player" 
% EPFL - Ecole Polytechnique Fédérale de Lausanne
% Gloria Dal Santo - SCIPER: 320734

% This algorithm follows the steps described by V. Garcia-Gomez1 et. al. in
% the paper "Binaural room impulse responses interpolation for multimedia 
% real-time applications". Some of the steps have been adapted to the
% analysed scenarion.

% as for now the algorithm will be tested on the left channel only, for an
% interpolation at 30° (20° - 40°)

clear all; close all; clc
addpath ../data/BRIR/ListeningRoom2m ./functions
h = struct();                   % structure that stores h1, h2, h_int, and 
                                % all the intermediate vectors
deg = -180:10:170;
IR = load('IR_Az_20_KMRL.mat');
h.h1.ir = IR.IR';
IR = load('IR_Az_40_KMRL.mat');
h.h2.ir = IR.IR';
deg_1 = deg(21); deg_2 = deg(23);
deg_int = 30;                    % interpolation angle
alpha = (deg_int-deg_1)/(deg_2-deg_1);
fs = 44.1e3;                    % sampling frequency
N = size(IR,2);        % BRIR length in samples

%% Windowing of the BRIRs
% separation of the direct+ealry reflection from the late reverberation

L = 2205;       % transition time (0.05 s)
% direct and ealry reflections
h.h1.he.ir = h.h1.ir(1:L);
h.h2.he.ir = h.h2.ir(1:L);
% late reverberation 
ovlp = 100;     % overlapping samples for crossover 
h.h1.lr.ir = h.h1.ir(L-ovlp:end);
h.h2.lr.ir = h.h2.ir(L-ovlp:end);

%% Dual-band processing of the direct+early reflections
% to separate the frequency components a 3rd order Butterworth filter is
% applied twice, forward and backward (zero phase filter)

fc = 150;       % cutoff freqeucny Hz
% compute the filter coefficients 
[bL,aL] = butter(3,fc/(fs/2),'low' ); 
[bH,aH] = butter(3,fc/(fs/2),'high'); 
% zero-phase filtering 
h.h1.he.low = filtfilt(bL,aL,h.h1.he.ir);
h.h1.he.high = filtfilt(bH,aH,h.h1.he.ir);
h.h2.he.low = filtfilt(bL,aL,h.h2.he.ir);
h.h2.he.high = filtfilt(bH,aH,h.h2.he.ir);

clear bL aL bH aH

% find peaks peaks
min_distance = 100;
[pks, n_pks] = find_peaks(h.h1.he.high, h.h2.he.high, min_distance);

% gravity point
for i = 1:n_pks 
    % location of the gravity point
    pks.h1.grav(i) = floor((1-alpha)*pks.h1.loc(i) + alpha*pks.h2.loc(i));
    pks.h2.grav(i) = pks.h1.grav(i);
    % number of samples from peak to gravity point
    pks.h1.dmax(i) = abs(pks.h1.grav(i)-pks.h1.loc(i));
    pks.h2.dmax(i) = abs(pks.h2.grav(i)-pks.h2.loc(i));    
end

% plot
figure('Renderer', 'painters', 'Position', [10 10 900 600]);
subplot(2,1,1);
plot(h.h1.he.high); hold on; plot(pks.h1.loc, pks.h1.amp, 'o'); xline(pks.h1.grav(1)); xline(pks.h1.grav(2));
xlim([350, 800]); ylim([-0.25, 0.25])
title('Direct + early reflection at $20^o$','interpreter','latex','FontSize',14)
legend('$h_e^1$','peaks','gravity points','interpreter','latex','FontSize',12);
xlabel('Samples','interpreter','latex','FontSize',14);
ylabel('Amplitude','interpreter','latex','FontSize',14)
subplot(2,1,2);
plot(h.h2.he.high); hold on; plot(pks.h2.loc, pks.h2.amp, 'o'); xline(pks.h2.grav(1)); xline(pks.h2.grav(2));
xlim([350, 800]); ylim([-0.25, 0.25])
title('Direct + early reflection at $40^o$','interpreter','latex','FontSize',14)
legend('$h_e^2$','peaks','gravity points','interpreter','latex','FontSize',12);
xlabel('Samples','interpreter','latex','FontSize',14);
ylabel('Amplitude','interpreter','latex','FontSize',14)

% warping

% creation of separated block where to perform warping
blck = 49;  % (block size)/2 -1
for i = 1 : n_pks
    if pks.h1.loc(i)-blck <= 0
        pks.h1.warp.(['warp_' num2str(i)]) = h.h1.he.high(1:pks.h1.loc(i)+blck); 
        pks.h1.wapr_loc(i) = pks.h1.loc(i);
        pks.h1.warp.(['index_warp_' num2str(i)]) = 1:pks.h1.loc(i)+blck;
    else 
        pks.h1.warp.(['warp_' num2str(i)]) = h.h1.he.high(pks.h1.loc(i)-blck:pks.h1.loc(i)+blck);
        pks.h1.wapr_loc(i) = 50;
        pks.h1.warp.(['index_warp_' num2str(i)]) = pks.h1.loc(i)-blck:pks.h1.loc(i)+blck;
    end
    if pks.h2.loc(i)-blck <= 0
        pks.h2.warp.(['warp_' num2str(i)]) = h.h2.he.high(1:pks.h2.loc(i)+blck);
        pks.h2.wapr_loc(i) = pks.h2.loc(i);
        pks.h2.warp.(['index_warp_' num2str(i)]) = 1:pks.h2.loc(i)+blck;
    else 
        pks.h2.warp.(['warp_' num2str(i)]) = h.h2.he.high(pks.h2.loc(i)-blck:pks.h2.loc(i)+blck);
        pks.h2.wapr_loc(i) = 50;
        pks.h2.warp.(['index_warp_' num2str(i)]) = pks.h2.loc(i)-blck:pks.h2.loc(i)+blck;
    end    
end

% move the blocks toward the gravity point and streach the part with lowest
% energy
for i = 1:n_pks
    % move peak in h1 to the right
    if pks.h1.grav(i) > pks.h1.loc(i)   
        [indx_1,~,~] = low_energy(pks.h1.warp.(['warp_' num2str(i)]),pks.h1.wapr_loc(i),1); 
        [indx_2,~,~] = low_energy(pks.h2.warp.(['warp_' num2str(i)]),pks.h2.wapr_loc(i),0); 
        % move peak in h1 to the right
        for j = 1:pks.h1.dmax(i)
            pks.h1.warp.(['warp_' num2str(i)]) = [pks.h1.warp.(['warp_' num2str(i)])(1:indx_1)...
                mean([ pks.h1.warp.(['warp_' num2str(i)])(indx_1) pks.h1.warp.(['warp_' num2str(i)])(indx_1+1)])...
                pks.h1.warp.(['warp_' num2str(i)])(indx_1+1:end-1)];
            indx_1 = indx_1+2;
        end
        % move peak in h2 to the left
        for j = 1:pks.h2.dmax(i)
            pks.h2.warp.(['warp_' num2str(i)]) = [pks.h2.warp.(['warp_' num2str(i)])(2:indx_2)...
                mean([ pks.h2.warp.(['warp_' num2str(i)])(indx_2) pks.h2.warp.(['warp_' num2str(i)])(indx_2+1)])...
                pks.h2.warp.(['warp_' num2str(i)])(indx_2+1:end)];
            indx_2 = indx_2+2;
        end
    % move peak in h1 to the left
    elseif pks.h1.grav(i) < pks.h1.loc(i)
        [indx_1,~,~] = low_energy(pks.h1.warp.(['warp_' num2str(i)]),pks.h1.wapr_loc(i),0); 
        [indx_2,~,~] = low_energy(pks.h2.warp.(['warp_' num2str(i)]),pks.h2.wapr_loc(i),1); 
        % move peak in h1 to the right
        for j = 1:pks.h1.dmax(i)
            pks.h1.warp.(['warp_' num2str(i)]) = [pks.h1.warp.(['warp_' num2str(i)])(2:indx_1)...
                mean([ pks.h1.warp.(['warp_' num2str(i)])(indx_1) pks.h1.warp.(['warp_' num2str(i)])(indx_1+1)])...
                pks.h1.warp.(['warp_' num2str(i)])(indx_1+1:end)];
            indx_1 = indx_1+2;
        end
        % move peak in h2 to the left
        for j = 1:pks.h2.dmax(i)
            pks.h2.warp.(['warp_' num2str(i)]) = [pks.h2.warp.(['warp_' num2str(i)])(1:indx_2)...
                mean([ pks.h2.warp.(['warp_' num2str(i)])(indx_2) pks.h2.warp.(['warp_' num2str(i)])(indx_2+1)])...
                pks.h2.warp.(['warp_' num2str(i)])(indx_2+1:end-1)];
            indx_2 = indx_2+2;
        end
    end  
end
% substitute the warpped section in the original location
for i = 1 : n_pks
    h.h1.he.high(pks.h1.warp.(['index_warp_' num2str(i)])) = pks.h1.warp.(['warp_' num2str(i)]);
    h.h2.he.high(pks.h2.warp.(['index_warp_' num2str(i)])) = pks.h2.warp.(['warp_' num2str(i)]);   
end

% plots
figure('Renderer', 'painters', 'Position', [10 10 900 600]);
subplot(2,1,1);
plot(h.h1.he.high); hold on; plot(pks.h1.warp.(['index_warp_' num2str(1)]), pks.h1.warp.(['warp_' num2str(1)])); 
plot(pks.h1.warp.(['index_warp_' num2str(2)]), pks.h1.warp.(['warp_' num2str(2)])); xline(pks.h1.grav(1),'.'); xline(pks.h1.grav(2),'.');
xlim([350, 800]); ylim([-0.25, 0.25])
title('Direct + early reflection at $20^o$ - \textit{warped}','interpreter','latex','FontSize',14)
legend('$h_e^1$','$h_{e, w1}^1$','$h_{e, w2}^1$','gravity points','interpreter','latex','FontSize',12);
xlabel('Samples','interpreter','latex','FontSize',14);
ylabel('Amplitude','interpreter','latex','FontSize',14)
subplot(2,1,2);
plot(h.h2.he.high); hold on; plot(pks.h2.warp.(['index_warp_' num2str(1)]), pks.h2.warp.(['warp_' num2str(1)])); 
plot(pks.h2.warp.(['index_warp_' num2str(2)]), pks.h2.warp.(['warp_' num2str(2)])); xline(pks.h2.grav(1)); xline(pks.h2.grav(2));
xlim([350, 800]); ylim([-0.25, 0.25])
title('Direct + early reflection at $40^o$ - \textit{warped}','interpreter','latex','FontSize',14)
legend('$h_e^2$','$h_{e, w1}^2$','$h_{e, w2}^2$','gravity points','interpreter','latex','FontSize',12);
xlabel('Samples','interpreter','latex','FontSize',14);
ylabel('Amplitude','interpreter','latex','FontSize',14)
%% Final Mix

% linear interpolation of the low frequency components
h.h_int.he.low = h.h1.he.low + (h.h2.he.low - h.h1.he.low)/2;

% linear interpolation between warped high frequency components
h.h_int.he.high = h.h1.he.high + (h.h2.he.high - h.h1.he.high)/2;
h.h_int.he.he_int = h.h_int.he.low + h.h_int.he.high;

% linear interpolation of the late reverberations
h.h_int.hr = (1-alpha)*h.h1.lr.ir+alpha*h.h2.lr.ir;

% crossover weights
w = sqrt(((1:ovlp)-1)/(ovlp-1));

% final result 
h.h_int.ir = [h.h_int.he.he_int(1:L-ovlp) ...
    (h.h_int.he.he_int(L-ovlp+1:end).*(1-w) + w.*h.h_int.hr(1:ovlp))...
    h.h_int.hr(ovlp:end)];


% plots
IR = load('IR_Az_30_KMRL.mat')
BRIR_30L = IR.IR';
figure('Renderer', 'painters', 'Position', [10 10 900 300])
plot(BRIR_30L); hold on; plot(h.h_int.ir)
ylim([-0.2,0.2]), xlim([350, 800])
legend('$h_{30^o}$','$\hat{h}_{30^o}$','interpreter','latex','FontSize',12)
xlabel('Samples','interpreter','latex','FontSize',14);
ylabel('Amplitude','interpreter','latex','FontSize',14)