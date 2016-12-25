% Main DSP Algorithm for live HFO detector
function [eeg] = cudaica_scalp_v4(eeg,input_matrix,outfile);
[header, signalHeader, signalCell] = blockEdfLoad(eeg)
eeg=[];
badchannels=[];
numchan=18;
if numel(signalCell) == 41
    fprintf('41 channel file');
    numchan=41;
    load('signalHeader_correctlabels_41.mat')
    for i=1:numchan
    signalHeader(i).signal_labels=signalHeader_correctlabels(i).signal_labels;   
    end;
    badchannels=[11:14 20 26];
else
    if numel(signalCell) == 43
    fprintf('43 channel file');
    numchan=43;
    load('signalHeader_correctlabels_43.mat')
    for i=1:numchan
    signalHeader(i).signal_labels=signalHeader_correctlabels(i).signal_labels;
    end;
    badchannels=[11:14 20 26];
    else
      if numel(signalCell) == 39
      fprintf('39 channel file');
      numchan=39;
      load('signalHeader_correctlabels_39.mat')
      for i=1:numchan
      signalHeader(i).signal_labels=signalHeader_correctlabels(i).signal_labels;
      end;
      badchannels=[11:14 25 27];
      else
      fprintf('non-standard file');
    end;
end;
end;
for i=1:18
    eeg.eeg_data(i,:)=signalCell{1,i};
    eeg.chanlist{i}=signalHeader(i).signal_labels
end;

eeg.eeg_data(badchannels,:)=[];
eeg.chanlist(badchannels)=[];
eeg.samp_rate=200;
echo off;
data=[];
Wo = 60/(eeg.samp_rate/2);  BW = Wo/35;
[b,a] = iirnotch(Wo,BW);
for i=1:18
noiseincluded=eeg.eeg_data(i,:);
noiseincluded = filter(b,a,noiseincluded);
data(i,:)=noiseincluded;
end;
pre_outfile=strcat('pre_',outfile);
%for i=1:numchan
%    signalHeader(i).signal_labels=signalHeader_correctlabels(i).signal_labels;
%end;
blockEdfWrite(pre_outfile, header,  signalHeader, signalCell)
data=[];
[MI,badchannel_index,badchannels]=find_badchannels_scalp(eeg,input_matrix); % Find MI of maximum artifact
if 21-numel(badchannel_index) < 8
    badchannel_index=[];
    badchannels=[];
end;
badchannel_eeg=[];
samplingrate=eeg.samp_rate;
fprintf('total length of EEG in minutes')
(((numel(eeg.eeg_data(1,:)))/samplingrate)/60) % Display total length of EEG.
load(input_matrix);
channelinfo = matrixreader(input_matrix); 
matrixsize = length(channelinfo.names);

% Match channels in the input_matrix with eeg.chanlist to rebuild the input data 
% structure.

numberfoundchannels = 0;
channelindex = 0;
for i = 1:length(channelinfo.names) % Search input_matrix channel 
    for j = 1:length(eeg.chanlist)
        if strcmp(eeg.chanlist{j},channelinfo.names{i})
            numberfoundchannels = numberfoundchannels + 1;
            foundchannels{numberfoundchannels} = eeg.chanlist{j};
            channelindex(numberfoundchannels) = j;
            disp(['Channel ', channelinfo.names{i}, ' was found.']);  % display found chan
        end
    end
end

for i = 1:length(foundchannels)
    eeg_data(i,:) = eeg.eeg_data(channelindex(i),:);
end

mean_tril=((sum(sum(tril(MI))))-numel(MI(1,:)))/((numel(MI)/2)-numel(MI(1,:))); % Remove bad channels if MI index indicates artifact
if mean_tril > 0.03 
  badchannel_eeg=eeg_data(badchannel_index,:);  
  eeg_data(badchannel_index,:)=[];    
  foundchannels(badchannel_index)=[];
  channelindex(badchannel_index)=[];
  for i=1:numel(badchannels)
      for j=1:numel(channelinfo.matrix(1,:))
          for k=1:numel(channelinfo.matrix(:,1))              
              if strcmp(badchannels{i},channelinfo.matrix{k,j})                  
                  channelinfo.matrix{k,j}={'0'};
              end;
          end;
      end;
  end;
end; 

[ic, max_ic]=cudaica_matlab_scalp_v2(eeg_data,samplingrate); % Clean data with CUDA ICA

% Rebuild eeg datastructure for later
eeg.eeg_data=eeg_data;
eeg.ic=ic;
eeg.samp_rate=samplingrate;
size_ic=numel(eeg.ic(1,:));
eeg.eeg_data=eeg.eeg_data(:,1:numel(eeg.ic(1,:)));
eeg = eeg_filter(eeg,0,16);
eeg_recompose=(eeg.eeg_data+eeg.ic);
eeg.chanlist=foundchannels';
size_eeg=numel(eeg_recompose(1,:));
%if numel(badchannel_eeg)>0
%badchannel_eeg=badchannel_eeg(:,1:size_eeg);
%eeg_recompose=insertrows(eeg_recompose,badchannel_eeg,badchannel_index);
%eeg.chanlist=insertrows(eeg.chanlist,badchannels,badchannel_index);
%end;
data={''};
for i=1:numel(eeg_recompose(:,1))
    data{i,1}=eeg_recompose(i,:);
end;
fprintf('max_ic values: ');
signalCell_new={''};
empty_channel_index=[];
if numel(signalCell) == 41
    fprintf('41 channel file');
    empty_channel_index=[11:14 20 26:41];
else
    if numel(signalCell) == 43
    fprintf('43 channel file');
    empty_channel_index=[11:14 20 26:43];
    else
      if numel(signalCell) == 39
      fprintf('39 channel file');
      empty_channel_index=[11:14 20 26:39];
      else
      fprintf('non-standard file');
    end;
end;
end;
new_bad_index=[];
for j=1:numel(badchannels)
for i=1:numel(signalHeader) 
    if strcmp(badchannels{j},signalHeader(i).signal_labels)
        new_bad_index=horzcat(new_bad_index,i);
    end;
end;
end;
empty_channel_index=horzcat(empty_channel_index,new_bad_index);
counter=1;
for i=1:numchan
     if ~any(i==empty_channel_index)
      signalCell_new(1,i)=data(counter,:);
      signalHeader(i).samples_in_record=200;
      counter=counter+1;
     else
      signalCell_new{1,i}=signalCell{1,i}(1:numel(eeg.ic(1,:)));
      signalHeader(i).samples_in_record=200;
     end;
end;
signalCell=signalCell_new;
blockEdfWrite(outfile, header,  signalHeader, signalCell)



