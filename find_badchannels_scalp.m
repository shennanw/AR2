function [MI,badchannel_index,badchannels]=find_badchannels(eeg,input_matrix);
load(input_matrix);
%Truncate the recordings
 
%First Read in the Matrix of EEGs
channelinfo = matrixreader(input_matrix);
matrixsize = length(channelinfo.names);
%Find Channels
numberfoundchannels = 0;
channelindex = 0;
for i = 1:length(channelinfo.names)
    for j = 1:length(eeg.chanlist)
        if strcmp(eeg.chanlist{j},channelinfo.names{i})
            numberfoundchannels = numberfoundchannels + 1;
            foundchannels{numberfoundchannels} = eeg.chanlist{j};
            channelindex(numberfoundchannels) = j;
            disp(['Channel ', channelinfo.names{i}, ' was found.']);
        end
    end
end
%Put the matrix data into a temp file (copied from Shennen)
for i = 1:length(foundchannels)
    temp(i,:) = eeg.eeg_data(channelindex(i),:);
end
eeg.eeg_data=temp;
eeg.chanlist=channelinfo.names';
if eeg.samp_rate < 520
    eeg_ds = eeg.eeg_data;
else 
   if eeg.samp_rate<1020
       data=[];
       eeg_ds=[];
       for i=1:numel(eeg.eeg_data(:,1))
           data=downsample(eeg.eeg_data(i,:),2);
           eeg_ds=vertcat(eeg_ds, data);           
       end;
       eeg.samp_rate=eeg.samp_rate/2;
   else
    data=[];
    eeg_ds=[];
       for i=1:numel(eeg.eeg_data(:,1))
           data=downsample(eeg.eeg_data(i,:),4);
           eeg_ds=vertcat(eeg_ds, data);           
       end;
       eeg.samp_rate=eeg.samp_rate/4;
   end;
end;
eeg.eeg_data=[];
eeg.eeg_data=eeg_ds;
eeg = eeg_filter(eeg,16,70);
eeg_ds=[];
eeg_hg_amplitude=[];
i=sqrt(-1);
for j=1:numel(eeg.eeg_data(:,1))
  j  
  hg_hilbert=hilbert(eeg.eeg_data(j,:));
  hg_amplitude=abs(hg_hilbert);
  eeg_hg_amplitude=vertcat(eeg_hg_amplitude, hg_amplitude);
end;
eeg_hg_amplitude_mean=mean(eeg_hg_amplitude);
eeg_hg_amplitude_mean_ds=downsample(eeg_hg_amplitude_mean,5);
mean_amplitude_smoothed=smooth(eeg_hg_amplitude_mean_ds,50);
zmean_amplitude_smoothed=zscore(mean_amplitude_smoothed);
flagged=0;
start={''};
finish={''};
duration={''};
event_duration=0;
intervals=0;
for i=1:numel(zmean_amplitude_smoothed)
    if ((flagged==0) && (zmean_amplitude_smoothed(i) > 1))  
        intervals=intervals+1;
        start{intervals}=i;
        flagged=1;
    end;
    if ((flagged==1) && (zmean_amplitude_smoothed(i)>1)) end;
    if ((flagged==1) && (zmean_amplitude_smoothed(i)<1)) 
        finish{intervals}=i;
        duration{intervals}=i-start{intervals};
        flagged=0;
    end;
end;
duration=cell2mat(duration);
start=cell2mat(start);
finish=cell2mat(finish);
[A,B]=max(duration)
MI_test=eeg.eeg_data(:,(start(B)*5):(finish(B)*5));
if ~isempty(MI_test)
MI(:,:) = mutualinformation_norm_strehl_ghosh1(MI_test');
find_indexMI=MI(2:(numel(MI(:,1))),1);
[A,B]=max(find_indexMI)
B=B+1;
[A,B]=find(MI(B,:)<0.03);
badchannels=channelinfo.names(B)';
badchannel_index=B;
else 
MI=zeros(numel(eeg.eeg_data(:,1)),numel(eeg.eeg_data(:,1)));
badchannels=[];
badchannel_index=[];
end;