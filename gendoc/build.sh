#!/bin/sh
git clone git@github.com:gecko0307/dlib.wiki.git
cd dlib.wiki
for i in *.md; do 
    MD="$(python ../markdown2.py --extras cuddled-lists,link-patterns,fenced-code-blocks --link-patterns-file ../linkpatterns --html4tags $i)";
    HTML="<html><head><meta charset=\"utf-8\"/><link rel=\"stylesheet\" href=\"github-markdown.css\"><link rel=\"stylesheet\" href=\"code-default.css\"></head><body class=\"markdown-body\" style=\"margin-left: 20%; margin-right: 20%;\">${MD}</body></html>";
    echo "${HTML}" > ../html/${i%.*}.html;
done;
cd ..
mv html/Home.html html/index.html;
