function HIFUplan_ms_Method
%Define the master figure size
delete(findobj('tag','HIFUplan'));
evalin('base','clear all');
evalin('base','close all');
panelFont = 12;
%% Main Figure __mf__
mf = figure('Visible','on',...
    'Units','normalized',...
    'Position',[.1,.1,.50,.50],...
    'NumberTitle','off',...
    'MenuBar','none', ...
    'Name','HIFU Plan Tool',...
    'tag','HIFUplan');
%% Mode Load && Reload
Load = uicontrol('parent',mf,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',[0.05 .9 .20 .05],...
    'FontSize', panelFont,...
    'String','Load Mode File',...
    'Callback',@loadMode);

    function loadMode(varargin)
        evalin('base','clear P');
        P = struct([]);
        mainFolder = pwd;
        [FileName,PathName] = uigetfile('*.data','MultiSelect', 'on');
        if PathName == 0 %if the user pressed cancelled, then we exit this callback
            cd(mainFolder);
            return
        else
            if ~iscell(FileName)
                ModeList{1,1} = FileName;
            else
                ModeList = FileName;
            end
            [~,TotalMode] = size(ModeList); %number of mode loaded
            for count = 1:TotalMode
                filename = [PathName,ModeList{1,count}];
                mode = readDataFile(filename);
                mode.filename = ModeList{1,count};
                eval(['P(1).mode', num2str(count),'= mode;']);
            end
            P.TotalMode = count;
            assignin('base','P', P);
            
            %set(Load,'Visible','off');
            set(Load,'Position',[0.20 0.05 0.15 0.05]);
            set(Load,'String','Reload Mode File');
            set(ModeMenu,'Value', 1)
            set(ModeMenu,'String', ModeList)
            set(ModeMenu,'Visible', 'on')
            set(ModeMenuText,'Visible', 'on')
            
            %             mf = findobj(0,'tag','HIFUtool');
            show = ['Number of Mode Files = ',num2str(TotalMode)];
            uicontrol('parent',mf,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.06 .9 .2 .05],...
                'FontSize', panelFont,...
                'String', show);
        end
        cd(mainFolder);
    end
%% Buttons in left part
uicontrol('parent',mf,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',[0.05 0.05 0.15 0.05],...
    'FontSize',panelFont,...
    'Visible','on',...
    'String','Exit',...
    'Callback',@ExitGUI);

    function ExitGUI(varargin)
        delete(findobj('tag','HIFUplan'));
    end

Run = uicontrol('parent',mf,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',[0.05 0.15 0.15 0.05],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String','Execute',...
    'Callback',@RunGUI);

    function RunGUI(varargin)
        evalin('base','VSX');
    end

ModeMenuText = uicontrol('parent',mf,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.05 .85 .3 .05],...
    'FontSize', 12,...
    'String', 'Choose Mode File to Set Parameters',...
    'Visible','off');

ModeMenu = uicontrol('parent',mf,...
    'Style','listbox',...
    'Units','normalized',...
    'Position',[0.07 .55 .3 .3],...
    'FontSize',12,...
    'Visible','off',...
    'Tag','ModeMenu',...
    'Value',1,'Min', 0, 'Max',10,...
    'Callback',@ModeSelect);

    function ModeSelect(varargin)
        set(mf1,'Visible','on');
        set(StageText1,'Visible','on');
        set(Stage,'Visible', 'on');
        set(Stage,'Value',1);
        set(StageSet,'String',"1");
        set(StageSet,'Visible', 'on');
        set(Save,'Visible','on');
        set(SetUp,'Visible','on');
        set(PRFText1,'Visible','off');
        set(PRF1,'Visible','off');
        set(PRFSet1,'Visible','off');
        set(PDText1,'Visible','off');
        set(PD1,'Visible','off')
        set(PDSet1,'Visible','off');
        set(BurstNumText1,'Visible','off');
        set(BurstNum1,'Visible','off');
        set(BurstNumSet1,'Visible','off');
        set(PDSet1,'Visible','off');
        set(PRFText2,'Visible','off');
        set(PRF2,'Visible','off');
        set(PRFSet2,'Visible','off');
        set(PDText2,'Visible','off');
        set(PD2,'Visible','off');
        set(PDSet2,'Visible','off');
        set(BurstNumText2,'Visible','off');
        set(BurstNum2,'Visible','off');
        set(BurstNumSet2,'Visible','off');
        set(BurstNumText3,'Visible','off');
        set(BurstNum3,'Visible','off');
        set(BurstNumSet3,'Visible','off');
        set(OffTimeText,'Visible','off');
        set(OffTime,'Visible','off');
        set(OffTimeSet,'Visible','off');
        
    end
%% Right part __mf1__
mf1 = uipanel('Title','Parameters',...
    'FontSize', panelFont,...
    'TitlePosition', 'centertop',...
    'Position',[0.4,0.02,0.58,0.96],...
    'Visible','off');

pos1 = 0.05;
pos2 = 0.95;
pos3 = 0.45;
pos4 = 0.05;
%% Stage Set
StageText1 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'Position',[pos1, pos2, pos3, pos4],...
    'FontSize', 10,...
    'String', 'Stage Number',...
    'Visible','off');

Stage = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[pos1 pos2-pos4 pos3 pos4],...
    'Visible','off',...
    'Value',1,...
    'Min',1,'Max',2,'SliderStep',[1,1],...
    'Callback',@StageSelect);

    function StageSelect(varargin)
        P = evalin('base','P');
        if P.TotalMode > 1
            set(Stage,'Value',1);
        else
            if Stage.Value >1.5
                set(Stage,'Value',2);
            else
                set(Stage,'Value',1);
            end
        end
        set(StageSet,'String',num2str(Stage.Value));
        set(PRFText1,'Visible','on');
        set(PRF1,'Visible','on');
        set(PRFSet1,'Visible','on');
        set(PDText1,'Visible','on');
        set(PD1,'Visible','on');
        set(PDSet1,'Visible','on');
        set(BurstNumText1,'Visible','on');
        set(BurstNum1,'Visible','on');
        set(BurstNumSet1,'Visible','on');
        set(OffTimeText,'Visible','on');
        set(OffTime,'Visible','on');
        set(OffTimeSet,'Visible','on');
        if P.TotalMode == 1 && Stage.Value == 1
            set(BurstNum2,'Enable','off');
            set(BurstNumText2,'Enable','off');
            set(BurstNumSet2,'Enable','off');
            set(BurstNumText3,'Visible','off');
            set(BurstNum3,'Visible','off');
            set(BurstNumSet3,'Visible','off');
            set(OffTime,'Enable','off');
            set(OffTimeSet,'Enable','off');
            set(OffTimeText,'Enable','off');
        else
            set(BurstNum2,'Enable','on');
            set(BurstNumText2,'Enable','on');
            set(BurstNumSet2,'Enable','on');
            set(OffTime,'Enable','on');
            set(OffTimeSet,'Enable','on');
            set(OffTimeText,'Enable','on');
        end
        if Stage.Value == 1
            set(PRFText2,'Visible','off');
            set(PRF2,'Visible','off');
            set(PRFSet2,'Visible','off');
            set(PDText2,'Visible','off');
            set(PD2,'Visible','off');
            set(PDSet2,'Visible','off');
            set(BurstNumText2,'Visible','on','String','Burst Number for MultiMode (1-3000)');
            set(BurstNum2,'Visible','on','Min',1,'Max',3000,'Value',80);
            set(BurstNumSet2,'Visible','on');
            set(OffTimeText,'Position',[pos1 pos2-9*pos4 pos3 pos4],'String','Off-Time for MultiMode (400-10000 ms)');
            set(OffTime,'Position',[pos1 pos2-10*pos4 pos3 pos4]);
            set(OffTimeSet,'Position',[pos1+pos3/2-0.05 pos2-11*pos4 0.1 pos4]);
        else
            set(PRFText2,'Visible','on');
            set(PRF2,'Visible','on');
            set(PRFSet2,'Visible','on');
            set(PDText2,'Visible','on');
            set(PD2,'Visible','on');
            set(PDSet2,'Visible','on');
            set(BurstNumText2,'Visible','on','String','Burst Number before Off-Time (10-1000)');
            set(BurstNum2,'Visible','on','Min',10,'Max',1000,'Value',200);
            set(BurstNumSet2,'Visible','on');
            set(BurstNumSet2,'String','15');
            set(BurstNumText3,'Visible','on','String','Burst Number after Off-Time (1-35)');
            set(BurstNum3,'Visible','on');
            set(BurstNumSet3,'Visible','on');
            set(OffTimeText,'Position',[pos1 pos2-15*pos4 pos3 pos4],'String','Off-Time (400-10000 ms)');
            set(OffTime,'Position',[pos1  pos2-16*pos4 pos3 pos4]);
            set(OffTimeSet,'Position',[pos1+pos3/2-0.05 pos2-17*pos4 .1 pos4]);
        end
    end

StageSet = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[pos1+pos3/2-0.05 pos2-2*pos4 .1 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(Stage.Value),...
    'Callback',@StageShow);

    function StageShow(varargin)
        Value = round(str2double(StageSet.String));
        if Value ~= Stage.Value
            P = evalin('base','P');
            if P.TotalMode > 1
                set(Stage,'Value',1);
            else
                set(Stage,'Value',Value);
            end
        end
        set(StageSet,'String',num2str(Stage.Value));
        set(PRFText1,'Visible','on');
        set(PRF1,'Visible','on');
        set(PRFSet1,'Visible','on');
        set(PDText1,'Visible','on');
        set(PD1,'Visible','on');
        set(PDSet1,'Visible','on');
        set(BurstNumText1,'Visible','on');
        set(BurstNum1,'Visible','on');
        set(BurstNumSet1,'Visible','on');
        if P.TotalMode == 1 && Value == 1
            set(BurstNum2,'Enable','off');
            set(BurstNumText2,'Enable','off');
            set(BurstNumSet2,'Enable','off');
            set(BurstNumText3,'Visible','off');
            set(BurstNum3,'Visible','off');
            set(BurstNumSet3,'Visible','off');
            set(OffTime,'Enable','off');
            set(OffTimeSet,'Enable','off');
            set(OffTimeText,'Enable','off');
        else
            set(BurstNum2,'Enable','on');
            set(BurstNumText2,'Enable','on');
            set(BurstNumSet2,'Enable','on');
            set(OffTime,'Enable','on');
            set(OffTimeSet,'Enable','on');
            set(OffTimeText,'Enable','on');
        end
        if strcmp(StageSet.String, '1')
            set(PRFText2,'Visible','off');
            set(PRF2,'Visible','off');
            set(PRFSet2,'Visible','off');
            set(PDText2,'Visible','off');
            set(PD2,'Visible','off');
            set(PDSet2,'Visible','off');
            set(BurstNumText2,'Visible','on','String','Burst Number (1-3000)');
            set(BurstNum2,'Visible','on','Min',1,'Max',3000,'Value',500);
            set(BurstNumText3,'Visible','off');
            set(BurstNum3,'Visible','off');
            set(BurstNumSet3,'Visible','off');
            set(OffTimeText,'Position',[pos1 pos2-9*pos4 pos3 pos4],'String','Off-Time for MultiMode (400-10000 ms)');
            set(OffTime,'Position',[pos1 pos2-10*pos4 pos3 pos4]);
            set(OffTimeSet,'Position',[pos1+pos3/2-0.05 pos2-11*pos4 0.1 pos4]);
            set(OffTime,'Enable','off');
            set(OffTimeSet,'Enable','off');
        else
            set(PRFText2,'Visible','on');
            set(PRF2,'Visible','on');
            set(PRFSet2,'Visible','on');
            set(PDText2,'Visible','on');
            set(PD2,'Visible','on');
            set(PDSet2,'Visible','on');
            set(BurstNumText2,'Visible','on','String','Burst Num before Off-Time (10-35)');
            set(BurstNum2,'Visible','on','Min',10,'Max',35,'Value',10);
            set(BurstNumSet2,'String','15');
            set(BurstNumSet2,'Visible','on');
            set(BurstNumText3,'Visible','on','String','Burst Num after Off-Time (1-35)');
            set(BurstNum3,'Visible','on');
            set(BurstNumSet3,'Visible','on');
            set(OffTimeText,'Visible','on');
            set(OffTime,'Visible','on');
            set(OffTimeSet,'Visible','on');
            set(OffTimeText,'Position',[pos1 pos2-15*pos4 pos3 pos4],'String','Off-Time (400-10000 ms)');
            set(OffTime,'Position',[pos1  pos2-16*pos4 pos3 pos4]);
            set(OffTimeSet,'Position',[pos1+pos3/2-0.05 pos2-17*pos4 0.1 pos4]);
        end
    end
%% PRF Set
PRFText1 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'Position',[pos1 pos2-3*pos4 pos3 pos4],...
    'FontSize', 10,...
    'String', 'PRF for Stage One (1~300 Hz)',...
    'Visible','off');

PRF1 = uicontrol('parent',mf1,...
    'Style','Slider',...
    'Units','normalized',...
    'Position',[pos1 pos2-4*pos4 pos3 pos4],...
    'Visible','off',...
    'Value',10,...
    'Min',1,'Max',300,'SliderStep',[0.05,0.15],...
    'Callback',@PRFSelect1);

    function PRFSelect1(varargin)
        Max_PD1 = 1/PRF1.Value * 10e6;
        set(PD1,'Max', Max_PD1);
        set(PRFSet1,'String',num2str(PRF1.Value));
    end

PRFSet1 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[pos1+pos3/2-0.1 pos2-5*pos4 .2 pos4],...
    'FontSize',panelFont,...
    'String',num2str(PRF1.Value),...
    'Visible','off',...
    'Callback',@PRFShow1);

    function PRFShow1(varargin)
        Value = str2double(PRFSet1.String);
        if Value ~= PRF1.Value
            set(PRF1,'Value',Value);
        end
    end

PRFText2 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'Position',[pos1 pos2-9*pos4 pos3 pos4],...
    'FontSize', 10,...
    'String', 'PRF for Stage Two (10~200 Hz)',...
    'Visible','off');

PRF2 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[pos1 pos2-10*pos4 pos3 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'Tag','PRF2',...
    'Value',10,...
    'Min',1,'Max',200,'SliderStep',[0.05,0.15],...
    'Callback',@PRFSelect2);

    function PRFSelect2(varargin)
        set(PRFSet2,'String',num2str(PRF2.Value));
    end

PRFSet2 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[pos1+pos3/2-0.05 pos2-11*pos4 0.1 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(PRF2.Value),...
    'Callback',@PRFShow2);

    function PRFShow2(varargin)
        Value = str2double(PRFSet2.String);
        if Value ~= PRF2.Value
            set(PRF2,'Value',Value);
        end
        
    end
%% PD Set
PDText1 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'Position',[pos1+pos3 pos2-3*pos4 pos3 pos4],...
    'FontSize', 10,...
    'String', 'PD for Stage One (1 us-10 ms)',...
    'Visible','off');

PD1 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[pos1+pos3 pos2-4*pos4 pos3 pos4],...
    'FontSize',14,...
    'Visible','off',...
    'Value',8000,...
    'Min',1,'Max',10000,'SliderStep',[0.01,0.1],...
    'Callback',@PDSelect1);

    function PDSelect1(varargin)
        set(PDSet1,'String',num2str(PD1.Value));
    end

PDSet1 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[pos1+pos3+pos3/2-0.05 pos2-5*pos4 0.1 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(PD1.Value),...
    'Callback',@PDShow1);

    function PDShow1(varargin)
        Value = str2double(PDSet1.String);
        if Value ~= PD1.Value
            set(PD1,'Value',Value);
        end
    end

PDText2 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'Position',[pos1+pos3 pos2-9*pos4 pos3 pos4],...
    'FontSize', 10,...
    'String', 'PD for Stage Two (300us -10 ms)',...
    'Visible','off');

PD2 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[pos1+pos3 pos2-10*pos4 pos3 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'Value',8000,...
    'Min',300,'Max',10000,'SliderStep',[0.05,0.15],...
    'Callback',@PDSelect2);

    function PDSelect2(varargin)
        set(PDSet2,'String',num2str(PD2.Value));
    end

PDSet2 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[pos1+pos3+pos3/2-0.05 pos2-11*pos4 0.1 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(PD2.Value),...
    'Callback',@PDShow2);

    function PDShow2(varargin)
        Value = str2double(PDSet2.String);
        if Value ~= PD2.Value
            set(PD2,'Value',Value);
        end
    end
%% BurstNum Set
BurstNumText1 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'FontSize', 10,...
    'String', 'Burst Number (10-20000)',...
    'Position',[pos1 pos2-6*pos4 pos3 pos4],...
    'Visible','off');

BurstNum1 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'Position',[pos1 pos2-7*pos4 pos3 pos4],...
    'Value',80,...
    'Min',1,'Max',20000,'SliderStep',[0.1,0.2],...
    'Callback',@BurstNumSelecet1);

    function BurstNumSelecet1(varargin)
        set(BurstNumSet1,'String',num2str(BurstNum1.Value));
    end

BurstNumSet1 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(BurstNum1.Value),...
    'Position',[pos1+pos3/2-0.05 pos2-8*pos4 0.1 pos4],...
    'Callback',@BurstNumShow1);

    function BurstNumShow1(varargin)
        Value = round(str2double(BurstNumSet1.String));
        if Value ~= BurstNum1.Value
            set(BurstNum1,'Value',Value);
            set(BurstNumSet1,'String',num2str(Value));
        end
    end

BurstNumText2 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'FontSize', 10,...
    'String', 'Burst Number (1-3000)',...
    'Position',[pos1 pos2-12*pos4 pos3 pos4],...
    'Visible','off');

BurstNum2 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'Position',[pos1 pos2-13*pos4 pos3 pos4],...
    'Value',20,...
    'Min',1,'Max',3000,'SliderStep',[0.01,0.2],...
    'Callback',@BurstNumSelecet2);

    function BurstNumSelecet2(varargin)
        set(BurstNumSet2,'String',num2str(BurstNum2.Value));
    end

BurstNumSet2 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(BurstNum2.Value),...
    'Position',[pos1+pos3/2-0.05 pos2-14*pos4 0.1 pos4],...
    'Callback',@BurstNumShow2);

    function BurstNumShow2(varargin)
        Value = round(str2double(BurstNumSet2.String));
        if Value ~= BurstNum2.Value
            set(BurstNum2,'Value',Value);
            set(BurstNumSet2,'String',num2str(Value));
        end
    end

BurstNumText3 = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'FontSize', 10,...
    'String', 'Burst Number (1-35)',...
    'Position',[pos1+pos3 pos2-12*pos4 pos3 pos4],...
    'Visible','off');

BurstNum3 = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'Tag','OffTime)',...
    'Position',[pos1+pos3 pos2-13*pos4 pos3 pos4],...
    'Value',4,...
    'Min',1,'Max',35,'SliderStep',[0.01,0.2],...
    'Callback',@BurstNumSelecet3);

    function BurstNumSelecet3(varargin)
        set(BurstNumSet3,'String',num2str(BurstNum3.Value));
    end

BurstNumSet3 = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(BurstNum3.Value),...
    'Position',[pos1+pos3+pos3/2-0.05 pos2-14*pos4 0.1 pos4],...
    'Callback',@BurstNumShow3);

    function BurstNumShow3(varargin)
        Value = round(str2double(BurstNumSet3.String));
        if Value ~= BurstNum3.Value
            set(BurstNum3,'Value',Value);
            set(BurstNumSet3,'String',num2str(Value));
        end
    end
%% Off-time Set
OffTimeText = uicontrol('parent',mf1,...
    'Style','text',...
    'Units','normalized',...
    'FontSize', 10,...
    'String', 'Off Time (400 ms-10 s)...',...
    'Visible','off');

OffTime = uicontrol('parent',mf1,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'Value',4500,...
    'Min',400,'Max',10000,'SliderStep',[0.05,0.15],...
    'Callback',@OffTimeSelect);

    function OffTimeSelect(varargin)
        set(OffTimeSet,'String',num2str(OffTime.Value));
    end

OffTimeSet = uicontrol('parent',mf1,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',panelFont,...
    'Visible','off',...
    'String',num2str(OffTime.Value),...
    'Callback',@OffTimeShow);

    function OffTimeShow(varargin)
        Value = round(str2double(OffTimeSet.String));
        if Value ~= OffTime.Value
            set(OffTime,'Value',Value);
        end
    end
%% Generate parameters
Save = uicontrol('parent',mf1,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',[pos1+pos3*1.2 pos2-17*pos4 0.35 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String','Save Parameters',...
    'Callback',@DataSave);

    function DataSave(varargin)
        P = evalin('base','P');
        
        P.StageNum = Stage.Value;
        P.OffTime = OffTime.Value;
        
        if ~isfield(P,'prf1')
            P.prf1 = zeros(1,P.TotalMode);
            P.pd1 = zeros(1,P.TotalMode);
            P.bnum1 = zeros(1,P.TotalMode);
            P.bnum2 = zeros(1,P.TotalMode);
        end
        
        P.prf1(ModeMenu.Value) = PRF1.Value;
        P.pd1(ModeMenu.Value) = PD1.Value;
        P.bnum1(ModeMenu.Value) = BurstNum1.Value;
        P.bnum2(ModeMenu.Value) = BurstNum2.Value;
        
        if Stage.Value > 1
            if ~isfield(P,'prf2')
                P.prf2 = zeros(1,P.TotalMode);
                P.pd2 = zeros(1,P.TotalMode);
                P.bnum3 = zeros(1,P.TotalMode);
            end
            P.prf2(ModeMenu.Value) = PRF2.Value;
            P.pd2(ModeMenu.Value) = PD2.Value;
            P.bnum3(ModeMenu.Value) = BurstNum3.Value;
        end
        assignin('base','P',P);
    end

SetUp = uicontrol('parent',mf1,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',[pos1 pos2-18*pos4-0.03 0.9 pos4],...
    'FontSize',panelFont,...
    'Visible','off',...
    'String','Generate Parameters After All Modes Are Set',...
    'Callback',@SetUpHIFU);

    function SetUpHIFU(varargin)
        P = evalin('base','P');
        set(Run,'Visible','on');
        
        Trans = TransducerInfo;
        if P.TotalMode > 1
            [TW,TX,SeqControl,Event] = SetUpHIFU_MultiMode(P, Trans);
        else
            if P.StageNum > 1
                [TW,TX,SeqControl,Event] = SetUpHIFU_SingleModeTwoStages_TriggerAtFirst(P, Trans);
            else
                [TW,TX,SeqControl,Event] = SetUpHIFU_SingleModeOneStage(P, Trans);
            end
        end
        
        Resource.Parameters.numTransmit = 256;      % number of transmit channels.
        Resource.Parameters.numRcvChannels = 256;   % number of receive channels.
        Resource.Parameters.Connector = [1,2];
        Resource.Parameters.verbose = 2;
        Resource.Parameters.initializeOnly = 0;
        Resource.Parameters.simulateMode = 0;
        Resource.HIFU.externalHifuPwr = 1;
        Resource.HIFU.extPwrComPortID = 'COM3';
        Resource.HIFU.psType = 'QPX600DP';
        
        assignin('base','P',P);
        assignin('base','Trans',Trans);
        assignin('base','TW',TW);
        assignin('base','TX',TX);
        assignin('base','SeqControl',SeqControl);
        assignin('base','Event',Event);
        assignin('base','Resource',Resource);
        assignin('base','filename','HIFUplanData');
        evalin('base', 'save(''MatFiles/HIFUplanData.mat'')');
    end
end
