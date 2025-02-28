function value = getParameters(dict_name, param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve values from a Simulink data dictionary.
%
% Input:
% dict_name: string - name of the dictionary to access
% param: nx1 cell - cell array containing the names of the fields to retrieve
%
% Output:
% value: nx1 cell - cell array containing the values corresponding to 
%                   the requested fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

% Initialize output cell array
value = cell(length(param),1);

% Retrieve data from the dictionary
for i= 1:length(param)
    entry = getEntry(section, param{i});
    value{i} = getValue(entry);
end