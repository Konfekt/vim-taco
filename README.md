# VimTaco

A tiny tab-completion plugin for Vim that completes

* file paths ([Ctrl-X_Ctrl-F](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-F)),
* code words ([Ctrl-X_Ctrl-O](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-X_CTRL-O)), and
* everything else by other words in open buffers, included files, dictionaries, thesauri or tags (= variable labels)
  ([Ctrl-N](http://vimhelp.appspot.com/insert.txt.html#i_CTRL-N))
* and by all other methods of Vim through customization.

To get a feel for it, start typing

* a file path and hit `<tab>` (and `/` or `\` after completing a directory name)
* a code word and hit `<tab>`, or
* any other word and `<tab>`

## Configuration

There are the variables :
```vim
'g:vim_completions'            = global dictionary of completion methods
'b:taco_completions'           = buffer-local variant of g:vim_completions
```
------------------------------------------------------------------------------
                                                         *'g:taco_completions'*

Configures, by 'rank', the order and, by 'pattern', context in which one of the following completion methods is used after the |<tab>| key is hit:

1. File Path   completion                     (|i_Ctrl-X_Ctrl-F|)
2. Omni        completion                     (|i_Ctrl-X_Ctrl-O|)
3. User        completion                     (|i_Ctrl-X_Ctrl-O|)
4. Line        completion                     (|i_Ctrl-X_Ctrl-O|)
5. Vim         completion                     (|i_Ctrl-X_Ctrl-O|)
6. Spell Check completion                     (|i_Ctrl-X_Ctrl-O|)
7. Generic     completion                     (|i_Ctrl-N|)

and which defaults to

```vim
  g:taco_completions.file.rank     = 10
  g:taco_completions.omni.rank     = 20
  g:taco_completions.user.rank     = 30
  g:taco_completions.line.rank     = 40
  g:taco_completions.spell.rank    = 50
  g:taco_completions.vim.rank      = 60
  g:taco_completions.gen.rank      = 99

  g:taco_completions.file.pattern  = '\v'.(has('win32') ? '\f\\' : '\/').'\f*$'
  g:taco_completions.omni.pattern  = '\m\<\v\k+(\.|->|::)\k*$'
  g:taco_completions.user.pattern  = 0
  g:taco_completions.line.pattern  = 0
  g:taco_completions.spell.pattern = 0
  g:taco_completions.vim.pattern   = 0
  g:taco_completions.gen.pattern   = '\m\<\v\k+$'
```


When none of the above completions above get any results,
you can press Tab again to force Vim's generic keyword completion.

                                                         *'b:taco_completions'*

Configures buffer-locally the order and context in which one of the above
completion methods is used after the |<tab>| key is hit. It is best set by a
FileType autocmd such as:

```vim
    autocmd FileType vim let b:taco_completions.vim.rank=11 |
                       \ let b:taco_completions.vim.pattern = '\v\k+$'
```



## Thanks
* to [ajh17](https://github.com/ajh17) whose plug-in [VimCompletesMe](https://github.com/ajh17/VimCompletesMe)
  inspired vim-taco.

