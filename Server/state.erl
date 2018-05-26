-module (state).
-export ([start/0]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).
-import (timer, [send_after/3]).
-import (creatures, [newCreature/1, updateCreature/3]).
-import (players, [newPlayer/1, accelerateForward/1, turnRight/1, turnLeft/1, updatePlayers/4 ]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Lista de users em espera, tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%


estado(Users_Score, Waiting) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            io:format("Recebi ready de ~p ~n", [Username]),
            case maps:find(Username, Users_Score) of
                {ok, {_, UserLevel }} -> % Descobrir nivel do User {GamesWon, UserLevel}
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}]); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            io:format(" Processo adversário de ~p é ~p ~n", [Username, H]),
                            Game = spawn( fun() -> gameManager (newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue})) end ),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
                            UserProcess ! UserProcessQueue  ! {go, Game},
                            estado( Users_Score, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}])
                    end
                ;
                error -> % Se User não existe, inserir no map com stats a zero
                    NewMap = maps:put(Username, {0,1}, Users_Score),
                    UserLevel = 1,
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                            io:format("Vou por o processo na queue"),
                            estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}]); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            Game = spawn( fun() -> gameManager(newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue})) end),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
                            UserProcess ! UserProcessQueue ! {go, Game},
                            estado( NewMap, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}])
                    end
            end;

        {gameEnd, Result} -> % O que é suposto devolvermos? {Username , Score} TEMOS QUE ACABAR ISTO!

            {{Username1, Score1}, {Username2, Score2}} = Result,

            % Atualização da Pontuação

            {ok, {GamesWon1, UserLevel1} } = maps:find(Username1, Users_Score),
            {ok, {GamesWon2, UserLevel2} } = maps:find(Username2, Users_Score),

            if
                Score1 > Score2 ->
                    NewGamesWon1 = GamesWon1 + 1,
                    NewGamesWon2 = GamesWon2,
                    NewUserLevel2 = UserLevel2,
                    if
                        NewGamesWon1 > UserLevel1 ->
                            NewUserLevel1 = UserLevel1 + 1;
                    true ->
                        NewUserLevel1 = UserLevel1
                    end;

                true ->
                    %Score 2 > Score2
                    NewGamesWon2 = GamesWon2 + 1,
                    NewGamesWon1 = GamesWon1,
                    NewUserLevel1 = UserLevel1,
                    if
                        NewGamesWon2 > UserLevel2 ->
                            NewUserLevel2 = UserLevel2 + 1;
                    true ->
                        NewUserLevel2 = UserLevel2
                    end
            end,
            AuxMap = maps:put( Username1, {NewGamesWon1, NewUserLevel1}, Users_Score),
            NewMap = maps:put( Username2, {NewGamesWon2, NewUserLevel2}, AuxMap),
            estado (NewMap, Waiting)
            ;
        {tops, From} ->
            List = maps:to_list(Users_Score),
            SortedList = lists:keysort(2, List)

    end
.

newState(Player1, Player2) ->
    State = { {newPlayer(1), Player1}, {newPlayer(2), Player2}, [newCreature(g), newCreature(g)], [ ], {1200,800}},
    io:fwrite("Estado: ~p ~n", [State]),
    State.


processKeyPressData( Data ) ->
    %% Do your thing Nunaroo :P
    %% Tem que retornar "w", "a" ou "d". Ou de alguma forma extrair algo do género
    %% No updateWithKeyPress eu também estou a verificar a tecla
    {}.


gameManager(State)->
    % Como calcular a pontuação?
    % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    receive
        {keyPressed, Data, From} ->
            io:format("Entrei no keyPressed ~n"),
            KeyPressed = processKeyPressData( Data ),
            NewState = updateWithKeyPress(State, KeyPressed, From),
            gameManager(NewState);
        {leave, From} ->
            {}
            ;
        refresh ->
            io:format("Entrei no ramo refresh ~n"),
            NewState = update(State),
            gameManager(NewState)
    end.

refreshTimer (Pid) ->
    FramesPerSecond = 40,
    Step = 1000/FramesPerSecond,
    send_after(Step, Pid, refresh),
    receive
        after
            1000 ->
                refreshTimer(Pid)
    end
    .

updateWithKeyPress(State, KeyPressed, From) ->
    {{ID_P1, P1}, {ID_P2, P2}, GreenCreatures, RedCreatures, ArenaSize } = State,

    if
        From == ID_P1 -> 
            if
                KeyPressed == "w" -> NewPlayer = accelerateForward(P1);
                KeyPressed == "a" -> NewPlayer = turnLeft(P1);
                KeyPressed == "d" -> NewPlayer = turnRight(P1)
            end,
            {{ID_P1, NewPlayer}, {ID_P2, P2}, GreenCreatures, RedCreatures, ArenaSize };
        From == ID_P2 -> 
            if
                KeyPressed == "w" -> NewPlayer = accelerateForward(P2);
                KeyPressed == "a" -> NewPlayer = turnLeft(P2);
                KeyPressed == "d" -> NewPlayer = turnRight(P2)
            end,
            {{ID_P1, P1}, {ID_P2, NewPlayer}, GreenCreatures, RedCreatures, ArenaSize };
        true -> 
            io:format("Unkown id ~p in updateWithKeyPress", [From]),
            {{ID_P1, P1}, {ID_P2, P2}, GreenCreatures, RedCreatures, ArenaSize }
    end.

update(State) ->
    {{P1_ID, P1}, {P1_ID, P2}, GreenCreatures, RedCreatures, ArenaSize} = State,

    %% Check for Colisions. And evaluate if there's energy to add
    %% Check to see if Players are outside the arena walls.
    
    {NewP1, NewP2} = updatePlayers(P1, P2, 0, 0),
    NewGreenCreatures = updateCreatures(GreenCreatures, NewP1, NewP2),
    NewRedCreatures = updateCreatures(RedCreatures, NewP1, NewP2),
    {NewP1, NewP2, NewGreenCreatures, NewRedCreatures, ArenaSize}.


updateCreatures(Creatures, P1, P2) ->
    %lists:map(updateCreature, Creatures).
    [ updateCreature(Creature, P1, P2) || Creature <- Creatures].

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [])
    .
