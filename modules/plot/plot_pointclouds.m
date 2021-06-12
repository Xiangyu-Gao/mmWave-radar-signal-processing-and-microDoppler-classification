% plot 3D point clouds
function [axh] = plot_pointclouds(detout)
% detout format: % [range bin, velocity bin, angle bin, power, range(m), ...
% velocity (m/s), angle(degree)]

figure('visible','on')
% x-direction: Doppler, y-direction: angle, z-direction: range
[axh] = scatter3(detout(:, 6), detout(:, 7), detout(:, 5), 'filled');
xlabel('Doppler velocity (m/s)')
ylabel('Azimuth angle (degrees)')
zlabel('Range (m)')
axis([-5, 5 -60 60 2 25]);
title('3D point clouds')
grid on

end