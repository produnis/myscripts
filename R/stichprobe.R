survey.categorical.n  <- function(alpha = 0.05, z = 1.96, P = 0.5, N=20000){
	
	Q = 1 - P
	SS = ( (P*Q) / (alpha/z)^2  )
	n = ( (SS*N) / (SS + N - 1) )
	return(n)
}


survey.categorical.meanError <- function(z = 1.96, P = 0.5, N = 20000, n = 377){
	
	Q = 1 - P
	A = ( (n*N) - 1 ) / (N - 1)
	alpha = sqrt( P*Q*(z^2) / A  )
	return(alpha)
}


survey.categorical.conf  <- function(alpha = 0.05, P = 0.5, N = 20000, n = 377){
	
	Q = 1 - P
	A = ( (n*N) - 1 ) / (N - 1)
	z = sqrt( (A*(alpha^2)) / (P*Q) )
	return(z)
}
survey.categorical.conf()



survey.contin.n <- function(z=1.96, sd = 1, item = 1, alpha = 0.03, N = 20000){
	
	if(item!=1){
		sd = item / (item - 1)
	}
	A = ( (z^2) * (sd^2) ) / ( (item * alpha)^2 )
	n = A / (1 + (A/N)) 
	return(n)
}
survey.contin.n(item=5)



survey.contin.meanError <- function(z=1.96, sd = 1, item = 1, n = 263, N = 20000){
	if(item!=1){
		sd = item / (item - 1)
	}
	A = ( (z^2) * (sd^2) ) / ( (item * alpha)^2 )
	alpha = ( sqrt( ( (z^2)*(sd^2) ) / A ) ) / item
	return(alpha)
}
survey.contin.meanError(item=5)


survey.contin.conf <- function(alpha = 0.03, sd = 1, item = 1, n = 263, N = 20000){
	if(item!=1){
		sd = item / (item - 1)
	}
	A = ( (z^2) * (sd^2) ) / ( (item * alpha)^2 )
	z = sqrt( ( A*(item*alpha)^2 ) / (sd^2) )
	return(z)
}
survey.contin.conf(item=5)



