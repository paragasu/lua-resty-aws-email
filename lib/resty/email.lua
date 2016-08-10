local aws_auth = require 'aws_auth'
local http = require 'requests'
local email_from
local config = {
  aws_service  = 'ses',  
  aws_key      = nil,
  aws_secret   = nil,
  aws_region   = nil,
  aws_host     = nil,
  request_body = nil
}

local _M  = {}
local mt  = { __index = _M }

-- init with table contain required information
-- to generate authorization header
-- aws_key, aws_secret and aws_region
function _M.new(self, c)
  email_from = c.email_from
  config.aws_secret  = c.aws_secret
  config.aws_region  = c.aws_region
  config.aws_key     = c.aws_key
  config.aws_host    = 'https://email.' .. c.aws_region .. '.amazonaws.com'
  return setmetatable(_M, mt)
end


-- send email
function _M.send(self, email_to, subject, message)
  config.request_body = {
    ['Action'] = 'SendEmail',
    ['Source'] = email_from,
    ['Destination.ToAddresses.member.1'] = email_to,
    ['Message.Subject.Data']   = subject
    ['Message.Body.Text.Data'] = message
  }

  local aws = aws_auth:new(config)
  local response = http.post({
    url = aws_host,
    header = {
      ['Content-Type'] = 'application/x-www-form-urlencoded', -- required
      ['Authorization'] = aws:get_authorization_header(),
      ['X-Amz-Date'] = aws:get_date_header()
    }
  })

  local inspect = require 'inspect'
  print(inspect(response))

end

ngx.say('SES done')
