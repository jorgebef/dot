-- require("workspace").setup()
require("lua-dev").setup()
require("config.mason").setup()
require("config.lsp.diagnostics").setup()
require("fidget").setup({ text = { spinner = "dots" } })
require("neoconf").setup()

local function on_attach(client, bufnr)
  require("nvim-navic").attach(client, bufnr)
  require("config.lsp.formatting").setup(client, bufnr)
  require("config.lsp.keys").setup(client, bufnr)
end

---@type lspconfig.options
local servers = {
  ansiblels = {},
  bashls = {},
  clangd = {},
  cssls = {},
  dockerls = {},
  tsserver = {},
  eslint = {},
  html = {},
  jsonls = {
    settings = {
      json = {
        format = {
          enable = true,
        },
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  pyright = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = {
          command = "clippy",
          extraArgs = { "--no-deps" },
        },
      },
    },
  },
  sumneko_lua = {
    single_file_support = true,
    settings = {
      Lua = {
        diagnostics = {
          unusedLocalExclude = { "_*" },
        },
        format = {
          enable = false,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
            continuation_indent_size = "2",
          },
        },
      },
    },
  },
  vimls = {},
  -- tailwindcss = {},
}

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

---@type _.lspconfig.options
local options = {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
}

for server, opts in pairs(servers) do
  opts = vim.tbl_deep_extend("force", {}, options, opts or {})
  if server == "tsserver" then
    require("typescript").setup({ server = opts })
  else
    require("lspconfig")[server].setup(opts)
  end
end

require("config.lsp.null-ls").setup(options)
-- require("config.lsp.install").setup(servers, options)
