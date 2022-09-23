-module(worker).
-export([get_bit_coins/6,loop/0, get_random_string/2]).
-import(string,[concat/2]).
-import(string,[sub_string/3]).

get_bit_coins(K,Start_value,End_value,Times,Pid,CurrentNode) ->
    if 
        Start_value < End_value ->
            RandString = get_random_string(10,"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"),
            Name = concat("Mehul",RandString),
            Binary = crypto:hash(sha256,Name),
            BitcoinBin = [binary:decode_unsigned(Binary)],
            BitcoinStr = binary_to_list(binary:encode_hex(Binary)),
            Sliced = sub_string(BitcoinStr,1,K),
            Check = string:copies("0", K),
            if 
                Sliced =:= Check ->
                    CurrentNode ! {found_bitcoin,Name,BitcoinBin},
                    get_bit_coins(K,Start_value+1,End_value,Times,Pid,CurrentNode);
                true ->
                    get_bit_coins(K,Start_value+1,End_value,Times,Pid,CurrentNode)
            end;
        Start_value >= End_value ->            
            CurrentNode ! {getnewWorker,Pid,CurrentNode},
            loop()
    end,
    get_bit_coins(K,Start_value,End_value,Times,Pid,CurrentNode).

loop() ->
    process_flag(trap_exit, true),
    receive
        {sendnew,K,Start_value,End_value,Times,Pid,CurrentNode} -> get_bit_coins(K,Start_value,End_value,Times,Pid,CurrentNode);
        {_Reason,_Stack} ->  exit(normal)
    end,
    loop().

get_random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).