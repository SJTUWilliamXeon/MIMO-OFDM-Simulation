clc;clear; close all;
load SER_result.mat;
load SER_result_withcoding.mat;
load BER_result.mat;
load BER_result_withcoding.mat;
load SNR.mat;
figure('Name','SER BER');

yyaxis left; plot(SNR,SER_result,'-o',SNR,SER_result_withcoding,'--s');ylabel('SER')
yyaxis right; plot(SNR, BER_result,'-o',SNR,BER_result_withcoding,'--gs');
legend('SER ','SER with channel coding','BER','BER with channel coding');
ylabel('BER');
xlabel('SNR£¨dB£©');

grid on;

title('SER & BER vs. SNR');

