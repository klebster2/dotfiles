--- Currently, this is the same as the example on the ollama page.
--- We will try something a lil more jazzy.
return {
  "nomnivore/ollama.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- All the user commands added by the plugin
  cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
  keys = {
    -- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
    {
      "<leader>oo",
      ":<c-u>lua require('ollama').prompt()<cr>",
      desc = "ollama prompt",
      mode = { "n", "v" },
    },
    -- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
    {
      "<leader>oG",
      ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
      desc = "ollama Generate Code",
      mode = { "n", "v" },
    },
  },
  ---@type Ollama.Config
  opts = {
    model = "arcee-ai/arcee-scribe",
    url = "http://127.0.0.1:11434",
    serve = {
      on_start = false,
      command = "ollama",
      args = { "serve" },
      stop_command = "pkill",
      stop_args = { "-SIGTERM", "ollama" },
    },
    -- View the actual default prompts in ./lua/ollama/prompts.lua
    prompts = {
      Sample_Prompt = {
        prompt = "Show me the money.",
        input_label = "> ",
        model = "arcee-ai/arcee-scribe",
        action = "display",
      }
    }
  }
}
