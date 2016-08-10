-- Lua resty module to send email via AWS SES API
-- Author: Jeffry L. <paragasu@gmail.com>
-- Website: github.com/paragasu/lua-resty-aws-email
-- Licence: MIT

local aws_auth = require 'resty.aws_auth'
local request  = require 'requests'
local http     = require 'resty.http'
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
  config.aws_host    = 'email.' .. c.aws_region .. '.amazonaws.com'
  return setmetatable(_M, mt)
end

local inspect = require 'inspect'

-- send email
function _M.send(self, email_to, subject, message)
  config.request_body = {
    ['Action'] = 'SendEmail',
    ['Source'] = email_from,
    ['Destination.ToAddresses.member.1'] = email_to,
    ['Message.Subject.Data']   = subject,
    ['Message.Body.Text.Data'] = message
  }

  local aws = aws_auth:new(config)
  local res = request.post('https://' .. config.aws_host, {
    data = ngx.encode_args(config.request_body),
    headers = {
      ['Content-Type'] = 'application/x-www-form-urlencoded', -- required
      ['Authorization'] = aws:get_authorization_header(),
      ['X-Amz-Date'] = aws:get_date_header()
    }
  })

  local body, err = res.xml() 
  local result = body.xml

  if body.xml == 'SendEmailResponse' then
    return true, body[1][1][1]  -- send
  else
    return false, body[1][3][1]  -- failed
  end

end

return _M
