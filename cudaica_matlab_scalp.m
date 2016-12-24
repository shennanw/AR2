function [hfo,ic1,ic2,ic3,ic4,ic5]=cudaica_matlab_scalp(eeg_data,samplingrate);
if samplingrate < 520
    maxband = 70;
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

low=16;
high=maxband;
%Filter Settings
if(low == 0) && (high == 0)
    disp('Impossible Filter between 0 and 0 Hz');
    return;
elseif (high == 0)
    CustomFilter = fir1(500,low/(samplingrate/2),'high');
    filetag = strcat('_filtered_hp_',int2str(low),'.mat');
elseif (low == 0)
    CustomFilter = fir1(500,high/(samplingrate/2),'low');
    filetag = strcat('_filtered_lp_',int2str(low),'.mat');
else
    CustomFilter = fir1(500,[low/(samplingrate/2) high/(samplingrate/2)]);
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
ic2=[];
ic3=[];
ic4=[];
ic5=[];
start=1;
totalpointsremaining=numel(eeg_data(1,:))-start;
cycles=floor(totalpointsremaining/(samplingrate*120));
cycles
for i=1:cycles 
    start=((i-1)*(samplingrate*120))+1;
    finish=(i*(samplingrate*120));
    start
    finish
    data=eeg_data(:,start:finish); % take 240 second segment 
    EEG = pop_importdata('setname','temp','data',data,'dataformat','matlab','srate',samplingrate); % load data in to eeglab
    [EEG.icaweights, EEG.icasphere, mods] = cudaica(EEG.data(:,:), 'lrate', 0.001)
    EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere ); % calculate ICA matrix
    EEG.icachansind=[1:numel(data(:,1))]; % populate channels
    OUTEEG = pop_subcomp(EEG, 1, 0); % remove ICA components
    hfo=horzcat(hfo,data);
    ic1=horzcat(ic1,OUTEEG.data); % addend cleaned data 
    OUTEEG = pop_subcomp(EEG, 1:2, 0); % remove ICA components
    ic2=horzcat(ic2,OUTEEG.data);
    OUTEEG = pop_subcomp(EEG, 1:3, 0);
    ic3=horzcat(ic3,OUTEEG.data);
    OUTEEG = pop_subcomp(EEG, 1:4, 0);
    ic4=horzcat(ic4,OUTEEG.data);
    OUTEEG = pop_subcomp(EEG, 1:5, 0);
    ic5=horzcat(ic5,OUTEEG.data);
end;
