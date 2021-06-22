% plot range-angle heatmap
function [axh] = plot_rangeDop(Dopdata_sum,rng_grid,vel_grid)

% plot 2D(range-Doppler)
figure('visible','on')
set(gcf,'Position',[10,10,530,420])
[axh] = surf(vel_grid,rng_grid,Dopdata_sum);
view(0,90)
axis([-8 8 2 25]);
grid off
shading interp
xlabel('Doppler Velocity (m/s)')
ylabel('Range(meters)')
colorbar
caxis([0,3e04])
title('Range-Doppler heatmap')

end