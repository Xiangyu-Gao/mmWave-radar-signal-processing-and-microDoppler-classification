function freq_grid = fftshiftfreqgrid(N,Fs)
%fftshiftfreqgrid Generate frequency grid

freq_res = Fs/N;
freq_grid = (0:N-1).'*freq_res;
Nyq = Fs/2;
half_res = freq_res/2;
if rem(N,2) % odd
    idx = 1:(N-1)/2;
    halfpts = (N+1)/2;
    freq_grid(halfpts) = Nyq-half_res;
    freq_grid(halfpts+1) = Nyq+half_res;
else
    idx = 1:N/2;
    hafpts = N/2+1;
    freq_grid(hafpts) = Nyq;
end

freq_grid = fftshift(freq_grid);
freq_grid(idx) = freq_grid(idx)-Fs;

end
