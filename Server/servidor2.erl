-module (servidor2).
-export ([server/1]).
-import (login_manager, [start/0,login/2, create_account/2]).

% Modulo em que é necessário fazer login para entrar no chat
% Mensagens aparecem prefixadas pelo username<
% Room possui um array de pids e um map Pid -> Username

server(Port) ->
    Room = spawn( fun() -> room( [] ,#{}) end),
    spawn( fun() -> start() end),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock, Room).


acceptor( LSock, Room)->
    %io:format("acceptor ~n"),
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn( fun() -> acceptor( LSock, Room) end), % Geramos outro aceptor para permitir que outros clientes se possam conectar ao servidor
    authenticator(Sock,Room).

authenticator(Sock,Room) ->
    %io:format("authenticator~n"),
    receive
        {tcp, _ , Data}->
            StrData = binary:bin_to_list(Data),
            %io:format("Recebi coisas~n"),
            case StrData of

                "*login " ++ Dados ->
                    %io:format("Entrei no login ~n"),
                    St = string:tokens(Dados, " "),
                    [U | P] = St,
                    case login(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"Login com sucesso\n">>),
                            Room ! {enter, self()}, % Entra na sala
                            gen_tcp:send(Sock, <<"Entrou na sala de chat\n">>),
                            user(Sock, Room);
                        invalid ->
                            gen_tcp:send(Sock,<<"Login inválido\n">>),
                            authenticator(Sock, Room) % Volta a tentar autenticar-se
                    end
                ;
                "*create_account " ++ Dados ->
                    io:format("Estou a criar conta~n"),
                    St = string:tokens(Dados, " "),
                    [U | P] = St,
                    case create_account(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"ok_create_account\n">>),
                            Room ! {enter, self(),U}, % Ao entrar digo o meu username
                            user(Sock, Room);
                        _ ->
                            gen_tcp:send(Sock,<<"invalid username or password\n">>),
                            authenticator(Sock,Room)
                    end
                ;
                _ ->
                    gen_tcp:send(Sock,<<"Nao fez match com nada ~n">>),
                    io:format("dados ~p~n",[Data]),
                    authenticator(Sock, Room)
            end
    end
.


room(Pids, UsernameMap) ->
    receive
        {enter, Pid, User} ->
            io:format("User ~p entered ~n",[User]),
            room([Pid | Pids], maps:put(Pid, User, UsernameMap));
        {line, Data, PidSender} -> % Recebemos Pid do Sender, traduzimos para username
            case maps:find (PidSender,UsernameMap) of
                error -> % Se há erro
                    PidSender ! error,
                    room (Pids, UsernameMap)
                ;
                {ok, Username} -> % Se há username registado com esse pid como value...
                    io:format("received ~p ~n", [Data]),
                    [Pid ! {line, Data, Username}  || Pid <- Pids, Pid /= PidSender], % Pid != PidSender
                    room(Pids, UsernameMap)
            end
        ;
        {leave, Pid} ->
            io:format("user left ~n",[]),
            room(Pids -- [Pid], UsernameMap)
    end.



%% line Data vem da room, é para ser enviado para o cliente
%% tcp Data vem do cliente, tem de ser enviado para Room
user(Sock, Room) ->
    receive
        {line, Data, User} -> %Acrescentamos prefixo de User à Mensagem
            Aux = User ++ " said: " ++ Data
            gen_tcp:send(Sock, Aux),
            user(Sock, Room);
        {tcp, _, Data} ->
            Room ! {line, Data, self()},
            user(Sock, Room);
        {tcp_closed, _} ->
            Room ! {leave, self()};
        {tcp_error, _} ->
            Room ! {leave, self()}
    end.
