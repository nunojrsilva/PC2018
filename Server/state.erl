-module (state).
-export ([start/0]).
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

% GAME END


start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, [], [], [], [])
    .

estado(Users_Score, Waiting, TopScoreTimes, TopScoreLevels, GamesUnderGoing) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            io:format("Recebi ready de ~p ~n", [Username]),
            case maps:find(Username, Users_Score) of
                {ok, {_, UserLevel }} -> % Descobrir nivel do User {GamesWon, UserLevel}
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                             estado(Users_Score, Waiting ++ [{Username, UserLevel, UserProcess}], TopScoreTimes, TopScoreLevels, GamesUnderGoing); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            io:format(" Processo adversário de ~p é ~p ~n", [Username, H]),
                            Game = spawn( fun() -> gameManager (newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue}), erlang:timestamp(), self()) end ),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
                            SpawnReds = spawn ( fun() -> addReds(Game) end),
                            UserProcess ! UserProcessQueue  ! {go, Game},
                            NewGame = {Game, Timer, SpawnReds},
                            estado( Users_Score, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopScoreTimes, TopScoreLevels, GamesUnderGoing ++ [NewGame] )
                    end
                ;
                error -> % Se User não existe, inserir no map com stats a zero
                    NewMap = maps:put(Username, {0,1}, Users_Score),
                    UserLevel = 1,
                    case lists:filter( fun ({_, L, _}) -> (L == UserLevel) or (L == UserLevel+1) or (L == UserLevel-1) end, Waiting) of
                        [] ->
                            io:format("Vou por o processo na queue"),
                            estado( NewMap, Waiting ++ [{Username, UserLevel, UserProcess}], TopScoreTimes, TopScoreLevels, GamesUnderGoing); %Adicionar User à queue porque não há ninguém para jogar com ele
                        [H | _] ->
                            {UsernameQueue, LevelQueue, UserProcessQueue}  = H,
                            PidState = self(),
                            Game = spawn( fun() -> gameManager(newState({Username, UserProcess}, {UsernameQueue, UserProcessQueue}), erlang:timestamp(), PidState ) end),
                            Timer = spawn( fun() -> refreshTimer(Game) end),
                            SpawnReds = spawn ( fun() -> addReds(Game) end),
                            UserProcess ! UserProcessQueue ! {go, Game},
                            NewGame = {Game, Timer, SpawnReds},
                            estado( NewMap, Waiting -- [{UsernameQueue, LevelQueue, UserProcessQueue}], TopScoreTimes, TopScoreLevels, GamesUnderGoing ++ [NewGame] )
                    end
            end;

        {gameEnd, Result, FromGame} ->
            io:format("Recebi Game ended ~n"),
            [{GamePid, Timer, SpawnReds}] = lists:filter( fun ({G, _, _}) ->  (G == FromGame) end, GamesUnderGoing),
            Timer ! SpawnReds ! stop,
            {{Winner, Score}, {Loser, Score}} = Result,
            io:format("Result : ~p~n", [Result]),
            %List = maps:to_list(Users_Score),
            %io:format("Valores : ~p~n", [List]),

            % Atualização da Pontuação

            {ok, {GamesWonWinner, WinnerLevel} } = maps:find(Winner, Users_Score),
            {ok, {_, LoserLevel} } = maps:find(Loser, Users_Score),

            NewGamesWonWinner = GamesWonWinner + 1,
            if
                NewGamesWonWinner > WinnerLevel ->
                    NewWinnerLevel = WinnerLevel + 1;
                true ->
                    NewWinnerLevel = WinnerLevel
            end,


            % if
            %     Score1 > Score2 ->
            %         NewGamesWon1 = GamesWon1 + 1,
            %         NewGamesWon2 = GamesWon2,
            %         NewUserLevel2 = UserLevel2,
            %         if
            %             NewGamesWon1 > UserLevel1 ->
            %                 NewUserLevel1 = UserLevel1 + 1;
            %         true ->
            %             NewUserLevel1 = UserLevel1
            %         end;
            %
            %     true ->
            %         %Score 2 > Score1
            %         NewGamesWon2 = GamesWon2 + 1,
            %         NewGamesWon1 = GamesWon1,
            %         NewUserLevel1 = UserLevel1,
            %         if
            %             NewGamesWon2 > UserLevel2 ->
            %                 NewUserLevel2 = UserLevel2 + 1;
            %         true ->
            %             NewUserLevel2 = UserLevel2
            %         end
            % end,


            %Update Tops
            NewTopScore = updateTop ({Winner, Score}, TopScoreTimes),
            NewTopScore_ = updateTop ({Loser, Score}, NewTopScore),
            NewTopLevel = updateTop ({Winner, NewWinnerLevel}, TopScoreLevels),
            NewTopLevel_ = updateTop ({Loser, LoserLevel}, NewTopLevel),
            NewMap = maps:put( Winner, {NewGamesWonWinner, NewWinnerLevel}, Users_Score),
            %NewMap = maps:put( Username2, {NewGamesWon2, NewUserLevel2}, AuxMap),
            estado (NewMap, Waiting, NewTopScore_, NewTopLevel_, GamesUnderGoing -- [{GamePid, Timer, SpawnReds}])
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
    Key = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
    io:format("Carregou na tecla ~p~n", [Key]),
    Key.


gameManager(State, TimeStarted, PidState)->
    io:format("Game Manager a correr ~n"),
    % Como calcular a pontuação?
    % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    receive
        {keyPressed, Data, From} ->
            io:format("Entrei no keyPressed ~n"),
            KeyPressed = processKeyPressData( Data ),
            { SomeoneLost, WhoLost } = checkLosses(State),
            if
                SomeoneLost ->
                    io:format("Someone Lost~n"),
                    endGame(State, TimeStarted, erlang:timestamp(), WhoLost, PidState); %gameManager(State, TimeStarted); % TODO: handle end game
                true ->
                    io:format("Update with KeyPress~n"),
                    NewState = updateWithKeyPress(State, KeyPressed, From),
                    %Res = formatState(NewState),
                    gameManager(NewState, TimeStarted, PidState)
            end;
        {leave, From} ->
            io:format("Alguem enviou leave"),
            {P1, P2, _, _, _ } = State,
            {_, {User1, Pid1}} = P1,
            {_, {User2, Pid2}} = P2,
            if
                Pid1 == From ->
                    endGame(State, TimeStarted, erlang:timestamp(), {User1, Pid1}, PidState);
                true ->
                    endGame(State, TimeStarted, erlang:timestamp(), {User2, Pid2}, PidState)
            end
            ;
        {refresh, _} ->
            io:format("Entrei no ramo refresh ~n"),
            { SomeoneLost, WhoLost } = checkLosses(State),
            {{_, {_, Pid1}}, {_, {_, Pid2}}, _, _, _} = State,

            if
                SomeoneLost ->
                    io:format("alguem morreu no refresh do gameManager~n"),
                    endGame(State, TimeStarted, erlang:timestamp(), WhoLost, PidState);
                true ->
                    NewState = update(State),
                    Res = formatState(NewState, TimeStarted),
                    io:format("Novo estado : ~p~n",[Res]),
                    Pid1 ! Pid2 ! {line, list_to_binary(Res)},
                    gameManager(NewState, TimeStarted, PidState)
            end
            ;
        {addReds, _} ->
            io:format("Entrei no addReds~n"),
            {P1, P2, GreenCreatures, RedCreatures, ArenaSize } = State,
            io:format("Vou Adicionar uma criatura vermelha~n"),
            Creature = newCreature(r),
            gameManager({P1, P2, GreenCreatures, RedCreatures ++ [Creature], ArenaSize}, TimeStarted, PidState)

    end.

endGame(State, TimeStarted, TimeEnded, WhoLost, PidState) ->
    %Construir as pontuações
    {{_, {U1, Pid1}}, {_, {U2, Pid2}}, _, _, _} = State,
    {LoserUsername, _} = WhoLost,
    Score = (timer:now_diff(TimeEnded, TimeStarted)) / 1000000,
    if
        LoserUsername == U1 ->
            Result = {{U2, Score}, {U1, Score}};
            %Result = {{U1, Score}, {U2, Score + 1}};
        true ->
            %Result = {{U1, Score + 1}, {U2, Score}}
            Result = {{U1, Score}, {U2, Score}}

    end,
    io:format("Enviar mensagem ao estado e aos users~n"),
    Res = formatResult(Result),
    Pid1 ! Pid2 ! {gameEnd, Res},
    PidState ! {gameEnd, Result, self() }.

%Não sei se funciona mas em principio sim , o processo e o mesmo






refreshTimer (Pid) ->
    %Step needs to be an integer!
    io:format("Refresh ativo ~n"),
    %FramesPerSecond = 40,
    %Step = 1000/FramesPerSecond,
    %NumStep = integer_to_float(Step),
    Time = 10,
    receive
        stop ->
            {}
    after
        Time ->
            Pid ! {refresh, self()},
            refreshTimer(Pid)
    end
    .

addReds (Pid) ->
    io:format("Red Ativo ~n"),
    Time = 10000,

    receive
        stop ->
        {}
    after Time ->
            Pid ! {addReds, self()},
            addReds(Pid)
    end
    .

updateTop ({User, Score}, []) -> [{User, Score}];
updateTop ({User, Score}, [ H = {User1, Score1} | T])->
    if
        Score > Score1 ->
            NewList = [{User, Score}, {User1, Score1}],
            Res = NewList ++ T,
            Res;
        true ->
            [H] ++ updateTop({User, Score}, T)
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
        (P1_X < 0) or (P1_X > ArenaX) or (P1_Y < 0) or (P1_Y > ArenaY) -> {true, ID_P1};
        (P2_X < 0) or (P2_X > ArenaX) or (P2_Y < 0) or (P2_Y > ArenaY) -> {true, ID_P2};
        true -> {false, none}
    end.


formatResult({{U1, S1}, {U2, S2}}) ->
    Res = "result,"++ U1 ++ "," ++ float_to_list(S1, [{decimals, 3}] ) ++ "," ++ U2 ++ "," ++ float_to_list(S2, [{decimals, 3}] ) ++ "\n",
    Res.

formatState(State, TimeStarted) ->
    %P1 and P2 contain the Player objects, Player1 and Player 2 contain {Username, UserProcess}
    %"elisio",1,2, 0,0,20,1,2.25,0.55,20,2,0.2,0.1,100;
    % "\n",1,2, 0,0,20,2,2.25,0.55,20,2,0.2,0.1,100;
    % 1;
    % 1,2 0, 3,4, 50, g,1;
    % 1,2, 0,3,4, 50, g,1;
    % 1;
    % 1,2, 0,3,4, 50, g,1;
    { {P1, {Username1, _}}, {P2, {Username2, _}}, GreenCreatures, RedCreatures, _} = State,
    User1 = formatPlayer(P1, Username1),
    User2 = formatPlayer(P2, Username2),
    Score = (timer:now_diff(erlang:timestamp(), TimeStarted)) / 1000000,
    %io:format("User1 : ~p~n",[User1]),

    {Green1, Green2} = GreenCreatures,
    GreenCreaturesLen = 2,
    GreenCreaturesAux = [formatCreatures(Green1), formatCreatures(Green2)],
    GreenCreaturesData = string:join(GreenCreaturesAux, ","),


    %io:format("Green : ~p~n",[GreenCreaturesData]),

    RedCreaturesLen = length(RedCreatures),
    RedCreaturesAux = [formatCreatures(Creature) || Creature <- RedCreatures],
    RedCreaturesData = string:join(RedCreaturesAux, ","),


    %io:format("Red : ~p~n",[RedCreaturesData]),
    % CENA NOVA!!!!!
    Result = "state," ++ float_to_list(Score, [{decimals, 3}]) ++ "," ++ User1 ++ "," ++
             User2 ++ "," ++
             integer_to_list(GreenCreaturesLen) ++ "," ++
             GreenCreaturesData ++ "," ++
             integer_to_list(RedCreaturesLen) ++ "," ++
             RedCreaturesData ++ "\n",
    Result.

formatCreatures(Creature) ->
    {{X, Y}, {DirX, DirY}, {Dx, Dy}, Size, Type, Velocity} = Creature,
    if
        Type == g ->
            StrType = "g";
        true ->
            StrType = "r"
    end,
    Result = float_to_list(X, [{decimals, 3}]) ++ "," ++
             float_to_list(Y, [{decimals, 3}]) ++ "," ++
             float_to_list(DirX, [{decimals, 3}]) ++ "," ++
             float_to_list(DirY, [{decimals, 3}]) ++ "," ++
             float_to_list(Dx, [{decimals, 3}]) ++ "," ++
             float_to_list(Dy, [{decimals, 3}]) ++ "," ++
             float_to_list(Size, [{decimals, 3}]) ++ "," ++
             StrType ++ "," ++
            float_to_list(Velocity, [{decimals, 3}]),
    Result.

formatPlayer(P1, Username1) ->
    {{P1x, P1y}, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    User1 = Username1 ++ "," ++
            float_to_list(P1x, [{decimals, 3}]) ++ "," ++
            float_to_list(P1y, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Direction, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Velocity, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Energy, [{decimals, 3}]) ++ "," ++
            integer_to_list(P1Type) ++ "," ++
            float_to_list(P1FrontAcceleration, [{decimals, 3}]) ++ "," ++
            float_to_list(P1AngularVelocity, [{decimals, 3}]) ++ "," ++
            float_to_list(P1MaxEnergy, [{decimals, 3}]) ++ "," ++
            float_to_list(P1EnergyWaste, [{decimals, 3}]) ++ "," ++
            float_to_list(P1EnergyGain, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Drag, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Size, [{decimals, 3}]),
    User1.
