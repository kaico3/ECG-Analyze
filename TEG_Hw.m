clc;
clear;

Fo=360; %sampling frequency
% x values are in milivolts

file=fopen('ecg.dat','rb');
[x, OS]=fscanf(file,'%f',inf);
fclose(file);

%there are 2560 points in ECG
%%
time_domain = (1:OS)';
%this signal is sampled with Fo Hz. 
%time_domain_s is in seconds
time_domain_s = (time_domain/Fo);
%time_domain_s is in milliseconds
time_domain_ms = time_domain_s*1000;
figure()
plot(time_domain_ms,x); xlabel('milliseconds-ms'); ylabel('amplitude-mV');title('040150075 H.Kayihan Comert');

%% frequency domain
f=fft(x,OS);
F=abs(f);
w=(0:(OS/2-1))/(OS/2)*(Fo/2);
figure()
plot(w,F(1:OS/2)); title('FFT-RAW ECG'); xlabel('frequency (Hz)');

%% finding R-R
%there are 9 nearly equally spaced ranges
%that has one R. 
%subsets_Matrix will be used in finding maximum values
num_R = 10;
subsets = zeros(num_R+1,1);

subset_size = OS/num_R;
subset_t = 1;
for i= 1:num_R+1
    subsets(i) =(subset_t-1)*subset_size;
    subset_t  = subset_t +  1;
end
subsets = round(subsets);
subsets(1) = 1;

%% to check if we indeed separate correctly
figure()
for i = 1:10
    subplot(5, 6, i) ;
    plot(time_domain(subsets(i):subsets(i+1)),x(subsets(i):subsets(i+1)));
end
%% finding RR distances
maximas = zeros(10,1);
for i = 1:10
    [y,ind] = max(x(subsets(i):subsets(i+1)));
    maximas(i) = subsets(i)+ind-1;
end
dists_RR = zeros(9,1);
for k = 1:9
    dists_RR(k) = maximas(k+1)-maximas(k);
end
dists_RR_ms = (dists_RR/Fo)*1000;
figure()
plot(dists_RR_ms,'.',"LineWidth",4,"Color",'k'); ylabel("ms");xlabel("R-R");
grid on
%% with 1VDC bias
b = ones(OS,1);
x_b = x + b;
subplot(3,1,1)
plot(time_domain_ms,x_b)
%% frequency domain
f=fft(x_b,OS);
Fdc=abs(f);
w=(0:(OS/2-1))/(OS/2)*(Fo/2);
plot(w,Fdc(1:OS/2)); title('FFT-ECG + Bias'); xlabel('frequency (Hz)');
%% first 20 terms 
plot(w(1:20),Fdc(1:20)); title('FFT-ECG + Bias'); xlabel('frequency (Hz)');
%% power line interference noise
Fsine = 50;                      % Sine wave frequency (hertz)
noise = 0.1*sin(2*pi*Fsine*time_domain_s);
figure()
plot(time_domain_ms,x+noise); xlabel("milliseconds-ms");ylabel('amplitude-mV'); title('ECG Data with noise');
Fs = 50; % Sine wave frequency (hertz) 
%% frequency domain
fn=abs(fft(noise,OS));
figure()
plot(w,fn(1:OS/2)+F(1:OS/2)); title('FFT- Noise'); xlabel('frequency (Hz)');
