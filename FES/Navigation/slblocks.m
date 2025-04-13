function blkStruct = slblocks
% This function specifies that the library 'mylib'
% should appear in the Library Browser with the 
% name 'My Library'

    Browser.Library = 'nav_lib';
    % 'mylib' is the name of the library

    Browser.Name = 'Navigation library';
    % 'My Library' is the library name that appears
    % in the Library Browser

    blkStruct.Browser = Browser;
