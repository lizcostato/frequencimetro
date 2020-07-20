fid = fopen('data_in.txt', 'r');
y = fscanf(fid, '%f');

% Só testes
%fprintf('Bora ver no que deu: \n');
%fprintf('%f\n', y);
%fprintf('length y: %d\n', length(y));

a = zeros(length(y)-1, 1);
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
    else if a(n-1) < a(n)
            %fprintf('Vale -> Subiu\n');
        end
    end
end

end

fprintf('Número de picos = %d\n', count);
fprintf('Tempo de amostragem: 10s\n');

%Considerando que em um período sempre tem 2 picos e que o tempo de
%amostragem foi de 10 segundos.
fprintf('A frequência é de %f bpm\n', count*60/2/10)

% Arquivo no qual os valores da onda de entrada serão armazenados
file = 'data_out.txt';
fid = fopen(file, 'w');

% Insere a no arquivo data_in.txt
dlmwrite('data_out.txt', a);

fclose(fid);