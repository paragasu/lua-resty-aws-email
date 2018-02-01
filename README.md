# lua-resty-aws-email
Send email using Amazon Simple Email Service(SES) API.

# Installation
```lua
#luarocks install lua-resty-aws-email
```

# API

**:new(aws_email_config)**
- @param table with 
  - aws_key from aws dashboard
  - aws_secret from aws dashboard
  - aws_region aws_region is where the SES account created

**:send(email, subject, body)**  
Send email body as text
- @param email string recipient email
- @param subject string email subject
- @param body string email content

**:send_html(email, subject, body)**  
send email body as html
- @param email string recipient email
- @param subject string email subject
- @param body string email content

# Usage
```lua
local ses = require 'resty.aws_email'

-- value from amazon simple email service dashboard
local aws_auth_config = {
  aws_key = 'AKIDEXAMPLE',
  aws_secret   = "xxxsecret",
  aws_region   = "us-east-1",  
}

local email = ses:new(aws_auth_config)
local res, err = email:send('hello@world.com', 'hello there', 'Sent using AWS Simple Email Service API') 

if not sent then
  ngx.say('Failed: ' .. err)
else
  ngx.say('Sent')
```

# Todo
- Add support for file attachment


# References
[AWS SES API](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/query-interface-requests.html)

