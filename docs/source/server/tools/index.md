# tools

## wikix
a tool to execute commands from wiki page easily.
```{code-block}
wikix() {
    curl -fsSL "{{url}}/remote/misc/wikix.sh" | bash -s -- "$@"
}
```
usage:
```
wikix <wiki_url>?action=raw
```
or if your wiki have been configured to use a shortten patten
```
wikix <url>?raw
```
## mdx
just like the one before, but for markdown
```{code-block}
mdx() {
    curl -fsSL "{{url}}/remote/misc/wikix.sh" | bash -s -- "$@"
}
```
usage:
```
mdx <sphinx_url>/_sources/page.md.txt
```
example
```{code-block}
export md_url={{mdurl}}
mdx $mdurl/server/ubuntu/mediawiki/install.md.txt
```