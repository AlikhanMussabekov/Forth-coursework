: concat ( str1 str2 -- str3 )
	( count str3 length ) 
	over count over count 1 + + 
	heap-alloc dup >r 
	dup rot 
	( save str1 len )
	dup count >r 
	( save str1 addr )
	dup >r  
	string-copy 
	( free str1 )
	r> heap-free 
	r> + swap 
	( save str2 addr )
	dup >r 
	string-copy 
	( free str2 )
	r> heap-free 
	r> prints
;