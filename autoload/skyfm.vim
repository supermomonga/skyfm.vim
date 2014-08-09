

" Load vital modules
let s:V = vital#of('skyfm')
let s:CACHE = s:V.import('System.Cache')
let s:JSON = s:V.import('Web.JSON')
let s:HTML = s:V.import('Web.HTML')
let s:HTTP = s:V.import('Web.HTTP')
let s:L = s:V.import('Data.List')
let s:PM = s:V.import('ProcessManager')


" Player
function! skyfm#play(key) " {{{
  if executable('mplayer')
    if s:PM.is_available()
      let channel = skyfm#channel(a:key)
      let playlist = channel['playlist']
      let play_command = substitute(g:skyfm#play_command, '%%URL%%', playlist, '')
      call skyfm#stop()
      call s:PM.touch('skyfm_radio', play_command)
      echo 'Playing ' . channel['name'] . '.'
      let g:skyfm#current_channel = channel['key']
    else
      echo 'Error: vimproc is unavailable.'
    endif
  else
    echo 'Error: Please install mplayer to listen streaming radio.'
  endif
endfunction " }}}
function! skyfm#channel(key) " {{{
  let channels = skyfm#channel_list()
  return get(filter(channels, 'v:val["key"] == "' . a:key . '"'), 0)
endfunction " }}}
function! skyfm#is_playing(...) " {{{
  " Process status
  let status = 'dead'
  try
    let status = s:PM.status('skyfm_radio')
  catch
  endtry

  if status == 'inactive' || status == 'active'
    return 1
  else
    return 0
  endif
endfunction " }}}
function! skyfm#current_channel() " {{{
  if skyfm#is_playing()
    return get(g:, 'skyfm#current_channel', '')
  else
    return ''
  endif
endfunction " }}}
function! skyfm#stop() " {{{
  if skyfm#is_playing()
    return s:PM.kill('skyfm_radio')
  endif
endfunction " }}}
function! skyfm#pause() " {{{
  " TODO
endfunction " }}}
function! skyfm#resume() " {{{
  " TODO
endfunction " }}}
function! skyfm#volume_up(level) " {{{
  " TODO
endfunction " }}}
function! skyfm#volume_down(level) " {{{
  " TODO
endfunction " }}}
function! skyfm#set_volume(level) " {{{
  " TODO
endfunction " }}}

" Channel handling
function! skyfm#update_channels() " {{{
  let data = s:JSON.decode(s:HTTP.request('get', 'http://ephemeron:dayeiph0ne%40pp@api.audioaddict.com/v1/sky/mobile/batch_update?stream_set_key=', { "client": [ "curl", "wget" ] }).content)
  let raw_channels = s:L.uniq_by(s:L.flatten(map(data.channel_filters, 'v:val.channels'), 1), 'v:val.key')
  let channels = map(raw_channels, '{
        \ "id": v:val.id,
        \ "key": v:val.key,
        \ "playlist": "http://listen.sky.fm/webplayer/" . v:val.key . ".pls",
        \ "name": v:val.name,
        \ "description": v:val.description,
        \ }')
  if skyfm#has_cache(g:skyfm#cache_previous_version)
    call skyfm#clear_cache(g:skyfm#cache_previous_version)
  endif
  return skyfm#write_cache(channels)
endfunction " }}}
function! skyfm#channel_list() " {{{
  call skyfm#update_cache_compatibility()
  return skyfm#read_cache()
endfunction " }}}
function! skyfm#channel_key_list() " {{{
  return map(skyfm#channel_list(), 'v:val["key"]')
endfunction " }}}
function! skyfm#channel_key_complete(a,l,p) " {{{
  " TODO: filter
  return skyfm#channel_key_list()
endfunction " }}}

" Cache handling
function! skyfm#cache_filename(...) " {{{
  let cache_version = get(a:, 1, g:skyfm#cache_version)
  return 'channel_list_v' . cache_version . '.json'
endfunction " }}}
function! skyfm#clear_cache(...) " {{{
  " TODO: depends on versions var is yokunai.
  let cache_version = get(a:, 1, g:skyfm#cache_version)
  return s:CACHE.deletefile(g:skyfm#cache_dir, skyfm#cache_filename(cache_version))
endfunction " }}}
function! skyfm#has_cache(...) " {{{
  let cache_version = get(a:, 1, g:skyfm#cache_version)
  return skyfm#read_cache(cache_version) != []
endfunction " }}}
function! skyfm#read_cache(...) " {{{
  let cache_version = get(a:, 1, g:skyfm#cache_version)
  let lines = s:CACHE.readfile(g:skyfm#cache_dir, skyfm#cache_filename(cache_version))
  let data = s:JSON.decode(len(lines) == 0 ? '[]' : lines[0])
  return data
endfunction " }}}
function! skyfm#write_cache(data, ...) " {{{
  let cache_version = get(a:, 1, g:skyfm#cache_version)
  let lines = [s:JSON.encode(a:data)]
  return s:CACHE.writefile(g:skyfm#cache_dir, skyfm#cache_filename(cache_version), lines)
endfunction
" }}}
function! skyfm#update_cache_compatibility() " {{{
  if !skyfm#has_cache()
    call skyfm#update_channels()
  end
endfunction " }}}

" Variables
let g:skyfm#cache_version = '1.0'
let g:skyfm#cache_previous_version = ''
let g:skyfm#cache_dir = get(g:, 'skyfm#cache_dir', expand("~/.cache/skyfm"))
let g:skyfm#play_command = get(g:, 'skyfm#play_command', "mplayer -slave -really-quiet -playlist %%URL%%")
let g:skyfm#playing_label_frames = get(g:, 'skyfm#playing_label_frames', [
      \   '    ',
      \   '||  ',
      \   '||||',
      \   '||| ',
      \   '|   ',
      \   '||| ',
      \   '||||',
      \   '||| ',
      \   '||||',
      \   '|   ',
      \   '    ',
      \   '    ',
      \   '||  ',
      \   '|   ',
      \   '||  ',
      \   '||||',
      \   '||||',
      \   '||| ',
      \   '||||',
      \   '|   ',
      \ ])

