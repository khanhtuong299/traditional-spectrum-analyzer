clear all;
load('filter00.mat');       %load IF filter (4kHz)
fs = 16000;                 %sample rate
L = 2048;                   %sample length
t=1/fs;
f_sig_min = 1000;           %frequency range of signal
f_sig_max = 3000;
f_lo_min = 5000;            %frequency range of LO
f_lo_max = 7000;
step_fr = 5;                %step of LO


x=(0:(L-1))*t;
f = f_sig_min:step_fr:f_sig_max;
len_f = length(f);
data = zeros(1,len_f);
j = 1;

timeInterval = 0.01;

Microphone = audioDeviceReader('SampleRate', fs,'SamplesPerFrame',L);         %setup Microphone for input
setup(Microphone);

%setup figure for spectrum
figureHandle = figure('NumberTitle','off',...
    'Name','Spectrum Analysis',...
    'Color',[0 0 0],'Visible','off');
axesHandle = axes('Parent',figureHandle,...
    'YGrid','on',...
    'YColor',[0.9725 0.9725 0.9725],...
    'XGrid','on',...
    'XColor',[0.9725 0.9725 0.9725],...
    'Color',[0 0 0]);
hold on;
plotHandle = plot(axesHandle,f,data,'Marker','.','LineWidth',1,'Color',[0 1 0]);


tic;
while(toc<20) %run 20 second
     audio = step(Microphone);

    for i = f_lo_min:step_fr:f_lo_max
        
        lo = sin(2*pi*i*x);               %create LO signal
        
        s_if = (audio.').*lo;             %mixer

        result = conv(s_if,filter00);     %IF filter
               
        data(j) = max(abs(result));       %envelope detector
        j = j+1;              
    end

    set(plotHandle,'YData',data,'XData', f);
    xlabel('Hz')
    ylabel('Volt')
    set(figureHandle,'Visible','on');
    pause(timeInterval);
    data = zeros(1,len_f);
    k = k +1;
    j = 1;
end

release(Microphone);
