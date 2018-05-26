-module(creatures).
-export([newCreature/1, updateCreature/3]).
-import(vectors2D, [multiplyVector/2, normalizeVector/1, halfWayVector/2, addPairs/2, distanceBetween/2, subtractVectors/2]).



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

