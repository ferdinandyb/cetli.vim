if exists('g:cetlivim_loaded')
    finish
endif

let cetlivim_loaded = 1

function! s:create_new_command(config)
    execute 'command! -bang -nargs=? ' . a:config.prefix . 'New call cetli#new("' . a:config.path .'","' a:config.default_type '", <q-args>)'
endfunction

function! s:create_search_command(config)
    execute 'command! -bang -nargs=? -complete=dir ' a:config.prefix . 'Search call cetli#fzf_search("' . a:config.prefix . '","' . a:config.path . '", <bang>0)'
endfunction

for config in g:cetli_configuration
    if config.naming != "manual"
        call s:create_new_command(config)
    endif
    call s:create_search_command(config)
endfor
