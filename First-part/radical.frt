include isprime.frt

: radical ( num -- radical )
    dup 1 
    = not 
    ( if num != 1 )
    if
        dup isprime
        ( if isprime )
        not 
        if 
            dup >r
            2 swap 
            2 /
            ( 2 num/2, num )
            swap r>
            ( num/2 2 num )
            1 >r
            ( num/2 2 num, 1 )
            repeat
                ( num/i i num, rad )
                2dup swap
                % 
                ( num/i i num num%i, rad )
                if ( if num % i != 0 )
                    ( num/i i num, rad )
                    over >r
                    rot dup 
                    r> >
                    if ( if num/i is bigger than i )
                        rot next_prime
                        ( num num/i new_i, rad )
                        rot 0 
                    else 
                        1 ( break loop )
                    then
                else
                    ( num/i i num, rad )
                    swap dup
                    ( num/i num i i, rad )
                    r> *
                    ( num/i num i i*rad )
                    >r next_prime 
                    ( num/i num new_i, i*rad )
                    swap 0
                    ( num/i new_i num 0, i*rad )
                then
            until
            drop drop 
            ( i, rad )
            drop r>
            ( rad )
        then
    then 
;

: next_prime ( x -- a )
    ( a - closest isprime num )
    repeat
        ( x )
        1 +
        ( increment x )
        dup isprime 
        ( is increment isprime )
    until
;
