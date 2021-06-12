clc;
clear;
close all;
load testdata_adc_data_20180624_1.mat; 
signal=Xcube(:,:,1);
%%
NumElements=4;
c = physconst('LightSpeed');
fc = 77e9;              % Operating frequency
lambda = c/fc;
ElementSpacing=lambda/2;

Nsamp = 256;
%%
%%
% Generate the multichannel signal received by the ULA.
%% Improving Resolution Using MVDR and MUSIC Estimators
NumSignals=1;
ScanAngles=[-90:90];


%% by WHJ 20180706 
[ymusic_my ang_my]= MUSIC(signal,NumSignals,NumElements,ScanAngles,1,ElementSpacing,fc,c)

figure(2)
PlotDOASpectra(ScanAngles,ymusic_my);
i=1;




function [scanpattern ang_estim]= MUSIC(X,NumSignals,NumElements,ang,L,elSp,freq,c)
%%% elsp: the interval between two antennas 
%%% NumElements: antenna number
%%% NumSignals: target number
%%% X: received signal
%%% L: subarray for spatial smoothing
%%% freq: center frequency
%%% c: speed
%%  From MUSICEstimator.m (privDOASpectrum function)
%% Compute eigenvectors of the covariance matrix
Nsig = NumSignals;   
NEle = NumElements;   
Cx=MLCovMtx(X,L);
% Cx=X.'*(X.')'/Nsig;
%% [eigenvals, eigenvects] = privEig(Cx);  
[eigenvects, eigenvalsC] = eig(Cx);
eigenvals = real(eigenvalsC);
[eigenvals,indx] = sort(diag(eigenvals),'descend');
eigenvects= eigenvects(:,indx);
eigenvals(eigenvals<0) = 0;
%% Form MUSIC denominator matrix from noise subspace eigenvectors
noise_eigenvects = eigenvects(:, Nsig + 1:end); 
%% position
EleIdx = 1:NEle;
delta = (NEle-1)/2+1;
numElIDX = numel(EleIdx);
pos  = [zeros(1,numElIDX);(EleIdx-delta)*elSp;zeros(1,numElIDX)];
%% tau returns the delay among sensor elements in a sensor array for a given direction specified in ANG. 
ang=[ang; zeros(1,length(ang))];
azang = ang(1,:);
elang = ang(2,:);
% angles defined in local coordinate system
incidentdir = [-cosd(elang).*cosd(azang);-cosd(elang).*sind(azang);-sind(elang)];
tau = pos.'*incidentdir/c;     

sv = exp(-1i*2*pi*freq*tau);    
D = sum(abs((sv'*noise_eigenvects)).^2,2)+eps(1); % 9.44 in Ref[1]
pPattern = 1./D; 
scanpattern = sqrt(pPattern);  
s = sign(diff(scanpattern));
iMax = 1+find(diff(s)<0);
[iPk iPk_pos]= sort(scanpattern(iMax),'descend');
iPk_pos=iMax(iPk_pos);
ang_estim=ang(1,iPk_pos(1:Nsig));
end

function Sx = MLCovMtx(X,L)
    % Maximum Likelihood
    K = size(X,1);
    M = size(X,2)-L+1;
    Sx = complex(zeros(M,M));
    for n=1:L
        % Forward-Only Spatial Smoothing
        subOut = X(:,n:n+M-1).';
        Sx =  Sx + 1/K*(subOut*subOut'); 
    end
    Sx = 1/L*Sx;
end
    
%% plot music
function PlotDOASpectra(x1,y1)
y1_dB = 20*log10(y1) - max(20*log10(y1));
plot(x1,y1_dB)
xlabel('Broadside Angle (degrees)');
ylabel('Power (dB)');
title('DOA Spatial Spectra')
legend('MUSIC');
grid on;

end





