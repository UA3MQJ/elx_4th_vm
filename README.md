# E4vm

Elixir based Forth VM based on materials from https://habr.com/ru/company/tinkoff/blog/477902/

source https://github.com/Tinkoff/Ogam3/blob/master/Ogam3/Frt/OForth.cs

# Project progress

Implemented words

- [x] Core: `nop exit quit next doList doLit here [ ] , immediate execute : ; branch 0branch dump words '`
- [x] Mem: `! @ variable constant`
- [x] Stack: `drop swap dup over rot nrot`
- [x] Math: `- + * / mod 1+ 1-`
- [x] Boolean: `true false and or xor not invert = <> < > <= >=`
- [x] Comment: `( \\`
- [ ] RW: `. .s cr bl word s" key` TODO: `word s"`


# quick start

Install Erlang and Elixir. You can install it, for example, using [asdf](https://github.com/asdf-vm/asdf) 
and plugins for [Erlang](https://github.com/asdf-vm/asdf-erlang) and [Elixir](https://github.com/asdf-vm/asdf-elixir). Im use 

```
elixir 1.13.3-otp-24
erlang 24.3.1
```

Or install Erlang and Elixir via packet manager.

## get deps

```
mix deps.get
```

## start E4vm in console mode

```
iex -S mix                                                                                                                            ✔ 
Erlang/OTP 24 [erts-12.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Interactive Elixir (1.13.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> E4vm.console
elx_4th_vm console
Type some forth commands. Type 'bye' to exit.

1 2
ok
+
ok
.
3 ok
bye
:ok
```


# Links

https://www.complang.tuwien.ac.at/forth/gforth/Docs-html/Word-Index.html

https://forth-standard.org/standard/core/Comma
