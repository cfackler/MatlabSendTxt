# MATLAB SendTxt

Send SMS and MMS text messages from MATLAB.  Text-only messages are sent via SMS.  Optionally, specified figures are rendered to images and attached to the body of an MMS message.

## Installation

Copy `SendTxt.m` to a location on MATLAB's [search path](http://www.mathworks.com/help/matlab/ref/path.html) (such as the working directory of your script file).  Configure your SMTP settings as described in the next section.

## Configuration

The text messages are sent as emails via a mobile carrier's email SMS or MMS gateways.  Before MATLAB can send emails, it must be configured with connection information for an SMTP server.  These preferences are persistent through MATLAB invocations so they need only be set once.  Note that your email password will be stored in plaintext in the MATLAB preferences; unfortunately this is unavoidable with the design of MATLAB's `sendmail` function.  The following commands will set the required MATLAB preference values:

```matlab
setpref('Internet', 'E_mail', 'username@domain.com');
setpref('Internet', 'SMTP_Username', 'username');
setpref('Internet', 'SMTP_Password', 'password');
setpref('Internet', 'SMTP_Server', 'smtp.domain.com');
```

If you wish to use an SMTP server that requires authentication and a secure connection (such as Gmail's servers), MATLAB must be configured for this case.  Unfortunately, these preferences are not persistent and must be set each time MATLAB is started.  To minimize the incovenience, add the following lines to your [`startup.m`](http://www.mathworks.com/help/matlab/ref/startup.html) file:

```matlab
% SSL connection required for Gmail SMTP servers
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', '465');
clear props;
```

## Usage

In the following, `number` is the recipient's phone number, passed as a string with 10 numeric digits.  (Formats such as '555-555-5555' and '(555) 555-5555' are supported in addition to '5555555555'.)  The carrier for the given mobile phone number is specified by a `carrier` string, as given in the following table:

| `carrier` | Mobile carrier   |
|-----------|------------------|
| 'att'     | AT&T Mobility    |
| 'verizon' | Verizon Wireless |

### Syntax

To send an SMS text message with body `message`,

```matlab
SendTxt(number, carrier, message);
```

To include an optional message `subject`,

```matlab
SendTxt(number, carrier, subject, message);
```

To include images of one or more figure windows (useful for sending the results of a batch computation, for example), specify `figure_h`, an array of handles to the figure windows to send.  Any handles not pointing to valid figure windows are ignored and a warning is generated.  The figures are rendered to temporary PNG files and attached to the body of an MMS message.  Once sent, the temporary files are automatically deleted.

```matlab
SendTxt(number, carrier, subject, message, figure_h);
```

### Examples

```matlab
SendTxt('555-555-5555', 'att', 'Calculation completed.');
SendTxt('(555) 555-5555', 'verizon', 'Calculation completed.', ...
  'Don''t forget to retrieve your results!');
SendTxt('5555555555', 'verizon', 'Calculation completed.', ...
  'Image of results figure attached.', gcf);
```

## License

> Copyright 2014 Cameron Fackler
> 
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
> 
> This program is distributed in the hope that it will be useful, but
> WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> General Public License for more details.
