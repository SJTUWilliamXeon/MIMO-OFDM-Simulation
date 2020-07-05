function rx_samples=add_awgn(tx_samples,SNR,sps)
%  

rx_samples=awgn(tx_samples,SNR,'measured');
rx_samples=rx_samples./sqrt(mean(abs(rx_samples).^2));

end