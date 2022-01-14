let s:cpo_save = &cpo
set cpo&vim

function! cetli#count_files(pattern)
  let filelist = split(globpath(g:cetli_directory, a:pattern), '\n')
  return len(filelist)
endfunction


let s:letters = "abcdefghijklmnopqrstuvwxyz"

" convert number to str (1 -> a, 27 -> aa)
function! cetli#numtoletter(num)
    if (a:num == 0)
        return ""
    endif
    let numletter = strlen(cetli#letters)
    let charindex = a:num % numletter
    let quotient = a:num / numletter
    if (charindex-1 == -1)
      let charindex = numletter
      let quotient = quotient - 1
    endif

    let result =  strpart(cetli#letters, charindex - 1, 1)
    if (quotient>=1)
      return cetli#numtoletter(float2nr(quotient)) . result
    endif
    return result
endfunction

function! cetli#date_to_name(date)
   return a:date
endfunction


function! cetli#new(...)

    let cetli_date = strftime(g:cetli_date_format)
    let filename = strptime(g:cetli_date_format,cetli_date)
    let filename = strftime(g:cetli_filename_date_format,filename)
    let file_count = cetli#count_files(filename . '*.md')
    let filename = filename . cetli#numtoletter(file_count) . ".md"
    let filename = g:cetli_directory . filename
    if (a:0 > 0)
        let cetli_title = a:1
    else
        let cetli_title = ''
    endif

    let lines = [ '---',
                \ 'title: ' . cetli_title,
                \ 'date: ' . cetli_date,
                \ 'tags:',
                \ '---' ]
    execute "e " filename
    call append(0, lines)

endfunction

function! cetli#parse_to_markdown_link(line)
    let filepath = split(a:line,":")[0]
    let filename = fnamemodify(filepath,":r")
    return "[" . filename . "](" . filepath . ")"
endfunction

function! cetli#parse_multiple_to_markdown_link(key, line)
    return ' - ' . cetli#parse_to_markdown_link(a:line)
endfunction

function! cetli#find_linkmode(lines)
   if (len(a:lines) == 1)
       execute 'normal! a' . s:parse_to_markdown_link(a:lines[0])
   else
       let lines = [""] + map(a:lines,function('cetli#parse_multiple_to_markdown_link'))
       call append('.',lines)
   endif
endfunction

function! cetli#rg_to_qf(line)
    let parts = split(a:line, ':')
    return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
          \ 'text': join(parts[3:], ':')}
endfunction

function! cetli#escape(path)
  return escape(a:path, ' %#\')
endfunction

function! cetli#find_openmode(lines)
    let list = map(a:lines, 'cetli#rg_to_qf(v:val)')
    let first = list[0]
    execute 'e ' . cetli#escape(first.filename)
    execute first.lnum
    execute 'normal!' first.col.'|zz'

    if len(list) > 1
      call setqflist(list)
      copen
      wincmd p
    endif
endfunction

function! cetli#find_sink(lines)
    if (a:lines[0] =~ '^ctrl-\w$')
        call cetli#find_linkmode(a:lines[1:])
    else
        call cetli#find_openmode(a:lines[1:])
    endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
