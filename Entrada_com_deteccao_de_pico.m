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
    hold on

% Só para ver cada uma das ondas que compoe o sinal de entrada
%figure
%    subplot(2,1,1)
%        plot(t, yp1)
%    subplot(2,1,2)
%        plot(t, yp2)
    
    % Inserindo também detecção de picos
    a = zeros(length(y)-1, 1);
    b = zeros(length(y)-1, 1);
    count = 0;

    for n = 1:1:length(y)-1

    if y(n) > y(n+1)
        a(n) = 0;
    else if y(n) < y(n+1)
        a(n) = 1;
        else
        a(n)= a(n-1);
        end
    end

    if n > 1
        if a(n-1) > a(n)
            %fprintf('Pico -> Desceu\n');
            count = count +1;
            if mod(count, 2) ~= 0
                b(n) = 1;
            end
        else if a(n-1) < a(n)
                %fprintf('Vale -> Subiu\n');
            end
        end
    end

    end

    fprintf('Número de picos = %d\n', count);
    fprintf('?empo de amostragem: 10s\n');

    %Considerando que em um período sempre tem 2 picos e que o tempo de
    %amostragem foi de 10 segundos.
    fprintf('A frequência é de %f bpm\n', count*60/2/10)
    
    %figure
        a = [a; 1];
        b = [b; 0];
        plot(t, (a-0.5)*2)
        hold off
    figure
        plot(t,y)
        hold on
        plot(t, b*1.6)
        hold off

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