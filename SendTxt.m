function SendTxt(number, carrier, subject, message, figure_h)
%SendTxt Send SMS or MMS message with optional figure images
% SendTxt(NUMBER, CARRIER, MESSAGE) sends an SMS text message to mobile
% phone NUMBER at CARRIER, with content MESSAGE.  CARRIER should be given
% as a string corresponding to a supported carrier as listed in the table
% below.
% 
% SendTxt(NUMBER, CARRIER, SUBJECT, MESSAGE) adds an optional SUBJECT to
% the SMS message.
% 
% SendTxt(NUMBER, CARRIER, SUBJECT, MESSAGE, FIGURE_H) sends an MMS
% message, including optional figure images.  FIGURE_H is an array of
% handles to figures to send.  Any non-figure handles in the array are
% ignored and generate a warning.  If CARRIER does not supply an MMS
% gateway, the figures are discarded and the text portions of the message
% are sent via SMS.
% 
% Supported carrier strings, corresponding carriers, and message types:
% 
%  string  | Carrier          | SMS? | MMS?
%  --------+------------------+------+-----
%  att     | AT&T             | yes  | yes
%  verizon | Verizon Wireless | yes  | yes
% 
% In the MMS form of the command, figures are print()ed to PNG images,
% stored in the system's temporary filesystem.  Image filenames are
% generated with tempname and temporary files are removed after the
% message is sent.
% 
% Examples:
% 
% SendTxt('555-555-5555', 'att', 'Calculation completed.');
% SendTxt('(555) 555-5555', 'verizon', 'Calculation completed.', ...
%   'Don''t forget to retrieve your results!');
% SendTxt('5555555555', 'verizon', 'Calculation completed.', ...
%   'Image of results figure attached.', gcf);
% 
% See also sendmail, gcf, print, tempname.
    
% Copyright 2014 Cameron Fackler
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see
% <http://www.gnu.org/licenses/>.

% Author: Cameron Fackler
% cfackler at gmail dot com
% 
% History:
%  July 9, 2014: Initial version

% lookup table of mobile carriers and SMS/MMS email gateways
% NOTE: if MMS gateway is not available for carrier, specify as []
gateway = struct( ...
    'att', struct('sms', 'txt.att.net', 'mms', 'mms.att.net'), ...
    'verizon', struct('sms', 'vtext.com', 'mms', 'vzwpix.com') ...
    );

% ensure requested carrier is supported
if ~sum(strcmpi(carrier, fieldnames(gateway)))
    error('Unsupported carrier; patches welcome if SMS/MMS gateway is known!');
end

% remove non-numeric characters from number string
number = regexprep(number, '\D', '');

% default to empty attachments list, modify later if figure handle(s) were
% passed
attachments = {};

% default to empty subject if only message given
if nargin < 4
    message = subject;
    subject = '';
end

% include figures as attached images if requested
if (nargin >= 5) && ~isempty(figure_h)
    num_h = length(figure_h);
    
    % only attempt to attach handles pointing to figures
    figure_h = figure_h(ishandle(figure_h));
    valid_h = strcmp('figure', get(figure_h, 'type'));
    
    % warn if invalid handles were passed
    if sum(valid_h) ~= num_h
        warning('Invalid figure handles ignored.');
    end
    
    % convert figures to images to attach to MMS
    for fig = figure_h(valid_h)
        % get unique temporary filename to store figure image
        image_file = [tempname, '.png'];
        
        % "print" figure to PNG image for attachment
        print(fig, '-dpng', image_file);
        
        % add image to list of attachments to send
        attachments = [attachments, image_file]; %#ok<AGROW>
    end
    
    % try to send via MMS
    domain = gateway.(lower(carrier)).mms;
    if isempty(domain)
        warning('Carrier does not support MMS, stripping attachments and sending SMS.');
        delete_temp_files(attachments);
        attachments = {};
    end
end

% send via SMS if no attachments
if isempty(attachments)
    domain = gateway.(lower(carrier)).sms;
end

% send constructed message via email
sendmail([number, '@', domain], subject, message, attachments);

% clean up temporary image files created
delete_temp_files(attachments);

end

% function to delete cell array of files
function delete_temp_files(file_list)
cellfun(@delete, file_list);
end
