return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    --   local logo = [[
    --  ██▀███   ▄▄▄      ▓█████▄ ▄▄▄█████▓ ▒█████   ██▓███
    -- ▓██ ▒ ██▒▒████▄    ▒██▀ ██▌▓  ██▒ ▓▒▒██▒  ██▒▓██░  ██▒
    -- ▓██ ░▄█ ▒▒██  ▀█▄  ░██   █▌▒ ▓██░ ▒░▒██░  ██▒▓██░ ██▓▒
    -- ▒██▀▀█▄  ░██▄▄▄▄██ ░▓█▄   ▌░ ▓██▓ ░ ▒██   ██░▒██▄█▓▒ ▒
    -- ░██▓ ▒██▒ ▓█   ▓██▒░▒████▓   ▒██▒ ░ ░ ████▓▒░▒██▒ ░  ░
    -- ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ▒▒▓  ▒   ▒ ░░   ░ ▒░▒░▒░ ▒▓▒░ ░  ░
    -- 		░▒ ░ ▒░  ▒   ▒▒ ░ ░ ▒  ▒     ░      ░ ▒ ▒░ ░▒ ░
    -- 		░░   ░   ░   ▒    ░ ░  ░   ░      ░ ░ ░ ▒  ░░
    --  		░           ░  ░   ░                 ░ ░
    --                   ░
    --
    --
    --   ]]

    --     local logo = [[
    --      ..      ...          ..                     ....              .....                  ....             ....      ..
    --   :~"8888x :"%888x     :**888H: `: .xH""     .xH888888Hx.       .H8888888h.  ~-.      .x~X88888Hx.       +^""888h. ~"888h
    --  8    8888Xf  8888>   X   `8888k XX888     .H8888888888888:     888888888888x  `>    H8X 888888888h.    8X.  ?8888X  8888f
    -- X88x. ?8888k  8888X  '8hx  48888 ?8888     888*"""?""*88888X   X~     `?888888hx~   8888:`*888888888:  '888x  8888X  8888~
    -- '8888L'8888X  '%88X  '8888 '8888 `8888    'f     d8x.   ^%88k  '      x8.^"*88*"    88888:        `%8  '88888 8888X   "88x:
    --  "888X 8888X:xnHH(``  %888>'8888  8888    '>    <88888X   '?8   `-:- X8888x       . `88888          ?>  `8888 8888X  X88x.
    --    ?8~ 8888X X8888      "8 '888"  8888     `:..:`888888>    8>       488888>      `. ?888%           X    `*` 8888X '88888X
    --  -~`   8888> X8888     .-` X*"    8888            `"*88     X      .. `"88*         ~*??.            >   ~`...8888X  "88888
    --  :H8x  8888  X8888       .xhx.    8888       .xHHhx.."      !    x88888nX"      .  .x88888h.        <     x8888888X.   `%8"
    --  8888> 888~  X8888     .H88888h.~`8888.>    X88888888hx. ..!    !"*8888888n..  :  :"""8888888x..  .x     '%"*8888888h.   "
    --  48"` '8*~   `8888!`  .~  `%88!` '888*~    !   "*888888888"    '    "*88888888*   `    `*888888888"      ~    888888888!`
    --   ^-==""      `""           `"     ""             ^"***"`              ^"***"`            ""***""             X888^"""
    --                                                                                                               `88f
    --                                                                                                                88
    --                                                                                                                ""
    -- 		]]
    --
    --  local logo = [[
    --  ,ggggggggggg,              ,ggg,  ,gggggggggggg,    ,ggggggggggggggg   _,gggggg,_      ,ggggggggggg,
    -- dP"""88""""""Y8,           dP""8I dP"""88""""""Y8b, dP""""""88""""""" ,d8P""d8P"Y8b,   dP"""88""""""Y8,
    -- Yb,  88      `8b          dP   88 Yb,  88       `8b,Yb,_    88       ,d8'   Y8   "8b,dPYb,  88      `8b
    --  `"  88      ,8P         dP    88  `"  88        `8b `""    88       d8'    `Ybaaad88P' `"  88      ,8P
    --   		88aaaad8P"         ,8'    88      88         Y8        88       8P       `""""Y8       88aaaad8P"
    --  	88""""Yb,          d88888888      88         d8        88       8b            d8       88"""""
    --  	 888     "8b   __   ,8"     88      88        ,8P        88       Y8,          ,8P       88
    --  	 888      `8i dP"  ,8P      Y8      88       ,8P'  gg,   88       `Y8,        ,8P'       88
    --  	 888       Yb,Yb,_,dP       `8b,    88______,dP'    "Yb,,8P        `Y8b,,__,,d8P'        88
    --  	 888        Y8 "Y8P"         `Y8   888888888P"        "Y8P'          `"Y8888P"'          88
    --
    --   ]]

    local logo = [[
                             ::                             
                             ++                             
                            -%%-                            
                            #%%#                            
                           =%%%%=                           
         -                .#%##%#.                -         
          *=              .%%##%%.              =*          
          -%#-            -%%##%%-            -#%-          
           #%#%-          +%%##%%+          -%#%#           
           :%%#%#:        =%%**%%=        :#%#%%:           
            =%%*%%+:      *%%**%%*      :+%%*%%=            
             =%%*#%%-     *%%**%%*     -%%#*%%=             
              -%%**%%*    -%%**%%-    *%%**%%-              
               :%%#+%%#-  :%%**%%:  -#%%+#%%:               
                .#%%+#%#+  #%**%#  +#%#+%%#.                
    .-+=:.        =%%**%%+ +%**%+ +%%**%%=        .:=+-.    
       =#%%**-:    .#%#*%%=.%##%.=%%*#%#.    :-**%%#=       
        .=%%###%#+-: -#%*#%.+##+.%#*%#- :-+#%###%%=.        
           :*%%####%#+::*###.**.###*::+#%####%%*:           
              :+*%%#####+=+#+--+#+=+#####%%*+:              
                  .-+*#####======#####*+-:                  
                     :-=+++*++++*+++=-:                     
                 :=#%##**+=: :: :=+**##%#=:                 
                             --                             
                             ::                             
]]
    dashboard.section.header.val = vim.split(logo, "\n")
    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file",       LazyVim.pick()),
      dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),
      dashboard.button("r", " " .. " Recent files",    LazyVim.pick("oldfiles")),
      dashboard.button("c", " " .. " Config",          LazyVim.pick.config_files()),
      dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("x", " " .. " Lazy Extras",     "<cmd> LazyExtras <cr>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 8
    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
