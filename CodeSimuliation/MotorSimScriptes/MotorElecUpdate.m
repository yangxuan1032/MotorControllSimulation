%% 
% 项目：         PMSM电机模型软件仿真 电力学参数更新
% 创建人：       杨晅
% 创建时间：     2024.11.18
% 版本：         V0.0.1    
% 更新记录：     初版软件发布  
% 2024.11.19    更新电压和电流更新公式
% 2024.12.16    更新电流积分项公式，增加计算步长时间； 
%               将电磁力矩计算公式迁移至电磁学更新方程处
% 2025.05.01    电机电力学建模初步测试成功
%%

function [MotorSimOutput] = MotorElecUpdate(MotorSimInput,Va,Vb,Vc,SimStep)
    MotorSimOutput = MotorSimInput;
    % Voltage Update
    [MotorSimOutput.SimVar.Valpha,MotorSimOutput.SimVar.Vbeta] = ClarkeTransform(Va,Vb,Vc);
    [MotorSimOutput.SimVar.Vd,MotorSimOutput.SimVar.Vq] = ParkTransform(MotorSimOutput.SimVar.Valpha,MotorSimOutput.SimVar.Vbeta,MotorSimOutput.SimVar.ThetaE);
    % Current Update
    MotorSimOutput.SimVar.Id_dot = (MotorSimOutput.SimVar.Vd/MotorSimOutput.Param.Ld)-(MotorSimOutput.Param.Rd*MotorSimOutput.SimVar.Id/MotorSimOutput.Param.Ld)...
        +(MotorSimOutput.SimVar.We*MotorSimOutput.Param.Lq*MotorSimOutput.SimVar.Iq);
    MotorSimOutput.SimVar.Iq_dot = (MotorSimOutput.SimVar.Vq/MotorSimOutput.Param.Lq)-(MotorSimOutput.Param.Rq*MotorSimOutput.SimVar.Iq/MotorSimOutput.Param.Lq)...
        -(MotorSimOutput.SimVar.We*MotorSimOutput.Param.Ld*MotorSimOutput.SimVar.Id) - (MotorSimOutput.SimVar.We*MotorSimOutput.Param.Phim);
    MotorSimOutput.SimVar.Id = MotorSimOutput.SimVar.Id + SimStep*MotorSimOutput.SimVar.Id_dot;
    MotorSimOutput.SimVar.Iq = MotorSimOutput.SimVar.Iq + SimStep*MotorSimOutput.SimVar.Iq_dot;
    % Torque Update
    MotorSimOutput.SimVar.Te = 3*MotorSimOutput.Param.Poles*MotorSimOutput.SimVar.Iq*(MotorSimOutput.Param.Phim - ...
        ((MotorSimOutput.Param.Ld-MotorSimOutput.Param.Lq)*MotorSimOutput.SimVar.Id))/2;
end   
% function [] = MotorElecInput(MotorSim,Va,Vb,Vc)
%     MotorSim.Input.Va = Va;
%     MotorSim.Input.Vb = Vb;
%     MotorSim.Input.Vc = Vc;
% end

function [Value_alpha,Value_beta] = ClarkeTransform(Value_a,Value_b,Value_c)
    Value_alpha = 3*Value_a/2;
    Value_beta = sqrt(3)*(Value_b-Value_c)/2;
end

function [Value_a,Value_b,Value_c] = InvClarkeTransform(Value_alpha,Value_beta)
    Value_a = 2*Value_alpha/3;
    Value_b = sqrt(3)*Value_beta/3 - Value_alpha/3;
    Value_c = -sqrt(3)*Value_beta/3 - Value_alpha/3;
end

function [Value_d,Value_q] = ParkTransform(Value_alpha,Value_beta,Theta)
    Value_d = (Value_alpha*cos(Theta)) + (Value_beta*sin(Theta));
    Value_q = (-Value_alpha*sin(Theta)) + (Value_beta*cos(Theta));
end

function [Value_alpha,Value_beta] = InvParkTransform(Value_d,Value_q,Theta)
    Value_alpha = Value_d*cos(Theta) - Value_q*sin(Theta);
    Value_beta = -Value_d*sin(Theta) + Value_q*cos(Theta);
end

