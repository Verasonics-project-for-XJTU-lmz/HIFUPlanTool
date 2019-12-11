%% Import data from text file.
function Mode = readDataFile(filename)

l = length(filename);

if l == 0
    filename = uigetfile;
end

    %% Read in text
         formatSpec = '%s%[^\n\r]';
         fileID = fopen(filename,'r');
         dataArray = textscan(fileID, formatSpec, 'ReturnOnError', false);
         fclose(fileID);

    %% Arrange data
    % field name: 
    % F, Pfall, Zmax, Umean, UMAp, yeta, bwx, bwy, bwzx, XPos,YPos,ZxPos, UA, UPH,Pany

         rawData = dataArray{1};

         expression  = '[-]*\d+[\.]{0,1}\d*[eEdD]{0,1}[+-]*\d*';
         ind = [];
         for i=1:size(rawData, 1)        
           result = regexp(rawData{i}, expression , 'match'); 
           if isempty(result)
              ind = [ind,i];
           else       
              rawData{i} = str2double(result{1});
           end
         end

         expression = '\=';
         Mode_temp = struct();
         for i = 1:length(ind)-1  
           fieldname = regexp(rawData{ind(i)},expression,'split');
           Mode_temp.(fieldname{1,1}) = cell2mat(rawData(ind(i)+1:ind(i+1)-1,1))';
         end
         fieldname = regexp(rawData{ind(end)},expression,'split');
         Mode_temp.(fieldname{1,1}) = cell2mat(rawData(ind(end)+1:end,1))';
         Mode = Mode_temp;
end
 

