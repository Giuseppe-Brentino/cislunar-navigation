function removeParameters(dict_name, param)

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

for i= 1:length(param)
    deleteEntry(section,param{i})
end

saveChanges(dictionary)