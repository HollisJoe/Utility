num=100;

x=rand(3,num)-0.5;
x(3,:)=x(3,:)+0.5;

R=rotaa(0.10,0.1, -0.1); 
T=rand(3,1);
T=T/norm(T);

x1=x;
x1 = bsxfun(@rdivide,x1, x1(3,:));

x2=R*x;
x2 = bsxfun(@plus,x2, T);
x2 = bsxfun(@rdivide,x2, x2(3,:));


 pose=iterative_2_view(x1(1:2,:), x2(1:2,:), [1:num;1:num], 1:num);
 
 'This is the computed pose'
 pose
 
 'This is the true pose'
 [R T]
 
 