% Frequência de amostragem
fs = 100;
% Período de amostragem
T = 1/fs;
% Número de amostras a serem feitas
L = 1000;

% Arquivos nos quais os valores da onda de entrada serão armazenados
file_y = 'data_in.txt';
fid_y = fopen(file, 'w');
file_b = 'data_bin.txt';
fid_b = fopen(file, 'w');

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

% b vai ser a nova entrada y(n).
% Primeiro, vamos deixar tudo > 0
b = y + 1.2;
% Segunda, temos 8 bits de entrada, logo, a entrada pode ir ate 255
% O maior atual eh menor que 2.7. Sendo assim, podemos multiplicar 
% b por 94 e pegar apenas a arte interia
b = fix(b*94);
figure
    plot(t,b)
% passando b de decimal pra binario
b = dec2bin(b);
% Insere b no arquivo data_bin.txt
dlmwrite('data_bin.txt', b, 'delimiter','');

fclose(fid_y);
fclose(fid_b);
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