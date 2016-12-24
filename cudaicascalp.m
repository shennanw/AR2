function [hfo,ic1]=cudaica_matlab(eeg_data,samplingrate);
if samplingrate < 520
    maxband = 200;
else 
   if samplingrate<1020
       maxband = 400;
   else
       maxband =600;
   end;
end;

for i=1:numel(eeg_data(:,1));
    temp_var=eeg_data(i,:);
    temp_var(isnan(temp_var))=0;
    eeg_data(i,:)=temp_var;
    eeg_data(i,:)=(eeg_data(i,:)-mean(eeg_data(i,:)));
end;

low=80;
high=maxband;
%Filter Settings
if(low == 0) && (high == 0)
    disp('Impossible Filter between 0 and 0 Hz');
    return;
elseif (high == 0)
    CustomFilter = fir1(1000,low/(samplingrate/2),'high');
    filetag = strcat('_filtered_hp_',int2str(low),'.mat');
elseif (low == 0)
    CustomFilter = fir1(1000,high/(samplingrate/2),'low');
    filetag = strcat('_filtered_lp_',int2str(low),'.mat');
else
    CustomFilter = fir1(1000,[low/(samplingrate/2) high/(samplingrate/2)]);
    filetag = strcat('_filtered_',int2str(low),'_',int2str(high),'.mat');
end

for i = 1:length(eeg_data(:,1))
    disp(strcat('Filtered:_',int2str(i),'_of_',int2str(length(eeg_data(:,1))),'_data.'));
    eeg_filtered_data(i,:) = filtfilt(CustomFilter,1,eeg_data(i,:));
end

eeg_data_unfiltered = eeg_data;
eeg_data = eeg_filtered_data;

hfo=[];
ic1=[];
start=1;
totalpointsremaining=numel(eeg_data(1,:))-start;
cycles=floor(totalpointsremaining/(samplingrate*90));
cycles
for i=1:cycles 
    start=((i-1)*(samplingrate*90))+1;
    finish=(i*(samplingrate*90));
    start
    finish
    data=eeg_data(:,start:finish); % take 30 second segment 
    EEG = pop_importdata('setname','temp','data',data,'dataformat','matlab','srate',samplingrate); % load data in to eeglab
    [EEG.icaweights, EEG.icasphere, mods] = cudaica(EEG.data(:,:), 'lrate', 0.001)
    EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere ); % calculate ICA matrix
    EEG.icachansind=[1:numel(data(:,1))]; % populate channels
    OUTEEG = pop_subcomp(EEG, 1, 0); % remove ICA components
    hfo=horzcat(hfo,data);
    ic1=horzcat(ic1,OUTEEG.data); % addend cleaned data 
end;
