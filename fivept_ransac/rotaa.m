function [ r]= rotaa( alpha, beta, gamma)

first=[1 0 0
	0 cos(alpha) sin(alpha)
	0 -1*sin(alpha) cos(alpha)];

second=[cos(beta) 0 -1*sin(beta)
	0 1 0
	sin(beta) 0 cos(beta)];

third=[ cos(gamma) sin(gamma) 0
	-1*sin(gamma) cos(gamma) 0
	0 0 1];

r=first*second*third;

