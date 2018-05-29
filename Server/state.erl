-module (state).
-export ([start/0, formatState/1]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).
-import (timer, [send_after/3]).
-import (creatures, [newCreature/1, updateCreature/3, checkRedColisions/3, checkColisionsList/2, checkColision/2, updateCreaturesList/3]).
-import (players, [newPlayer/1, accelerateForward/1, turnRight/1, turnLeft/1, updatePlayers/4 ]).
-import (vectors2d, [multiplyVector/2, normalizeVector/1, halfWayVector/2, addPairs/2, distanceBetween/2, subtractVectors/2]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Lista de users em espera, tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

%% IMPORTANT note about the User
%% In the State we save a pair that represents the user: {PlayerAvartar, UserObject}
%%  - The first element represents the PlayerAvatar; referenced as (P#)
%%  - The second Element is another pair representing the User {Username, UserProcess}: referenced as whole as (ID_P#)
%%     -- The first element is the User's username;   referenced as (U#)
%%     -- The first element is the User's Process ID; referenced as (PID_P#)


start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [], #{}, #{})
    .

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
            GamesF = fun ({_, {GamesWon1, _}}, {_, {GamesWon2, _}}) -> GamesWon1 > GamesWon2 end,
            LevelsF = fun ({_, {_, Level1}}, {_, {_, Level2}}) -> Level1 > Level2 end,
            GamesTop = lists:sort(GamesF, List),
            LevelsTop = lists:sort(LevelsF, List),
            From ! {tops, {GamesTop, LevelsTop}},
            estado (Users_Score, Waiting)
    end
.



newState(Player1, Player2) ->
    State = { {newPlayer(1), Player1}, {newPlayer(2), Player2}, {newCreature(g), newCreature(g)}, [ ], {1200,800}},
    io:fwrite("Estado: ~p ~n", [State]),
    State.



processKeyPressData( Data ) ->
    %% Do your thing Nunaroo :P
    %% Tem que retornar "w", "a" ou "d". Ou de alguma forma extrair algo do género
    %% No updateWithKeyPress eu também estou a verificar a tecla
    {}.



gameManager(State)->
    io:format("Game Manager a correr ~n"),
    % Como calcular a pontuação?
    % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    receive
        {keyPressed, Data, From} ->
            io:format("Entrei no keyPressed ~n"),
            KeyPressed = processKeyPressData( Data ),
            { SomeoneLost, WhoLost } = checkLosses(State),
            if
                SomeoneLost -> gameManager(State); % TODO: handle end game
                true ->
                    NewState = updateWithKeyPress(State, KeyPressed, From),
                    gameManager(NewState)
            end;
        {leave, From} -> % O que é isto?
            {}
            ;
        {refresh, From} ->
            io:format("Entrei no ramo refresh ~n"),
            { SomeoneLost, WhoLost } = checkLosses(State),
            NewState = update(State),
            Res = formatState(NewState),
            io:format("~p~n",[Res]),
            From ! back,
            gameManager(NewState)
    end.



refreshTimer (Pid) ->
    %Step needs to be an integer!
    io:format("Refresh ativo ~n"),
    FramesPerSecond = 40,
    Step = 1000/FramesPerSecond,
    Pid ! {refresh, 5},
    timer:send_after( Step, Pid, {refresh, self()} ),
    receive
        back ->
            refreshTimer(Pid)
    end
    .



updateWithKeyPress(State, KeyPressed, From) ->
    {{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize } = State,

    if
        From == PID_P1 ->
            if
                KeyPressed == "w" -> NewPlayer = accelerateForward(P1);
                KeyPressed == "a" -> NewPlayer = turnLeft(P1);
                KeyPressed == "d" -> NewPlayer = turnRight(P1)
            end,
            update({{NewPlayer, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize });
        From == PID_P2 ->
            if
                KeyPressed == "w" -> NewPlayer = accelerateForward(P2);
                KeyPressed == "a" -> NewPlayer = turnLeft(P2);
                KeyPressed == "d" -> NewPlayer = turnRight(P2)
            end,
            update({{P1, {U1,PID_P1}}, {NewPlayer, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize });
        true ->
            io:format("Unkown id ~p in updateWithKeyPress", [From]),
            update({{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize })
    end.



checkLosses(State) ->
    %% Determines if a player if lost
    %% Which means determining if a player as touched a red creature,
    %% or if a player as gone outside the board
    %% returns a pair where the first element is a boolean value saying if someon loss
    %% the second value is the id of the player o lost.
    %% if no player lost then the second value is `none`
    %% eg.: {true, PlayerID}, or {false, none}. Where PlayerID is some value that represents the player
    {{P1, ID_P1}, {P2, ID_P2}, _, RedCreatures, ArenaSize} = State,
    { HasColisions, PlayerColidedID } = checkRedColisions({P1, ID_P1}, {P2, ID_P2}, RedCreatures),
    { WentOutsideBoard, PlayerOutsideID} = checkOutsideArena({P1, ID_P1}, {P2, ID_P2}, ArenaSize),
    if
        HasColisions == true -> {true, PlayerColidedID};
        WentOutsideBoard == true -> {true, PlayerOutsideID};
        true -> {false, none}
    end.



update(State) ->
    {{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize} = State,
    {Green1, Green2} = GreenCreatures,

    % Update Players
    GreenColisions_P1 = checkGreenColisions(P1, GreenCreatures),
    GreenColisions_P2 = checkGreenColisions(P2, GreenCreatures),
    {NewP1, NewP2} = updatePlayers(P1, P2, GreenColisions_P1, GreenColisions_P2),

    % Update Green Creatures
    Green1Colided = checkColision(P1, Green1) or checkColision(P2, Green1),
    Green2Colided = checkColision(P1, Green2) or checkColision(P2, Green2),
    if
        Green1Colided == true -> NewGreen1 = newCreature(g);
        true -> NewGreen1 = updateCreature(Green1, P1, P2)
    end,
    if
        Green2Colided == true -> NewGreen2 = newCreature(g);
        true -> NewGreen2 = updateCreature(Green2, P1, P2)
    end,
    NewGreenCreatures = { NewGreen1, NewGreen2 },

    % Update Red Creatures
    NewRedCreatures = updateCreaturesList(RedCreatures, P1, P2),

    % Return New State
    { {NewP1, {U1,PID_P1}}, {NewP2,{U2,PID_P2}}, NewGreenCreatures, NewRedCreatures, ArenaSize }.



checkGreenColisions( Player, GreenCreatures ) ->
    {Creature1, Creature2} = GreenCreatures,
    Colided1 = checkColision(Player, Creature1),
    Colided2 = checkColision(Player, Creature2),
    if
        Colided1 and Colided2 -> 2;
        Colided1 and not Colided2 -> 1;
        not Colided1 and Colided2 -> 1;
        true -> 0
    end.



checkOutsideArena(P1, P2, ArenaSize) ->
    {{P1Position, _, _, _, _, _, _, _, _, _, _, _}, ID_P1} = P1,
    {{P2Position, _, _, _, _, _, _, _, _, _, _, _}, ID_P2} = P2,
    {ArenaX, ArenaY} = ArenaSize,
    { P1_X, P1_Y } = P1Position,
    { P2_X, P2_Y } = P2Position,
    if
        (P1_X < 0) or (P1_X < ArenaX) or (P1_Y < 0) or (P1_Y < ArenaY) -> {true, ID_P1};
        (P2_X < 0) or (P2_X < ArenaX) or (P2_Y < 0) or (P2_Y < ArenaY) -> {true, ID_P2};
        true -> {false, none}
    end.

formatState(State) ->
    %P1 and P2 contain the Player objects, Player1 and Player 2 contain {Username, UserProcess}
    %"elisio",1,2, 0,0,20,1,2.25,0.55,20,2,0.2,0.1,100;
    % "\n",1,2, 0,0,20,2,2.25,0.55,20,2,0.2,0.1,100;
    % 1;
    % 1,2 0, 3,4, 50, g,1;
    % 1,2, 0,3,4, 50, g,1;
    % 1;
    % 1,2, 0,3,4, 50, g,1;
    { {P1, {Username1, _}, {P2, Username2}, GreenCreatures, RedCreatures, Size}} = State,
    User1 = formatPlayer(P1, Username1),
    User2 = formatPlayer(P2, Username2),

    F = fun(Elem, Accum) ->
        if
            Accum == "" ->
                Elem;
            true ->
                Accum ++ ";" ++ Elem
        end
    end,

    GreenCreaturesLen = length(GreenCreatures),
    GreenCreaturesAux = [formatCreatures(Creature) || Creature <- GreenCreatures],
    GreenCreaturesData = lists:foldl(F, "", GreenCreaturesAux),

    RedCreaturesLen = length(RedCreatures),
    RedCreaturesAux = [formatCreatures(Creature) || Creature <- RedCreatures],
    RedCreaturesData = lists:foldl(F, "", RedCreaturesAux),

    Result = User1 ++ ";" ++
             User2 ++ ";" ++
             integer_to_list(GreenCreaturesLen) ++ ";" ++
             GreenCreaturesData ++ ";" ++
             integer_to_list(RedCreaturesLen) ++ ";" ++
             RedCreaturesData,
    Result.

formatCreatures(Creature) ->
    {{X, Y}, Direction, {Dx, Dy}, Size, Type, Velocity} = Creature,
    Result = integer_to_list(X) ++ "," ++
             integer_to_list(Y) ++ "," ++
             integer_to_list(Direction) ++ "," ++
             integer_to_list(Dx) ++ "," ++
             integer_to_list(Dy) ++ "," ++
             integer_to_list(Size) ++ "," ++
             Type ++ "," ++
             integer_to_list(Velocity),
    Result.

formatPlayer(P1, Username1) ->
    {{P1x, P1y}, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    User1 = Username1 ++ "," ++
            integer_to_list(P1x) ++ "," ++
            integer_to_list(P1y) ++ "," ++
            integer_to_list(P1Direction) ++ "," ++
            integer_to_list(P1Velocity) ++ "," ++
            integer_to_list(P1Energy) ++ "," ++
            integer_to_list(P1Type) ++ "," ++
            integer_to_list(P1FrontAcceleration) ++ "," ++
            integer_to_list(P1AngularVelocity) ++ "," ++
            integer_to_list(P1MaxEnergy) ++ "," ++
            integer_to_list(P1EnergyWaste) ++ "," ++
            integer_to_list(P1EnergyGain) ++ "," ++
            integer_to_list(P1Drag) ++ "," ++
            integer_to_list(P1Size),
    User1.

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [])
    .
