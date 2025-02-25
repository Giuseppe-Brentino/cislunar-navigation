function removeParameters(dict_name, param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove specified parameters from a Simulink data dictionary.
%
% Input:
% dict_name: string - name of the dictionary to modify
% param: nx1 cell - cell array containing the names of the fields to remove
%
% Output:
% None 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

% Remove the specified fields from the dictionary
for i= 1:length(param)
    deleteEntry(section,param{i})
end

% Save changes to the dictionary
saveChanges(dictionary)