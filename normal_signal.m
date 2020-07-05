%% normalize
function samples = normal_signal(signal_sample)
    samples = signal_sample./sqrt(mean(abs(signal_sample).^2));
end