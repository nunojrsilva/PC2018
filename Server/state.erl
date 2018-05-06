-module (state).
% -export ([function/arity]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Queue de Users em espera , tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure --
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

start() ->
    % Nao sei se será necessária esta funcao, vamos manter just in case
    estado( #{}, queue:new(), #{}, #{}, []) end),
    .



estado(Users_Score, Waiting, TopLevels, TopScore) ->
    receive
        {ready, Username, UserProcess} -> % Se há um user pronto a jogar, temos que ver qual é o seu nivel
            case maps:find(Username, Users_Score) of ->
                {ok, {_, NivelUser}} -> % Descobrir nivel do User
                    case queue:out(Waiting) of
                        {value, UserOnQueue, Q2} ->
                            {UsernameQueue, NivelQueue, QueueUserProcess} = UserOnQueue,
                            if
                                NivelQueue == NivelUser + 1 or NivelUser == NivelQueue + 1 ->
                                    Game = spawn (fun() -> gameManager({Username, UserProcess}, {UserOnQueue,UserProcess})); % É necessário guardar o Pid?

                                true -> % Temos de voltar a procurar na queue, como?? E colocar o user que retiramos novamente na queue


                            end
                        {empty,_ } ->
                            estado(Users_Score, queue:in({Username, NivelUser, UserProcess}, TopLevels, TopScore)) %Adicionar User à queue
                    end
                {empty, _ } -> % Se User não existe, inserir no map com stats a zero






gameManager(PlayerOne, PlayerTwo)-> % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    {Username1, UserProcess1} = PlayerOne,
    {Username2, UserProcess2} = PlayerTwo,
    GameStat = maps:new(),
    {Username1, X, Y, LP, RP, FP} =
    %Criar criaturas
    %Armazenar posiçoes de todos eles
    %Processos que carregam propulsores
