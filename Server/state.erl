-module (state).
-export ([start/0]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Lista de users em espera, tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [], #{}, #{})
    .



estado(Users_Score, Waiting, TopLevels, TopScore) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            io:format("Recebi ready de ~p ~n", [Username]),
            case maps:find(Username, Users_Score) of
                {ok, {_, UserLevel }} -> % Descobrir nivel do User
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopLevels, TopScore); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            io:format(" Processo adversário de ~p é ~p ~n", [Username, H]),
                            Game = spawn( fun() -> gameManager ({Username, UserProcess}, {UsernameQueue, UserProcessQueue}) end ),
                            UserProcess ! UserProcessQueue  ! {go, Game},
                            estado( Users_Score, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopLevels, TopScore)
                    end
                ;
                error -> % Se User não existe, inserir no map com stats a zero
                    NewMap = maps:put(Username, {0,1}, Users_Score),
                    UserLevel = 1,
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                            io:format("Vou por o processo na queue"),
                            estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopLevels, TopScore); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            Game = spawn( fun() -> gameManager({Username, UserProcess}, {UsernameQueue, UserProcessQueue}) end),
                            UserProcess ! UserProcessQueue ! {go, Game},
                            estado( NewMap, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopLevels, TopScore)
                    end
                end
            ;
        {gameEnd, Result} -> % O que é suposto devolvermos? {Username , Score} TEMOS QUE ACABAR ISTO!
            Result
    end
.





% Parametros a guardar por user : Posicao, Direcao, Aceleracao,
% É aqui que comunicamos com o clientes

gameManager(PlayerOne, PlayerTwo)-> % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    io:format("Hello"),
    {Username1, UserProcess1} = PlayerOne,
    {Username2, UserProcess2} = PlayerTwo,
    % GameStat = maps:new(),
    % {Username1, X, Y, LP, RP, FP} =
    Refresher = spawn(fun() -> refresh(UserProcess1, UserProcess2, abc) end).
    %Criar criaturas
    %Armazenar posiçoes de todos eles
    %Processos que carregam propulsores



% refresh( Process1, Process2, GameInfo) ->
%     timer:send_after(10, refresh, self()),
%     receive
%         refresh ->
%             io:format("Sending data to the client"),
%             Process1 ! Process2 ! {line, GameInfo}
%     end
%     .
