function [sys,x0,str,ts]=ADRC_1n(t,x,u,flag,RT,h,B01,B02,r)

switch flag
    case 0
        [sys,x0,str,ts]=mdlInitializeSizes(h);
    case 2
        sys=mdlUpdate(t,x,u,RT,h,B01,B02);
    case 3
        sys=mdlOutputs(x,r);
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,h);
    case {1,9}
        sys=[];
    otherwise 
        error(['Unhandled flag=',num2str(flag)]);
end

function [sys,x0,str,ts]=mdlInitializeSizes(h)
    sizes=simsizes;
    sizes.NumContStates=0;
    sizes.NumDiscStates=4;
    sizes.NumOutputs=2;
    sizes.NumInputs=3;
    sizes.DirFeedthrough=1;
    sizes.NumSampleTimes=1;
    sys=simsizes(sizes);
    x0=[0;0;0;0];
    str=[];
    ts=[h 0];
    
function sys=mdlUpdate(t,x,u,RT,h,B01,B02)
    v3=SecondRise(u(1),RT,t);
    v2=x(2)+h*v3;
    v1=x(1)+h*v2;
    
    %sys(2)=x(2)+h*v3;
    %sys(1)=x(1)+h*x(2);     
    
    %fh=fhan(e1,x(2),r0,h);
    %sys(1)=x(1)+h*x(2);
    %sys(2)=x(2)+h*fh;
    
    %%%加速度
    %v3=SecondRise(u(1),RisingTime,t);
    %%速度与位置    
    
    e2=x(3)-u(2);
    z1=x(3)+h*(x(4)-B01*e2+u(3));
    z2=x(4)+h*(-B02*e2);
    
    sys=[v1;v2;z1;z2];

function sys=mdlOutputs(x,r)   
    e3=x(1)-x(3);
    sys(1)=r*e3-x(4);
    sys(2)=x(1);
    
    
function sys=mdlGetTimeOfNextVarHit(t,h)
    sys=t+h;

function f=SecondRise(SP,RT,tt)               %SP是设定值，RT是上升到设定值的时间

if tt<RT/2 && tt>=0
    f=4*SP/RT^2;
elseif tt>=RT/2 && tt<RT
    f=-4*SP/RT^2;
else
    f=0;
end
