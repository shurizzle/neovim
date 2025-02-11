local helpers = require('test.functional.helpers')(after_each)
local clear = helpers.clear
local eq = helpers.eq
local exec = helpers.exec
local exec_lua = helpers.exec_lua
local feed = helpers.feed
local meths = helpers.meths
local poke_eventloop = helpers.poke_eventloop

before_each(clear)

describe('state() function', function()
  it('works', function()
    meths.ui_attach(80, 24, {})  -- Allow hit-enter-prompt

    exec_lua([[
      function _G.Get_state_mode()
        _G.res = { vim.fn.state(), vim.api.nvim_get_mode().mode:sub(1, 1) }
      end
      function _G.Run_timer()
        local timer = vim.uv.new_timer()
        timer:start(0, 0, function()
          _G.Get_state_mode()
          timer:close()
        end)
      end
    ]])
    exec([[
      call setline(1, ['one', 'two', 'three'])
      map ;; gg
      set complete=.
      func RunTimer()
        call timer_start(0, {id -> v:lua.Get_state_mode()})
      endfunc
      au Filetype foobar call v:lua.Get_state_mode()
    ]])

    -- Using a ":" command Vim is busy, thus "S" is returned
    feed([[:call v:lua.Get_state_mode()<CR>]])
    eq({ 'S', 'n' }, exec_lua('return _G.res'))

    -- Using a timer callback
    feed([[:call RunTimer()<CR>]])
    poke_eventloop()  -- Process pending input
    poke_eventloop()  -- Process time_event
    eq({ 'c', 'n' }, exec_lua('return _G.res'))

    -- Halfway a mapping
    feed([[:call v:lua.Run_timer()<CR>;]])
    meths.get_mode()  -- Process pending input and luv timer callback
    feed(';')
    eq({ 'mS', 'n' }, exec_lua('return _G.res'))

    -- Insert mode completion
    feed([[:call RunTimer()<CR>Got<C-N>]])
    poke_eventloop()  -- Process pending input
    poke_eventloop()  -- Process time_event
    feed('<Esc>')
    eq({ 'aSc', 'i' }, exec_lua('return _G.res'))

    -- Autocommand executing
    feed([[:set filetype=foobar<CR>]])
    eq({ 'xS', 'n' }, exec_lua('return _G.res'))

    -- messages scrolled
    feed([[:call v:lua.Run_timer() | echo "one\ntwo\nthree"<CR>]])
    meths.get_mode()  -- Process pending input and luv timer callback
    feed('<CR>')
    eq({ 'Ss', 'r' }, exec_lua('return _G.res'))
  end)
end)
