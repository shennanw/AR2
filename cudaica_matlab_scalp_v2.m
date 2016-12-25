function [ic,max_ic]=cudaica_matlab_scalp_v2(eeg_data,samplingrate);
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

ic=[];
max_ic=[];
start=1;
totalpointsremaining=numel(eeg_data(1,:))-start;
cycles=floor(totalpointsremaining/(samplingrate*120));
cycles
for i=1:cycles 
    start=((i-1)*(samplingrate*120))+1;
    finish=(i*(samplingrate*120));
    start
    finish
    data=eeg_data(:,start:finish); % take 120 second segment 
    EEG = pop_importdata('setname','temp','data',data,'dataformat','matlab','srate',samplingrate); % load data in to eeglab
    [EEG.icaweights, EEG.icasphere, mods] = cudaica(EEG.data(:,:), 'lrate', 0.001)
    EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere ); % calculate ICA matrix
    EEG.icachansind=[1:numel(data(:,1))]; % populate channels
    inv_w_matrix=abs(EEG.icawinv);
    max_inv_w_matrix=max(inv_w_matrix);
    [C,D]=find(max_inv_w_matrix>0.5);
    max_ic_raw=max(D);
    size_inv_w_matrix=numel(inv_w_matrix(1,:));
    inv_w_matrix_resize=reshape(inv_w_matrix,(size_inv_w_matrix*size_inv_w_matrix),1);
    zinv_w_matrix_resize=zscore(inv_w_matrix_resize);
    zinv_w_matrix=reshape(zinv_w_matrix_resize,size_inv_w_matrix,size_inv_w_matrix);
    max_w_matrix=max(zinv_w_matrix);
    [A,B]=find(max_w_matrix>2);
    if max_ic_raw < max(B)
        max_ic(i)=max_ic_raw;        
    else
        max_ic(i)=max(B); 
    end;
    if numel(B)==0
        max_ic(i)=1;
    end;
    OUTEEG = pop_subcomp(EEG, 1:max_ic(i), 0);
    ic=horzcat(ic,OUTEEG.data);
end;
if numel(eeg_data(1,:)-finish)>(samplingrate*10)
    start=finish+1;
    finish=numel(eeg_data(1,:))
    data=eeg_data(:,start:finish); % take 120 second segment 
    EEG = pop_importdata('setname','temp','data',data,'dataformat','matlab','srate',samplingrate); % load data in to eeglab
    [EEG.icaweights, EEG.icasphere, mods] = cudaica(EEG.data(:,:), 'lrate', 0.001)
    EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere ); % calculate ICA matrix
    EEG.icachansind=[1:numel(data(:,1))]; % populate channels
    inv_w_matrix=abs(EEG.icawinv);
    size_inv_w_matrix=numel(inv_w_matrix(1,:));
    inv_w_matrix_resize=reshape(inv_w_matrix,(size_inv_w_matrix*size_inv_w_matrix),1);
    zinv_w_matrix_resize=zscore(inv_w_matrix_resize);
    zinv_w_matrix=reshape(zinv_w_matrix_resize,size_inv_w_matrix,size_inv_w_matrix);
    max_w_matrix=max(zinv_w_matrix);
    [A,B]=find(max_w_matrix>2);
    max_ic(i+1)=max(B); 
    if numel(B)==0
        max_ic(i+1)=1;
    end;
    OUTEEG = pop_subcomp(EEG, 1:max_ic(i+1), 0);
    ic=horzcat(ic,OUTEEG.data);
end;
    