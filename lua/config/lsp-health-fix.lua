local ok, lsp_health = pcall(require, "vim.lsp.health")
if not ok or type(lsp_health.check) ~= "function" then
  return
end

if lsp_health._safe_wrapped then
  return
end

local original_check = lsp_health.check

local function sanitize_concat_list(list)
  if type(list) ~= "table" then
    return list
  end
  for i, item in ipairs(list) do
    if type(item) ~= "string" then
      list[i] = tostring(item)
    end
  end
  return list
end

local function sanitize_enabled_lsp_configs()
  local enabled = vim.lsp._enabled_configs
  local configs = vim.lsp.config
  if type(enabled) ~= "table" or type(configs) ~= "table" then
    return
  end

  for name in pairs(enabled) do
    local cfg = configs[name]
    if type(cfg) == "table" then
      cfg.filetypes = sanitize_concat_list(cfg.filetypes)
      cfg.root_markers = sanitize_concat_list(cfg.root_markers)
    end
  end
end

lsp_health.check = function()
  sanitize_enabled_lsp_configs()
  local success, err = pcall(original_check)
  if success then
    return
  end

  vim.health.start("vim.lsp")
  vim.health.warn("vim.lsp healthcheck 部分检查被跳过（兼容性问题）")
  vim.health.info(tostring(err))
end

lsp_health._safe_wrapped = true
