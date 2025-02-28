function addParameters(dict_name, param, value)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add new elements to a data dictionary.
%
% Input:
% dict_name: string - name of the dictionary to modify
% param: nx1 cell - cell array containing the names of the new fields
% value: nx1 cell - cell array containing the data of the fields
%                   listed in param
%
% Output:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

% Add data to the dictionary
if length(param)~=length(value)
    error('input sizes do not agree');
else
    for i= 1:length(param)
        addEntry(section,param{i},value{i})
    end
end
% Save changes
saveChanges(dictionary)
