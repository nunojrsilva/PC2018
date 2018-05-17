-module (server).
-export ([start/1]).
-import (login_manager, [start/0,login/2, create_account/2]). %INCOMPLETO
%-import (state,[]). %INCOMPLETO

% Modulo que implementa um servidor para o jogo "Vaga Vermelha"

start (Port) ->
    %Room = spawn( fun() -> room( [] ,#{}) end),
    PidState = spawn ( fun() -> state:start() end), % Quero criar um processo que guarda e gere o estado atual desde que o servidor foi arrancado
    register(state, PidState),
    PidLogin = spawn( fun() -> login_manager:start() end), % Criar processo que se encarrega de guardar os logins e validar passwords
    %spawn( fun() -> start() end),
    register(login_manager, PidLogin ),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock).


acceptor ( LSock )->
    io:format("acceptor ~n"),
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn( fun() -> acceptor( LSock ) end), % Geramos outro aceptor para permitir que outros clientes se possam conectar ao servidor
    authenticator(Sock).

authenticator(Sock) ->
    io:format("authenticator~n"),
    receive
        {tcp, _ , Data}->
            StrData = binary:bin_to_list(Data),
            io:format("Recebi coisas~n"),
            case StrData of

                "*login " ++ Dados ->
                    io:format("Entrei no login ~n"),
                    St = string:tokens(Dados, " "),
                    [U | P] = St,
                    case login(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"Login sucessful\n">>),
                            state ! {ready, self()}, % Avisa o processo state que está pronto
                            gen_tcp:send(Sock, <<"Waiting for the server\n">>),
                            user(Sock, U);
                        invalid ->
                            gen_tcp:send(Sock,<<"Login Error\n">>),
                            authenticator(Sock) % Volta a tentar autenticar-se
                    end
                ;
                "*create_account " ++ Dados ->
                    io:format("Estou a criar conta~n"),
                    St = string:tokens(Dados, " "),
                    [U | P] = St,
                    case create_account(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"ok_create_account\n">>),
                            user(Sock, U);
                        _ ->
                            gen_tcp:send(Sock,<<"invalid username or password\n">>),
                            authenticator(Sock)
                    end
                ;
                _ ->
                    gen_tcp:send(Sock,<<"No match for that option ~n">>),
                    io:format("dados ~p~n",[Data]),
                    authenticator(Sock)
            end
    end
.




user(Sock, Username) ->
    state ! {ready, Username, self()},
    gen_tcp:send(Sock, <<"Waiting for the server\n">>),
    receive % Bloqueia à espera da resposta do servidor
        {go, GameManager, state} ->
            userOnGame(Sock, GameManager) % Entra em modo "game"
    end.

userOnGame(Sock, GameManager) -> % Faz a mediação entre o Cliente e o processo GameManager
    receive
        {line, Data} -> % Recebemos alguma coisa do processo GameManager
            gen_tcp:send(Sock, Data),
            userOnGame(Sock, GameManager);
        {tcp, _, Data} ->
            GameManager ! {line, Data, self()},
            userOnGame(Sock, GameManager);
        {tcp_closed, _} ->
            GameManager ! {leave, self()};
        {tcp_error, _} ->
            GameManager ! {leave, self()}
    end.
