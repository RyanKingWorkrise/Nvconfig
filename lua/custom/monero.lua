local M = {}

function M.get_price()
  local handle = io.popen("curl -s 'https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=usd'")
  if not handle then return "XMR: unavailable" end
  local result = handle:read("*a")
  handle:close()

  local price = result:match('"usd"%s*:%s*([%d%.]+)')
  if price then
    return "Monero (XMR): $" .. price
  else
    return "XMR: unavailable"
  end
end

return M

