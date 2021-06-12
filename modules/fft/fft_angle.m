function [AngData] = fft_angle(Xcube,fft_Ang,Is_Windowed)

Nr=size(Xcube,1);   %%%length of Chirp
Ne=size(Xcube,2);   %%%length of receiver
Nd=size(Xcube,3);   %%%length of chirp loop

% win = taylorwin(Ne,5,-60);
% win = win/norm(win);
for i = 1:Nd
    for j = 1:Nr
        if Is_Windowed
            win_xcube = reshape(Xcube(j,:,i),Ne,1).*taylorwin(Ne);
        else
            win_xcube = reshape(Xcube(j,:,i),Ne,1).*1;
        end
        AngData(j,:,i) = fftshift(fft(win_xcube,fft_Ang));
    end
end
end