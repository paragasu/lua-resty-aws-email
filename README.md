# lua-resty-aws-email
Send email using Amazon Simple Email Service (SES)  API.

# Installation

  #luarocks install lua-resty-aws-email


# Usage
```lua
local aws_auth_config = {
  aws_key = 'AKIDEXAMPLE',
  aws_secret   = "xxxsecret",
  aws_region   = "us-east-1",  
}

local email = require 'resty.aws_email'
local email = email:new(aws_auth_config)
local err, ok = email:send('hello@world.com', 'hello there', 'Sent using AWS Simple Email Service API') 

if not ok then
  ngx.say('Failed to send email')
end
```

# Todo
- Add support for file attachment


# References
[AWS SES API](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/query-interface-requests.html)

