function [rx_bits,dec_symbols] = QPSK_demodulation(codebook,rx_symbols,message_length)
% demodulation for QPSK
%   codebook is the same with codebook used in modulation 
% symbols are received symbols 
for i=1:4
    dist(i,:)=abs(rx_symbols-codebook(i)).^2;
end
[~,ind]=min(dist);
dec_symbols=codebook(ind); 
rx_bits=zeros(1,message_length);
ind=ind-1;
rx_bits(1:2:end)=mod(ind,2);
rx_bits(2:2:end)=(ind-rx_bits(1:2:end))./2;
end

