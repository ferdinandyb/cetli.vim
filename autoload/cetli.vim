let s:cpo_save = &cpo
set cpo&vim

function! cetli#count_files(pattern, dirpath)
  let l:filelist = split(globpath(a:dirpath, a:pattern), '\n')
  return len(l:filelist)
endfunction


let s:letters = "abcdefghijklmnopqrstuvwxyz"

" convert number to str (1 -> a, 27 -> aa)
function! cetli#numtoletter(num)
    if (a:num == 0)
        return ""
    endif
    let l:numletter = strlen(cetli#letters)
    let l:charindex = a:num % l:numletter
    let l:quotient = a:num / l:numletter
    if (charindex-1 == -1)
      let l:charindex = l:numletter
      let l:quotient = l:quotient - 1
    endif

    let l:result =  strpart(cetli#letters, charindex - 1, 1)
    if (l:quotient>=1)
      return cetli#numtoletter(float2nr(l:quotient)) . l:result
    endif
    return result
endfunction

function! cetli#date_to_name(date)
   return a:date
endfunction

function! cetli#parse_titletags(arguments)
    let l:tags = join(filter(split(a:arguments," "),'v:val =~ "^#" '), ", ")
    let l:title = join(filter(split(a:arguments," "),'v:val !~ "^#" '), " ")
    return [l:title, l:tags]
endfunction

function! cetli#new(fecni,...)
    if a:fecni
        let l:dirpath = g:fecni_directory
    else
        let l:dirpath = g:cetli_directory
    endif
    let l:cetli_date = strftime(g:cetli_date_format)
    let l:filename = strptime(g:cetli_date_format,cetli_date)
    let l:filename = strftime(g:cetli_filename_date_format,filename)
    let l:file_count = cetli#count_files(filename . '*.md', l:dirpath)
    let l:filename = l:filename . cetli#numtoletter(l:file_count) . ".md"
    let l:filename = l:dirpath . l:filename
    if (a:0 > 0)
        let l:result = cetli#parse_titletags(a:1)
        let l:cetli_title = l:result[0]
        let l:cetli_tags = " " . l:result[1]
        echom
    else
        let l:cetli_title = ''
        let l:cetli_tags = ''
    endif

    let l:lines = [ '---',
                \ 'title: ' . l:cetli_title,
                \ 'date: ' . l:cetli_date,
                \ 'tags:'. l:cetli_tags]
    if a:fecni
        let l:lines = l:lines + ["type":]
    endif

    let l:lines = l:lines + [ '---' ]
    execute "e " filename
    call append(0, lines)

endfunction

function! cetli#parse_to_markdown_link(line)
    let l:filepath = split(a:line,":")[0]
    let l:filename = fnamemodify(l:filepath,":r")
    return "[" .l:filename . "](" . l:filepath . ")"
endfunction

function! cetli#parse_multiple_to_markdown_link(key, line)
    return ' - ' . cetli#parse_to_markdown_link(a:line)
endfunction

function! cetli#find_linkmode(lines)
   if (len(a:lines) == 1)
       execute 'normal! a' . s:parse_to_markdown_link(a:lines[0])
   else
       let l:lines = [""] + map(a:lines,function('cetli#parse_multiple_to_markdown_link'))
       call append('.',lines)
   endif
endfunction

function! cetli#rg_to_qf(line)
    let l:parts = split(a:line, ':')
    return {'filename': l:parts[0], 'lnum': l:parts[1], 'col': l:parts[2],
          \ 'text': join(l:parts[3:], ':')}
endfunction

function! cetli#escape(path)
  return escape(a:path, ' %#\')
endfunction

function! cetli#find_openmode(lines)
    let l:list = map(a:lines, 'cetli#rg_to_qf(v:val)')
    let l:first = list[0]
    execute 'e ' . cetli#escape(first.filename)
    execute l:first.lnum
    execute 'normal!' l:first.col.'|zz'

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
