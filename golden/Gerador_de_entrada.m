% Frequência de amostragem
fs = 100;
% Período de amostragem
T = 1/fs;
% Número de amostras a serem feitas
L = 1000;

% Arquivo no qual os valores da onda de entrada serão armazenados
file = 'data_in.txt';
fid = fopen(file, 'w');

% Start stopwatch timer
tic

% Instantes de amostragem
t=0:T:10-T;

% Composição do sinal de entrada
yp1 = 0.8*sin(0.75*2*pi*t/1);
yp2 = 0.7*sin(0.75*2*2*pi*t/1-0.8);
y = yp1+yp2;

% Deixa os dados em uma coluna, ao invés de uma linha
y = y.';

% Insere y(n) no arquivo data_in.txt
dlmwrite('data_in.txt', y);

fclose(fid);
%fprintf('length t: %d\n', length(t));
%fprintf('length y: %d\n', length(y));

% Read elapsed time from stopwatch
toc
figure
    plot(t,y)

% Só para ver cada uma das ondas que compoe o sinal de entrada
%figure
%    subplot(2,1,1)
%        plot(t, yp1)
%    subplot(2,1,2)
%        plot(t, yp2)
    
% Inserindo ruidos (0.1Hz, 50Hz, 60Hz, 500Hz)
y = y.';
y = y + sin(0.1*2*pi*t/1-0.8);
y = y + sin(50*2*pi*t/1-0.8);
y = y + sin(60*2*pi*t/1-0.8);
y = y + sin(500*2*pi*t/1-0.8);
y = y.';

% Gráfico com ruídos
figure
    plot(t,y)