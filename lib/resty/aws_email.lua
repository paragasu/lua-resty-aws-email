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
  config.aws_secret  = c.aws_secret
  config.aws_region  = c.aws_region
  config.aws_key     = c.aws_key
  config.aws_host    = 'email.' .. c.aws_region .. '.amazonaws.com'
  return setmetatable(_M, mt)
end


-- send email
-- @param email_to string or array recipient email eg hello<hello@world.com> 
--        for multiple email eg {"hello<hello@world.com>", "sumandak<sumandak@tamparuli.com>" }
-- @return bool, info 
function _M:send(email_to, subject, message)
  if not email_to or not _M.check_valid_email(email_to) then 
    return error('Invalid email recipient: ' .. tostring(email_to)) 
  end
  if not subject then return error('Missing required email subject') end
  if not message then return error('Missing required email message') end
  config.request_body = {
    ['Action'] = 'SendEmail',
    ['Source'] = tostring(email_from),
    ['Destination.ToAddresses.member.1'] = tostring(email_to),
    ['Message.Subject.Data']   = subject,
    ['Message.Body.Text.Data'] = message
  }
  -- configure recipien_email
  if type(email_to) == 'table' then
    _M.configure_multiple_recipient(email_to)  
  end

  local aws   = aws_auth:new(config)
  local httpc = http.new()
  local res, err = httpc:request_uri('https://' .. config.aws_host, {
    method = 'POST',
    body   = ngx.encode_args(config.request_body),
    headers = {
      ['Content-Type'] = 'application/x-www-form-urlencoded', -- required
      ['Authorization'] = aws:get_authorization_header(),
      ['X-Amz-Date'] = aws:get_date_header()
    }
  }) 

  if not res then
    return false, err
  else
    local body = xml.load(res.body)     
    if body.xml == 'SendEmailResponse' then
      return true, body[1][1][1]  -- send
    else
      local info  = body[1][3][1]
      ngx.log(ngx.ERR, 'Email sending failed: ' .. info,  i(config.request_body))
      return false, info  -- failed
    end
  end 
end

-- set correct parameter for one or more email
function _M.configure_multiple_recipient(email)
  if type(email) ~= 'table' then return end
  for k, v in ipairs(email) do
    config.request_body['Destination.ToAddresses.member.' .. k] = tostring(v)
  end
end

-- check for valid email
function _M.check_valid_email(email)
  if type(email) == 'string' then return _M.is_email(email) end
  -- assume array
  for k, v in pairs(email) do
    if not _M.is_email(v) then return false end
  end 
  return true
end

-- check if the email's format is valid
function _M.is_email(email)
  local valid = string.match(tostring(email), '^%w+@%w+[%.%w]+$')
  return valid == nil and false or true   
end

return _M
