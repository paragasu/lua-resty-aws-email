-- Lua resty module to send email via AWS SES API
-- Author: Jeffry L. <paragasu@gmail.com>
-- Website: github.com/paragasu/lua-resty-aws-email
-- Licence: MIT

local i = require 'inspect'
local aws_auth = require 'resty.aws_auth'
local http     = require 'resty.http'
local xml      = require 'xml'
local email_from = ''
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
function _M:new(c)
  if not c then return error('Missing aws ses config') end
  if not c.aws_secret then return error('Missing required aws_secret') end
  if not c.aws_region then return error('Missing required aws_region') end
  if not c.aws_key then return error('Missing required aws_key') end
  if not c.email_from then return error('Need to specify email_from') end
  email_from = c.email_from
  config.aws_secret = c.aws_secret
  config.aws_region = c.aws_region
  config.aws_key  = c.aws_key
  config.aws_host = 'email.' .. c.aws_region .. '.amazonaws.com'
  config.is_html = false
  return setmetatable(_M, mt)
end

function _M.request()
  local aws   = aws_auth:new(config)
  local httpc = http.new()
  local res, err = httpc:request_uri('https://' .. config.aws_host, {
    method = 'POST',
    body = ngx.encode_args(config.request_body),
    ssl_verify = false,
    headers = {
      ['Content-Type'] = 'application/x-www-form-urlencoded', -- required
      ['Authorization'] = aws:get_authorization_header(),
      ['X-Amz-Date'] = aws:get_date_header()
    }
  }) 

  if not res then return nil, err end
  local body = xml.load(res.body)     
  if body.xml == 'SendEmailResponse' then
    return body[1][1][1]  -- success 
  else
    return nil, body[1][3][1] -- failed
  end
end

-- send email
-- @param email_to string or array recipient email eg hello<hello@world.com> 
--        for multiple email eg {"hello<hello@world.com>", "sumandak<sumandak@tamparuli.com>" }
-- @return res, err 
function _M.send(self, email_to, subject, message)
  if not subject then return nil, 'Missing required email subject' end
  if not message then return nil, 'Missing required email message' end
  if not email_to or not self:is_valid_destination(email_to) then return nil, 'Invalid email recipient: ' .. tostring(email_to) end

  config.request_body = {
    ['Action'] = 'SendEmail',
    ['Source'] = tostring(email_from),
    ['Message.Subject.Data'] = subject
  }

  self.set_destination(email_to)
  self.set_message(message)
  return self.request()
end

function _M.send_html(self, email_to, subject, message)
  config.is_html = true
  return self:send(email_to, subject, message)
end

function _M.set_message(message)
  if config.is_html == true then
    config.request_body['Message.Body.Html.Data'] = message
  else
    config.request_body['Message.Body.Text.Data'] = message
  end
end

function _M.set_destination(email)
  if type(email) == 'table' then
    for k, v in ipairs(email) do
      config.request_body['Destination.ToAddresses.member.' .. k] = tostring(v)
    end
  else
    config.request_body['Destination.ToAddresses.member.1'] = tostring(email)
  end
end

function _M.is_email(email)
  return string.match(tostring(email), '^[%w%.]+@%w+%.[%w%.]+$') ~= nil
end

function _M.is_valid_destination(self, email)
  if not email then return false end 
  if type(email) == 'string' then return self.is_email(email) end
  for k, v in pairs(email) do 
    if not self.is_email(v) then return false end 
  end 
  return true
end

return _M
