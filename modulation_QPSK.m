%% QPSK modulation
function [codebook,tx_symbols]=modulation_QPSK(tx_bits)
%% tx_bits generation
M=4;
len=length(tx_bits);
symbollen=len/log2(M);
tx_bits_index=reshape(tx_bits,2,symbollen);
%% QPSK codebook 
codebook=[exp(1j*pi/4) exp(-1j*pi/4) exp(1j*3*pi/4) exp(-1j*3*pi/4)];
%% QPSK modulation
% get the result sambol 
tx_symbols=codebook([1 2]*tx_bits_index+1);
end