-module(players).
-export([newPlayer/1, accelerateForward/1, turnRight/1, turnLeft/1, updatePlayers/4 ]).
-import(vectors2d, [multiplyVector/2, normalizeVector/1, halfWayVector/2, addPairs/2, distanceBetween/2, subtractVectors/2]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).

%Player = {Position(vector), Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}
newPlayer(Type) ->
    %Constants
    FrontAcceleration = 2.25,
    AngularVelocity = 0.55,
    MaxEnergy = 20.0,
    EnergyWaste = 2.0,
    EnergyGain = 0.2,
    Drag = 0.1,
    Size = 100.0,
    %Variables
    Position = {float(rand:uniform(1200)),float(rand:uniform(800))},
    Direction = 0.0,
    Velocity = 1.0,
    Energy = 20.0,

    {Position, Direction, Velocity, Energy, Type, FrontAcceleration, AngularVelocity, MaxEnergy, EnergyWaste, EnergyGain, Drag, Size}.


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



updatePlayers(P1, P2, GreenColisions1, GreenColisions2) ->
    {P1Position, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    {P2Position, P2Direction, P2Velocity, P2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size} = P2,
    % P1PositionOffset = {0,0},
    % P1EnergyToAdd = 0,
    % P2PositionOffset = {0,0},
    % P2EnergyToAdd = 0,

    Distance = distanceBetween(P1Position, P2Position), % Falta ter em conta a força entre players
    VectorP1toP2 = subtractVectors(P1Position, P2Position),
    if
        Distance == 0 -> Divisor = 0.0;
        true          -> Divisor = (1.0/(pow(Distance,2.0)))
    end,

    DirectionVecP1 = multiplyVector({cos(P1Direction), sin(P1Direction)}, P1Velocity),
    DirectionVecP2 = multiplyVector({cos(P2Direction), sin(P2Direction)}, P2Velocity),

    NewP1Position = addPairs( multiplyVector(VectorP1toP2, -Divisor), addPairs(P1Position, DirectionVecP1)),
    NewP2Position = addPairs( multiplyVector(VectorP1toP2, Divisor), addPairs(P2Position, DirectionVecP2)),

    if
        P1Velocity > 0.0 -> NewP1Velocity = P1Velocity - P1Drag;
        true -> NewP1Velocity = 0.0
    end,
    if
        P2Velocity > 0.0 -> NewP2Velocity = P2Velocity - P1Drag;
        true -> NewP2Velocity = 0.0
    end,

    if
        (P1Energy + P1EnergyGain + GreenColisions1) > P1MaxEnergy -> NewP1Energy = P1MaxEnergy;
        true -> NewP1Energy = P1Energy + P1EnergyGain + GreenColisions1
    end,
    if
        (P2Energy + P2EnergyGain + GreenColisions2) > P2MaxEnergy -> NewP2Energy = P2MaxEnergy;
        true -> NewP2Energy = P2Energy + P2EnergyGain + GreenColisions2
    end,


    {
        {NewP1Position, P1Direction, NewP1Velocity, NewP1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size},
        {NewP2Position, P2Direction, NewP2Velocity, NewP2Energy, P2Type, P2FrontAcceleration, P2AngularVelocity, P2MaxEnergy, P2EnergyWaste, P2EnergyGain, P2Drag, P2Size}
    }.
