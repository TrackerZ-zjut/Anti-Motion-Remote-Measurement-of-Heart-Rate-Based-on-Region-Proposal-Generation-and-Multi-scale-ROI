clear;
workDir = 'G:\ZMH\Multi-scale rPPG';
addpath([NEWworkDir '\utils']);

nVersion = 1;
fps_Real = 30;
fps_Est = 30;
nSubject = 49;

SNRs = zeros(nSubject+1,nVersion);
MAEs = zeros(nSubject+1,nVersion);
RMSEs = zeros(nSubject+1,nVersion);

for iVersion = 1
    
    sum_SNR = 0;
    sum_MAE = 0;
    sum_RMSE = 0;
    n_SNR = 0;
    n_MAE = 0;
    n_RMSE = 0;
    
    for iSub = 1 :nSubject
        
        subName = [ 'subject' num2str(iSub) ];
        
        vidDir = [workDir '\Result\UBFC_DATASET\DATASET_2\' subName ];
        filePath = [vidDir '\vid.avi'];
        newResultDir = [ 'G:\HWR\ZMH\Result\UBFC_DATASET\DATASET_2\' subName ];
        PluseEst_File = [ newResultDir '\new_single_CHROM_1220.mat' ];% predicted data
        
        if ~exist(filePath,'file')
            disp( [  subName ' ��Ƶ������' ] )
            continue;
        end
        
        real_pulse_File = [vidDir '\ground_truth.txt' ];% real data
        ground_truth = dlmread( real_pulse_File );
        gt_pulse = ground_truth( 1, : );   %  real waveform
        
        load(PluseEst_File);
        
        nor_ppgClipped = normalizeSignal(gt_pulse');
        gt_HR = instantPulseFFT(nor_ppgClipped,fps_Real,false); %  real HR
        
        nor_PulseEst = normalizeSignal(PulseEst);%predicted waveform
        est_HR = instantPulseFFT(nor_PulseEst,fps_Est,false);  %   predicted HR
        
        %  ensure same length
        minLen = min( length(gt_HR) , length(est_HR) );
        gt_HR = gt_HR(1:minLen);
        est_HR = est_HR(1:minLen);
        
        SNRs(iSub,iVersion) = eval_SNR(mean(gtHR),nor_PulseEst,fps);  %get SNR
        MAEs(iSub,iVersion) = sum(abs(gt_HR - est_HR))/length(gtHR);  % get MAE
        RMSEs(iSub,iVersion) = sqrt(mean((gt_HR - est_HR).^2));  %get RMSE
        
        sum_SNR = sum_SNR + SNRs(iSub,iVersion);
        sum_MAE = sum_MAE + MAEs(iSub,iVersion);
        sum_RMSE = sum_RMSE + RMSEs(iSub,iVersion);
        n_SNR = n_SNR + 1;
        n_MAE = n_MAE + 1;
        n_RMSE = n_RMSE + 1;
        
    end
    
    SNRs(iSub+1,iVersion) = sum_SNR/n_SNR; %Average SNRs
    MAEs(iSub+1,iVersion) = sum_MAE/n_MAE; %Average MAEs
    RMSEs(iSub+1,iVersion) = sum_RMSE/n_RMSE; %Average RMSEs
    
end

