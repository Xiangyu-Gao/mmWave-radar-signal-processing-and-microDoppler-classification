function [DopData]=fft_doppler(Xcube,fft_Vel,Is_Windowed)
%%%%  Xcube : Nr*Ne*Nd , original data
%%%   fft_Rang: range fft length
%%%   fft_Vel:  velocity fft length(2D-FFT)
%%%   fft_Ang:  angle fft length(3D FFT)

Nr=size(Xcube,1);   %%% length of Chirp
Ne=size(Xcube,2);   %%% # of receiver
Nd=size(Xcube,3);   %%% # of chirp loop

%% Second fft on dopper dimension
for i=1:Ne
    for j=1:Nr
       if Is_Windowed
           win_dop =reshape(Xcube(j,i,:),Nd,1).* hanning(Nd);
       else
           win_dop =reshape(Xcube(j,i,:),Nd,1);
       end
           
       DopData(j,i,:)=fftshift(fft(win_dop,fft_Vel));
     end
end
end

