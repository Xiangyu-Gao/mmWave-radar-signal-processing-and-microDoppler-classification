function [Angdata] = Normalize(Xcube, max_val)
% max_val = 5e+03; % unwindowed max value ###data with 1642 before July
% max_val = 3e+04; % unwindowed max value ###data with 1843 after July
Xcube = Xcube./max_val;
Angdata = single(Xcube);
end