-module (login_manager).
-export( [startLM/0, create_account/2, close_account/2, login/2, logout/1, online/0]).

% Map é um mapa de username -> {password, online} sendo true se está online ou false caso contrário


startLM () ->
    Pid = spawn ( fun() -> loop ( #{} ) end ),
    register (module,Pid).

loop(Map) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find (User,Map) of
                error when User =:= "", Pass =:= "" ->
                    From ! {bad_arguments ,module},
                    loop (Map);
                error ->
                    From ! {ok,module},
                    loop ( maps:put(User, {Pass, true}, Map) );
                _ ->
                    From ! {user_exists, module},
                    loop (Map)
            end
        ;

        { close_account, User, Pass, From} ->
            case maps:find (User, Map) of
                {ok , {Pass, _ } } ->
                        From ! { ok, module},
                        loop ( maps:remove (User,Map) );

                _ ->
                    From ! { invalid, module},
                    loop ( Map )
            end
        ;

        {login , User , Pass , From} ->
            case maps:find (User,Map) of
                {ok, {Pass,false}} ->
                    From ! { ok, module},
                    loop ( maps:put ( User, {Pass,true}, Map) ) ;
                _ ->
                    From ! { invalid, module},
                    loop ( Map )
            end
        ;
        {logout, User , From} ->
            case maps:find (User,Map) of
                {ok, {Pass,true}} ->
                    From ! { ok, module},
                    loop ( maps:put ( User, {Pass, false}, Map) );
                _ ->
                    From ! {invalid, module},
                    loop ( Map )
            end
        ;
        {online , From} ->
            %io:format("Entrei no online"),
            OnlineList = [ OnlineUser || {OnlineUser, { _, true} } <- maps:to_list(Map)], % Não nos interessa a password
            From ! {OnlineList, module},
            loop ( Map )
    end
.

create_account(Username, Passwd) ->
    module ! {create_account, Username, Passwd , self()},
    receive
        {Res, module} -> Res
    end.


close_account(Username, Passwd) ->
    module ! { close_account, Username, Passwd, self() },
    receive
        {Res, module} ->
            Res
    end.


login(Username, Passwd) ->
    module ! { login, Username, Passwd, self() },
    receive
        {Res, module} ->
            Res
    end
.

logout(Username) ->
    module ! { logout , Username, self() },
    receive
        {Res, module} ->
            Res
    end
.
online() ->
    module ! { online, self()},
    receive
        {Res, module} ->
            Res
    end
.
