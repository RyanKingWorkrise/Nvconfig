local M = {}

local function curl(url)
  local handle = io.popen("curl -s '" .. url .. "'")
  if not handle then return nil end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function fetch_price(coin)
  local url = "https://api.coingecko.com/api/v3/simple/price?ids=" .. coin .. "&vs_currencies=usd&include_24hr_change=true"
  local data = curl(url)
  if not data then return "N/A" end

  local price = data:match('"usd":([%d%.]+)')
  local change = data:match('"usd_24h_change":([%-%d%.]+)')
  if price then
    local pct = change and string.format(" (%+.2f%%)", tonumber(change)) or ""
    return tonumber(price), pct
  end
  return nil, nil
end

local function fetch_history(coin, days)
  local url = "https://api.coingecko.com/api/v3/coins/" .. coin .. "/market_chart?vs_currency=usd&days=" .. days
  local data = curl(url)
  if not data then return {} end

  local prices = {}
  for p in data:gmatch("%[%d+,(%d+%.?%d*)%]") do
    table.insert(prices, tonumber(p))
  end
  return prices
end

local function pct_change(prices, offset)
  if #prices < offset + 1 then return "N/A" end
  local now = prices[#prices]
  local past = prices[#prices - offset]
  local change = ((now - past) / past) * 100
  return string.format("%+.2f%%", change)
end

local function sparkline(prices, points)
  if #prices == 0 then return "" end
  points = points or 20
  local step = math.floor(#prices / points)
  local sampled = {}
  for i = 1, #prices, step do
    table.insert(sampled, prices[i])
    if #sampled >= points then break end
  end

  local min, max = math.huge, -math.huge
  for _, v in ipairs(sampled) do
    if v < min then min = v end
    if v > max then max = v end
  end

  local blocks = { "▁","▂","▃","▄","▅","▆","▇","█" }
  local graph = {}
  for _, v in ipairs(sampled) do
    local idx = math.floor(((v - min) / (max - min)) * (#blocks - 1)) + 1
    table.insert(graph, blocks[idx])
  end

  return table.concat(graph)
end

function M.open()
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  local lines = { "" }

  for _, coin in ipairs({ "monero", "bitcoin" }) do
    local price, daily = fetch_price(coin)
    local prices = fetch_history(coin, 365)

    table.insert(lines, string.upper(coin) .. ":")
    table.insert(lines, string.format("   Price: $%s %s", price or "N/A", daily or ""))

    if #prices > 0 then
      table.insert(lines, "   1d:  " .. pct_change(prices, 1))
      table.insert(lines, "   7d:  " .. pct_change(prices, 7))
      table.insert(lines, "   30d: " .. pct_change(prices, 30))
      table.insert(lines, "   1y:  " .. pct_change(prices, 364))
      table.insert(lines, "   " .. sparkline(prices, 30))
    end

    table.insert(lines, "")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M

