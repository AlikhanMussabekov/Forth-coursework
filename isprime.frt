: isprime 
	dup 0 < if ." Incorrect argument " else
  		dup 2 < if drop 0 else
			1 >r 
				repeat  
					dup
					( increment div )
					r> 1 + dup >r 
					( check div ) 
					% 0 = 	
				until 
			r> = 
		then
	then
;

: isprime-allot
	isprime
	1 allot 
	dup rot swap 
	! 
;