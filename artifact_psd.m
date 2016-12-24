function [ai, clean_eeg, artifact_segments]=artifact_psd(eeg, chanindex);
ai=[];
for i=chanindex:chanindex 
    temp(1,:) = eeg.eeg_data(i,:);
end
ripple = [80 250]; % ripple definition ShennanW
RippleFilt = fir1(1000,[ripple(1)/(eeg.samp_rate/2) ripple(2)/(eeg.samp_rate/2)]);
temp = filtfilt(RippleFilt,1,temp);
for i=1:1
    a=num2str(i);
    data.label{i} = ['chan' a];
end;
data.fsample=eeg.samp_rate;
%Here on in returns to Shennen's Code
data.time=cell(1,1);
time=[(1/eeg.samp_rate):(1/eeg.samp_rate):10];
data.time{1,1}=time;
time=[];
data.trial=cell(1,1);
data.trial{1,1}=temp; % the fieldtrip data format has been succesfully constructed
temp=[];
cfg=[];
cfg.lpfilter='no';
cfg.hpfilter='no';
cfg.blc='no';
cfg.offset='no'
dataLFP=ft_preprocessing(cfg, data); %Fieldtrip preprocessing
dataLFP.cfg.trl=[1 length(eeg.eeg_data) 0]; % define trial structure
cfg=[];
slide.trialwindow=round(data.fsample*90);
slide.advance=round(data.fsample*90);
slide.samp_rate=data.fsample;
slide.lengthrecording=length(eeg.eeg_data(1,:));
save('cudaica_trialfun_parameters.mat','slide');
cfg.trialfun='cudaica_trialfun';
dataLFP.cfg.trl=[1 length(eeg.eeg_data(1,:)) 0];
temp=ft_definetrial(cfg) %build trial array
cfg=[];
cfg.trl=temp.trl;
LFPSLIDE=ft_redefinetrial(cfg, dataLFP); %parse data into trials
POWER=[];
for l=1:numel(LFPSLIDE.trial) %calculate power for each window across all windows
    cfg=[];
    cfg.trials=l;
    cfg.method='mtmfft';
    cfg.output='pow';
    cfg.tapsmofrq=5;
    cfg.foilim=[100 200] 
    freq = ft_freqanalysis(cfg,LFPSLIDE);
    LFPpower=sum(freq.powspctrm(:,:)'); 
    POWER=vertcat(POWER, LFPpower); % build 3D array
    
    %Calculating the Locations of the Windows
    output_data.windowbegin(l) = 1 + (slide.advance * (l-1));
    output_data.windowend(l) = slide.trialwindow + (slide.advance * (l-1));
    output_data.windowmid(l) = (output_data.windowbegin(l) + output_data.windowend(l))/2;
end;

psd_art_index=zeros(numel(POWER),1);
for i=1:numel(POWER)
    if POWER(i) >= 4
        psd_art_index(i)=1;
        if i>2
        psd_art_index(i-1)=1;
        end;
        psd_art_index(i+1)=1;
    end;
end;
clean_eeg=eeg.eeg_data;
artifact_segments=[];
ai=zeros(numel(eeg.eeg_data(:,1)),numel(eeg.eeg_data(1,:)));
for i=1:numel(psd_art_index)
    if i==1
        if psd_art_index(1)==1
            ai(:,1:slide.advance)=10;
            artifact_segments=horzcat(artifact_segments, 1:slide.advance);
        end;
    else
     if i==numel(psd_art_index)
         if psd_art_index(i)==1
            ai(:,((i-1)*slide.advance):numel(eeg.eeg_data(1,:)))=10;
            artifact_segments=horzcat(artifact_segments,((i-1)*slide.advance):(numel(eeg.eeg_data(1,:))));
        end;
     else
         if psd_art_index(i)==1
            ai(:,((i-1)*slide.advance):(i*slide.advance))=10;
            artifact_segments=horzcat(artifact_segments,((i-1)*slide.advance):(i*slide.advance));
        end;
    end;
    end;
end;

clean_eeg(:,artifact_segments)=[];

   
