return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local cmp_nvim_lsp = require "cmp_nvim_lsp"
      local capabilities = cmp_nvim_lsp.default_capabilities()

      vim.lsp.start {
        name = "pyright",
        cmd = { "pyright-langserver", "--stdio" },
        capabilities = capabilities,
        filetypes = { "python" },
        root_dir = vim.fs.dirname(vim.fs.find({ "pyproject.toml", ".git" }, { upward = true })[1] or vim.loop.cwd()),
      }

      vim.lsp.start {
        name = "tsserver",
        cmd = { "typescript-language-server", "--stdio" },
        capabilities = capabilities,
        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        root_dir = vim.fs.dirname(vim.fs.find({ "package.json", ".git" }, { upward = true })[1] or vim.loop.cwd()),
      }
    end,
  },

  {
    "github/copilot.vim",
    lazy = false,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip").config.set_config {
            history = true,
            updateevents = "TextChanged,TextChangedI",
          }
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip",
      "https://codeberg.org/FelipeLema/cmp-async-path.git",
      {
        "windwp/nvim-autopairs",
        config = function()
          local npairs = require "nvim-autopairs"
          npairs.setup {
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt", "vim" },
          }

          local cmp_autopairs = require "nvim-autopairs.completion.cmp"
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },
    },
    config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources {
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
          { name = "async_path" },
        },
        experimental = { ghost_text = true },
      }
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "github/copilot.vim" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

{
  "ellisonleao/carbon-now.nvim",
  lazy = true,
  cmd = "CarbonNow",
  opts = {
    options = {
      theme = "solarized",
      font_family = "Monoid",
    },
  },
},



}
