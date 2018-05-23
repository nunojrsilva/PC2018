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


gameManager(PlayerOne, PlayerTwo)-> % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    %io:fwrite("GameManager ativo entre ~p",[]),
    Creatures = 12,
    Estado = {newPlayer(1), newPlayer(2),  {newCreature(r), newCreature(g)}, {1200,800}},
    io:fwrite("Estado: ~p", [Estado]).




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
    NewCreat = updateCreatures(Creatures),
    {NewP1, NewP2, NewCreat, Size}.

updatePlayers(P1, P2, EnergyToAddP1, EnergyToAddP2) ->
    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size} = P1,
    {EPosition, EDirection, EVelocity, EEnergy, EType, EFrontAcceleration, EAngularVelocity, EMaxEnergy, EEnergyWaste, EEnergyGain, EDrag, ESize} = P2,
    P1PositionOffset = {0,0},
    P1EnergyToAdd = 0,
    P2PositionOffset = {0,0},
    P2EnergyToAdd = 0,

    Distance = distanceBetween(Position, EPosition),
    VectorP1toP2 = subtractVectors(Position, EPosition),
    DirectionVecP1 = {cos(Direction) * Velocity, sin(Direction)* Velocity},
    DirectionVecP2 = {cos(EDirection) * EVelocity, sin(EDirection)* EVelocity},

    Position = addPairs(Position, DirectionVecP1),
    EDirection = addPairs(EPosition, DirectionVecP2),

    Position = subtractVectors(VectorP1toP2, Position),
    EPosition = addPairs(VectorP1toP2, EPosition),

    Velocity = Velocity - Drag,
    EVelocity = EVelocity - EDrag,

    Energy = Energy + EnergyGain + EnergyToAddP1,
    EEnergy = EEnergy + EEnergyGain + EnergyToAddP2,

    {{Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size},
        {EPosition, EDirection, EVelocity, EEnergy, EType, EFrontAcceleration, EAngularVelocity, EMaxEnergy, EEnergyWaste, EEnergyGain, EDrag, ESize}}.


updateCreatures(Creatures) ->
    1.



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
