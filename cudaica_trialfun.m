function [trl, event] = cudaica_trialfun(cfg)
load('cudaica_trialfun_parameters.mat','slide');
trl = [];
shifter = slide.advance
totalwindows = floor(slide.lengthrecording/slide.advance);

for i = 1:totalwindows %(Should generate 1 less than the max number of windows
    event    = 0;
    trlbegin = (1+((i-1)*shifter));       
    trlend   = (slide.samp_rate +((i-1)*shifter));    % Advances 1 second and shifts one shifter size
    offset   = 0;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end

