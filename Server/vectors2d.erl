-module(vectors2d).
-export([multiplyVector/2, normalizeVector/1, halfWayVector/2, addPairs/2, distanceBetween/2, subtractVectors/2]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).


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
