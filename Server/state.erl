-module (state).
-export ([start/0]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).
-import (timer, [send_after/3]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Lista de users em espera, tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%


estado(Users_Score, Waiting, TopLevels, TopScore) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            io:format("Recebi ready de ~p ~n", [Username]),
            case maps:find(Username, Users_Score) of
                {ok, {_, UserLevel }} -> % Descobrir nivel do User {GamesWon, UserLevel}
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopLevels, TopScore); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            io:format(" Processo adversário de ~p é ~p ~n", [Username, H]),
                            Game = spawn( fun() -> gameManager (newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue})) end ),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
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
                            Game = spawn( fun() -> gameManager(newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue})) end),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
                            UserProcess ! UserProcessQueue ! {go, Game},
                            estado( NewMap, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopLevels, TopScore)
                    end
                end

        % {gameEnd, Result} -> % O que é suposto devolvermos? {Username , Score} TEMOS QUE ACABAR ISTO!
        %     {{Username1, Score1}, {Username2, Score2}} = Result,
        %
        %     % Atualização da Pontuação do User1
        %
        %     {ok, {GamesWon1, UserLevel1} } = maps:find(Username1, Users_Score),
        %     {ok, {GamesWon2, USer}}
        %
        %     if
        %         Score1 > Score2 ->
        %             NewGamesWon1 = GamesWon1 + 1,
        %             if
        %                 NewGamesWon1 > UserLevel1 ->
        %                     NewUserLevel1 = UserLevel1 + 1,
        %             true ->
        %                 NewUserLevel1 = UserLevel1
        %             end
        %
        %         true ->
        %             NewGamesWon1 = GamesWon1,
        %             NewUserLevel1 = UserLevel1
        %     end,
        %     NewMap = maps:put(Username1, {NewGamesWon1, NewUserLevel1}, Users_Score),
        %     estado (NewMap, Waiting, TopLevels, TopScore); % Vale a pena guardar TopLEvels e TopScore?

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

%Player = {Position(vector), Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}
newPlayer(Type) ->
    %Constants
    FrontAcceleration = 2.25,
    AngularVelocity = 0.55,
    MaxEnergy = 20,
    EnergyWaste = 2,
    EnergyGain = 0.2,
    Drag = 0.1,
    Size = 100,
    %Variables
    Position = {1,2},
    Direction = 0,
    Velocity = 0,
    Energy = 20,

    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}.


%Creature = {Position(vector), Direction, DesiredDirection(vector), Size, Type, Velocity}
newCreature(Type) ->
    %Constants
    Velocity = 1,
    %Variables
    Position = {1,2},
    Direction = 0,
    DesiredDirection = {3,4},
    Size = 50,

    {Position, Direction, DesiredDirection, Size, Type, Velocity}.


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

accelerateForward(Player) ->
    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size} = Player,

    if
        Energy >= EnergyWaste ->
            NewVelocity = Velocity + FrontAcceleration,
            NewEnergy   = Energy - EnergyWaste
    end,
    {Position, Direction, NewVelocity, NewEnergy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}.

turnRight(Player) ->
    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size} = Player,

    if
        Energy >= EnergyWaste ->
            NewDirection = Direction + AngularVelocity,
            NewEnergy   = Energy - EnergyWaste
    end,
    {Position, NewDirection, Velocity, NewEnergy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}.

turnLeft(Player) ->
    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size} = Player,

    if
        Energy >= EnergyWaste ->
            NewDirection = Direction - AngularVelocity,
            NewEnergy   = Energy - EnergyWaste
    end,
    {Position, NewDirection, Velocity, NewEnergy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}.

update(State) ->
    {{P1_ID, P1}, {P1_ID, P2}, Creatures, Size} = State,
    {NewP1, NewP2} = updatePlayers(P1, P2, 0, 0),
    NewCreat = updateCreatures(Creatures, NewP1, NewP2),
    {NewP1, NewP2, NewCreat, Size}.


updatePlayers(P1, P2, EnergyToAddP1, EnergyToAddP2) ->
    {P1Position, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    {P2Position, P2Direction, P2Velocity, P2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size} = P2,
    % P1PositionOffset = {0,0},
    % P1EnergyToAdd = 0,
    % P2PositionOffset = {0,0},
    % P2EnergyToAdd = 0,

    Distance = distanceBetween(P1Position, P2Position), %Porque é que precisamos disso?
    VectorP1toP2 = subtractVectors(P1Position, P2Position),
    DirectionVecP1 = multiplyVector({cos(P1Direction) * P1Velocity, sin(P1Direction)* P1Velocity}, Distance),
    DirectionVecP2 = multiplyVector({cos(P2Direction) * P2Velocity, sin(P2Direction)* P2Velocity}, Distance),

    NewP1Position = subtractVectors( VectorP1toP2, addPairs(P1Position, DirectionVecP1)),
    NewP2Position = addPairs(VectorP1toP2, addPairs(P2Position, DirectionVecP2)),

    NewP1Velocity = P1Velocity - P1Drag,
    NewP2Velocity = P2Velocity - P2Drag,

    NewP1Energy = P1Energy + P1EnergyGain + EnergyToAddP1,
    NewP2Energy = P2Energy + P2EnergyGain + EnergyToAddP2,

    {
        {NewP1Position, P1Direction, NewP1Velocity, NewP1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size},
        {NewP2Position, P2Direction, NewP2Velocity, NewP2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size}
    }.


updateCreatures(Creatures, P1, P2) ->
    %lists:map(updateCreature, Creatures).
    [ updateCreature(Creature, P1, P2) || Creature <- Creatures].


updateCreature(Creature, P1, P2) ->
    {Position, Direction, _, Size, Type, Velocity} = Creature,
    {PositionP1, _, _, _, _, _, _, _, _, _, _, _} = P1,
    {PositionP2, _, _, _, _, _, _, _, _, _, _, _} = P2,

    DistanceP1 = distanceBetween(Position, PositionP1),
    DistanceP2 = distanceBetween(Position, PositionP2),

    if
        DistanceP1 < DistanceP2 -> NewDesiredDirection = subtractVectors(Position, PositionP1);
        true -> NewDesiredDirection = subtractVectors(Position, PositionP2)
    end,

    NewDirection = multiplyVector(normalizeVector(halfWayVector(Direction, NewDesiredDirection)), Velocity),
    NewPosition = addPairs(Position, NewDirection),

    {NewPosition, NewDirection, NewDesiredDirection, Size, Type, Velocity}.


multiplyVector(Vector, Mag) ->
    {X,Y} = Vector,
    { Mag * X, Mag * Y}.

normalizeVector(Vector) ->
    {X, Y} = Vector,
    Divisor = sqrt( pow(X,2) + pow(Y,2) ),
    { X/Divisor, Y/Divisor }.

halfWayVector(Vector1, Vector2) ->
    io:fwrite("Argumentos do halfWayVector : ~p",[Vector1]),
    io:fwrite("Argumentos do halfWayVector : ~p",[Vector2]),
    {X1, Y1} = Vector1,
    {X2, Y2} = Vector2,
    { (X1 + X2)/2, (Y1 + Y2)/2}.


addPairs(Pair1, Pair2) ->
    {X1, Y1} = Pair1,
    {X2, Y2} = Pair2,
    {X1 + X2, Y1 + Y2}.

distanceBetween(Pos1, Pos2) ->
    {X1, Y1} = Pos1,
    {X2, Y2} = Pos2,
    sqrt( pow(X1 - X2, 2) + pow(Y1 - Y2, 2)).

subtractVectors(Pos1, Pos2) ->
    {X1, Y1} = Pos1,
    {X2, Y2} = Pos2,
    {X2 - X1, Y2 - Y1}.

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [], #{}, #{})
    .
