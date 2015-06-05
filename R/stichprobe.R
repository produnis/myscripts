sampleSize <- function(alpha = 0.05, z = 1.96, P = 0.5, N=20000){
	
	Q = 1 - P
	SS = ( (P*Q) / (alpha/z)^2  )
	n = ( (SS*N) / (SS + N - 1) )
	return(n)
}

