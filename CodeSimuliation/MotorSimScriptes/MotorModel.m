%% 
% 项目：       PMSM电机模型软件仿真
% 创建人：     杨晅
% 创建时间：   2024.11.07
% 版本：       V0.0.1    
% 更新记录：   初版软件发布  
% 2024.11.25    初步完成电力和机械更新函数，但是计算结果存在问题
% 2024.11.27    计算问题为函数中结构体为参数，已修改
%               仿真数据出现超限值，电学和动力学方程存在问题待排查
% 2024.12.23    机械动力学方程的摩擦力模型待更新
% 2024.12.25    查明电机阻尼和阻力相关参数设定过小
% 2025.05.01    电机仿真代码初步测试成功
%%
clear 
close all
clc
%%  电机本体参数
% Machine Parameters
MotorSim.Param.J = 1.03e-3;
MotorSim.Param.Damp = 1e-5;
MotorSim.Param.TFric_Static = 8.59e-2;
MotorSim.Param.TFric = 8.59e-2;
MotorSim.Param.WindFric = 4e-5;
MotorSim.Param.ThetaM_Init = 0;
MotorSim.Param.ThetaE_Init = 0;
MotorSim.Param.Wm_Init = 0;
MotorSim.Param.We_Init = 0;

% Structure Parameters
MotorSim.Param.Solts = 1;
MotorSim.Param.Poles = 4;
% Magnetic Parameters
MotorSim.Param.Phim = 0.0059;
    %待确定永磁体的绕组模型

% Electrical Parameters
MotorSim.Param.RPhase = 0.02861;
MotorSim.Param.LPhase = 1.1269e-4;

MotorSim.Param.Rd = MotorSim.Param.RPhase;
MotorSim.Param.Ld = MotorSim.Param.LPhase/2;
MotorSim.Param.Ldq = 0;

MotorSim.Param.Rq = MotorSim.Param.RPhase;
MotorSim.Param.Lq = MotorSim.Param.LPhase/2;
MotorSim.Param.Lqd = 0;

%%  电机仿真状态变量
% Electrical Varilable
MotorSim.SimVar.Va = 0;
MotorSim.SimVar.Vb = 0;
MotorSim.SimVar.Vc = 0;
MotorSim.SimVar.Valpha = 0;
MotorSim.SimVar.Vbeta = 0;
MotorSim.SimVar.Vd = 0;
MotorSim.SimVar.Vq = 0;
% Current Differential Variable
% MotorSim.SimVar.Ia_dot = 0;
% MotorSim.SimVar.Ib_dot = 0;
% MotorSim.SimVar.Ic_dot = 0;
% MotorSim.SimVar.Ialpha_dot = 0;
% MotorSim.SimVar.Ibeta_dot = 0;
MotorSim.SimVar.Id_dot = 0;
MotorSim.SimVar.Iq_dot = 0;
% Current Variable
% MotorSim.SimVar.Ia = 0;
% MotorSim.SimVar.Ib = 0;
% MotorSim.SimVar.Ic = 0;
% MotorSim.SimVar.Ialpha = 0;
% MotorSim.SimVar.Ibeta = 0;
MotorSim.SimVar.Id = 0;
MotorSim.SimVar.Iq = 0;
% Back Electromotive Force Variable
% MotorSim.SimVar.Ea = 0;
% MotorSim.SimVar.Eb = 0;
% MotorSim.SimVar.Ec = 0;
% MotorSim.SimVar.Ealpha = 0;
% MotorSim.SimVar.Ebeta = 0;
% MotorSim.SimVar.Ed = 0;
% MotorSim.SimVar.Eq = 0;

% Machine Variable
MotorSim.SimVar.Wm_dot = 0;
MotorSim.SimVar.Wm = 0;
MotorSim.SimVar.We = 0;
MotorSim.SimVar.Speed = 0;
MotorSim.SimVar.ThetaM = 0;
MotorSim.SimVar.ThetaE = 0;
MotorSim.SimVar.Te = 0;

% Magentic Variable
% MotorSim.SimVar.Phia = 0;
% MotorSim.SimVar.Phib = 0;
% MotorSim.SimVar.Phic = 0;
% MotorSim.SimVar.Phialpha = 0;
% MotorSim.SimVar.Phibeta = 0;
% MotorSim.SimVar.Phid = 0;
% MotorSim.SimVar.Phiq = 0;

% %%  电机输入参数
% % Electical Variable
% MotorSim.Input.Va = 0; 
% MotorSim.Input.Vb = 0;
% MotorSim.Input.Vc = 0;
% 
% % Machine Variable
% MotorSim.Input.TL = 0;

% %% 电机变量结果参数
% % Voltage Variable
% MotorSim.Output.Vd = 0;
% MotorSim.Output.Vq = 0;
% MotorSim.Output.Valpha = 0;
% MotorSim.Output.Vbeta = 0;
% MotorSim.Output.Va = 0;
% MotorSim.Output.Vb = 0;
% MotorSim.Output.Vc = 0;
% % Current Variable
% MotorSim.Output.Id = 0;
% MotorSim.Output.Iq = 0;
% MotorSim.Output.Ialpha = 0;
% MotorSim.Output.Ibeta = 0;
% MotorSim.Output.Ia = 0;
% MotorSim.Output.Ib = 0;
% MotorSim.Output.Ic = 0;
% % Back Electromotive Force Variable
% MotorSim.Output.Ed = 0;
% MotorSim.Output.Eq = 0;
% MotorSim.Output.Ealpha = 0;
% MotorSim.Output.Ebeta = 0;
% MotorSim.Output.Ea = 0;
% MotorSim.Output.Eb = 0;
% MotorSim.Output.Ec = 0;
% 
% % Magnetic Variable
% MotorSim.Output.Phid = 0;
% MotorSim.Output.Phiq = 0;
% MotorSim.Output.Phialpha = 0;
% MotorSim.Output.Phibeta = 0;
% MotorSim.Output.Phia = 0;
% MotorSim.Output.Phib = 0;
% MotorSim.Output.Phic = 0;

%%  Main
SimStep = 5e-5;
w = 2*pi*10;
t = 0:SimStep:1e1;
PhaseMove = pi/2;
SimIn.Va = 1*cos(w*t+(PhaseMove));
SimIn.Vb = 1*cos(w*t-(2*pi/3)+(PhaseMove));
SimIn.Vc = 1*cos(w*t-(4*pi/3)+(PhaseMove));

SimRes.Elec_Valpha = zeros(1,length(t));
SimRes.Elec_Vbeta = zeros(1,length(t));
SimRes.Elec_Vd = zeros(1,length(t));
SimRes.Elec_Vq = zeros(1,length(t));
SimRes.Elec_Id_dot = zeros(1,length(t));
SimRes.Elec_Iq_dot = zeros(1,length(t));
SimRes.Elec_Id = zeros(1,length(t));
SimRes.Elec_Iq = zeros(1,length(t));
SimRes.Elec_Te = zeros(1,length(t));

SimRes.Machine_Wm_dot= zeros(1,length(t));
SimRes.Machine_Wm = zeros(1,length(t));
SimRes.Machine_We = zeros(1,length(t));
SimRes.Machine_Thetam = zeros(1,length(t));
SimRes.Machine_Thetae = zeros(1,length(t));

MotorParamInit(MotorSim);
 
for i = 1:length(t)

    % SimIn.Va(i) = 1*cos(MotorSim.SimVar.ThetaE+(PhaseMove));
    % SimIn.Vb(i) = 1*cos(MotorSim.SimVar.ThetaE-(2*pi/3)+(PhaseMove));
    % SimIn.Vc(i) = 1*cos(MotorSim.SimVar.ThetaE-(4*pi/3)+(PhaseMove));

    MotorSim = MotorElecUpdate(MotorSim,SimIn.Va(i),SimIn.Vb(i),SimIn.Vc(i),SimStep);
    MotorSim = MotorMachineUpdate(MotorSim,SimStep);

    SimRes.Elec_Valpha(i) = MotorSim.SimVar.Valpha;
    SimRes.Elec_Vbeta(i) = MotorSim.SimVar.Vbeta;
    SimRes.Elec_Vd(i) = MotorSim.SimVar.Vd;
    SimRes.Elec_Vq(i) = MotorSim.SimVar.Vq;
    SimRes.Elec_Id_dot(i) = MotorSim.SimVar.Id_dot;
    SimRes.Elec_Iq_dot(i) = MotorSim.SimVar.Iq_dot;
    SimRes.Elec_Id(i) = MotorSim.SimVar.Id;
    SimRes.Elec_Iq(i) = MotorSim.SimVar.Iq;
    SimRes.Elec_Te(i) = MotorSim.SimVar.Te;

    SimRes.Machine_Wm_dot(i) = MotorSim.SimVar.Wm_dot;
    SimRes.Machine_Wm(i) = MotorSim.SimVar.Wm;
    SimRes.Machine_We(i) = MotorSim.SimVar.We;
    SimRes.Machine_Thetam(i) = MotorSim.SimVar.ThetaM;
    SimRes.Machine_Thetae(i) = MotorSim.SimVar.ThetaE;
    i/length(t)
end

%%
figure(1);
subplot(2,2,1);
plot(SimIn.Va);
title('Va');
subplot(2,2,2);
plot(SimIn.Vb);
title('Vb');
subplot(2,2,3);
plot(SimIn.Vc);
title('Vc');

figure(2);
subplot(2,2,1);
plot(SimRes.Elec_Valpha);
title('Valpha');
subplot(2,2,2);
plot(SimRes.Elec_Vbeta);
title('Vbeta');
subplot(2,2,3);
plot(SimRes.Elec_Vd);
title('Vd');
subplot(2,2,4);
plot(SimRes.Elec_Vq);
title('Vq');

figure(3);
subplot(2,2,1);
plot(SimRes.Elec_Id_dot);
title('Id\_dot');
subplot(2,2,2);
plot(SimRes.Elec_Iq_dot);
title('Iq\_dot');
subplot(2,2,3);
plot(SimRes.Elec_Id);
title('Id');
subplot(2,2,4);
plot(SimRes.Elec_Iq);
title('Iq');

figure(4);
subplot(2,2,1);
plot(SimRes.Machine_Wm);
title('Wm');
subplot(2,2,2);
plot(SimRes.Machine_We);
title('We');
subplot(2,2,3);
plot(SimRes.Machine_Thetam);
title('ThetaM');
subplot(2,2,4);
plot(SimRes.Machine_Thetae);
title('ThetaE');

figure(5)
subplot(1,2,1)
plot(SimRes.Machine_Wm_dot);
title('Wm\_dot');
subplot(1,2,2)
plot(SimRes.Elec_Te);
title('Te');

%%  Function Define
function[] = MotorParamInit(MotorSim)
    MotorSim.SimVar.Wm = MotorSim.Param.Wm_Init;
    MotorSim.SimVar.We = MotorSim.Param.We_Init;
    MotorSim.SimVar.ThetaM = MotorSim.Param.ThetaM_Init;
    MotorSim.SimVar.ThetaE = MotorSim.Param.ThetaE_Init;
end

