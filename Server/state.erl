-module (state).
-export ([start/0]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).

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


gameManager(PlayerOne, PlayerTwo)-> % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    %io:fwrite("GameManager ativo entre ~p",[]),
    Creatures = 12,
    Estado = {newPlayer(1), newPlayer(2),  [newCreature(g), newCreature(g)], {1200,800}},
    io:fwrite("Estado: ~p", [Estado]).
    %io:fwrite("Estado depois de update: ~p", [update(Estado)])
    





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

update(State) ->
    {P1, P2, Creatures, Size} = State,
    {NewP1, NewP2} = updatePlayers(P1, P2, 0, 0),
    NewCreat = updateCreatures(Creatures, NewP1, NewP2),
    {NewP1, NewP2, NewCreat, Size}.

updatePlayers(P1, P2, EnergyToAddP1, EnergyToAddP2) ->
<<<<<<< HEAD
    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size} = P1,
    {EPosition, EDirection, EVelocity, EEnergy, EType, EFrontAcceleration, EAngularVelocity, EMaxEnergy, EEnergyWaste, EEnergyGain, EDrag, ESize} = P2,
=======
    {P1Position, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    {P2Position, P2Direction, P2Velocity, P2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size} = P2,
    % P1PositionOffset = {0,0},
    % P1EnergyToAdd = 0,
    % P2PositionOffset = {0,0},
    % P2EnergyToAdd = 0,
>>>>>>> 3b1d329ff96b749d6656fe557a369176ce757c39

    Distance = distanceBetween(P1Position, P2Position), %Porque é que precisamos disso?
    VectorP1toP2 = subtractVectors(P1Position, P2Position),
    DirectionVecP1 = {cos(P1Direction) * P1Velocity, sin(P1Direction)* P1Velocity},
    DirectionVecP2 = {cos(P2Direction) * P2Velocity, sin(P2Direction)* P2Velocity},

    NewP1Position = addPairs(P1Position, DirectionVecP1),
    NewP2Position = addPairs(P2Position, DirectionVecP2),

    NewNewP1Position = subtractVectors(VectorP1toP2, NewP1Position),
    NewNewP2Position = addPairs(VectorP1toP2, NewP2Position),

    NewP1Velocity = P1Velocity - P1Drag,
    NewP2Velocity = P2Velocity - P2Drag,

    NewP1Energy = P1Energy + P1EnergyGain + EnergyToAddP1,
    NewP2Energy = P2Energy + P2EnergyGain + EnergyToAddP2,

    {{NewNewP1Position, P1Direction, NewP1Velocity, NewP1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size},
        {NewNewP2Position, P2Direction, NewP2Velocity, NewP2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size}}.


updateCreatures(Creatures, P1, P2) ->
    %lists:map(updateCreature, Creatures).
    [ updateCreature(Creature, P1, P2) || Creature <- Creatures].


updateCreature(Creature, P1, P2) ->
    {Position, Direction, DesiredDirection, Size, Type, Velocity} = Creature,
    {PositionP1, _, _, _, _, _, _, _, _, _, _, _} = P1,
    {PositionP2, _, _, _, _, _, _, _, _, _, _, _} = P2,

    DistanceP1 = distanceBetween(Position, PositionP1),
    DistanceP2 = distanceBetween(Position, PositionP2),

    if
        DistanceP1 < DistanceP2 -> NewDesiredDirection = subtractVectors(Position, PositionP1);
        true -> NewDesiredDirection = subtractVectors(Position, PositionP2)
    end,

    NewDirection = halfWayVector(Direction, NewDesiredDirection),
    NewNewDirection = normalizeVector(NewDirection),
    NewNewNewDirection = multiplyVector(NewNewDirection, Velocity),
    NewPosition = addPairs(Position, NewNewNewDirection),

    {NewPosition, NewNewNewDirection, NewDesiredDirection, Size, Type, Velocity}.


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
