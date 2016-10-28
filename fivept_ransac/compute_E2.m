
function [E] = compute_E2(Q1,Q2)

%   diag( Q1'*E*Q2)=0


Evec   = calibrated_fivepoint( Q1,Q2);

E=zeros(3,3,size(Evec,2));

for i=1:size(Evec,2)
  E(:,:,i) = reshape(Evec(:,i),3,3);

end

