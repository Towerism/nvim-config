-- nvim 0.12 dropped single-node handlers (`all = false`, legacy `true`): they now
-- get capture lists, but nvim-treesitter's directives still index match[id] as a
-- single node, so any markdown fenced code block raises
-- "attempt to call method 'range' (a nil value)" (e.g. previewing a README).
return {
  "nvim-treesitter/nvim-treesitter",
  init = function()
    local query = require("vim.treesitter.query")
    local function single_node(add)
      return function(name, handler, opts)
        if opts == true or (type(opts) == "table" and opts.all == false) then
          local inner = handler
          handler = function(match, ...)
            local proxy = setmetatable({}, {
              __index = function(_, id)
                local v = match[id]
                if type(v) == "table" then
                  return v[#v]
                end
                return v
              end,
            })
            return inner(proxy, ...)
          end
        end
        return add(name, handler, opts)
      end
    end
    query.add_directive = single_node(query.add_directive)
    query.add_predicate = single_node(query.add_predicate)

    -- Same change for iter_matches: captures are node lists, but nvim-treesitter's
    -- iter_prepared_matches stores them as `.node`, so locals.get_scopes returns
    -- tables and vim-illuminate errors on "attempt to call method 'parent'".
    local function patch_prepared_matches()
      local ok, ts_query = pcall(require, "nvim-treesitter.query")
      if not ok or ts_query._single_node_patched then
        return
      end
      ts_query._single_node_patched = true
      local orig = ts_query.iter_prepared_matches
      ts_query.iter_prepared_matches = function(q, ...)
        local proxy = setmetatable({
          iter_matches = function(_, ...)
            local iter = q:iter_matches(...)
            return function()
              local pattern, match, metadata = iter()
              if pattern == nil then
                return nil
              end
              local single = {}
              for id, v in pairs(match) do
                single[id] = type(v) == "table" and v[#v] or v
              end
              return pattern, single, metadata
            end
          end,
        }, { __index = q })
        return orig(proxy, ...)
      end
    end
    patch_prepared_matches()
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(ev)
        if ev.data == "nvim-treesitter" then
          patch_prepared_matches()
        end
      end,
    })
  end,
}
