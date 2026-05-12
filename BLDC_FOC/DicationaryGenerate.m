 %% 系统仿真参数配置
% 创建人：      杨晅
% 创建时间：    2024.08.20
% 版本：        V0.0.1                    
% 更新记录：       
% 2024.09.29   更新一部分参数读取生成函数
% 2025.01.21    更新Excel数据读取、数据字典生成功能
%%
clear 
close all
clc
Simulink.data.dictionary.closeAll;
%%
ExeclName = "MotorControlData.xlsx";
SheetNames = ["Input","Simulink","Parameter","CodeGenerate"];
% 电机模型类型：1，数学模型；2，物理模型
MotorModelType = 1;

try 
   if(MotorModelType==1)
       save_system('MotorCtrl_FOC_Math.slx');
       fprintf('数学模型保存中\n');
       close_system('MotorCtrl_FOC_Math.slx');
       fprintf('数学模型已关闭\n');
   else
       save_system('MotorCtrl_FOC_Physic.slx');
       fprintf('物理模型保存中\n');
       close_system('MotorCtrl_FOC_Physic.slx');
       fprintf('物理模型已关闭\n');
   end
   Simulink.data.dictionary.closeAll;
   fprintf('数据字典已关闭\n');
catch

end

if(2~=exist('MotorControlData.xlsx','file'))
    error('Can not find excel file! ');
end

CreateVaribale(ExeclName,SheetNames(1));
CreateVaribale(ExeclName,SheetNames(2));
CreateVaribale(ExeclName,SheetNames(3));

clear ExeclName SheetNames;

if(MotorModelType==1)
    delete MotorControlDataDictionary_Math.sldd;
    DataDic = Simulink.data.dictionary.create('MotorControlDataDictionary_Math.sldd');
    importFromBaseWorkspace(DataDic);
    saveChanges(DataDic);
    clear
    open_system("MotorCtrl_FOC_Math.slx");
else
    delete MotorControlDataDictionary_Physic.sldd;
    DataDic = Simulink.data.dictionary.create('MotorControlDataDictionary_Physic.sldd');
    importFromBaseWorkspace(DataDic);
    saveChanges(DataDic);
    clear
    open_system("MotorCtrl_FOC_Physic.slx");
end

%% function Create Simulink Data Dictionary 
function CreateVaribale(filename,sheetname)
    uint8_type = [0,255];
    uint16_type = [0,65535];
    uint32_type = [0,4.2e9];
    int8_type = [-128,127];
    int16_type = [-32768,32767];
    int32_type = [-2.1e9,2.1e9];
    boolean_type = [0,1];
    

    fprintf('正在创建数据%s!\n',sheetname);
    clear raw;
    raw = readcell(filename,'Sheet',sheetname);
    [rawN,~] = size(raw);

    for i = 2:rawN
        name = raw{i,1};
        if(~ismissing(name))
            % Create Simulink Parameter Object
            ParamObj = Simulink.Parameter;
            % Set Simlink Parameter Value
            if(ischar(raw{i,3}))
                ParamObj.Value = str2double(raw{i,3});
            else
                ParamObj.Value = raw{i,3};
            end
            % Set Simlink Parameter Stroage 
            if((raw{i,6} == "Const") || (raw{i,6} == "ConstVolatile"))
                ParamObj.CoderInfo.StorageClass = 'Custom';
                ParamObj.CoderInfo.CustomStorageClass = raw{i,6};
            else
                ParamObj.CoderInfo.StorageClass = raw{i,6};
            end
            ParamObj.CoderInfo.Alias = '';
            ParamObj.CoderInfo.Alignment = -1;
            % Set Simulink Parameter Description
            ParamObj.Description = raw{i,8};
            % Set Simulink Parameter Datatype
            ParamObj.DataType = raw{i,2};
    
            % Set Simulink Parameter Data Max and Min Value
            if(~ismissing(raw{i,4}))
                ParamObj.Min = raw{i,4};
            else 
                switch raw{i,3}
                    case 'uint8'
                        ParamObj.Min = uint8_type(1);
                    case 'uint16'
                        ParamObj.Min = uint16_type(1);
                    case 'uint32'
                        ParamObj.Min = uint32_type(1);
                    case 'int8'
                        ParamObj.Min = int8_type(1);
                    case 'int16'
                        ParamObj.Min = int16_type(1);
                    case 'int32'
                        ParamObj.Min = int32_type(1);
                    case 'boolean'
                        ParamObj.Min = boolean_type(1);
                    case 'double'
                        ParamObj.Min = raw{i,4};
                    case 'single'
                        ParamObj.Min = raw{i,4};
                    otherwise
                        error("Please Input Right Variable Type!\n");
                end
            end
            if(~ismissing(raw{i,5}))
                ParamObj.Max = raw{i,5};
            else 
                switch raw{i,3}
                    case 'uint8'
                        ParamObj.Max = uint8_type(2);
                    case 'uint16'
                        ParamObj.Max = uint16_type(2);
                    case 'uint32'
                        ParamObj.Max = uint32_type(2);
                    case 'int8'
                        ParamObj.Max = int8_type(2);
                    case 'int16'
                        ParamObj.Max = int16_type(2);
                    case 'int32'
                        ParamObj.Max = int32_type(2);
                    case 'boolean'
                        ParamObj.Max = boolean_type(2);
                    case 'double'
                        ParamObj.Max = raw{i,5};
                    case 'single'
                        ParamObj.Max = raw{i,5};
                    otherwise
                        error("Please Input Right Variable Type!\n");
                end
            end

            assignin('base',name,ParamObj);
            clear name ParamObj;
        end
    end
end

% function  createEnmuVaribale(filename)
%     Function running 
% 
%     raw = readcell(filename,'Sheet','枚举变量');
%     [Nraw,~] = size(raw);
%     for i = 1:Nraw
% 
%         if(~ismissing(raw{i,1}))
%             name = raw{i,1};
% 
%             ParamObj = Simulink.data.dictionary.EnumTypeDefinition;
%             ParamObj.AddClassNameToEnumNames = true;
% 
%             removeEnumeral(ParamObj,1);
% 
%             j = i;
%             while(~ismissing(raw{j,3}))
%                 appendEnumeral(ParamObj,raw{j,3},raw{j,4},raw{j,5});
%                 j = j+1;
%             end
% 
%             assignin('base',name,ParamObj);
%             clear ParamObj name;
%         end
%     end
% end

% function createTable(filename,sheetname) 
% 
%     ParamObj = Simulink.Parameter;
%     ParamObj.Value = cell2mat(readcell(filename,'Sheet',sheetname,'Range','D2:D1281'));
%     ParamObj.CoderInfo.StorageClass = 'Custom';
%     ParamObj.COderInfo.CustomStorageClass = 'Const';
%     ParamObj.DataType = 'single';
%     assignin('base','SinCosTable',ParamObj);
%     clear ParamObj;
% end

% function createSimulinkSignal(filename,sheetname)
% 
%     raw = readcell(filename,'Sheet',sheetname);
%     [Nraw,~] = size(raw);
% 
%     for i = 2:Nraw
%         name = raw{i,1};
%         ParamObj = Simulink.Signal;
%         ParamObj.CoderInfo.StorageClass = 'ExportedGlobal';
%         assignin('base',name,ParamObj);
%         clear name ParamObj;
%     end
% end


% function createSimulinkBus(filename,sheetname)
% 
%     raw = readcell(filename,'Sheet',sheetname);
%     [Nraw,~] = size(raw);
%     BusObj = Simulink.Bus;
%     BusObj.Name = 'UserReq';
%     Elems = Simlink.BusElements;
%     for i = 2:Nraw
%         Elems(i).Name = raw{i,1};
%     end
%     assignin('base','UserReq',ParamObj);
%     clear name ParamObj;
% end
