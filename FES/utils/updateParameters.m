function updateParameters(dict_name, param, value, varargin)

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

for i= 1:length(param)
    entry = getEntry(section, param{i});
   setValue(entry, value{i});
end

saveChanges(dictionary)

if nargin==3
    propagateParameters();
end
