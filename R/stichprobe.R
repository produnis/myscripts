## SAMPLE SIZE CALCULATION
## WITH GNU R
#--------------------------
# Licence: GPL
# Author:  produnis 2015
#--------------------------


# survey.categorical.n()
# This function throws a minimum sample size (n)
# for a survey with categorical items
# Default options are:
#   alpha = 0.05 (error of means)
#   z = 1.96 (z-value of normal distribution,
#             1.96 -> 95 % Confidence level)
#   P = percentage for answer balance (worst case is 50% = 0.5)
#   N = population size 
survey.categorical.n  <- function(alpha = 0.05, z = 1.96, P = 0.5, N=20000){
	
	Q = 1 - P
	SS = ( (P*Q) / (alpha/z)^2  )
	n = ( (SS*N) / (SS + N - 1) )
	return(n)
}


# survey.categorical.meanError(n)
# This function throws the error of means
# related to a given/achieved sample size (n)
# for a survey with categorical items
# Default options are:
#   n = sample size achieved
#   z = 1.96 (z-value of normal distribution,
#             1.96 -> 95 % Confidence level)
#   P = percentage for answer balance (worst case is 50% = 0.5)
#   N = population size 
survey.categorical.meanError <- function(z = 1.96, P = 0.5, N = 20000, n = 377){
	
	Q = 1 - P
	A = ( (n*N) - 1 ) / (N - 1)
	alpha = sqrt( P*Q*(z^2) / A  )
	return(alpha)
}


# survey.categorical.conf(n)
# This function throws the z-value of 
# the achived confidence level
# related to a given/achieved sample size (n)
# for a survey with categorical items
# Default options are:
#   n = sample size achieved
#   alpha = 0.05 (error of means)
#   P = percentage for answer balance (worst case is 50% = 0.5)
#   N = population size 
survey.categorical.conf  <- function(alpha = 0.05, P = 0.5, N = 20000, n = 377){
	
	Q = 1 - P
	A = ( (n*N) - 1 ) / (N - 1)
	z = sqrt( (A*(alpha^2)) / (P*Q) )
	return(z)
}
survey.categorical.conf()



# survey.contin.n(item=5)
# This function throws a minimum sample size (n)
# for a survey with continoues/scaled items
# Default options are:
#   alpha = 0.05 (error of means)
#   z = 1.96 (z-value of normal distribution,
#             1.96 -> 95 % Confidence level)
#   item = Number of ticks on the scale
#            e.g. a likert scale with 7 options
#            has item=7.  standard deviation is 
#            computed using  item / (item-1)
#          Leave blank for continous data
#
#   sd = standard deviation in population
#        if "item" is set, sd is calculated automatically
#   N = population size 
survey.contin.n <- function(z=1.96, sd = 1, item = 1, alpha = 0.03, N = 20000){
	
	if(item!=1){
		sd = item / (item - 1)
	}
	A = ( (z^2) * (sd^2) ) / ( (item * alpha)^2 )
	n = A / (1 + (A/N)) 
	return(n)
}
survey.contin.n(item=5)


# survey.contin.meanError(item=5,n)
# This function throws the error of means
# related to a given/achieved sample size (n)
# for a survey with continoues/scaled items
# Default options are:
#   z = 1.96 (z-value of normal distribution,
#             1.96 -> 95 % Confidence level)
#   item = 1 Number of ticks on the scale
#              e.g. a likert scale with 7 options
#              has item=7.  standard deviation is 
#              computed using  item / (item-1)
#          Leave blank for continous data
#
#   sd = 1  standard deviation in population
#           if "item" is set, sd is calculated automatically
#   N = population size 
survey.contin.meanError <- function(z=1.96, sd = 1, item = 1, n = 263, N = 20000){
	if(item!=1){
		sd = item / (item - 1)
	}
	A = (n*N)/(N-n)
	alpha = ( sqrt( ( (z^2)*(sd^2) ) / A ) ) / item
	return(alpha)
}
survey.contin.meanError(item=5)


# survey.contin.conf(item=5,n)
# This function throws the z-value of 
# the achived confidence level
# related to a given/achieved sample size (n)
# for a survey with continoues/scaled items
# Default options are:
#   alpha = 0.05 (error of means)
#   item = 1 Number of ticks on the scale
#              e.g. a likert scale with 7 options
#              has item=7.  standard deviation is 
#              computed using  item / (item-1)
#          Leave blank for continous data
#
#   sd = 1  standard deviation in population
#           if "item" is set, sd is calculated automatically
#   N = population size
survey.contin.conf <- function(alpha = 0.03, sd = 1, item = 1, n = 263, N = 20000){
	if(item!=1){
		sd = item / (item - 1)
	}
	A = (n*N)/(N-n)
	z = sqrt( ( A*(item*alpha)^2 ) / (sd^2) )
	return(z)
}
survey.contin.conf(item=5)



