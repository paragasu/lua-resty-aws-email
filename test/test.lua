package.path = package.path .. ";./lib/resty/?.lua"

local i = require 'inspect'
local email = require 'aws_email'

require 'busted.runner'()

describe('Email', function()
  it('Test invalid email', function()
    local res = email.is_email('sumandak@gmail')
    assert.falsy(res)
  end) 

  it('Test valid email', function()
    local res = email.is_email('sumandak@gmail.com')
    assert.is_true(res)
  end) 

  it('Test valid multiple email', function()
    local res = email:is_valid_destination({ "sumandak@gmail.com", "sumandak@tamparuli.com", "ii8@hello10.com" })
    assert.is_true(res)
  end)

  it('Test invalid multiple email', function()
    local res = email:is_valid_destination({ "sumandak@gmail", "sumandak@tamparuli.com", "ii8@hello10.com" })
    assert.is_false(res)
  end)
end)
