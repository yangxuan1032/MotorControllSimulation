%% 
% 项目：       PMSM电机模型软件仿真 机械动力学参数更新
% 创建人：     杨晅
% 创建时间：   2024.11.18
% 版本：       V0.0.1    
% 更新记录：     初版软件发布  
% 2024.11.19    更新机械相关参数更新算法
% 2024.12.16    更新转速积分项公式，增加时间步长；
%               将电磁转矩计算迁移至电力学更新方程中
% 2024.12.18    更新转速加速度计算公式
% 2024.12.30    电机机械动力学存在问题
% 2025.02.25    电机机械动力学中的电机转速加速度应该分类进行讨论，启动、运行、停机三个阶段。
% 2025.05.01    电机机械动力学建模初步测试成功
%%
function  [MotorSimOutput] = MotorMachineUpdate(MotorSimInput,SimStep)
    MotorSimOutput = MotorSimInput;
    TL_Temp = 0;
    if(MotorSimOutput.SimVar.Wm == 0)
       if(MotorSimOutput.SimVar.Te>MotorSimOutput.Param.TFric_Static)
            MotorSimOutput.SimVar.Wm_dot = (MotorSimOutput.SimVar.Te - MotorSimOutput.Param.TFric_Static)/MotorSimOutput.Param.J;
       else
            MotorSimOutput.SimVar.Wm_dot = 0;
       end
    else
        TL_Temp = MotorSimOutput.Param.Damp*abs(MotorSimOutput.SimVar.Wm) + MotorSimOutput.Param.TFric*abs(MotorSimOutput.SimVar.Wm) + MotorSimOutput.Param.WindFric*abs(MotorSimOutput.SimVar.Speed);
        MotorSimOutput.SimVar.Wm_dot = (MotorSimOutput.SimVar.Te - sign(MotorSimOutput.SimVar.Wm)*TL_Temp)/MotorSimOutput.Param.J;
    end
    MotorSimOutput.SimVar.Wm = MotorSimOutput.SimVar.Wm + SimStep*MotorSimOutput.SimVar.Wm_dot;
    MotorSimOutput.SimVar.Speed = MotorSimOutput.SimVar.Wm*30/pi;
    MotorSimOutput.SimVar.ThetaM = mod(MotorSimOutput.SimVar.ThetaM + SimStep*MotorSimOutput.SimVar.Wm,2*pi);
    MotorSimOutput.SimVar.We = MotorSimOutput.Param.Poles*MotorSimOutput.SimVar.Wm;
    MotorSimOutput.SimVar.ThetaE = mod(MotorSimOutput.SimVar.ThetaE + SimStep*MotorSimOutput.SimVar.We,2*pi);
end