function updateParameters(dict_name, param, value, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update specified parameters in a Simulink data dictionary and optionally 
% propagate changes to other related parameters.
%
% Input:
% dict_name: string - name of the dictionary to modify
% param: nx1 cell - cell array containing the names of the fields to update
% value: nx1 cell - cell array containing the new values for the fields 
%                   listed in param
% varargin: optional - if not present, propagate the changes to the other
%                      dictionary parameters.
%
% Output:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open or create a Simulink data dictionary
dictionary = Simulink.data.dictionary.open(dict_name);

% Get the section of the dictionary for design data
section = getSection(dictionary, 'Design Data');

% Update the specified fields with new values
for i= 1:length(param)
    entry = getEntry(section, param{i});
   setValue(entry, value{i});
end

% Save the changes to the dictionary
saveChanges(dictionary)

% Optionally propagate changes if only 3 input arguments are provided
if nargin==3
    propagateParameters();
end
