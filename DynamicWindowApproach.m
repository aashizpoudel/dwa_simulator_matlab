function [u,trajDB]=DynamicWindowApproach(x,model,goal,evalParam,ob,R)
%A function that calculates the input value by DWA

%Dynamic Window[vmin,vmax,ωmin,ωmax] Creation
Vr=CalcDynamicWindow(x,model);
%Evaluation function calculation
evalDB=[];
trajDB=[];
vx_samples = 15;
vth_samples = 10 ;
for vt=linspace(Vr(1),Vr(2),vx_samples)
    for ot=linspace(Vr(3),Vr(4),vth_samples)
        %Trajectory estimation
        [xt,traj]=GenerateTrajectory(x,vt,ot,evalParam(5),model); %evalparam(5) is simtime.
        %Calculation of each evaluation function
        pathCost=CalcPathEval(xt,x,goal);
        obscost=CalcDistEval(xt,ob,R); %obscost
        distance = CalcDistanceEval(xt,goal);
        vel= Vr(2) - vt;
        evalDB=[evalDB;[vt ot pathCost distance obscost vel]];
        trajDB=[trajDB;traj'];     
    end
end 
if isempty(evalDB)
    disp('no path to goal!!');
    u=[0;0];return;
end

%Normalization of each merit function
evalDB=NormalizeEval(evalDB);

%Calculation of final evaluation value
feval=[];
for id=1:length(evalDB(:,1))
    feval=[feval;evalParam(1:4)*evalDB(id,3:6)'];
end
% evalDB=[evalDB feval];

[maxv,ind]=min(feval);%Calculate the index of the input value with the lowest cost value
u=evalDB(ind,1:2)';%Returns an input value with a high evaluation value