-module (state).
% -export ([function/arity]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Queue de Users em espera , tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [], #{}, #{}, []) end),
    .



estado(Users_Score, Waiting, TopLevels, TopScore) ->
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            case maps:find(Username, Users_Score) of ->
                {ok, {_, UserLevel }} -> % Descobrir nivel do User
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting)) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopLevels, TopScore)); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {{value, {UsernameQueue, LevelQueue, UserProcessQueue} }, Q_}  = H,
                            Game = spawn( fun() -> gameManager({Username, UserProcess}, {UsernameQueue, UserProcessQueue})),
                            UserProcess ! UserProcessQueue {go, Game},
                            estado( Users_Score, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopLevels, TopScore)
                    end
                ;
                {empty, _ } -> % Se User não existe, inserir no map com stats a zero
                    NewMap = maps:put(Username, {0,1}),
                    UserLevel = 1,
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting)) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopLevels, TopScore)); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {{value, {UsernameQueue, LevelQueue, UserProcessQueue} }, Q_}  = H,
                            Game = spawn( fun() -> gameManager({Username, UserProcess}, {UsernameQueue, UserProcessQueue})),
                            UserProcess ! UserProcessQueue {go, Game},
                            estado( Users_Score, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopLevels, TopScore)
                    end
                ;
        {gameEnd, Result} -> % O que é suposto devolvermos? {Username , Score}







gameManager(PlayerOne, PlayerTwo)-> % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    {Username1, UserProcess1} = PlayerOne,
    {Username2, UserProcess2} = PlayerTwo,
    GameStat = maps:new(),
    {Username1, X, Y, LP, RP, FP} =
    %Criar criaturas
    %Armazenar posiçoes de todos eles
    %Processos que carregam propulsores
