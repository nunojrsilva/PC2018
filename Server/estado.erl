-module (estado).
% -export ([function/arity]).

% O que será necessário manter no estado?
% - Lista de Users Online
% - Queue de Users em espera??
% - Top Pontuaçoes e Top Niveis
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

start() {
Loop = spawn( fun() -> estado( [], queue:new(), #{}, #{}, []) end),
}


estado(Online, Waiting, TopLevels, TopScore, GamesUndergoing) ->
