% ------------- Eraly Reflection + Reverb ----------------- %

% This code is part of the semester project "Design of an Externalized
% Music Player"
% EPFL - Ecole Polytechnique Fédérale de Lausanne
% Gloria Dal Santo - SCIPER: 320734

% Extract the ealry reflection and late reverberation from the BRIR 
% The direct reflection contained in the HRTF should complete the early
% reflection + late reverberation without overlapping
% Only one stereo BRIR/HRTF is processed (symmetry around 0 azimuth).

clear all; close all; clc
addpath '../data/HRTF/elev0'
addpath '../data/BRIR/ListeningRoom2m'

if not(isfolder('./output'))
    mkdir('./output')
end

% load data
load('ir_m2_L_NOD.mat');
load('ir_m2_R_NOD.mat');
[HRTF, fs] = audioread("H0e030a.wav");

deg =-180:10:170;
index_0 = 19; index30 = 22; index_30 = 19;

% store BRIR at 30°, -30°, 0°
BRIR30L = ir_m2_L_NOD(index30,:);
BRIR30R = ir_m2_R_NOD(index30,:);
BRIR_30L = ir_m2_L_NOD(index_30,:);
BRIR_30R = ir_m2_R_NOD(index_30,:);
BRIR_0L = ir_m2_L_NOD(index_0,:);
BRIR_0R = ir_m2_R_NOD(index_0,:);

plot(HRTF(:,1)); % left channel
hold on
plot(HRTF(:,2)) % right channel 
plot(BRIR_30L);
plot(BRIR_30R);
legend('HRTF - L','HRTF - R','BRIR - L','BRIR - R','interpreter','latex','FontSize',12);
title('Impulse responses at $30^o$','interpreter','latex','FontSize',14)
xlim([0, 500])

%% BRIR 30 deg 
% plot only left channel
figure
subplot(2,1,1);plot(HRTF(:,1));
hold on
BRIR_30L(1:size(HRTF,1)) = 0;
plot(BRIR_30L);
legend('HRTF','BRIR','interpreter','latex','FontSize',12)
title('Impulse responses at $30^o$ - Left','interpreter','latex','FontSize',14)
xlabel('Samples','interpreter','latex','FontSize',14)
ylabel('Amplitude','interpreter','latex','FontSize',14)
xlim([0, 500]); ylim([-0.5 0.5])


% plot only left channel
subplot(2,1,2); plot(HRTF(:,2))
hold on
BRIR_30R(1:size(HRTF,1)) = 0;
plot(BRIR_30R);
legend('HRTF','BRIR','interpreter','latex','FontSize',12)
title('Impulse responses at $30^o$ - Right','interpreter','latex','FontSize',14)
xlabel('Samples','interpreter','latex','FontSize',14)
ylabel('Amplitude','interpreter','latex','FontSize',14)

xlim([0, 500]); ylim([-0.5 0.5])

BRIR30L(1:size(HRTF,1)) = 0;
BRIR30R(1:size(HRTF,1)) = 0;

audiowrite('./output/Rev30L.wav',BRIR30L,fs);
audiowrite('./output/Rev30R.wav',BRIR30R,fs);
audiowrite('./output/Rev_30L.wav',BRIR_30R,fs);
audiowrite('./output/Rev_30R.wav',BRIR_30L,fs);

%% BRIR 0 deg
% plot only left channel
figure
plot(HRTF(:,1));
hold on
BRIR_0L(1:size(HRTF,1)) = 0;
plot(BRIR_0L);
legend('HRTF - L','BRIR - L','interpreter','latex','FontSize',12)
title('HRTF $30^o$ | BRIR $0^o$ - Left','interpreter','latex','FontSize',14)
xlim([0, 500])

% plot only right channel
figure
plot(HRTF(:,2));
hold on
BRIR_0R(1:size(HRTF,1)) = 0;
plot(BRIR_0R);
legend('HRTF - L','BRIR - L','interpreter','latex','FontSize',12)
title('HRTF $30^o$ | BRIR $0^o$ - Right','interpreter','latex','FontSize',14)
xlim([0, 500])
audiowrite('./output/Rev0L.wav',BRIR_0L,fs);
audiowrite('./output/Rev0R.wav',BRIR_0R,fs);

%% ENERGY 
% Direct to Reverberation Ratio
% computes the coefficents alpha that guarantees DRR = 7 

DRR = 7;
[HRTF_0, fs] = audioread("H0e000a.wav");
BRIR_0L = load('IR_Az_0_KMRL.mat');
BRIR_0R = load('IR_Az_0_KMRR.mat');

% compute the energy of the impulse responses
E_HRTF_0L = HRTF_0(:,1)'*HRTF_0(:,1);   % left channel
E_HRTF_0R = HRTF_0(:,2)'*HRTF_0(:,2);   % right channel
E_R_0L = BRIR_0L.IR'*BRIR_0L.IR;
E_R_0R = BRIR_0R.IR'*BRIR_0R.IR;
E_HRTF_L = HRTF(:,1)'*HRTF(:,1);
E_HRTF_R = HRTF(:,2)'*HRTF(:,2);
E_R_30L = BRIR_30L*BRIR_30L';
E_R_30R = BRIR_30R*BRIR_30R';

alpha_0L = sqrt(E_HRTF_0L)/sqrt(E_R_0L)/(10^(DRR/20));
alpha_0R = sqrt(E_HRTF_0R)/sqrt(E_R_0R)/(10^(DRR/20));

alpha_30L = sqrt(E_HRTF_L)/sqrt(E_R_30L)/(10^(DRR/20)); % to be applied on -30deg R
alpha_30R = sqrt(E_HRTF_R)/sqrt(E_R_30R)/(10^(DRR/20)); % to be appplied on -30deg L
    
alpha_0L = sqrt(E_HRTF_L)/sqrt(E_R_0L)/(10^(DRR/20)); % to be applied on -30deg R
alpha_0R = sqrt(E_HRTF_R)/sqrt(E_R_0R)/(10^(DRR/20)); % to be appplied on -30deg L

% DDR_30L = 10*log10(E_HRTF_L/alpha_30L^2/E_R_30L);
% DDR_30R = 10*log10(E_HRTF_R/alpha_30R^2/E_R_30R);