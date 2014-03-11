import json, httpclient, strutils, os, algorithm, cgi

const
  packagesUrl = "https://raw.github.com/nimrod-code/packages/master/packages.json"
  apiUrl = "https://api.github.com/repos/$1/$2"

proc fetchGithub(owner: string, name: string): auto =
  let key = "cache/" & owner & "+" & name
  if not existsFile(key):
    let url = apiUrl % [owner, name]
    echo url
    let content = getContent(url)
    writeFile(key, content)
  readFile(key).parseJson

type Package = Tuple[name: string, url: string,
                     description: string, license: string,
                     web: string, stars: int]

let packagesDoc = getContent(packagesUrl).parseJson
var packages = newSeq[Package]()

include "index.tmpl"

for item in packagesDoc:
  let url = item["url"].str
  var count = 0
  if url.startswith("git://github.com/") or url.startswith("https://github.com/"):
    let spl = url.split('/')
    let doc = fetchGithub(spl[3], spl[4])
    count = doc["stargazers_count"].num.int
  let p: Package = (item["name"].str,
                    url,
                    item["description"].str,
                    item["license"].str,
                    if item["web"] != nil: item["web"].str else: "",
                    count)
  packages.add p

packages.sort((proc(a, b: Package): int = cmp(a.stars, b.stars)), Descending)

echo genIndex(packages)
