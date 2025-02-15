function value = getParameters(dict_name, param)

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

value = cell(length(param),1);
for i= 1:length(param)
    entry = getEntry(section, param{i});
    value{i} = getValue(entry);
end