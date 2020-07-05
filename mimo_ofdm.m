%% ���빦�ܣ����OFDM-MIMOϵͳ�ĵ��ƺͽ����δ�����ŵ����룩 

clear all;

%% ������ʼ��
number_sc=600;               %���ز�����
number_fft=1024;             %1024���ز�
number_cp=number_fft/4;    % ѭ��ǰ׺���ȣ���Cyclic prefix��

number_antenna = 4;            %��������
number_frm =10;                  %֡��
number_per_frm = 6;            %ÿ֡�ķ�����
SNR= -20 : 5 : 20;                  %���������
frequency_space = 15e3;       %Ƶ�ʼ��
Ts=1/(frequency_space);        % ����ʱ�䣨Ƶ�ʼ��������
h= [1, 0.1, 0.2, 0.1;
       0.1, 1, 0.2, 0.1;
       0.1, 0.2 ,1,0.2;
       0.2, 0.1, 0.1,1];                 % 4*4���߾���

P_data=randi([0 1],1,number_sc*number_per_frm*number_frm*number_antenna);        %���ɳ�ʼ������
save('P_data.mat','P_data');
BER_result= [];
SER_result=[];

%% QPSK����
for SNR=-20 : 5 : 20
    [codebook, tx_symbols]= modulation_QPSK(P_data);
    % �����任
    tx_symbols = reshape(tx_symbols,4,length(tx_symbols)/4);

    % OFDM����
    trans_data=[];
    for n = 1:number_antenna

        antenna = tx_symbols(n,:);
        
        %�����任
        antenna = reshape(antenna, number_sc,[]);
        %�����ź����ó�0
        antenna= [zeros(number_fft-number_sc,size(antenna,2));antenna];
        % ifft �任�õ�OFDM�ź�
        ifft_data = ifft(antenna);
        % ���뱣�������ѭ��ǰ׺
        Tx_data=[ifft_data(number_fft-number_cp+1:end,:);ifft_data];      %��ifft��ĩβѭ��ǰ׺���䵽��ǰ��
        %����ת��
        Tx_data = reshape(Tx_data,1,[]);
        trans_data=[trans_data;Tx_data];
    end
    
    % �ŵ�
    rx_data = h*trans_data;
    for n =1:number_antenna
        rx_data(n,:)= add_awgn(rx_data(n,:),SNR);
    end
    %MIMO
    rx_data = h\rx_data;
    %OFDM
    rx_symbols = [];

    for n = 1:number_antenna
        rx_data1=rx_data(n,:);
        rx_data1= reshape(rx_data1,number_fft+number_cp,[]);
        %ȥ���������������ǰ׺
        rx_data2=rx_data1(number_cp+1:end,:);
        % fft�任
        fft_data=fft(rx_data2);
        fft_data=fft_data(end-number_sc+1:end,:);
        % �����任
        antenna_symbols = reshape(fft_data,1,[]);
        rx_symbols= [rx_symbols;antenna_symbols];
    end
    
    rx_symbols_demo =reshape(rx_symbols,1,[]);
    rx_symbols_demo = normal_signal(rx_symbols_demo);
    scatterplot(rx_symbols_demo(1,:));grid;title(['SNR:',num2str(SNR),'dB'])
    [rx_bits,rx_symbols] = QPSK_demodulation(codebook,rx_symbols_demo,length(P_data));
    tx_symbols = reshape(tx_symbols,1,[]);
    SER = sum(abs(tx_symbols-rx_symbols)>0.1)/length(tx_symbols);
    [num,BER]= biterr(rx_bits,P_data);
    SER_result= [SER_result,SER];
    BER_result=[BER_result,BER];
end

SNR =-20 : 5 : 20;

save('SNR.mat','SNR');
save('SER_result.mat','SER_result');
save('BER_result.mat','BER_result');