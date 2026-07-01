local M = {}

M.leader_groups = {
  primitive = nil,

  git = {
    key = "g",
    name = "git",
  },

  language = {
    key = "l",
    name = "language",
  },

  diagnostics = {
    key = "d",
    name = "diagnostics",
  },
}

local function normalize_options(options)
  options = vim.deepcopy(options or {})

  local mode = options.mode or "n"
  local group = options.group

  options.mode = nil
  options.group = nil

  if options.silent == nil then
    options.silent = true
  end

  return mode, group, options
end

local function leader_prefix(group)
  if group == nil then
    return "<leader>"
  end

  local group_config = M.leader_groups[group]

  if group_config == nil then
    error("Unknown leader group: " .. group)
  end

  return "<leader>" .. group_config.key
end

function M.map(lhs, rhs, options)
  local mode, _, keymap_options = normalize_options(options)

  vim.keymap.set(mode, lhs, rhs, keymap_options)
end

function M.leader(suffix, rhs, options)
  local mode, group, keymap_options = normalize_options(options)
  local lhs = leader_prefix(group) .. suffix

  vim.keymap.set(mode, lhs, rhs, keymap_options)
end

function M.lazy_map(lhs, rhs, options)
  options = vim.deepcopy(options or {})

  local mode = options.mode
  options.mode = nil
  options.group = nil

  return vim.tbl_extend("force", {
    lhs,
    rhs,
    mode = mode,
  }, options)
end

function M.lazy_leader(suffix, rhs, options)
  options = vim.deepcopy(options or {})

  local group = options.group
  local mode = options.mode

  options.group = nil
  options.mode = nil

  local lhs = leader_prefix(group) .. suffix

  return vim.tbl_extend("force", {
    lhs,
    rhs,
    mode = mode,
  }, options)
end

function M.which_key_spec()
  local spec = {}

  for _, group in pairs(M.leader_groups) do
    table.insert(spec, {
      "<leader>" .. group.key,
      group = group.name,
    })
  end

  return spec
end

return M