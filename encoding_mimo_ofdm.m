%% 代码功能：完成OFDM-MIMO系统的调制和解调（未加入信道编码）

clear all;

%% 参数初始化
number_sc=600;               %子载波数量
number_fft=1024;             %1024个载波
number_cp=number_fft/4;    % 循环前缀长度（即Cyclic prefix）

number_antenna = 4;            %天线数量
number_frm =10;                  %帧数
number_per_frm = 6;            %每帧的符号数
SNR= -20 : 5 : 20;                  %仿真信噪比
frequency_space = 15e3;       %频率间隔
Ts=1/(frequency_space);        % 符号时间（频率间隔倒数）
h= [1, 0.1, 0.2, 0.1;
       0.1, 1, 0.2, 0.1;
       0.1, 0.2 ,1,0.2;
       0.2, 0.1, 0.1,1];                 % 4*4天线矩阵

%与不使用信道编码使用一样的比特流信息
load P_data.mat;

%进行编码
P_coded_data = encode(P_data,3,1);
BER_result_withcoding= [];
SER_result_withcoding=[];

%% QPSK调制
for SNR=-20:5:20
    [codebook, tx_symbols]= modulation_QPSK(P_coded_data);
    %% 串并变换
    tx_symbols = reshape(tx_symbols,4,length(tx_symbols)/4);

    % OFDM调制
    trans_data=[];
    for n = 1:number_antenna

        antenna = tx_symbols(n,:);
        
        %继续串并变换
        antenna = reshape(antenna, number_sc,[]);
        %把其它信号设置成0
        antenna= [zeros(number_fft-number_sc,size(antenna,2));antenna];
        % ifft 变换 得到 OFDM信号
        ifft_data = ifft(antenna);
        % 插入保护间隔、循环前缀
        Tx_data=[ifft_data(number_fft-number_cp+1:end,:);ifft_data];   %把ifft的末尾循环前缀补充到最前面
        %并串转换
        Tx_data = reshape(Tx_data,1,[]);
        trans_data=[trans_data;Tx_data];
    end
    % 信道
    rx_data = h*trans_data;
    for n =1:number_antenna
        rx_data(n,:)= add_awgn(rx_data(n,:),SNR);
    end
    %MIMO
    rx_data = h\rx_data;
    %OFDM
    rx_symbols = [];
    %scatterplot(rx_data(1,:));grid;
    for n = 1:number_antenna
        rx_data1=rx_data(n,:);
        rx_data1= reshape(rx_data1,number_fft+number_cp,[]);
        %去掉保护间隔，保护前缀
        rx_data2=rx_data1(number_cp+1:end,:);
        % fft变换
        fft_data=fft(rx_data2);
        fft_data=fft_data(end-number_sc+1:end,:);
        % 并串变换
        antenna_symbols = reshape(fft_data,1,[]);
        rx_symbols= [rx_symbols;antenna_symbols];
    end
    rx_symbols_demo =reshape(rx_symbols,1,[]);
    rx_symbols_demo = normal_signal(rx_symbols_demo);
    scatterplot(rx_symbols_demo(1,:));grid;title(['channel coding rx symbols SNR:',num2str(SNR),'dB'])
    [rx_bits,rx_final_symbols] = QPSK_demodulation(codebook,rx_symbols_demo,length(P_coded_data));
    tx_symbols = reshape(tx_symbols,1,[]);
    SER = sum(abs(tx_symbols-rx_final_symbols)>0.1)/length(tx_symbols);
    rx_bits= decode(rx_bits,3,1);
    [num,BER]= biterr(rx_bits,P_data);
    SER_result_withcoding= [SER_result_withcoding,SER];
    BER_result_withcoding=[BER_result_withcoding,BER];
end
SNR =-20:5:20;

save('SER_result_withcoding.mat','SER_result_withcoding');
save('BER_result_withcoding.mat','BER_result_withcoding');


