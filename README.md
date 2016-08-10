# lua-resty-aws-email
Send email using Amazon Simple Email Service(SES) API.

# Installation

    #luarocks install lua-resty-aws-email


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
local sent, info = email:send('hello@world.com', 'hello there', 'Sent using AWS Simple Email Service API') 

if not sent then
  ngx.say('Failed: ' .. info)
else
  ngx.say('Sent')
```

# Todo
- Add support for file attachment


# References
[AWS SES API](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/query-interface-requests.html)

