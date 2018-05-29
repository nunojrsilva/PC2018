-module(creatures).
-export([newCreature/1, updateCreature/3, checkRedColisions/3, checkColisionsList/2, checkColision/2, updateCreaturesList/3]).
-import(vectors2d, [multiplyVector/2, normalizeVector/1, halfWayVector/2, addPairs/2, distanceBetween/2, subtractVectors/2]).



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


checkRedColisions( Player1, Player2, RedCreatures ) ->
    { P1, ID_P1 } = Player1,
    { P2, ID_P2 } = Player2,
    ColisionsP1 = checkColisionsList(P1, RedCreatures),
    ColisionsP2 = checkColisionsList(P2, RedCreatures),
    if
        ColisionsP1 == true -> {true, ID_P1};
        ColisionsP2 == true -> {true, ID_P2};
        true -> {false, none}
    end.

checkColisionsList( Player, Creatures ) ->
    if
        Creatures == [] -> false;
        true -> 
            [Creature | T ] = Creatures,
            checkColision(Player, Creature) or checkColisionsList(Player, T)
    end.


checkColision( Player, Creature ) ->
    {PlayerPosition, _, _, _, _, _, _, _, _, _, _, PlayerSize} = Player,
    {CreaturePosition, _, _, CreatureSize, _, _} = Creature,

    Distance = distanceBetween(PlayerPosition, CreaturePosition),
    if
        Distance < (PlayerSize/2 + CreatureSize/2) -> true;
        true -> false
    end.

updateCreaturesList(Creatures, P1, P2) ->
    %lists:map(updateCreature, Creatures).
    [ updateCreature(Creature, P1, P2) || Creature <- Creatures].
