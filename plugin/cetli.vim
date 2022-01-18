if exists('g:cetlivim_loaded')
    finish
endif

let cetlivim_loaded = 1

command! -bang -nargs=? -complete=dir CetliFind
    \ call fzf#run(fzf#wrap('cetlifind',
    \ { 'dir': g:cetli_directory,
    \ 'source': 'rg "\S" --type markdown --color=always --smart-case --vimgrep',
    \ 'options': '--expect=ctrl-' . g:cetli_fzf_insert_link_ctrl . '
                \ --multi
                \ --ansi --delimiter=":"
                \ --preview="bat --style=plain --color=always {1}"',
    \ 'sink*': function('cetli#find_sink')
    \}, <bang>0))


command! -bang -nargs=? CetliNew call cetli#new(0, <q-args>)
command! -bang -nargs=? FecniNew call cetli#new(1, <q-args>)
