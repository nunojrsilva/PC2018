-module (login_manager).
-export( [start/0, create_account/2, close_account/2, login/2, logout/1, online/0]).


% Paradigma de Actores - usar diversos micro processos para encapsular o estado da nossa aplicação

% Map é um mapa de username -> {password, online} sendo true se está online ou false caso contrário


start () ->
    Pid = spawn ( fun() -> loop ( #{} ) end ),
    register (?MODULE,Pid).

loop(Map) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find (User,Map) of
                error ->
                    From ! {ok,?MODULE},
                    loop ( maps:put(User, {Pass, true}, Map) );
                _ ->
                    From ! {user_exists, ?MODULE},
                    loop (Map)
            end
        ;

        { close_account, User, Pass, From} ->
            case maps:find (User, Map) of
                {ok , {Pass, _ } } ->
                        From ! { ok, ?MODULE},
                        loop ( maps:remove (User,Map) );

                _ ->
                    From ! { invalid, ?MODULE},
                    loop ( Map )
            end
        ;

        {login , User , Pass , From} ->
            case maps:find (User,Map) of
                {ok, {Pass,false}} ->
                    From ! { ok, ?MODULE},
                    loop ( maps:put ( User, {Pass,true}, Map) ) ;
                _ ->
                    From ! { invalid, ?MODULE},
                    loop ( Map )
            end
        ;
        {logout, User , From} ->
            case maps:find (User,Map) of
                {ok, {Pass,true}} ->
                    From ! { ok, ?MODULE},
                    loop ( maps:put ( User, {Pass, false}, Map) );
                _ ->
                    From ! {invalid, ?MODULE},
                    loop ( Map )
            end
        ;
        {online , From} ->
            %io:format("Entrei no online"),
            OnlineList = [ OnlineUser || {OnlineUser, { _, true} } <- maps:to_list(Map)], % Não nos interessa a password
            From ! {OnlineList, ?MODULE},
            loop ( Map )
    end
.

create_account(Username, Passwd) ->
    ?MODULE ! {create_account, Username, Passwd , self()},
    receive
        {Res, ?MODULE} -> Res
    end.


close_account(Username, Passwd) ->
    ?MODULE ! { close_account, Username, Passwd, self() },
    receive
        {Res, ?MODULE} ->
            Res
    end.


login(Username, Passwd) ->
    ?MODULE ! { login, Username, Passwd, self() },
    receive
        {Res, ?MODULE} ->
            Res
    end
.

logout(Username) ->
    ?MODULE ! { logout , Username, self() },
    receive
        {Res, ?MODULE} ->
            Res
    end
.
online() ->
    ?MODULE ! { online, self()},
    receive
        {Res, ?MODULE} ->
            Res
    end
.
