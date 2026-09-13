#!/usr/bin/env bash
# Собирает index.html из page.html.
#
# page.html — единственный источник страницы. Он же публикуется как Artifact на
# claude.ai, где обёртку документа (<!doctype>, <head>, сброс стилей) добавляет
# платформа. Здесь ту же обёртку добавляет этот скрипт, чтобы страницу отдавал
# GitHub Pages. Граница между будущим <head> и <body> размечена в page.html
# комментарием <!--/head-->.
set -euo pipefail
cd "$(dirname "$0")"

marker='<!--/head-->'
grep -qF "$marker" page.html || { echo "page.html: нет маркера $marker" >&2; exit 1; }

head_part=$(sed "/$(printf '%s' "$marker" | sed 's/[][\/.*^$]/\\&/g')/q" page.html | sed '$d')
body_part=$(sed "1,/$(printf '%s' "$marker" | sed 's/[][\/.*^$]/\\&/g')/d" page.html)

{
  cat <<'HTML'
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Сквер на улице Марии Поливановой и тоннель под Киевским направлением МЖД: история защиты сквера, документы и требования жителей.">
<meta property="og:type" content="article">
<meta property="og:title" content="Сквер и тоннель">
<meta property="og:description" content="Сохраним сквер на улице Марии Поливановой. История, документы и позиция жителей Очаково-Матвеевского.">
<meta property="og:locale" content="ru_RU">
<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%8C%B3</text></svg>">
<style>:root{color-scheme:light dark}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>
HTML
  printf '%s\n' "$head_part"
  printf '</head>\n<body>\n'
  printf '%s\n' "$body_part"
  printf '</body>\n</html>\n'
} > index.html

echo "index.html собран: $(wc -c < index.html) байт"
