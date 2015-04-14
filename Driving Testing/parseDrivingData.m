function [datastr] = parseDrivingData(datafile)
% PARSEDRIVINGDATA(datafile)
% Input the filename of a driving data file and the output is a structure
% of all of the parsed/processed information

dataFID = fopen(datafile);
% data = [];


datastr = struct([]);
datastr(1).FR_time = [];
datastr(1).FR = [];
datastr(1).FL_time = [];
datastr(1).FL = [];
datastr(1).BR_time = [];
datastr(1).BR = [];
datastr(1).BL_time = [];
datastr(1).BL = [];
datastr(1).pwmL_time = [];
datastr(1).pwmL = [];
datastr(1).pwmR_time = [];
datastr(1).pwmR = [];
datastr(1).deltaFL_time = [];
datastr(1).deltaFL = [];
datastr(1).deltaFR_time = [];
datastr(1).deltaFR = [];
datastr(1).time = [];
datastr(1).DT = [];

dataline = fgetl(dataFID);
dataline_EOT = find(dataline == ' ',1,'first')-1;
dataline_SOD = find(dataline == ' ',1,'last') +3; % Skip to after the '$D'
FR_count = 1;
FRS_count = 1;
FL_count = 1;
FLS_count = 1;
BR_count = 1;
BL_count = 1;
pwmL_count = 1;
pwmR_count = 1;
deltaFL_count = 1;
deltaFR_count = 1;
DT_count = 1;
while dataline ~= -1
%     disp(dataline(8:9))
    if length(dataline) > dataline_SOD
%         disp(dataline)
    switch dataline(dataline_SOD:dataline_SOD+1)
        case 'FR'
            if strcmp(dataline(dataline_SOD+2),'D')
                if strcmp(dataline(dataline_SOD+3),'D')
                    datastr.deltaFR_time(deltaFR_count) = str2double(dataline(1:dataline_EOT));
                    datastr.deltaFR(deltaFR_count) = str2double(dataline(dataline_SOD+5));
                    deltaFR_count = deltaFR_count + 1;
                else
                    datastr.FR_time(FR_count) = str2double(dataline(1:dataline_EOT));
                    datastr.FR(FR_count) = str2double(dataline(dataline_SOD+4:end));
                    FR_count = FR_count+1;
                end
            elseif strcmp(dataline(dataline_SOD+2),'S')
                datastr.FRS_time(FRS_count) = str2double(dataline(1:dataline_EOT));
                datastr.FRS(FRS_count) = str2double(dataline(dataline_SOD+4:end));
                FRS_count = FRS_count+1;
            end
        case 'FL'
            if strcmp(dataline(dataline_SOD+2),'D')
                if strcmp(dataline(dataline_SOD+3),'D')
                    datastr.deltaFL_time(deltaFL_count) = str2double(dataline(1:dataline_EOT));
                    datastr.deltaFL(deltaFL_count) = str2double(dataline(dataline_SOD+5));
                    deltaFL_count = deltaFL_count + 1;
                else
                    datastr.FL_time(FL_count) = str2double(dataline(1:dataline_EOT));
                    datastr.FL(FL_count) = str2double(dataline(dataline_SOD+4:end));
                    FL_count = FL_count+1;
                end
            elseif strcmp(dataline(dataline_SOD+2),'S')
                datastr.FLS_time(FLS_count) = str2double(dataline(1:dataline_EOT));
                datastr.FLS(FLS_count) = str2double(dataline(dataline_SOD+4:end));
                FLS_count = FLS_count+1;
            end
        case 'BR'
            datastr.BR_time(BR_count) = str2double(dataline(1:dataline_EOT));
            datastr.BR(BR_count) = str2double(dataline(dataline_SOD+4:end));
            BR_count = BR_count+1;
        case 'BL'
            datastr.BL_time(BL_count) = str2double(dataline(1:dataline_EOT));
            datastr.BL(BL_count) = str2double(dataline(dataline_SOD+4:end));
            BL_count = BL_count+1;
        case 'pw'
            if strcmp(dataline(dataline_SOD+3),'L')
                datastr.pwmL_time(pwmL_count) = str2double(dataline(1:dataline_EOT));
                datastr.pwmL(pwmL_count) = str2double(dataline(dataline_SOD+5:end));
                pwmL_count = pwmL_count+1;
            elseif strcmp(dataline(dataline_SOD+3),'R')
                datastr.pwmR_time(pwmR_count) = str2double(dataline(1:dataline_EOT));
                datastr.pwmR(pwmR_count) = str2double(dataline(dataline_SOD+5:end));
                pwmR_count = pwmR_count+1;
            end
        case 'T:'
            datastr.DT_time(DT_count) = str2double(dataline(1:dataline_EOT));
            datastr.DT(DT_count) = str2double(dataline(dataline_SOD+2:end));
            DT_count = DT_count + 1;
    end
    end
    dataline = fgetl(dataFID);
    dataline_EOT = find(dataline == ' ',1,'first')- 1;
    dataline_SOD = find(dataline == ' ',1,'last') + 3;
end

fclose(dataFID);

end

